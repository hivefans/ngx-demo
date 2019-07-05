
--[[
    Create by lixy at 2019-06-21 14:02
    @brief:	游戏平台数据管理
]]

local sys = require("base.sys")
local db_mysql = require('base.db.db_mysql')

local _M = {}

--[[
    Create by lixy at 2019-06-21 14:02
    @brief:	 添加游戏平台
    @params: 
    @return:
]]
function _M.add_platform(gpid, gpname, srv_type, srv_addr)
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        return nil, err
    end
    local sql = string.format("select * from t_gplatform where gpid='%s'", gpid)
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, sql=", sql, ", error=", err)
        return nil, err
    end
    if res[1] then
        return nil, string.format("游戏平台[%s]已经存在", gpid)
    end

    local p = {
        gpid = gpid, 
        gpname = gpname, 
        status = 1, 
        server_type = srv_type, 
        server_host = srv_addr
    }
    sql = db_mysql.fmt_insert("t_gplatform", p)
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, sql=", sql, ", error=", err)
        return nil, err
    end
    return sys.err_code.SUCCESS
end

--[[
    Create by lixy at 2019-06-21 14:03
    @brief:	 修改游戏平台
    @params:
    @return:
]]
function _M.modify_platform()
end


--[[
    Create by lixy at 2019-06-21 14:03
    @brief:	 删除游戏平台
    @params:
    @return:
]]
function _M.delete_platform()
end


--[[
    Create by lixy at 2019-06-21 15:46
    @brief:	
    @params:
    @return:
]]
function _M.list_platform()
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        return nil, err
    end
    local sql = "select * from t_gplatform"
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, sql=", sql, ", error=", err)
        return nil, err
    end
    return res
end



return _M

