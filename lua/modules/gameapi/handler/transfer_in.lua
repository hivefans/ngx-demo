--[[
    Create by lixy at 2019-05-08 11:28
    @brief: 
    @url:   /gameapi/handler/transfer_in.do
]]


local api_def = require("gameapi.conf.api_def")
local cache_manager = require("system.cache_manager")
local gapi_manager = require("gameapi.model.gapi_manager")

local sys = sys
local err_code = sys.err_code

-- 检查参数
local args = sys.request.get_args()
local ok, err = sys.request.check_keys(args, {"app_id", "user_id", "platform_id", "amount"})
if not ok then
    ngx.log(ngx.ERR, '请求参数错误. error=', err, ', args=', sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.PARAM_ERR, "参数错误.", {error= err})
end

-- 检查参数
local platform = args.inner_args.platform
local platform_agent = platform.agent
local user = args.inner_args.user
local agent = args.inner_args.agent

-- 检查代理状态
if agent.state ~= 1 then 
    return sys.request.say(sys.err_code.AGENT_DISABLE, "代理状态异常")
end
if agent.account_state ~= 1 then
    return sys.request.say(sys.err_code.AGENT_ACCOUNT_DISABLE, "代理账户状态异常", agent)
end

-- 检查游戏平台状态
if tonumber(platform.state) ~= 1 then
    return sys.request.say(sys.err_code.PLATFOMR_DISABLE, "游戏平台状态异常", platform)
end

-- 检查用户状态
if user.state ~= 1 then
    return sys.request.say(sys.err_code.PLATFOMR_DISABLE, "用户状态异常", user)
end
if user.account_state ~= 1 then
    return sys.request.say(sys.err_code.PLATFOMR_DISABLE, "用户账户状态异常", user)
end

-- 生成订单编号
local trade_no = gapi_manager.create_trans_id(args.platform_id, user.uid, platform_agent)
args.inner_args.trade_no = trade_no

-- 生成订单


-- 请求游戏平台子接口
local res, err = sys.request.capture(ngx.HTTP_POST, api_def.platform_gateway, args)
if not res then
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = err })
end
if res.code == sys.err_code.SUCCESS then
    return sys.request.say(res.code, res.msg, res.data)
end

return sys.request.say(res.code, res.msg, res.data)