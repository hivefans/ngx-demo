--[[
    Create by lixy at 2019-05-07 10:43
    @brief: 系统全局管理对象
]]

local db_mysql = require("common.db.db_mysql")
local time_manager = require("common.time_manager")

local sys = sys

local  _M =  {}

function _M.get_sys_status()
    return sys.basedef.SYSTEN_STATUS.OK
end

--[[
    Create by lixy at 2019-05-08 18:01
    @brief:  连接数据库
    @params: 
        app_id: 代理ID
    @return: 
]]
function _M.conn_db(app_id) 
    -- 读取代理数据库配置信息(从主服务REDIS中读取)

    local agent = {}
    local sys_conf = {}

    local conf = {
        host = agent.db_host,
        port = agent.db_port,
        database = sys_conf.db_name,
        user = sys_conf.db_user,
        password = sys_conf.db_passwd,
        max_packet_size = sys_conf.db_max_size or 1024 * 1024
    }
end

--[[
    Create by lixy at 2019-05-08 18:01
    @brief:  连接REDIS
    @params: 
        app_id: 代理ID
    @return: 
]]
function _M.conn_redis(app_id) 
end


--[[
    Create by lixy at 2019-05-07 10:43
    @brief:  写操作日志
    @params: 
    @return: 
]]
function _M.log(eid, app_id, user_id, platform_id, type, state, params, remarks)
    -- local eid = time_manager.uuid()
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, err
    end
    local p = {
        eid = eid,
        app_id = app_id, 
        user_id = user_id,
        platform_id = platform_id, 
        type = type,
        state = state,
        params = params,
        remarks = remarks
    }
    local sql = db.fmt_insert("t_event_log", p)
    local res, err = db:query(sql)
    if not res then
        db:close()
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, err
    end
    db:close(true)
    return true
end


return _M