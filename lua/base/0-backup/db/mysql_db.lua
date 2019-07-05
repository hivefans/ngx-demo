--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/db/db_json_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 主要用于对mysql的简单封装

    update delete insert 返回的数据结构如下
    {"insert_id":55,"affected_rows":1,"server_status":2,"warning_count":0}
    select 返回的结果为数组对象{} or {{name="zhang",password="123456"},{name="zhang",password="123456"}}
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]


local cjson = require("cjson")
local mysql         = require "resty.mysql"
local db_conf       = require "server.conf.mysql_conf"

local g_mysql_config = db_conf.mysql_master;
local ngx_quote_sql_str = ngx.quote_sql_str

local  MYSQL_CONNECT_TIME_OUT = 5000    -- 超时时间
local  MYSQL_CONNECT_POOL_SIZE = 5000    -- 增强缓冲池的能力 可以将该值设置为5000

local _M = {
    start_index=0,
    offset=20
}

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function cud_query: 增删改操作二次封装 如果操作结果失败或者影响行数为0 提示用户返回错误
                        插入请注意重复键的业务场景
-- @param _sql: 增删改的sql语句
-- @return res: 修改成功的res; 返回 nil 表示失败
-- @return err: 操作成功但是影响为0 表示未修改,对于需要判定必须修改成功的的场景需要执行判断effected_rows 不为0
-- @usages:
	local ZS_ERROR_CODE = ZS_ERROR_CODE
	local mysql_db = require "resty.utils.db.mysql_db"

    local mysql_cli = mysql_db:new();
    if not mysql_cli then
        return nil, "数据库连接异常", ZS_ERROR_CODE.MYSQL_NEW_ERR;
    end
    local up_sql = "update tests set id=5 where id = 10;"
    local res,err,errcode,sqlstate = mysql_cli:cud_query(up_sql)
    if not res then
        if err = -1 then
            ngx.log(ngx.ERR,"修改失败")
        else
            ngx.log(ngx.ERR,"bad result: ", err,": ",errcode, ": ", sqlstate,".");
        end
    end

--
]]
local function cud_query(_self,_sql)
    local res, err, errcode, sqlstate = _self:query(_sql)
    if not res then
        return res, err, errcode, sqlstate
    end
    if res["affected_rows"] == 0 then
        return nil,-1,"effected_rows is 0,opt err!"
    end
    return res
end
mysql.cud_query = cud_query

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function muti_query: 多语句执行函数封装

-- @param _sql: 多条sql组成的字符串
-- @param _nums: mysql sql 语句数量

-- @return res: 修改成功的res; 返回 nil 表示失败
-- @return err: err 为 -1 表示执行出现错误
-- @usages:
	local ZS_ERROR_CODE = ZS_ERROR_CODE
	local mysql_db = require "resty.utils.db.mysql_db"

    local mysql_cli = mysql_db:new();
    if not mysql_cli then
        return nil, "数据库连接异常", ZS_ERROR_CODE.MYSQL_NEW_ERR;
    end
    local muti_sql = "select * from user;select * from tests;"
    local res,err,errcode,sqlstate = mysql_cli:muti_query(muti_sql)
    if not res then
         if err = -1 then
            ngx.log(ngx.ERR,"修改失败")
         else
            ngx.log(ngx.ERR,"bad result: ", err,": ",errcode, ": ", sqlstate,".");
         end
    end

--]]
local function muti_query(_self,_sql,_nums)
    local res, err, errcode, sqlstate = _self:query(_sql,_nums)
    if not res then
        return res, err, errcode, sqlstate
    end
    local result = {}
    result[1] = res
    local index = 1
    while err == "again" do
        local  res, err, errcode, sqlstate = _self:read_result()
        if not res then
            -- ngx.log(ngx.ERR, "bad result #", i, ": ", err, ": ", errcode, ": ", sqlstate, ".")
            break;
        else
            index = index + 1
            result[index] = res
        end
    end
    if _nums ~= index then
        return nil,-1
    end
    return result
end
mysql.muti_query = muti_query



--[[
    开启事务
    对于支持savepoint 模式需要单独处理
]]
local function start_transaction(_self)
    --local res, err, errno, sqlstate
    if _self.cur_transactions > 0 then
        return true, 'already started'
    end
    _self.cur_transactions = _self.cur_transactions + 1
    return _self:query("START TRANSACTION;")
end
mysql.start_transaction = start_transaction

--[[
    提交事务
]]
local function commit(_self)
    --local res, err, errno, sqlstate =
    _self.cur_transactions = _self.cur_transactions -1
    return _self:query("COMMIT;")
end
mysql.commit = commit

--[[
    回滚事务
]]
local function rollback(_self)
    --local res, err, errno, sqlstate =
    _self.cur_transactions = _self.cur_transactions -1
    return _self:query("ROLLBACK;")
end
mysql.rollback = rollback

-- 对于开启事务服务的mysql 连接 尽可能单次使用
local function enable_savepoit(_self,_savepoint_enabled)
    if  _self.savepoint_enabled then
        return
    end
    _self.savepoint_enabled = _savepoint_enabled
end
mysql.enable_savepoit = enable_savepoit




_M.errorCount = 0
_M.okCount = 0
return _M