--[[
    Create by lixy at 2019-05-07 14:49
    @brief: 注册新用户
    @url:   /gameapi/handler/register.do
    @params: 
        app_id:         [string] 代理ID
        agent_user_id:  [string] 代理用户ID
]]

local dao_user = require("gameapi.dao.dao_user")

local sys = sys 

-- 检查参数
local args = sys.request.get_args()
local ok, err = sys.request.check_keys(args, {"app_id", "user_id"})
if not ok then
    ngx.log(ngx.ERR, '请求参数错误. error=', err, ', args=', sys.utils.json_encode(args))
    return sys.request.say(sys.err_code.PARAM_ERR, "参数错误.", { error= err, args = args })
end

-- local agent = args.inner_args.agent
-- if not agent then
--     ngx.log(ngx.ERR, '请求参数错误. error=参数[agent]缺失, args=', sys.utils.json_encode(args))
--     return sys.request.say(sys.err_code.SYS_ERR, "系统错误")
-- end

local app_id = args.app_id
local agent_user_id = args.user_id
local platform_id =  args.platform_id

local uid, err = dao_user.create(app_id, agent_user_id, platform_id, '123456')
if not uid then
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error= err})
end
if uid == -1 then
    return sys.request.say(sys.err_code.USER_REPEAT_RESIGER, "用户已经存在", { user_id = agent_user_id})
end

return sys.request.say(sys.err_code.SUCCESS, "注册用户成功", { uid = uid} )



