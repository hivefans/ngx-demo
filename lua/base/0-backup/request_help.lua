--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/request_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: ngx request 请求的功能解释与简单封装
        ngx var的成员说明:
--------------------------------------------------------华丽的分割线------------------------------------------------------------

--]]
local cjson = require "cjson"
local decode = cjson.decode
local _M = {}
_M._VERSION = '0.01'



-- 获得request 头信息
_M.get_headers = ngx.req.get_headers
local get_uri_args = ngx.req.get_uri_args
local read_body = ngx.req.read_body
local get_body_data = ngx.req.get_body_data
local get_post_args = ngx.req.get_post_args


-- get 请求的简要写法

_M.read_body = read_body
_M.get_body_data = get_body_data
_M.get_post_args = get_post_args


_M.get_uri_args = function()
    local args = get_uri_args()
    return _M.revise_args(args)
end

function _M.revise_args(args)
    if args then
        for k, v in pairs(args) do
            if args[k] == '' or tostring(args[k]) == "userdata: NULL" then
                args[k] = nil
            end
        end
    else
        args = {}
    end
    return args
end


-- application/x-www-form-urlencoded 方式的post请求
_M.get_post_args = function()
    read_body()
    return get_post_args()
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_all_args:  获取http get/post 请求参数支持 application/x-www-form-urlencoded 方式的post请求;
                         args 和 post的字段注意区别
-- @return uri_args: uri 的参数
-- @return post_args: post 传递的数据值
-- @usages: 建议尽量确定传送模式
	local request_help = require "resty.utils.request_help"
	local uri_args,post_args = request_help.get_all_args();
]]
_M.get_all_args = function()
    local uri_args = get_uri_args();
    read_body()
    local body_args = get_post_args()
    return uri_args, body_args
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_json_post:  获取http post 请求参数支持 application/json 方式的post请求;
                         args 和 post的字段注意区别
-- @return post_args: post json 数据
-- @usages: 建议尽量确定传送模式
	local request_help = require "resty.utils.request_help"
	local json_data = request_help.get_json_post();
]]
_M.get_json_post = function()
    read_body()
    local post_data = get_body_data()
    local ok, post_args = pcall(decode, post_data)
    if ok then
        for k, v in pairs(post_args) do
            if post_args[k] == '' or tostring(post_args[k]) == "userdata: NULL" then
                post_args[k] = nil
            end
        end
        return post_args
    else
        return nil
    end
end


--[[
-- @author: Steven（01）
-- @date: 2018-11-07

-- @function get_xml_post:  获取http post 请求参数支持 text/xml 方式的post请求;
                         args 和 post的字段注意区别
-- @return post_args: post json 数据
-- @usages: 建议尽量确定传送模式
	local request_help = require "resty.utils.request_help"
	local json_data = request_help.get_json_post();
]]
_M.get_xml_post = function()
    read_body()
    local post_data = get_body_data()
    local ok, post_args = pcall(decode, post_data)
    if ok then
        return post_args
    else
        return nil
    end
end



local function explode (_str, seperator)
    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(_str, seperator, pos, true)
    end do
        table.insert(arr, string.sub(_str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(_str, pos))
    return arr
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_multipart_post:  当post上传带有文件类型等参数的请求,调用本函数进行数据处理 multipart/form-data
                                   -- 需要测试和优化!!!!
-- @return post_args: post json 数据
-- @usages:
	local request_help = require "resty.utils.request_help"
	local post_args = request_help.get_multipart_post();
]]
function _M.get_multipart_post()
    local request_method = ngx.var.request_method
    local args = {}
    if "GET" == request_method then
        args = ngx.req.get_uri_args()
    elseif "POST" == request_method then
        local receive_headers = ngx.req.get_headers()
        local file_args = {}
        local is_have_file_param = false
        ngx.req.read_body()
        --判断是否是multipart/form-data类型的表单
        if string.sub(receive_headers["content-type"], 1, 20) == "multipart/form-data;" then
            is_have_file_param = true
            content_type = receive_headers["content-type"]
            body_data = ngx.req.get_body_data()--body_data 是符合http协议的请求体，不是普通的字符串
            local error_code = nil
            local error_msg = ""

            --请求体的size大于nginx配置里的client_body_buffer_size，则会导致请求体被缓冲到磁盘临时文件里，client_body_buffer_size默认是8k或者16k
            if not body_data then
                local datafile = ngx.req.get_body_file()
                if not datafile then
                    error_code = 1
                    error_msg = "no request body found"
                else
                    local fh, err = io.open(datafile, "r")
                    if not fh then
                        error_code = 2
                        error_msg = "failed to open " .. tostring(datafile) .. "for reading: " .. tostring(err)
                    else
                        fh:seek("set")
                        body_data = fh:read("*a")
                        fh:close()
                        if body_data == "" then
                            error_code = 3
                            error_msg = "request body is empty"
                        end
                    end
                end
            end

            local new_body_data = {}
            --确保取到请求体的数据  
            if not error_code then
                local boundary = "--" .. string.sub(receive_headers["content-type"], 31)
                local body_data_table = explode(tostring(body_data), boundary)

                local first_string = table.remove(body_data_table, 1)
                local last_string = table.remove(body_data_table)

                for i, v in ipairs(body_data_table) do
                    local start_pos, end_pos, capture, capture2 = string.find(v, 'Content%-Disposition: form%-data; name="(.+)"; filename="(.*)"')
                    if not start_pos then
                        --普通参数
                        local t = explode(v, "\r\n\r\n")
                        local temp_param_name = string.sub(t[1], 41, -2)
                        local temp_param_value = string.sub(t[2], 1, -3)
                        args[temp_param_name] = temp_param_value
                    else
                        --文件类型的参数，capture是参数名称，capture2是文件名
                        file_args[capture] = capture2
                        table.insert(new_body_data, v)
                    end
                end
                table.insert(new_body_data, 1, first_string)
                table.insert(new_body_data, last_string)
                --去掉app_key,app_secret等几个参数，把业务级别的参数传给内部的API  
                body_data = table.concat(new_body_data, boundary)--body_data可是符合http协议的请求体，不是普通的字符串
            end
        else
            args = ngx.req.get_post_args()
        end
    end
    args.body_data = body_data;
    return args;
end

--[[
-- get_or_post 判断当前为post 还是 get 请求
-- example 
-- @param  无
-- @return true 表示post； false 表示 get 请求
--]]
_M.get_or_post = function()
    -- body
    local request_method = ngx.var.request_method;
    if "GET" == request_method then
        return false;
    elseif "POST" == request_method then
        return true;
    end
    return nil
end

--------------------------------------------------------华丽的分割线------------------------------------------------------------
-- ngx var 地址相关功能封装与说明

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_domain_url:  获得当前请求的域名
-- @return domain_url: 获得协议+域名 例如 http://www.goodtime.vip
-- @usages:
	local request_help = require "resty.utils.request_help"
	local domain_url = request_help.get_domain_url();
]]
_M.get_domain_url = function( _with_port )
    local server_port = ngx.var.server_port
    local scheme = ngx.var.scheme

    if _with_port then
        local port_str = ""
        if scheme == "https"  then
            port_str =  server_port =="443" and "" or ":"..server_port
        elseif scheme == "http" then
            port_str = server_port =="80" and "" or ":"..server_port
        else
            port_str = ":"..server_port
        end
        return ngx.var.scheme .. "://" .. ngx.var.host..port_str
    else
        return ngx.var.scheme .. "://" .. ngx.var.host
    end
end


--[[
-- get_curl_url 获得当前的访问的地址不包括参数
-- example 
-- @param  无
-- @return 返回除参数以外的地址信息
--]]
_M.get_curl_url = function()
    return ngx.var.scheme .. "://" .. ngx.var.host .. ngx.var.request_uri
end


--[[
-- get_cli_ip 获得用户端ip地址
-- example 
-- @param  无
-- @return true 表示post； false 表示 get 请求
--]]
_M.get_cli_ip = function()
    local headers = ngx.req.get_headers()
    local cli_ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    return cli_ip
end
--[[
    http://127.0.0.1:80/testres.do
ngx.say( ngx.var.host)      -- 127.0.0.1
ngx.say( ngx.var.scheme ) -- http
ngx.say(ngx.var.remote_addr) -- 127.0.0.1 
ngx.say(ngx.var.scheme.."://"..ngx.var.remote_addr) 
ngx.say(ngx.var.server_addr) -- 127.0.0.1 
ngx.say(ngx.var.uri) -- /testres.do 


for k,v in pairs(ngx.var) do
    if type(k) == "string" then
        ngx.say(k)
        ngx.say(v)
    end

end
]]
_M.param_nil_judge = function(_param)
    if not _param or type(_param) ~= "table" then
        return nil
    end
    local param_res = {}
    for k, v in pairs(_param) do
        if v == nil then
            table.insert(param_res, k)
        end
    end
    return param_res
end

return _M 


