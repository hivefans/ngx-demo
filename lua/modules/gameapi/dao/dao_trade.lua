--[[
    Create by lixy at 2019-05-24 09:59
    @brief: 交易记录数据库数据管理
]]


local db_mysql = require('common.db.db_mysql')
local time_manager = require("common.time_manager")

local _M = {}

--[[
    Create by lixy at 2019-05-24 13:38
    @brief:  创建订单
    @params: 
        uid     [string] 用户ID
        ttype   [string] 交易类型
        from_id [string] 交易发起者ID
        to_id   [string] 交易对象ID
    @return: 
]]
function _M.create_trade(outid, biz_id, uid, ttype, from_id, to_id, amount, remarks)
    local trade_id = time_manager.uuid()

    -- 连接数据库
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    local p = {
        bizorg_id_fk = biz_id,
        user_id_fk = uid,
        order_no_fk = outid,
        trade_no = trade_id,
        trade_type = ttype,
        trade_from_id = from_id,
        trade_from_balance = nil,
        trade_from_amount = amount,
        trade_to_id = to_id,
        trade_to_balance = nil,
        trade_to_amount = nil,
        trade_state = 2,
        remarks = remarks
    }
    local sql = db.fmt_insert("t_trade_tf", p)
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误，error=", err, ", sql=", sql)
        return nil, err
    end
    return trade_id
end


--[[
    Create by lixy at 2019-05-24 13:38
    @brief:  确认完成订单
    @params: 
    @return: 
]]
function _M.confirm_trade(trade_id, state, amount, remarks)

    -- 连接数据库
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    local p = {
        trade_to_amount = amount,
        trade_to_balance = nil
    }
    local sql = db.fmt_update("t_trade_tf", p, string.format("trade_id='%s' AND state='2'", trade_id))
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误，error=", err, ", sql=", sql)
        return nil, err
    end
    if res.affected_rows == 0 then
        ngx.log(ngx.ERR, "数据库错误，error=数据错误，affected_rows=0, sql=", sql)
        return nil, "数据错误，无记录更新"
    end
    return true
end

return _M