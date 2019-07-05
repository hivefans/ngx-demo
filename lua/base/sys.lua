local _M = {}

_M.cjson = require("cjson")

_M.conf = require("conf.sys_conf")

_M.request = require("base.request")

_M.err_code = require("base.error_code")

_M.utils = require("common.utils")

_M.basedef = require("system.basedef")


-- 打印错误信息
local function __TRACKBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6);
    local msg = "\n\n"
    msg = msg .. "\n======================================================================================"
    msg = msg .. "\n*                               XPCALL TRACKBACK ERROR                                 *"
    msg = msg .. "\n*                                                                                       *"
    msg = msg .. "\n====================================================================================== \n"
    msg = msg .. track_text
    msg = msg .. " ERROR\n====================================================================================== TRACKBACK END"
    ngx.log(ngx.ERR, msg);
    local exception_text = "LUA EXCEPTION\n" .. track_text;
    return errmsg;
end

_M.exec_xpcall = function(func, ...)
    local res, res_func = xpcall(func, __TRACKBACK__, ...)
    if res then
        return res_func
    else
        return nil, "调用XPCALL失败"
    end
end

return _M