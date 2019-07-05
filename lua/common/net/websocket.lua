-- simple chat with redis

local resty_wsserver = require "resty.websocket.server"
local redis = require "resty.redis"
local cjson = require("cjson")



local _M = {
    MSG_ID_EVENT = "0",
    name = nil,
    channel = nil,
    wb = nil,
    thread_id = nil,
    handler = nil,
    exit_code = 0,
    exit_reason = ""
}

_M.EVENT = {
    OPEN = "OPEN",
    MESSAGE = "MESSAGE",
    CLOSE = "CLOSE",
    ERROR = "ERROR",
}

--[[
    @brief: 客户端连接时创建新的websocket客户端处理对象, 初始化websocket信息
    @param: name:       名称标识
            channel:    订阅频道
            handler:    事件回调处理对象, 实现如下函数接口：
                        on_event(type, ws, data)  
                            参数 [type]:    
                                    "WS_EVENT_OPEN": 连接成功
                                    "WS_EVENT_CLOSE": 连接关闭
                                    "WS_EVENT_ERROE": 异常错误
                                    "WS_EVENT_MESSAGE": 接收到websocket消息
                            参数 [ws]: websocket对象
]]
function _M:new(name, channel, handler)
    local ws, err = resty_wsserver:new {timeout = 10000, max_payload_len = 65535}
    if not ws then
        return nil, "Websocket server new failed: " .. err
    end
    local o = {}
    setmetatable(o, {__index = self})
    o.ws = ws
    o.channel = channel
    o.name = name
    o.handler = handler
    if handler and handler.on_event then
        handler.on_event(_M.EVENT.OPEN, o)
    end
    return o
end


function _M.on_publish(self, red)
    -- loop : read from redis
    while true do
        local res, err = red:read_reply()
        if res then
            local item = res[3]
            local bytes, err = self.ws:send_text(item)
            if not bytes then
                -- better error handling
                ngx.log(ngx.ERR, "===>> Failed to send text: " .. err)
                return ngx.exit(444)
            end
        end
    end
end

function _M:run(t_timeout)
    self.timestamp = os.time()
    -- init redis
    local red = redis:new()
    red:set_timeout(t_timeout or 2000)
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.log(ngx.ERR, "===>> Failed to connect redis: " .. err)
        return nil, "Failed to connect redis: " .. err
    end

    -- 订阅 redis channel
    local res, err = red:subscribe(self.channel)
    if not res then
        ngx.log(ngx.ERR, "===>> Failed to subscribe redis: channel=" .. self.channel .. ", " .. err)
        return nil, "Failed to subscribe redis: channel=" .. self.channel .. ", " .. err
    end

    -- 开启线程处理订阅频道的消息
    self.thread_id = ngx.thread.spawn(self.on_publish, self, red)

    -- 循环处理接收消息
    while true do
        -- 没有设置回调时结束循环
        if not self.handler then
            ngx.log(ngx.ERR, "===>> No message handler.")
            break
        end

        -- 获取数据
        local data, type, err = self.ws:recv_frame()

        -- 如果连接损坏 退出
        if self.ws.fatal then
            ngx.log(ngx.ERR, "===>> Failed to receive frame: " .. err)
            if self.handler.on_event then
                self.handler.on_event(_M.EVENT.ERROR, self, err)
            end
            break
        end

        if not data then
            -- ngx.log(ngx.ERR, "===>> No data, send ping.")
            local bytes, err = self.ws:send_ping()
            if not bytes then
                ngx.log(ngx.ERR, "===>> Send ping failed.")
                if self.handler.on_event then
                    self.handler.on_event(_M.EVENT.ERROR, self, err)
                end
                break
            end
        elseif type == "close" then
            if self.handler.on_event then
                self.handler.on_event(_M.EVENT.CLOSE, self)
            end
            break
        elseif type == "ping" then
            local bytes, err = self.ws:send_pong()
            if not bytes then
                ngx.log(ngx.ERR, "===>> Failed to send ping: " .. err)
                if self.handler.on_event then
                    self.handler.on_event(_M.EVENT.ERROR, self)
                end
                break
            end
        elseif type == "pong" then
        elseif type == "text" then
            ngx.log(ngx.ERR, "===>> Websocket recv message: ", data)
            -- local msg = cjson.decode(data)
            -- if self.MSG_ID_EVENT == msg.id then
            --     self.ws.send_close(self.exit_code, self.exit_reason)
            --     break
            -- end
            if self.handler and self.handler.on_event then
                -- self.handler.on_event("WS_EVENT_MESSAGE", self, data)
                self.handler.on_event(_M.EVENT.MESSAGE, self, data)
            end
        end
    end -- end of while

    ngx.log(ngx.ERR, "===>> [" .. self.name .. "] Websocket loop end.")
    if self.thread_id then
        ngx.thread.wait(self.thread_id)
    end
    return true
end

function _M:publish(type, data)
    --send to redis
    local red = redis:new()
    red:set_timeout(1000) -- 1 sec
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.log(ngx.ERR, "===>> Failed to connect redis: " .. err)
        return nil, "Failed to connect redis: " .. err
    end
    local res, err = red:publish(self.channel, cjson.encode({type = type, data = data or {}}))
    if not res then
        ngx.log(ngx.ERR, "===>> Failed to publish redis: " .. err)
        return nil, "Failed to publish redis: " .. err
    end
    return res
end

function _M:clear()
end

--[[
    主动关闭连接
]]
function _M:close(code, reason)
    self.exit_code = code
    self.exit_reason = reason
    self:publish(self.MSG_ID_EVENT)
end

--[[
    发送文本消息
]]
function _M:send(text)
    if not self.ws then
        return false, "Websocket is not connected."
    end
    self.ws:send_text(text)
    return true
end

-- --[[
--     @brief: 发送协议消息
--     @param: [id] 消息id
--     @param: [data] 消息内容
--     @return:    $1: true: 发送成功, false: 发送失败
--                 $2: 错误信息, 发送成功时为nil
-- ]]
-- function _M:send(id, data)
--     local msg = {id = id, data=data}
--     return self:send_text(cjson.encode(msg))
-- end

return _M
