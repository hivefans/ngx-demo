

local _M = {}

-- 打印错误信息
local function __TRACKBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6);
    ngx.log(ngx.ERR, "\n\n---------------------------------------- TRACKBACK ----------------------------------------");
    ngx.log(ngx.ERR, track_text, "LUA ERROR");
    ngx.log(ngx.ERR, "\n---------------------------------------- TRACKBACK ----------------------------------------");
    local exception_text = "LUA EXCEPTION\n" .. track_text;
    return errmsg;
end

function _M.xpcall(func, ...)
    local ok, res = xpcall(func, __TRACKBACK__, ...)
    if ok then
        return res
    end
    return nil, "XPCALL failed"
end


function _M.pcall(func, ...)
    local ok, res = pcall(func, ...)
    if ok then
        return res
    end
    return nil, "PCALL failed"
end

return _M

