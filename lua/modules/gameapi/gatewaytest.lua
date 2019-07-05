--[[
    Create by lixy at 2019-05-07 13:24
    @brief: 
    @url:   /gameapi/gatewaytest.do
]]


local sys = sys
local rsa = require("common.crypto.rsa")
local time_manager = require("common.time_manager")

-- 获取请求参数
local args = sys.request.get_args() or {}

-- 签名
local sign, err = rsa:sign(sys.basedef.rsa_private_key, 'SHA256', nil, rsa:get_sort_buf(args))
if not sign then
    return sys.request.say(sys.err_code.SYS_ERR, "模拟签名失败", { error = err })
end
args.sign = ngx.encode_base64(sign)

local url_gateway = "/gameapi/gateway.do"
local res, err = sys.request.capture(ngx.HTTP_POST, url_gateway, args)
if not res then
    return sys.request.say(sys.err_code.SYS_ERR, "系统错误", { error = err })
end

return sys.request.say(res.code, res.msg, res.data)