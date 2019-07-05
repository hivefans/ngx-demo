--[[
    此文件用于调用指定游戏平台相关API操作
    从 gapi_conf 读取游戏平台配置信息 (接口处理对象及接入agent参数信息)

    @url:   /gameapi/gateway_platform.do
]]

local api_def = require("gameapi.conf.api_def")

local sys = sys

-- 检查参数
local args = sys.request.get_args()
local ok, err = sys.request.check_keys(args, {"platform_id", "cmd"})
if not ok then
    return sys.request.say(sys.err_code.PARAM_ERR, "请求参数错误: ", { error = err })
end

if not args.inner_args then
    ngx.log(ngx.ERR, "请求子接口参数[inner_args]缺失, args=", sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = "args.inner_args=nil" })
end
if not args.inner_args.platform then
    ngx.log(ngx.ERR, "请求子接口参数[inner_args.platform]缺失, args=", sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = "args.inner_args.platform=nil" })
end

local agent = args.inner_args.platform.agent
if not agent then
    ngx.log(ngx.ERR, "请求子接口参数[inner_args.platform.agent]缺失, args=", sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = "args.inner_args.platform.agent=nil" })
end

-- 游戏平台编码
local platform_id = args.platform_id

-- 从配置中读取游戏平台信息
local platform_def = api_def.get_platform(platform_id)
if not platform_def then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]未定义", platform_id))
    return sys.request.say(sys.err_code.SYS_ERR, "不支持的游戏平台")
end

-- 从配置中读取接口处理模块（lua文件）
local handler_name = platform_def.handler
if not handler_name then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]未定义接口处理文件", platform_id))
    return sys.request.say(sys.err_code.SYS_ERR, "不支持的游戏平台")
end

-- 从配置中读取代理基础信息
local agent_def = platform_def.agent_def or {}

-- 检查API接入账户信息

local ok, err = sys.request.check_keys(agent, agent_def)
if not ok then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]参数[agent]错误, error=%s, agent_def=%s, agent=%s", platform_id, err, sys.utils.json_encode(agent_def), sys.utils.json_encode(agent)))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", args)
end

-- 加载接口处理模块
local handler, err = sys.exec_xpcall(require, handler_name)
if not handler then
    ngx.log(ngx.ERR, string.format("require游戏平台[%s]的接口处理文件[%s]失败", platform_id, handler_name))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误")
end

local cmd_code = args["cmd"]
local cmd_handler_name = platform_def.cmd_handler

if not cmd_handler_name then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]未定义操作处理函数, cmd_handler=nil", platform_id))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误")
end

local cmd_handler = handler[cmd_handler_name]
if not cmd_handler then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]未实现操作处理函数[%s]", platform_id, cmd_handler_name))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误")
end

local result = cmd_handler(args)
if not result then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]操作处理函数[%s]返回值错误", platform_id, cmd_handler_name))
    return sys.request.say(sys.err_code.PARAM_ERR, "系统错误")
end
-- ngx.log(ngx.ERR, sys.utils.json_encode(result))
return sys.request.say(result.code, result.msg, result.data)

-- local func_def = {
--     -- 用户注册
--     [api_def.CMD.register] = 'register',
--     -- 登入游戏
--     [api_def.CMD.login] = 'login',
--     -- 用户上分
--     [api_def.CMD.transfer_in] = 'transfer_credit_in',
--     -- 用户下分
--     [api_def.CMD.transfer_out] = 'transfer_credit_out',
--     -- 获取余额
--     [api_def.CMD.GET_BALANCE] = 'get_blance',
--     -- 查询订单
--     [api_def.CMD.QUERY_TRANSACTION] = 'get_transaction',
--     -- 获取交易记录
--     [api_def.CMD.GET_TRADE_TF] = 'get_trade_record',
--     -- 获取游戏记录
--     [api_def.CMD.GET_GAME_RECORDS] = 'get_game_record',
--     -- 获取用户信息
--     [api_def.CMD.GET_USER_INFO] = 'get_user_info',
--     -- 下线用户(踢出用户)
--     [api_def.CMD.USER_OFFLINE] = 'kick_user',
--     -- 凍結用戶
--     [api_def.CMD.ACCOUNT_FREEZE] = 'freeze_user',
-- }

-- local func_name = func_def[cmd_code]
-- if not func_name then
--     return sys.request.say(sys.err_code.PARAM_ERR, "不支持的操作")
-- end
-- local func = handler[func_name]
-- if not func then
--     ngx.log(ngx.ERR, string.format("游戏平台[%s]未实现操作[%s]", platform_id, func_name))
--     return sys.request.say(sys.err_code.PARAM_ERR, "不支持的操作")
-- end

-- local result = func(args, agent)
-- if not result then
--     ngx.log(ngx.ERR, string.format("游戏平台[%s]操作[%s]返回值错误", platform_id, func_name))
--     return sys.request.say(sys.err_code.PARAM_ERR, "系统错误")
-- end

-- ngx.say(sys.utils.json_encode(result))





