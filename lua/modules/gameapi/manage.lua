--[[
    Create by lixy at 2019-05-22 11:02
    @brief: API管理接口
]]

local sys = require("base.sys")
local handler_manager = require("gameapi.handler.manager")

-- local lst_cmd = {
--     ['list_game'] = "list_game",
--     ['add_game'] = "add_game",
--     ['modify_game'] = "modify_game",
--     ['delete_game'] = "delete_game",
--     ['add_platform'] = "add_platform",
-- }

-- 获取请求参数
local args = sys.request.get_args()

-- 检查参数
local ok, err = sys.request.check_keys(args, {"cmd"})
if not ok then
    ngx.log(ngx.ERR, '请求参数错误. error=', err, ', args=', sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.PARAM_ERR, "参数错误.", {error= err})
end

local cmd = args['cmd']
-- local handler_name = lst_cmd[cmd]
-- if not handler_name then
--     return sys.request.say(sys.err_code.PARAM_ERR, "不支持的操作.cmd=" .. (cmd or ''), lst_cmd)
-- end

local handler_name = cmd
local handler = handler_manager[handler_name]
if not handler then
    return sys.request.say(sys.err_code.PARAM_ERR, "未定义的操作.cmd=" .. (cmd or ''))
end

local res = sys.exec_xpcall(handler, args)
if not res then
    ngx.log(ngx.ERR, string.format("调用 gameapi.handler.manager 函数[%s]错误", handler_name))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误")
end

return sys.request.say(res.code, res.msg, res.data)



