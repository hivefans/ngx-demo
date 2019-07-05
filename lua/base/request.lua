

local cjson = require("cjson")-- JSON解析库
local resty_http = require("resty.http")

local _M = {}

--[[
    解析请求参数
]]
function _M.get_args()
    -- 判断当前请求类型： GET/POST
    local method = ngx.req.get_method()
    local args = {}
    if method == "GET" then -- 解析 GET 请求参数
        args = ngx.req.get_uri_args() or {}
    elseif method == "POST" then -- 解析 POST 请求参数
        ngx.req.read_body()
        local buf = ngx.req.get_body_data()
        if buf then
            local utils = require("common.utils")
            args = utils.json_decode(buf) or buf
        else
            args = {}
        end
    end
    for k, v in pairs(args) do
        if type(v) == 'userdata' or v == "" then
            v = nil
        end
    end
    return args
end

--[[
    检查参数，检查关键key参数是否存在于参数table表中
    @params:
        args: 参数表(table) 如： {id=100, type=1}
        keys: 关键key(数组) 如： {"id", "type"}
    @return:
        $1: 检查状态： true：检查的参数存在于参数表中; nil: 有参数不存在 或 参数表为nil 或关键key为nil
        $2: 错误信息
]]
function _M.check_keys(args, keys)
    if not args or not keys then
        return nil
    end
    local errmsg = ""
    for k,v in pairs(keys) do
        if not args[v] then
            if errmsg ~= "" then
                errmsg = errmsg .. ","
            end
            errmsg = errmsg .. v
        end
    end
    if errmsg ~= "" then
        return nil, "参数[" .. errmsg .. "]缺失"
    end
    return true
end


--[[
    发送HTTP GET请求
]]
function _M.http_get(url, params, header, t_timeout, ssl)
    local http = resty_http.new()
    http:set_timeout(t_timeout or 10000)

    local req_url = url
    if params then
        local buf = ""
        if header and header["Content-Type"] == "application/x-www-form-urlencoded" then
            buf = ngx.encode_args(params)
        else
            for k, v in pairs(params) do
                if buf ~= "" then
                    buf = buf .. "&"
                end
                buf = buf .. k .. "=" .. v
            end
        end
        req_url = url .. "?" .. buf
    end

    return http:request_uri(req_url, {
        method = "GET",
        ssl_verify = (ssl and true) or false,
        headers = header
        --headers = { ["Content-Type"] = "application/json" },
        --body = utils.json_encode(params)
    })
end



--[[
    发送HTTP POST请求
]]
function _M.http_post(url, params, header, t_timeout, ssl)
    local http = resty_http.new()
    http:set_timeout(t_timeout or 10000)

    local body = nil
    if params then
        if header and header["Content-Type"] then
            local content_type = header["Content-Type"]
            if string.sub(content_type, 1, string.len(CONTENT_TYPE.URLENCODE)) == CONTENT_TYPE.URLENCODE then
                --body = ngx.encode_args(params)
                body = utils.url_encode_sort(params)
            elseif string.sub(content_type, 1, string.len(CONTENT_TYPE.JSON)) == CONTENT_TYPE.JSON then
                body = utils.json_encode(params)
            else
                body = utils.url_encode_sort(params)
            end
        else
            body = utils.url_encode_sort(params)
        end
    end
    --ngx.log(ngx.ERR, "================= HTTP 请求:\n\t** url: ", url, "\n\t** body: ", body)
    return http:request_uri(url, {
        method = "POST",
        ssl_verify = (ssl and true) or false,
        headers = header,
        --headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
        --headers = { ["Content-Type"] = "application/json" },
        body = body
    })
end

--[[
    请求访问内部子接口 （CAPTURE）
    @params:
        method: 请求方式： ngx.HTTP_GET / ngx.HTTP_POST
        url:    接口地址 如： /modules/test/getdata.do
]]
function _M.capture(method, url, params)
    if not url then
        return nil, "ngx.CAPTURE 参数错误, url=nil"
    end
    --[[
        example: 
            ngx.location.capture(url, { method = ngx.HTTP_POST, body = cjson.encode(params) })
            ngx.location.capture(url, { method = ngx.HTTP_GET,  args = params })
    ]]
    local p = {}
    if  method == ngx.HTTP_POST then
        p.method = ngx.HTTP_POST
        p.body = cjson.encode(params)
    else
        p.method = ngx.HTTP_GET
        p.args = params
    end
    local res, err = ngx.location.capture(url, p)
    if not res then
        ngx.log(ngx.ERR, "ngx.CAPTURE 失败, error=", err, ", url=", url, ", params=")
        return nil, "ngx.CAPTURE 失败, error=" .. (err or 'nil') .. ", url=" .. (url or 'nil')
    end
    if 200 ~= res.status then
        ngx.log(ngx.ERR, "ngx.CAPTURE 错误, status=", res.status, ", body=", res.body, ", url=", url)
        return nil, "ngx.CAPTURE 错误, status=" .. res.status .. ", body=" .. (res.body or '')
    end
    local res_body, err = sys.utils.json_decode(res.body)
    if not res_body then
        ngx.log(ngx.ERR, "ngx.CAPTURE 返回值错误, JSON解析失败, body=", res.body, "url=", url)
        return nil, "ngx.CAPTURE 返回值错误, JSON解析失败， body=" .. (res.body or 'nil') 
    end
    return res_body
end


--[[
    返回数据给网络请求方，数据格式为JSON字符串 如: {code=200, msg="SUCCESS", data={status=1, name="hello"}} （JSON转换成字符串）
    @params:
        code: 错误码
        msg： 描述信息
        data: 返回数据体
    @return: nil
]]
function _M.say(code, msg, data)
    ngx.say(cjson.encode({code=code,msg=msg,data=data}))
    return
end


function _M.response(code, msg, data)
    return {code=code,msg=msg,data=data}
end




return _M