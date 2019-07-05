--[[
    初始化NGINX
]]

sys = require('base.sys')

-- ngx系统接口定义
require("base.ngx_mock")

-- JSON 解析库
require("cjson")

ngx.log(ngx.ERR, "===== 启动 OPENRESTY")


math.randomseed(tostring(os.time()):reverse():sub(1, 7))
-- math.randomseed(tostring(require("socket").gettime()):reverse():sub(1, 6))




