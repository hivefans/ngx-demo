--[[
    Create by lixy at 2019-05-22 14:24
    @brief: 游戏管理 
]]

local db_mysql = require('common.db.db_mysql')

local _M = {}

--[[
    Create by lixy at 2019-05-22 14:32
    @brief:  获取游戏列表
    @params: 
    @return: 
]]
function _M.list_game(page, page_size, platform_id, gtype, state, gcode, gname)
    local sql = [[select
        t_game.game_platform_code_fk platform_id
        , t_game.game_code
        , t_game.game_name
        , t_game.game_state
        , t_game_category.cate_code 
        , t_game_category.cate_title
        , t_game_category.cate_description
        from t_game left join t_game_cate 
        on t_game_cate.game_code_fk=t_game.game_code 
        and t_game_cate.game_platform_code_fk=t_game.game_platform_code_fk
        left join t_game_category 
        on t_game_category.cate_code=t_game_cate.cate_code_fk
    ]]

    local buf = ""
    buf = db_mysql.append_sql(buf, 't_game.game_platform_code_fk', platform_id, '=', 'and')
    buf = db_mysql.append_sql(buf, 't_game_category.cate_code', gtype, '=', 'and')
    buf = db_mysql.append_sql(buf, 't_game.game_state', state, '=', 'and')
    buf = db_mysql.append_sql(buf, 't_game.game_code', gcode, '=', 'and')
    buf = db_mysql.append_sql(buf, 't_game.game_name', gname, '=', 'and')

    if buf ~= ""  then 
        sql = sql .. " where " .. buf
    end
    if page and page_size then
        sql = sql .. string.format("limit %s, %s;", buf, page*page_size, page_size)
    end
    
    -- 连接数据库
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    -- 查询数据
    local res, err = db:query(sql)
    if not res then
        return nil, "数据库错误, error=" .. (err or 'nil')
    end
    return res
end


return _M
