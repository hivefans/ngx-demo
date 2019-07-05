--[[
    Create by lixy at 2019-05-08 15:10
    @brief: 
]]


local _M = {}

--[[
    开启定时器
    @params:
        handler: 回调函数，该函数返回true终止定时器，nil/false继续循环
        interval: 定时器间隔时间，单位秒， nil时使用 1
        delay:   首次执行的延迟时间，单位秒，nil时使用interval, interval也为nil时使用0.01
]]
_M.start = function(handler, interval, delay, ...)
    if not handler then
        ngx.log(ngx.ERR, "开启定时器失败，回调函数=nil")
        return
    end
    while true do
        local res, err = ngx.timer.at(delay or interval or 0.01, _M.on_timer, handler, interval or 1, ...)
        if res then
            break
        else
            ngx.log(ngx.ERR, "开启定时器失败，", err)
            ngx.sleep(1)
        end
    end
end


_M.on_timer = function(premature, handler, interval, ...)
    if premature then
        return
    end
    if not handler then
        ngx.log(ngx.ERR, "开启定时器失败，回调函数=nil")
        return
    end

    local res = sys.exec_xpcall(handler, ...)
    if res then
        ngx.log(ngx.ERR, "定时器关闭.")
        return
    end

    local res, err = ngx.timer.at(interval, _M.on_timer, handler, interval, ...)
    if not res then
        ngx.log(ngx.ERR, "开启定时器失败，", err)
        ngx.sleep(interval)
        _M.on_timer(false, handler, interval, ...)
    end
end

return _M