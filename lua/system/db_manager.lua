--[[
    Create by lixy at 2019-05-27 14:12
    @brief: 数据库管理器
]]

local cache_manager = require("system.cache_manager")

local _M = {}



function _M.get_db_conf(biz_id)
    local sys_conf = cache_manager.get_sys_setting()
    if not sys_conf then
        return nil
    end

    local biz = cache_manager.get_biz(biz_id)
    if not biz then
        return nil
    end

    local db_conf = {
        host = biz.db_host,
        port = biz.db_port,
        database = biz.db_name,
        user = sys_conf.db_user,
        password = sys_conf.db_passwd,
        max_packet_size = biz.db_max_size or 1024 * 1024
    }
    ngx.log(ngx.ERR, "MYSQL: ", sys.utils.json_encode(db_conf))

    local redis_conf = {
        host = biz.redis_host,
        port = biz.redis_port,
        password = sys_conf.redis_passwd,
        max_packet_size = 1024 * 1024
    }
    ngx.log(ngx.ERR, "REDIS: ", sys.utils.json_encode(redis_conf))
end


return _M