

local ngx_ex = require("base.ngx_ex")

local module_name = ngx.var.modulename
local action = ngx.var.action

module_name = "lua.modules." .. string.gsub(module_name, "/", ".")

local module, err = ngx_ex.xpcall(require, module_name)
if module then
    local func = module[action]
    if func then
        local res = ngx_ex.xpcall(func)
        if res and type(res) == 'string' then
            ngx.say(res)
        end
    else
        ngx.say(string.format("ERROR: action [%s]不存在", action))
    end
else
    ngx.say(string.format("ERROR: module [%s]不存在", module_name))
end