--[[
--  作者:Steven
--  日期:2018-05-07
--  文件名:lua/resty/debug/debug_openresty.lua
--  版权说明:
--  openresty 调试和执行测试环境, 通过该接口模拟ngx的功能接口,实现openrety业务开发与调试
--  使用说明: 开发完成某个接口之后,通过该接口对于要测试的接口引用本函数实现一次业务引入与关联,之后可以对脚本进行业务处理
--
--]]


-- 1 新增lualib lua 与 so 环境目录
--[[
package.path用于搜索自己写的库文件或者第三方的库文件
lua_package_path 'lua/?.lua;lua/modules/?.lua;/usr/local/share/lua/5.1/?.lua;/opt/openresty/nginx/lualib/;;';
]]


package.path = package.path..";ngx_base/?.lua;modules/?.lua;"
package.path = package.path..";lua/?.lua;lua/modules/?.lua;/usr/local/share/lua/5.1/?.lua;/opt/openresty/lualib/?.lua;;"

require "resty.debug.ngx_mock"
require "resty.debug.debug_url"

--[[
package.cpath用于搜索自己写的so库文件或者第三方的so库文件
]]
--搜索指定路径下，以.so结尾的文件
package.cpath = package.cpath..";/opt/openresty/lualib/?.so;"
-- 2 引入拓展函数接口

-- 3 工程的配置文件扫描与环境初始化
require "conf.base_config"
require "resty.lua_ex.lua_func_ex"


local TEST_ID = {
    id=ngx.worker.id()
}
ngx.log(ngx.ERR,"000000:",TEST_ID.id)
return TEST_ID