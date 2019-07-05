--[[
    Created by lixy at 2019-03-01 13:09
    @brief:	 redis 操作对象
]]

local resty_redis = require("resty.redis")

local _M = {
    m_red = nil
}

--[[
    Created by lixy at 2019-03-01 13:14
    @brief:	 
    @param:	 
        conf:   [object] redis服务器信息： 
                {
                    host = "127.0.0.1",
                    port = "6379",
                    password = "***",
                }
    @return:	
]]
function _M:new(conf, t_timeout)
    local red, err = resty_redis:new()
    if not red then
        return nil, "REDIS 初始化错误: " .. (err or 'nil')
    end
    red:set_timeout(t_timeout or 1000)
    local ok, err = red:connect(conf.host, conf.port)
    if not ok then
        return nil, "REDIS 连接错误: " .. err
    end
    if conf.password then
        local ok, err = red:auth(conf.password)
        if not ok then
            return nil, "REDIS 认证错误：" .. err
        end 
    end
    local o = setmetatable({}, { __index = _M })
    o.m_red = red
    return o
end

--[[
    Created by lixy at 2019-03-01 13:21
    @brief:	 
    @param:	 
    @return:	
]]
function _M:exec(cmd, ...)
    if not self.m_red then
        return nil, "REDIS 没有初始化"
    end
    local cmd_handler = self.m_red[cmd]
    if not cmd_handler then
        return nil, string.format("REDIS 不支持指令[%s]", cmd)
    end
    local res, err = cmd_handler(self.m_red, ...)
    if not res and err then
        local cjson = require('cjson')
        ngx.log(ngx.ERR, "REDIS错误, error=", err, ",cmd=", cmd, ", params=", cjson.encode({...}))
    end
    if type(res) == "userdata" then
        return nil
    end
    return res, err 
end



return _M 