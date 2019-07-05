--[[
    Create by lixy at 2019-06-25 16:16
    @brief:	后台任务定义管理
]]

local sys = require("base.sys")
local db_mysql = require('base.db.db_mysql')


local _M = {}

--[[
    Create by lixy at 2019-06-25 16:17
    @brief:	
    @params:
    @return:
]]
function _M.add_task(tid, ttype, bizid, gpid, setting)
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, err
    end

    local sql = string.format("select * from t_task where tid='%s';", tid)
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, err
    end
    if res[1] then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, string.format("任务[%s]已经存在", tid)
    end

    local p = {
        tid = tid,
        ttype = ttype,
        bizid_fk = bizid,
        gpid_fk = gpid,
        status = 1,
        setting = setting
    }
    local sql = db_mysql.fmt_insert("t_task", p)
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, err
    end
    return sys.err_code.SUCCESS
end


--[[
    Create by lixy at 2019-06-25 16:17
    @brief:	
    @params:
    @return:
]]
function _M.modify_task(tid, gpid, bizid, interval, setting, status)
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, err
    end
    local p = {
        gpid_fk = gpid, 
        bizid_fk = bizid,
        interval = interval,
        setting = setting,
        status = status,
    }
    local sql = db_mysql.fmt_update('t_task', p, string.format("tid='%s'", tid))
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, err
    end
    if res.affected_rows == 0 then
        return nil, "无数据更新"
    end
    return sys.err_code.SUCCESS
end

--[[
    Create by lixy at 2019-06-25 16:17
    @brief:	
    @params:
    @return:
]]
function _M.delete_task()
end


--[[
    Create by lixy at 2019-06-25 16:18
    @brief:	
    @params:
    @return:
]]
function _M.list_task()
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, err
    end

    local sql = "select * from t_task"
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, err
    end
    return res
end



return _M