--[[
    Create by lixy at 2019-05-05 09:54
    @brief: 
    @url:   /gameapi/gateway.do
]]

local api_def = require("gameapi.conf.api_def")
local rsa = require("common.crypto.rsa")
local sys_manager = require("system.sys_manager")
local cache_manager = require("system.cache_manager")
local time_manager = require("common.time_manager")

local sys = sys

-- 检查HTTP请求方式
if ngx.req.get_method() ~= 'POST' then
    return sys.request.say(sys.err_code.REQ_TYPE_ERR, "不支持GET请求.")
end

-- 获取请求参数
local args = sys.request.get_args()

-- 检查参数
local ok, err = sys.request.check_keys(args, {"version", "cmd", "app_id", "sign"})
if not ok then
    ngx.log(ngx.ERR, '请求参数错误. error=', err, ', args=', sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.PARAM_ERR, "参数错误.", {error= err})
end

--=====================================================================================================================
-- 版本号检查
local version = args.version
if version ~= sys.conf.version then
    return sys.request.say(sys.err_code.PARAM_ERR, "版本错误.")
end

-- 检查系统状态
if (sys_manager.get_sys_status() ~= sys.basedef.SYSTEN_STATUS.OK) then
    return sys.request.say(sys.err_code.SYS_OFF, "系统维护")
end

local app_id = args.app_id
local cmd_code = args.cmd
local platform_id = args.platform_id
local user_id = args.user_id
local sign = args.sign

local inner_args = {}

-- 获取代理信息
local agent, err = cache_manager.get_biz(app_id)
if not agent then
    if err then
        ngx.log(ngx.ERR, "获取代理信息失败, error=", err)
        return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = err} )
    else
        return sys.request.say(sys.err_code.AGENT_NOT_EXIST, "代理不存在", { app_id = app_id })
    end
end
-- 保存 agent 到请求参数中
inner_args.agent = {
    state = agent.state,
    name = agent.name,
    account_state = agent.account.account_state,
}
if  agent.account and platform_id and agent.account[platform_id] then
    inner_args.agent.account_state = agent.account[platform_id].account_state
end

-- 从代理信息中获取RSA密钥
-- RSA 签名验证
args.sign = nil
local res = rsa:verify(agent.rsa_pub_key, 'SHA256', rsa:get_sort_buf(args), ngx.decode_base64(sign))
if not res then
    return sys.request.say(sys.err_code.RSA_ERR, "RSA签名错误", { args = args, sign = sign })
end

-- 检查当前操作码是否支持
local cmd = api_def.get_cmd(cmd_code)
if not cmd then
    return sys.request.say(sys.err_code.PARAM_ERR, "不支持的操作指令.", {support = api_def.get_support()})
end

--[[
    根据操作码，对系统数据进行查询，并传递到子接口，
    登入，上分，下分接口 查询用户数据，游戏平台数据
]]
if cmd_code == api_def.CMD.login  
    or cmd_code == api_def.CMD.transfer_in
    or cmd_code == api_def.CMD.transfer_out 
    or cmd_code == api_def.CMD.balance
    or cmd_code == api_def.CMD.query_trans
then
    -- 检查参数 user_id 
    if not user_id then
        local err = "参数[user_id]缺失"
        ngx.log(ngx.ERR, '请求参数错误. error=', err, ', args=', sys.utils.json_encode(args))
        return sys.request.say(sys.err_code.PARAM_ERR, "参数错误.", {error= err})
    end

    -- 检查平台
    local platform, err = cache_manager.get_platform(platform_id)
    if not platform then
        if err then
            ngx.log(ngx.ERR, "获取游戏平台信息失败, error=", err, " args=", sys.utils.json_encode(args))
            return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = err} )
        else
            return sys.request.say(sys.err_code.PLATFOMR_NOT_EXIST, "游戏平台不存在", { platform_id = platform_id })
        end
    end
    inner_args.platform = {
        state = platform.platform_state,
        name = platform.name,
        request_type = platform.request_type,
        server_addr = platform.server_addr,
        port = platform.port,
        agent = platform.agent
    }

     -- 检查用户
     local user, err = cache_manager.get_biz_user(user_id)
     if not user then 
         if err then 
             ngx.log(ngx.ERR, "获取用户信息失败, error=", err, " args=", sys.utils.json_encode(args))
             return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = err} )
         else
             -- 注册新用户
             return sys.request.say(sys.err_code.USER_NOT_EXIST, "用户不存在", { user_id = user_id })
         end
     end
     if user.account then
         user.account = user.account[platform_id] or {}
     end
     inner_args.user = {
        uid = user.user_id,
        state = user.user_state,
        account_state = user.account.account_state,
        err_state = user.account.err_state,
        -- user = user
        -- last_login_info = user.last_login_info,
     }
end

local eid = time_manager.uuid()
sys_manager.log(eid, app_id, user_id, platform_id, cmd_code, 1, sys.utils.json_encode(args), "发起请求")

-- 调用HANDLER处理请求
args.inner_args = inner_args
local res, err = sys.request.capture(ngx.HTTP_POST, cmd.handler, args)
if not res then
    sys_manager.log(eid, app_id, user_id, platform_id, cmd_code, -1, sys.utils.json_encode(args), "操作失败: error=" .. (err or ""))
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = err, args = args })
end
if res.code ~= sys.err_code.SUCCESS then
    sys_manager.log(eid, app_id, user_id, platform_id, cmd_code, -1, sys.utils.json_encode(args), "操作失败: error=" .. (err or "") .. ", code=" .. res.code)
else
    sys_manager.log(eid, app_id, user_id, platform_id, cmd_code, 0, sys.utils.json_encode(args), "操作成功")
end

return sys.request.say(res.code, res.msg, res.data)
