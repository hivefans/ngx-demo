
local cjson = require("cjson")


local _M = {}

function _M.json_encode(data)
    if not data then
        return nil
    end
    return cjson.encode(data)
end

function _M.json_decode(text)
    text = text or '{}'
    if type(text) ~= "string" then
        return nil, "JSON decode 数据格式错误, type=" .. type(text)
    end
    local res, data = pcall(cjson.decode, text)
    if not res then
        return nil, "JSON decode failed. text=" .. text
    end
    return data
end




function _M.load_json_file(filename)
    local f = io.open(filename, "r")

    local buf = nil
    while true do
        local bufline = f:read()
        if not bufline then
            break
        end
        if not buf then
            buf = bufline
        else
            buf  = buf .. bufline
        end
    end
    ngx.log(ngx.ERR, buf)
    return buf
end

return _M