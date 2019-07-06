--[[
--  作者:Steven
--  日期:2018-05-07
--  文件名:lua/resty/debug/debug_url.lua
--  版权说明:
--  openresty 调试和执行测试环境, 通过该接口模拟ngx的功能接口,实现openrety业务开发与调试
--  本函数主要用来测试各类关于http接口等相关分解与测试,模拟ngx的配置解析与测试,模拟参数传输的测试
--  如 http://www.xxx.com/tests/readme.action
--]]




--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function test_get:  test http get fun
-- @param _url: the http get url like this http://www.zhengsutec.com/uuid.do?name=steven
-- @return string: the signed string from _unsigned_map with the "key1=value1&key2=value2" style
-- @usages:
]]
function test_get(_url)
    if not _url then return assert(nil) end
    -- 正则表示分解 指定地址的各类数据信息
    ngx.req.get_uri_args()

end