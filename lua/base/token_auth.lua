--[[
    Created by lixy at 2019-03-01 14:27
    @brief:	 
]]

local sys_conf = require("conf.sys_conf")
local db_redis = require("db.db_redis")


local token_key = "TOKEN_LOGIN"

local _M = {}

_M.login = function(login_id, token, data, expire_time)
    local redis, err = db_redis:new()
    if not redis then
        return nil, err
    end
    local key = token_key .. ":".. login_id
    local res, err = redis:exec("hmset", key, "token", token or "", "data", data or "")
    if not res then
        return nil, err
    end
    local res, err = redis:exec("expire", key, expire_time or 1800)
    if not res then
        return nil, err
    end
    return true
end

_M.logout = function(login_id) 
    local redis, err = db_redis:new()
    if not redis then
        return nil, err
    end
    local key = token_key .. ":".. login_id
    local res, err = redis:exec("del", key)
    if not res and err then
        return nil, err
    end
    return true
end

_M.get_login_cache = function(login_id)
    local redis, err = db_redis:new()
    if not redis then
        return nil, err
    end
    local key = token_key .. ":".. login_id
    local res, err = redis:exec("hgetall", key)
    if not res then
        return nil, err
    end
    local result = {}
    for i=1, #res, 2 do
        result[res[i]] = res[i+1]
    end
    return result
end

_M.update_expire = function (login_id, expire_time)
    local redis, err = db_redis:new()
    if not redis then
        return nil, err
    end
    local key = token_key .. ":".. login_id
    local res, err = redis:exec("expire", key, expire_time or 600)
    if not res then
        return nil, err
    end
    return true
end

return _M