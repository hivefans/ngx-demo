--[[
    Create by lixy at 2019-05-07 15:00
    @brief: 用户数据管理
]]

local db_redis = require('common.db.db_redis')
local db_mysql = require('common.db.db_mysql')
local crypto = require('common.crypto.resty_crypto')
local uuid = require("common.uuid"):new("465a78ad-93cc-432e-a836-9824d49506d6")

local _M = {}

local function create_user_id()
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local index, err = red:exec("incr", "XY_API_USER_INDEX");
    if not index then  
        ngx.log(ngx.ERR, "创建redis客户端错误","redis_cli:incr(ZS_PRE_USER_CODE_INC)");
        return nil
    end
    return index + sys.conf.USER_ID_INDEX
end

--[[
    创建新用户
    @params: 
        agent_id:       [string] 代理ID
        agent_user_id:  [string] 代理用户账户ID
        platform_code:  [string] 游戏平台编码
--]]
function _M.create(agent_id, agent_user_id, platform_id, password)
    -- 连接数据库
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    -- 开启事务
    local res, err = db:start_transaction()
    if not res then
        db:close()
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    local uid = create_user_id()
   
    -- 生成中间表对象
    local user = {
        bizorg_id_fk = agent_id,
        user_id_fk = uid,
        bizorg_user_id = agent_user_id,
        bizorg_user_no = uuid:get64(agent_id .. agent_user_id),
    }

    -- 写入代理用户关联数据
    local sql = db.fmt_insert ("t_bizorg_user", user)
    local res, err, errcode = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        db:rollback()
        local ok, errs = db:close()
        if not ok then
            ngx.log(ngx.ERR, '关闭数据库失败. err: ', errs)
        end

        if errcode == 1062 then
            ngx.log(ngx.ERR, string.format("代理[%s]用户[%s]已经存在", agent_id, agent_user_id))
            return -1, "用户已经存在"
        end
        return nil, err
    end

    -- 写入用户数据
    local user = {
        user_id = uid,
        password = crypto.sha256(password or "123456"),
        user_state = sys.basedef.USER_STATUS.OK,
    }
    local sql = db.fmt_insert("t_user", user)
    local res, err, errcode, sqlstate = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        db:rollback()
        local ok, errs = db:close()
        if not ok then
            ngx.log(ngx.ERR, '关闭数据库失败. error=', errs)
        end
        return nil, err
    end

    -- 创建用户游戏平台账户
    if platform_id then
        local user_account = {
            user_id_fk = uid,
            account_no = agent_id .. ":" .. agent_user_id  .. ":" .. platform_id,
            -- cur_type = _bizorg_user.currency_type,
            account_type = platform_id,
            account_state = 1,
        }

        local sql = db.fmt_insert("t_user_account", user_account)
        local res, err, errcode, sqlstate = db:query(sql)
        if not res then
            ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
            db:rollback()
            local ok, errs = db:close()
            if not ok then
                ngx.log(ngx.ERR, '关闭数据库失败. err: ', errs)
            end
            return nil, err
        end
    end

    -- 提交事务
    local res, err = db:commit()
    if not res then
        ngx.log(ngx.ERR, "数据库错误, 提交事务失败, error=", err, ", sql=", sql)
        db:rollback()
        local ok, errs = db:close()
        if not ok then
            ngx.log(ngx.ERR, '关闭数据库失败. err: ', errs)
        end
        return nil, err
    end
    
    -- 数据库对象保存到缓冲池
    db:close(true)
    return uid
end

return _M