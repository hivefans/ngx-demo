--[[
    初始化NGINX
]]


-- ngx系统接口定义
require("base.ngx_mock")

-- JSON 解析库
require("cjson")

ngx.log(ngx.ERR, "===== 启动 OPENRESTY")