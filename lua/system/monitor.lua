--[[
    Create by lixy at 2019-05-08 15:03
    @brief: 系统监控器
]]

local cjson = require("cjson")
local timer = require("common.timer")
local db_redis = require('common.db.db_redis')

local _M = {}

--[[
    Create by lixy at 2019-05-22 19:55
    @brief:  启动监控任务
    @params: 无
]]
function _M.startup()
    local workerid = ngx.worker.id() 

    timer.start(_M.on_timer, 10, 0.01)

    -- timer.start(cache_manager.cache, 30, nil)


    -- 启动拉单定时任务
    local task_game_records = require("gameapi.task.game_records")
    timer.start(task_game_records.on_timer, 3, 0.01)

    -- timer.start(task_game_records.on_timer, 3, 1)


    -- 启动交易记录迁移定时任务


    -- 启动异常交易检查定时任务



end


--[[
    Create by lixy at 2019-05-22 20:49
    @brief:  监控器处理定时器，1秒执行一次
    @params: 无
    @return: 
        $1 [bool] true: 结束定时器， false 或 nil: 继续循环定时器
]]
function _M.on_timer()
    if ngx.worker.id() == 0 then 
        local lst_req, err = _M.get_alive_request()
        if lst_req then
            for k, v in pairs(lst_req) do 
                if ngx.time() - tonumber(v.timestamp) > 100 then
                    _M.remove_statistics_alive(k)
                end
            end
        end
    end

    -- 不关闭定时器
    return false
end


--[[
    Create by lixy at 2019-05-22 19:55
    @brief:  添加统计：同时活跃请求数量
    @params:
        id [string] 标识ID，不可重复
    @return: 
        $1 [bool] true: 操作成功， nil: 操作失败
        $2 [string] 错误信息
]]
function _M.add_statistics_alive(id, params)
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end

    if not params then
        params = {}
    end

    -- 保存时间戳
    params.timestamp = ngx.time()

    local res, err = red:exec("hset", sys.basedef.REDIS_KEYS.STATISTICS_API_REQUEST, id, cjson.encode(params))
    if not res and err then
        return nil, err
    end
    return true
end


--[[
    Create by lixy at 2019-05-22 20:35
    @brief:  清理统计：同时活跃请求数量
    @params: 
        id [string] 请求标识ID
    @return: 
        $1 [bool] true: 操作成功， nil: 操作失败
        $2 [string] 错误信息
]]
function _M.remove_statistics_alive(id)
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local res, err = red:exec("hdel", sys.basedef.REDIS_KEYS.STATISTICS_API_REQUEST, id)
    if not res and err then
        return nil, err
    end
    return true
end


--[[
    Create by lixy at 2019-05-22 20:11
    @brief:  获取当前活跃请求详情
    @params: 无
    @return: 
        $1 [bool] 结果数据， nil: 操作失败
        $2 [string] 错误信息
]]
function _M.get_alive_request()
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end

    local res, err = red:exec("hgetall", sys.basedef.REDIS_KEYS.STATISTICS_API_REQUEST)
    if not res then
        if err then
            return nil, err
        else
            return {}
        end
    end
    local result = {}
    for i=1, #res, 2 do
        result[res[i]] = sys.utils.json_decode(res[i+1]) or {}
    end
    return result
end


--[[
    Create by lixy at 2019-05-22 20:32
    @brief:  获取当前活跃请求数量
    @params: 无
    @return: 
        $1 [number] 请求数量
]]
function _M.get_alive_nums()
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end
    local res, err = red:exec("hlen", sys.basedef.REDIS_KEYS.STATISTICS_API_REQUEST)
    if not res then
        if err then
            return nil, err
        end
    end
    return res
end


--[[
    Create by lixy at 2019-05-23 11:35
    @brief:  
    @params: 
    @return: 
]]
function _M.add_statistics_nums()
end


function _M.test()
    ngx.log(ngx.ERR, "开始测试 =====================================")
    
    local red, err = db_redis:new(sys.conf.redis_conf)
    if not red then
        ngx.log(ngx.ERR, "REDIS错误, error=", err)
        return nil, "REDIS错误, error=" .. (err or 'nil')
    end

    local t0 = ngx.time()
    for i=1, 10000, 1 do 
        

        local res, err = red:exec("set", "LIXY_TEST_0", "1")
        if not res and err then
            return nil, err
        end

        local res, err = red:exec("get", "LIXY_TEST_0")
        if not res and err then
            ngx.log(ngx.ERR, ">>>>>>>>>>> REDIS ERROR")
            -- return nil, err
        end
    end
    ngx.log(ngx.ERR, "REDIS 耗时: ", ngx.time()-t0)


    local db_mysql = require('common.db.db_mysql')
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    local t0 = ngx.time()
    for i=1, 10000, 1 do
        local sql = "select * from t_sys_conf;"
        local res, err = db:query(sql)
        if not res then 
            ngx.log(ngx.ERR, ">>>>>>>>>>> MYSQL ERROR")
        end
    end
    db:close(true)
    ngx.log(ngx.ERR, "MYSQL 耗时: ", ngx.time()-t0)
end

return _M