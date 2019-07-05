--[[
    Create by lixy at 2019-05-08 15:23
    @brief: 获取余额
    @url:   /gameapi/handler/balance.do
]]

local api_def = require("gameapi.conf.api_def")
local cache_manager = require("system.cache_manager")
local gapi_manager = require("gameapi.model.gapi_manager")

local sys = sys
local err_code = sys.err_code

-- 检查参数
local args = sys.request.get_args()
local ok, err = sys.request.check_keys(args, {"app_id", "user_id", "platform_id"})
if not ok then
    ngx.log(ngx.ERR, '请求参数错误. error=', err, ', args=', sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.PARAM_ERR, "参数错误.", {error= err})
end

-- 请求游戏平台子接口
local res, err = sys.request.capture(ngx.HTTP_POST, api_def.platform_gateway, args)
if not res then
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = err })
end
if res.code == sys.err_code.SUCCESS then
    return sys.request.say(res.code, res.msg, res.data)
end

return sys.request.say(res.code, res.msg, res.data)