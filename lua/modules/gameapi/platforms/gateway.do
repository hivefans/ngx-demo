--[[
    此文件用于调用指定游戏平台相关API操作
    从 gapi_conf 读取游戏平台配置信息 (接口处理对象及接入agent参数信息)
]]

local sys = require("server.sys")
local gapi_conf = require "gapi_platform.bundles.gapi_conf"

-- 解析参数
local args = sys.request.get_post_json_args()
if not args then
    return sys.say(sys.ERR_CODE.PARAM_ERR, "请求参数格式错误: 需要JSON字符串")
end

-- 检查参数: 接口类型
local ok, err = sys.utils.check_keys(args, {"platform_code", "method", "agent"})
if not ok then
    return sys.say(sys.ERR_CODE.PARAM_ERR, "请求参数错误: ", { error = err })
end

-- 游戏平台编码
local platform_code = args['platform_code']

-- 从配置中读取游戏平台信息
local platform_def = gapi_conf.platform_def[platform_code]
if not platform_def then
    ngx.log(ngx.ERR, string.format("gapi_conf文件中的platform_def未定义游戏平台[%s]的相关信息", platform_code))
    return sys.say(sys.ERR_CODE.SYS_ERR, "不支持的游戏平台")
end

-- 从配置中读取代理基础信息
local agent_def = platform_def.agent_def
if not agent_def then
    ngx.log(ngx.ERR, string.format("gapi_conf文件中的platform_def未定义游戏平台[%s]的代理相关信息", platform_code))
    return sys.say(sys.ERR_CODE.SYS_ERR, "不支持的游戏平台")
end


-- 从配置中读取接口处理模块（lua文件）
local handler_name = platform_def.handler
if not handler_name then
    ngx.log(ngx.ERR, string.format("gapi_conf文件中的platform_def未定义游戏平台[%s]的接口处理文件", platform_code))
    return sys.say(sys.ERR_CODE.SYS_ERR, "不支持的游戏平台")
end

-- 加载接口处理模块
local handler, err = sys.exec_xpcall(require, handler_name)
if not handler then
    ngx.log(ngx.ERR, string.format("require游戏平台[%s]的接口处理文件[%s]失败", platform_code, handler_name))
    return sys.say(sys.ERR_CODE.SYS_ERR, "系统错误")
end

-- 检查API接入账户信息
local agent = args["agent"]
local ok, err = sys.utils.check_keys(agent, agent_def)
if not ok then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]参数[agent]错误, error=%s, agent_def=%s", platform_code, err, agent_def))
    return sys.say(sys.ERR_CODE.PARAM_ERR, "参数[agent]错误", { error = err })
end

local method_id = args["method"]

local func_def = {
    -- 用户注册
    [gapi_conf.METHOD.REGISTER_GAME] = 'register',
    -- 登入游戏
    [gapi_conf.METHOD.LOGIN_GAME] = 'login',
    -- 用户上分
    [gapi_conf.METHOD.TRANSFER_CREDIT] = 'transfer_credit_in',
    -- 用户下分
    [gapi_conf.METHOD.TAKE_NOW] = 'transfer_credit_out',
    -- 获取余额
    [gapi_conf.METHOD.GET_BALANCE] = 'get_blance',
    -- 查询订单
    [gapi_conf.METHOD.QUERY_TRANSACTION] = 'get_transaction',
    -- 获取交易记录
    [gapi_conf.METHOD.GET_TRADE_TF] = 'get_trade_record',
    -- 获取游戏记录
    [gapi_conf.METHOD.GET_GAME_RECORDS] = 'get_game_record',
    -- 获取用户信息
    [gapi_conf.METHOD.GET_USER_INFO] = 'get_user_info',
    -- 下线用户(踢出用户)
    [gapi_conf.METHOD.USER_OFFLINE] = 'kick_user',
    -- 凍結用戶
    [gapi_conf.METHOD.ACCOUNT_FREEZE] = 'freeze_user',
}

local func_name = func_def[method_id]
if not func_name then
    return sys.say(sys.ERR_CODE.PARAM_ERR, "不支持的操作")
end
local func = handler[func_name]
if not func then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]未实现操作[%s]", platform_code, func_name))
    return sys.say(sys.ERR_CODE.PARAM_ERR, "不支持的操作")
end

local result = func(args, agent)
if not result then
    ngx.log(ngx.ERR, string.format("游戏平台[%s]操作[%s]返回值错误", platform_code, func_name))
    return sys.say(sys.ERR_CODE.PARAM_ERR, "系统错误")
end

ngx.say(sys.utils.json_encode(result))





