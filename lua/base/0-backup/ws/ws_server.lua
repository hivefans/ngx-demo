--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/uuid_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: --  websocket 服务器端封装,主要用于websocket服务器端的数据结构业务处理


--------------------------------------------------------华丽的分割线------------------------------------------------------------
--	使用方式
	local webSocket = require "common.ws_server"

	local wsImpl = webSocket:newServer(pushFCB, msgFCB)

	local res = wsImpl.loop()

	function msgFCB(msgType,msgData)

	end


-- push_loop 系统的循环推送函数,主要是用redis订阅系统完成事件的发送与管理
-- 未来可自定义合适的loop系统, redis的系统性能压力

local push_loop = function ( _self )
	-- body
	if not _self.subscribe_list then
		return nil
	end
	-- --create redis
	local red = redis:new()
	red:set_timeout(5000) -- 1 sec
	local ok, err = red:connect("127.0.0.1", 6379)
	if not ok then
		ngx.log(ngx.ERR, "failed to connect redis: ", err)
		_self:exit(404)
		return
	end

	--sub
	-- local res, err = red:subscribe(subscribe_list[1],subscribe_list[2])
	for i=1,#_self.subscribe_list do
		local res, err = red:subscribe(_self.subscribe_list[i])
		if not res then
			ngx.log(ngx.ERR, "failed to sub redis: ", err)
			_self:exit(444)
			return
		end
	end


	-- loop : read from redis 发起订阅
	while _self.closeFlag == false do
		local res, err = red:read_reply() -- ["message","gameroom1","3333"] ["subscribe","111",2]
		if res then
			local typ = res[1]
			local item = res[3]
			ngx.log(ngx.ERR,"------",cjson.encode(res))
			if typ == "message" then
				local bytes, err = _self:sendMsg(item)
				if not bytes then
					-- better error handling
					ngx.log(ngx.ERR, "failed to send text: ", err)
					-- return ws:exit(444)
				end
			end

		end
	end


end

-- 用户自定义响应消息函数 案例
    -- FATAL_EVENT = 1,    -- ws 异常失败的事件类型
    -- NODATE_EVENT = 2,   -- ws 没有数据错误事件通知
    -- PING_ERR_EVENT = 3, -- ws ping事件
    -- CLOSE_EVENT = 4,    -- ws 客户端连接关闭事件
    -- PONG_EVENT = 5,     -- ws pong事件
    -- TEXT_EVENT = 6,     -- 通信到来事件到来
    -- SEND_ERR_EVENT = 7, -- 发送错误事件
local msgDispath = function( event, data )
    -- body
    if event == WS_EVENT.FATAL_EVENT
        or event == WS_EVENT.NODATE_EVENT
        or event == WS_EVENT.PING_ERR_EVENT
        or event == WS_EVENT.CLOSE_EVENT
        or event == WS_EVENT.SEND_ERR_EVENT
    then
    -- ws离线消息,将用户当前状态设置为false
        player:player_break_us2ms()
    elseif event == WS_EVENT.TEXT_EVENT then
        local process =  cjson.decode(data)
        process.user_code = player.user_code
        player:dispatch_process(process)

    else

    end

end

--]]

local cjson = require "cjson"
local event = require "resty.base.event"
local server = require "resty.websocket.server"

local WS_EVENT = event.WS_EVENT

local _M  = {
	wb = nil,	-- wb 对象
	co = nil,	-- push 系统的线程对象
	closeFlag = false, -- 退出标志,设置为 true,各个循环函数将退出
	callback = {
		dispatch = nil,
		push_loop = nil,
	},
	-- 用户消息列表, 该主要用于消息管理, 未来实现类似redis系统,支持离线推送的能力
	-- 0.01版本使用redis模式代替
	subscribe_list = nil,
}

_M.__index = _M

function _M:new(_opts)
	local ws = setmetatable({},self) -- 创建一个新类 继承于原 _M
	local wb, err = server:new{
		timeout = 5000,
		max_payload_len = _opts.max_payload_len or 65535
	}
	if not wb then
		ngx.log(ngx.ERR,"websocket new error, err is ",err)
		return nil
	end
	ws.wb = wb
	return ws
end

-- 初始化socket 回调对象
function _M:set_cb(_cbobj)
	if not _cbobj or not _cbobj.push_loop or not _cbobj.dispatch then
		return false
	end
	self.cbobj=_cbobj
	return true
end

--[[
-- _M:exit() 退出函数,将系统标志设置为true  ,循环函数进退出阻塞
-- 同时清理和释放资源
-- @param  httpErr http 错误信息,如444错误 ,403错误
--]]
function _M:exit( httpErr, code, reason )
	-- body
	if httpErr == 404 then return end
	self.closeFlag = true  
	self.exit_code = code 
	self.exit_reason = reason
	ngx.log(ngx.ERR,'------ws socket:exit')
end


--[[
-- _M:clear() 退之后进行资源释放，释放内存
-- @param  
--]]
function _M:clear(code, reason)  
	self.exit_code = code or 0
	self.exit_reason = reason or "Websocket end"
	local code = self.exit_code
	local msg = self.exit_reason

	if self.wb then
		if not self.wb.fatal then
			self.wb:send_close(code, msg)
		end
	end

	if self.co then
		ngx.thread.wait(self.co)
	end
	ngx.log(ngx.ERR,'------ws socket:clear')
end

--[[
-- _M:spawn( _callback ) 设置轻线程回调
-- @param  _callback 回调函数对象,该对象需要支持回调函数
--]]
function  _M:spawn( )
	-- body
	local push_loop = self.cbobj.push_loop
	if push_loop then
		self.co = ngx.thread.spawn(push_loop, self.opts)
	end  
end

--[[
-- _M:sendMsg( _msg ) 设置轻线程回调
-- @param  _callback 回调函数对象,该对象需要支持回调函数
--]]
function  _M:sendMsg( _msg, _msgType )
	-- body
	if not _msg then 
		return
	end
	if not _msgType then 	-- 文本
		-- ngx.log(ngx.ERR,"sendmsg ",'string')
		return self.wb:send_text(_msg)
	else
		-- ngx.log(ngx.ERR,"sendmsg ",'binary')
		return self.wb:send_binary(_msg)
	end
end


--[[
-- _M:loop() 阻塞状态的接收函数
 
--]]
function  _M:loop()
-- 开启轻线程,进行数据订阅的数据管理
	self:spawn();  
-- 回调消息函数,各个回调函数,自行进行数据组装和管理
	local dispatch = self.cbobj.dispatch
	local cbobj = self.cbobj
	if not dispatch then
		ngx.log(ngx.ERR,"websocket dipatch is nill!!!!!")
		return
 	end

	while not self.closeFlag do
	    -- 获取数据
	    local data, typ, err = self.wb:recv_frame()

	    -- 如果连接损坏 退出
	    if self.wb.fatal then
	        -- ngx.log(ngx.ERR, "failed to receive frame: ", err)
	        -- 通知业务引擎进行状态提醒和修改
			dispatch(WS_EVENT.FATAL_EVENT)

	        return ngx.exit(444)
	    end

	    if not data then
	        local bytes, err = self.wb:send_ping()
	        if not bytes then
	        	-- ngx.log(ngx.ERR, "failed to send ping: ", err)
	          
	            -- 通知业务引擎进行状态提醒和修改
				cbobj:dispatch(WS_EVENT.NODATE_EVENT)
	          
	          	return ngx.exit(444)
	        end
	        -- ngx.log(ngx.ERR, "send ping: ", data)
	    elseif typ == "close" then
	        -- 通知业务引擎进行状态提醒和修改
	        -- msgFCB() 
			dispatch(WS_EVENT.CLOSE_EVENT)
	        self.closeFlag = true;
	        break
	    elseif typ == "ping" then
	        local bytes, err = self.wb:send_pong()
	        if not bytes then
	            -- ngx.log(ngx.ERR, "failed to send pong: ", err)

	            -- 通知业务引擎进行状态提醒和修改
				dispatch(WS_EVENT.PING_ERR_EVENT)
				return ngx.exit(444)
	        end
	    elseif typ == "pong" then
	        -- ngx.log(ngx.ERR, "client ponged")
	        -- self.msgFCB(WS_EVENT.PONG_EVENT)   
	    elseif typ == "text" then 
			-- 通知业务引擎进行状态提醒和修改  返回值需要进行一次json 或者 直接返回string
			dispatch(WS_EVENT.TEXT_EVENT,data)
			-- self.wb:send_text("11111")
			
	    elseif typ == "binary" then
			dispatch(WS_EVENT.BINARY_EVENT,data)
	    end
	end
end

return _M
 