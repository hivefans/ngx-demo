--[[
    Create by lixy at 2019-05-07 09:12
    @brief: 系统缓存管理
]]
local sys = sys
local db_redis = require('common.db.db_redis')
local db_mysql = require('common.db.db_mysql')

local redkeys = {
    XY_API_SYSTEM = "0_XY_API_SYSTEM",
    XY_API_BIZ = '0_XY_API_BIZ',
    XY_API_PLATFORM = '0_XY_API_PLATFORM',
    XY_API_USER = '0_XY_API_USER',
    XY_API_BIZ_USER = '0_XY_API_BIZ_USER',
    XY_API_GAMES = '0_XY_API_GAMES'
}

local function null_to_nil(obj) 
    local tmp = {}
    for k, v in pairs(obj) do
        if tostring(v) ~= "userdata: NULL" then
            tmp[k] = v
        end
    end
    return tmp
end


local _M = {}

--[[
    Create by lixy at 2019-05-07 09:12
    @brief:  加载数据缓存到REDIS
    @params: NULL
    @return: 
]]
function _M.cache()
    ngx.log(ngx.ERR, "开始缓存数据...")

    -- 清理缓存
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end

    -- red:exec('del', redkeys.XY_API_PLATFORM)
    -- red:exec('del', redkeys.XY_API_BIZ)
    -- red:exec('del', redkeys.XY_API_USER)
    -- red:exec('del', redkeys.XY_API_BIZ_USER)
    -- red:exec('del', redkeys.XY_API_GAMES)

    -- 加载保存缓存数据
    _M.cache_sys_setting()
    _M.cache_platform()
    _M.cache_bizorg()
    _M.cache_user()
    _M.cache_games()

    ngx.log(ngx.ERR, "缓存数据结束")
end

function _M.cache_sys_setting()
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    local sql = "select * from t_sys_conf;"
    local res, err = db:query(sql)
    if not res then
        db:close()
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, "数据库错误"
    end
    local setting = res[1]
    if not setting then
        db:close(true)
        ngx.log(ngx.ERR, "数据错误, 系统数据未初始化, sql=", sql)
        return nil, "数据错误, 系统数据未初始化"
    end

    local res, err = red:exec('hset', redkeys.XY_API_SYSTEM , sys.conf.SERVER_ID or "SRV001", sys.cjson.encode(setting))
    if not res then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end

    db:close(true)
    return setting
end


function _M.cache_platform(platform_id) 
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    local sql = [[SELECT 
        platform_code
        , platform_name name
        -- , platform_url	
        -- , platform_logo	
        -- , platform_effects	
        -- , platform_description	
        -- , platform_hot	
        , platform_state	
        , support_demo_mode	demo_support
        , platform_index	
        , cut_percentage	
        -- , is_opened	
        -- , create_date	
        , server_addr	
        , port	
        , request_type	
        -- , is_extension
        -- t_three_gplatform_account.bizorg_id_fk bizorg_id
        -- , t_three_gplatform_account.game_platform_code_fk platform_code
        -- , t_three_gplatform_account.account_number	
        -- , t_three_gplatform_account.currency_type	
        , t_three_gplatform_account.balance	
        , t_three_gplatform_account.game_platform_json agent	
        -- , t_three_gplatform_account.opt_time
        FROM t_three_game_platform LEFT JOIN t_three_gplatform_account
        ON t_three_gplatform_account.game_platform_code_fk=t_three_game_platform.platform_code
    ]]
    if platform_id then
        sql = sql .. string.format(" WHERE t_three_game_platform.platform_code='%s'", platform_id)
    end
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, "数据库错误"
    end

    local platform_map = {}
    for k, v in pairs(res) do
        local platform = null_to_nil(v)
        if platform.agent then
            platform.agent = sys.utils.json_decode(platform.agent)
        end
        
        local id = platform.platform_code
        local res, err = red:exec('hset', redkeys.XY_API_PLATFORM , id, sys.cjson.encode(platform))
        if not res then
            ngx.log(ngx.ERR, "REDIS错误, error=", err)
            return nil, "REDIS错误, error=" .. (err or 'nil')
        end
        platform_map[id] = platform
    end
    db:close(true)
    ngx.log(ngx.ERR, "缓存游戏平台数量:", #res)
    return platform_map
end


function _M.cache_bizorg(biz_id) 
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end
    
    local sql = [[SELECT 
        bizorg_id
        , parent_id_fk parent_id
        -- ,bizorg_logo
        , nick_name
        , bizorg_name name
        , password
        , pay_password
        , area_code
        , phone_number
        , email
        , state
        -- , url
        -- , create_admin_id
        -- , is_delete
        -- , create_date
        -- , update_date
        -- , bizorg_state
        -- , opt_time
        -- , last_login_time
        -- , remark
        -- , bizorg_code
        -- , is_bizorg
        , t_bizorg_system_config.db_host
        , t_bizorg_system_config.db_port
        , t_bizorg_system_config.db_name
        , t_bizorg_system_config.redis_host
        , t_bizorg_system_config.redis_port
        , t_bizorg_system_config.bizorg_rsa_pub_key rsa_pub_key
        FROM t_bizorg LEFT JOIN t_bizorg_system_config ON t_bizorg_system_config.bizorg_id_fk=t_bizorg.bizorg_id
    ]]
    if biz_id then
        sql = sql .. string.format(" WHERE bizorg_id='%s'", biz_id)
    end
    local res, err = db:query(sql)
    if not res then
        db:close()
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, "数据库错误"
    end

    local biz_count = #res 

    local biz_map = {}
    for k, v in pairs(res) do
        local biz = null_to_nil(v)
        local id = biz.bizorg_id
        biz.account = {}
        biz_map[id] = biz
    end

    local sql = [[SELECT
        bizorg_id_fk
        , balance
        , account_state
        , cut_percentage	
        , game_platform_code  platform_code
        , game_platform_agent_info agent_info
        , self_configed
        FROM t_bizorg_account
    ]]
    local res, err = db:query(sql)
    if not res then
        db:close()
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, "数据库错误"
    end
    for k, v in pairs(res) do
        local account = null_to_nil(v)
        local biz_id = account.bizorg_id_fk
        account.bizorg_id_fk = nil
        if biz_map[biz_id] then
            biz_map[biz_id].account[account.platform_code] = account
        end
    end

    for k, v in pairs(biz_map) do
        local res, err = red:exec('hset', redkeys.XY_API_BIZ, v.bizorg_id, sys.cjson.encode(v))
        if not res then
            db:close()
            ngx.log(ngx.ERR, "REDIS错误, error=", err)
            return nil, "REDIS错误, error=" .. (err or 'nil')
        end
    end

    db:close(true)
    ngx.log(ngx.ERR, "缓存代理数量:", biz_count)
    return biz_map
end

function _M.cache_user(biz_user_id, user_id) 
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end

    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end
    local sql = [[SELECT 
        t_user.user_id	
        , t_user.user_name
        , t_user.password	
        , t_user.email	
        , t_user.phone_number	
        , t_user.area_code	
        , t_user.user_state	
        -- , t_user.registration_time	
        -- , t_user.interval_regist_time	
        , t_user.last_login_info
        , t_bizorg_user.bizorg_id_fk bizorg_id
        -- , t_bizorg_user.user_id_fk	
        , t_bizorg_user.bizorg_user_id	
        -- , t_bizorg_user.bizorg_user_no
        FROM t_user
        LEFT JOIN t_bizorg_user ON t_user.user_id = t_bizorg_user.user_id_fk
    ]]
    if biz_user_id then
        sql = sql .. string.format(" WHERE t_bizorg_user.bizorg_user_id='%s'", biz_user_id)
    elseif user_id then
        sql = sql .. string.format(" WHERE t_bizorg_user.user_id_fk='%s'", user_id)
    end

    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, "数据库错误"
    end
    local user_map = {}
    for k, v in pairs(res) do
        local user = null_to_nil(v)
        user.account = {}
        user_map[user.user_id] = user
    end
    local user_count = #res

    local sql = [[SELECT 
        user_id_fk user_id	
        , account_no	
        , balance	
        -- , consume_balance	
        -- , integral	
        -- , popularity	
        , pay_password	
        , account_state	
        , account_type	
        -- , cur_type	
        -- , pay_info	
        , err_state 
        FROM t_user_account
    ]]
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, "数据库错误"
    end
    for k, v in pairs(res) do
        local account = null_to_nil(v)
        local user_id = account.user_id
        account.user_id = nil
        if user_map[user_id] then 
            user_map[user_id].account[account.account_type] = account
        end
    end

    local biz_user_map = {}
    for k, v in pairs(user_map) do
        local user = v
        local res, err = red:exec('hset', redkeys.XY_API_USER, user.user_id,  sys.cjson.encode(user))
        if not res then
            ngx.log(ngx.ERR, "REDIS错误, error=", err)
            return nil, "REDIS错误, error=" .. (err or 'nil')
        end
        local res, err = red:exec('hset', redkeys.XY_API_BIZ_USER, user.bizorg_user_id,  sys.cjson.encode(user))
        if not res then
            ngx.log(ngx.ERR, "REDIS错误, error=", err)
            return nil, "REDIS错误, error=" .. (err or 'nil')
        end
        biz_user_map[user.bizorg_user_id] = user
    end
    db:close(true)
    ngx.log(ngx.ERR, "缓存用户数量:", user_count)
    if biz_user_id then
        return biz_user_map
    else
        return user_map
    end
end

--[[
    缓存游戏记录
    @params: 
        platform_id:    游戏平台编码
        game_id:        游戏编码
]]
function _M.cache_games(platform_id, game_id)
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end
    local sql = [[SELECT 
        t_game.game_platform_code_fk platform_code
        , game_code	
        , game_name name
        -- , game_ab
        , game_state	
        -- , game_logo1	
        -- , game_logo	
        -- , game_css	
        -- , game_index	
        -- , is_can_disable	
        -- , is_hot	
        -- , game_logo2	
        -- , is_top 
        , t_game_category.cate_code
        , t_game_category.cate_title
        FROM t_game 
        LEFT JOIN t_game_cate ON t_game_cate.game_code_fk=t_game.game_code AND t_game_cate.game_platform_code_fk=t_game.game_platform_code_fk
        LEFT JOIN t_game_category ON t_game_category.cate_code=t_game_cate.cate_code_fk
    ]]
    local sql_where = ""
    if platform_id then
        sql_where = db.append_sql(sql_where, "t_game.game_platform_code_fk", platform_id, "=", "AND")
    end
    if game_id then
        sql_where = db.append_sql(sql_where, "t_game.game_code", game_id, "=", "AND")
    end
    if sql_where ~= "" then
        sql = sql .. "WHERE " .. sql_where
    end
    sql = sql .. " ORDER BY t_game.game_platform_code_fk;"

    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, "数据库错误, error=", err, ", sql=", sql)
        return nil, "数据库错误"
    end
    local game_map = {}
    for k, v in pairs(res) do
        local game = v
        local res, err = red:exec('hset', redkeys.XY_API_GAMES, game.platform_code .. ":" .. game.game_code, sys.cjson.encode(game))
        if not res then
            ngx.log(ngx.ERR, "REDIS错误, error=", err)
            return nil, "REDIS错误, error=" .. (err or 'nil')
        end
        if not game_map[game.platform_code] then
            game_map[game.platform_code] = {}
        end
        game_map[game.platform_code][game.game_code] = game
    end
    ngx.log(ngx.ERR, "缓存游戏数量:", #res)
    return game_map
end



--[[
    读取缓存数据
]]
function _M.get_cache(key, id) 
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local res, err = red:exec('hget', key, id)
    if not res then
        if err then
            ngx.log(ngx.ERR, "REDIS错误, error=", err)
            return nil, "REDIS错误, error=" .. (err or 'nil')
        else
            -- 不存在
            -- 查询数据库
            local result = nil
            local err = nil
            if key == redkeys.XY_API_PLATFORM then
                result, err = _M.cache_platform(id)
                if result then
                    result = result[id]
                end
            elseif key == redkeys.XY_API_BIZ then
                result, err = _M.cache_bizorg(id)
                if result then
                    result = result[id]
                end
            elseif key == redkeys.XY_API_USER then
                result, err = _M.cache_user(nil, id)
                if result then
                    result = result[id]
                end
            elseif key == redkeys.XY_API_BIZ_USER then
                result, err = _M.cache_user(id, nil)
                if result then
                    result = result[id]
                end
            elseif key == redkeys.XY_API_GAMES then
                local i, j = string.find(id, ':')
                local platform_id = string.sub(id, 1, i-1)
                local game_id = string.sub(id, j+1)
                result, err = _M.cache_games(platform_id, game_id)
                if result and result[platform_id] then
                    result = result[platform_id][game_id]
                else
                    result = nil
                end
            end
            return result 
        end
    end
    local data = sys.utils.json_decode(res)
    if not data then
        ngx.log(ngx.ERR, "缓存数据格式错误, JSON解析失败, data=", res, ", key=", key, ", id=", id)
        return nil, "缓存数据格式错误, JSON解析失败, data=" .. (res or 'nil')
    end
    return data
end


--[[
    获取游戏平台信息
    @return:
        $1: 游戏信息
        $2: 错误信息， $1和$2都为nil表示无数据
]]
function _M.get_platform(platform_id)
    return _M.get_cache(redkeys.XY_API_PLATFORM, platform_id)
end

--[[
    获取渠道信息
    @return:
        $1: 游戏信息
        $2: 错误信息， $1和$2都为nil表示无数据
]]
function _M.get_biz(biz_id) 
    return _M.get_cache(redkeys.XY_API_BIZ, biz_id)
end

--[[
    获取用户信息
    @return:
        $1: 游戏信息
        $2: 错误信息， $1和$2都为nil表示无数据
]]
function _M.get_user(user_id)
    return _M.get_cache(redkeys.XY_API_USER, user_id)
end

--[[
    获取代理用户信息
    @return:
        $1: 游戏信息
        $2: 错误信息， $1和$2都为nil表示无数据
]]
function _M.get_biz_user(biz_user_id)
    return _M.get_cache(redkeys.XY_API_BIZ_USER, biz_user_id)
end

--[[
    获取游戏信息
    @params:
    @return:
        $1: 游戏信息
        $2: 错误信息， $1和$2都为nil表示无数据
]]
function _M.get_game(platform_id, game_id)
    return _M.get_cache(redkeys.XY_API_GAMES, platform_id .. ":" .. game_id)
end

function _M.get_sys_setting()
    return _M.get_cache(redkeys.XY_API_SYSTEM, sys.conf.SERVER_ID or "SRV001")
end


return _M