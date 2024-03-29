--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/thread/mutex_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 互斥帮助对象,用于当前系统或者多线程之间的锁,
--	由于系统大多数时间应用在分布式环境中,故系统同时支持分布式环境锁,分布式环境锁使用redis唯一状态管理 online_union_help.lua
--	注意事项: 项目中每个协程都需要使用自己的mutex对象
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]
--[[
 local resty_lock = require "resty.lock"
                for i = 1, 2 do
                    local lock, err = resty_lock:new("my_locks")
                    if not lock then
                        ngx.say("failed to create lock: ", err)
                    end

                    local elapsed, err = lock:lock("my_key")
                    ngx.say("lock: ", elapsed, ", ", err)

                    local ok, err = lock:unlock()
                    if not ok then
                        ngx.say("failed to unlock: ", err)
                    end
                    ngx.say("unlock: ", ok)
                end

]]
local resty_lock = require "resty.lock" 

local _M = {}
_M.__index = _M

--[[
-- new  创建互斥锁对象,
-- example

-- @param _self
-- @param _mutex_key 对象锁的唯一 key 锁需要注意使用地方
-- @param _opt ngx lock对象的协程
-- @return nil 表示失败 true 表示成功
--]]
_M.new = function( _self, _mutex_key, _opt )
	local impl = setmetatable({}, _self)
	impl.mutex_key = _mutex_key

	if not res then return nil end
	return impl
end


--[[
	默认锁的调用方式,对应的需要调用释放锁,由于ngx是一个单线程,单个业务中不需要用锁,
--	不同协程序不能使用同一个lock对象,否则直接返回被锁,无法进行block, 故两个协程只能通过new的方式创建lock对象
]]
_M.lock = function( _self )
	local lock, err = resty_lock:new("ngx_locks")
	if not lock then
		ngx.log(ngx.ERR,"failed to create lock: ", err)
		-- 消息未执行 如何处理???
		return nil
	end
	local elapsed, err = lock:lock(_self.mutex_key)
 	if not elapsed then 
 		ngx.log(ngx.ERR,"ngx lock fail, err is ",err)
 		return nil
 	end
	_self.lock = lock
	return true
end

--[[
	ngx unlock
]]
_M.unlock = function( _self )
	if not _self.lock then return nil end
 	local elapsed, err = _self.lock:unlock()

 	if not elapsed then
 		if err ~= "unlocked" then
 			-- 解锁失败,设置超时强制释放 如果强制释放失败
 			local res,err = _self.lock:expire(3)
 			if not res then
 				ngx.log(ngx.ERR,"ngx expire fail, err is ",err)
 			end
 		else
 			ngx.log(ngx.ERR,"ngx unlock fail, err is ",err)
 		end
 		return nil
 	end
	return true 
end
 




return _M
 
