--[[
    Create by lixy at 2019-05-24 10:19
    @brief: 到游戏平台拉单定时任务执行模块
]]

local db_mysql = require('common.db.db_mysql')

local _M = {}

_M.list_task = {}


function _M.on_timer()
    -- 连接数据库
    local db, err = db_mysql:new(sys.conf.db_conf)
    if not db then
        ngx.log(ngx.ERR, "数据库错误, error=", err)
        return nil, "数据库错误, error=" .. (err or 'nil')
    end

    -- 查询数据库获取任务配置信息
    local sql = "SELECT * FROM t_task;"
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, '查询游拉单定时任务失败，数据库错误，error=', err)
        db:close();
        return false
    end

    -- 遍历任务配置项
    -- 如果任务状态开启，为该任务创建新协程执行任务过程，并保存协程id信息，在下一次定时器执行时判断协程是否存在，不存在则创建
    for i = 1, #res, 1 do
        local item = res[i]
        local task_id = item.id     -- 任务ID
        local task_state = item.state -- 任务状态


        if sys.basedef.TASK_TYPE.GAME_RECODE == item.type then
            -- 拉单任务

            -- 任务开启状态
            if task_state ~= 1 then 
            elseif (type(item.server_id) ~= "userdata" and item.server_id == sys.conf.SERVER_ID) then
                ngx.log(ngx.ERR, "  >>> ", item.server_id, " server id 不匹配")
            else
                -- 检查任务协程是否启动
                if _M.list_task[task_id] then
                    -- 检查任务协程是否崩溃 （时间戳和当前时间间隔很长）
                    if (ngx.time() - _M.list_task[task_id].timestamp) > 100 then -- 和当前时间间隔超过100秒
                        -- 不确定协程是否还存在，强制将其关闭
                        -- ngx.thread.kill(lst_task_thread[task_id].thread_id)
                        _M.list_task[task_id] = nil
                    end
                end

                if not _M.list_task[task_id] then
                    -- 创建任务处理协程
                    _M.list_task[task_id] = {
                        thread_id = ngx.thread.spawn(_M.on_thread, task_id),
                        timestamp = ngx.time()
                    }
                    ngx.log(ngx.ERR, "启动拉单任务：", item.id)
                end
                
            end
        end
    end

    db:close(true);
    
    -- 不关闭定时器，返回 false 或 nil
    return false
end





function _M.on_thread(task_id)
    local interval = 60

    while true do
        local db, err = db_mysql:new(sys.conf.db_conf)
        if not db then
            ngx.log(ngx.ERR, "数据库错误, error=", err)
            return nil, "数据库错误, error=" .. (err or 'nil')
        end

        local sql = string.format("SELECT * FROM t_task WHERE id='%s';", task_id)
        local res, err = db:query(sql)
        if not res then
        else
            local task = res[1]
            if task then
                interval = task.interval
                local setting = sys.utils.json_decode(task.setting) or {}
                local buf = string.format([[任务：%s, 状态：%s, 设置：%s, HANDLER: %s]], task.id, task.state, task.setting, task.ext2)

                _M.do_task(task, db)
                ngx.log(ngx.ERR, buf)
            else
                -- 查询任务不存在
                return
            end 
        end

        db:close(true)
        ngx.sleep(interval)
    end
    
    ngx.log(ngx.ERR, "拉单定时任务协程结束: task_id=", task_id)
end



function _M.do_task(task, db)
    -- 查询所需讯息
    local task_id = task.id
    local setting = task.setting
    local platform_code = task.ext1
    local url = task.ext2
    local biz_id = task.ext3

    if not biz_id or ngx.null == biz_id or '' == biz_id or 'userdata: NULL' == biz_id then
        biz_id = nil
    end

    local setting, err = sys.utils.json_decode(setting)
    if not setting then
        ngx.log(ngx.ERR, "TASK setting format error (JSON):", err)
        return
    end
    if not setting.sign then
        ngx.log(ngx.ERR, "TASK setting format error: sign is not exist")
        return
    end

    -- 判断URL是否以‘/’开头
    local s_temp = string.gsub(url, 1, 1)
    if s_temp ~= "/" then
        url = "/" .. url
    end

    -- 读取游戏平台的服务地址， 不存在则使用本地服务
    local sql = string.format("SELECT server_addr, request_type FROM t_three_game_platform WHERE platform_code='%s';", platform_code)
    local res, err = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, 'Get game platform configure from database failed: err=', err, ", sql=", sql)
        return
    end
    if not res[1] then
        ngx.log(ngx.ERR, 'Get game platform configure from database failed: NO DATA, sql=', sql)
        return
    end

    -- 解析当前游戏服务地址：
    local req_type = res[1].request_type
    local srv_addr = res[1].server_addr
    if not req_type or ngx.null == req_type or 'userdata: NULL' == req_type or "" == req_type then
        req_type = "LOCAL"
    end
    if req_type == "LOCAL" or (not srv_addr or ngx.null == srv_addr or 'userdata: NULL' == srv_addr or "" == srv_addr) then
        srv_addr = "http://127.0.0.1:9002" 
    end

    url = srv_addr .. url

    local params = {}
    for k, v in pairs(setting) do
        params[k] = v
    end
    params.task_id = task_id
    params.platform_id = platform_code
    params.platform_agent = nil
    --params.bizorg = {}

    -- -- 查询平台自己的第三方接入账号信息
    -- local agent, err, self_configed = game_manager.get_platform_agent(platform_code, biz_id)
    -- if not agent then
    --     ngx.log(ngx.ERR, "get agent failed: error=", err, ", platform_code=", platform_code, ", biz_id=", biz_id)
    --     return
    -- end
    -- params.platform_agent = agent
    -- params.platform_agent.self_configed = self_configed
    -- params.app_id = biz_id

    -- ngx.log(ngx.ERR, string.format("TASK [%s] BEGIN: sign=%s, url=%s", task_id, sys.utils.json_encode(setting.sign),  url))
    -- local new_sign = _M.req_game_server(platform_code, setting, url, params)
    -- if new_sign then
    --     setting.sign = new_sign
    --     _M.update_task_setting(params.task_id, setting)
    -- end
    -- ngx.log(ngx.ERR, string.format("TASK [%s] END: sign=%s, url=%s", task_id, sys.utils.json_encode(new_sign or setting.sign), url))

    -- -- sys.request.capture(ngx.HTTP_POST, task.ext2)

    -- local p = { sign = setting.sign, params = params }
    -- local res, err = sys.request.http_post(url, p, { ["Content-Type"] = "application/json" }, 30000, false)
    -- if not res then
    --     ngx.log(ngx.ERR, "HTTP response ERROR: " .. err, ",url=", url)
    --     return nil, err
    -- else
    --     if res.status == 200 then
    --         local body = utils.json_decode(res.body)
    --         if body then
    --             local data = body.data
    --             if data and data.sign and data.records then
    --                 -- ngx.log(ngx.ERR, "需要保存数据: ", #data.records)
    --                 -- local ok, err = game_manager.save_game_data(data.records)
    --                 local ok, err = game_manager.save_game_data1(data.records, platform_code)
    --                 if ok then
    --                     -- 保存数据成功
    --                     return data.sign
    --                 else
    --                     ngx.log(ngx.ERR, "Save record to database failed: error=", err)
    --                     return false
    --                 end
    --             else
    --                 ngx.log(ngx.ERR, "TASK handler response(ERROR): ", res.body, ", url=", url)
    --             end
    --         else
    --             ngx.log(ngx.ERR, 'JOSN 解析失败. body: ', res.body)
    --         end
    --     else
    --         ngx.log(ngx.ERR, "HTTP 请求返回错误, status=", res.status)
    --     end

    -- end
end

return _M