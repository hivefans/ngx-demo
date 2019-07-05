
local cjson = require("cjson")


local _M = {}

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
    return _M.json_decode(buf)
end

function _M.json_encode(buf)
    return cjson.encode(buf)
end

function _M.json_decode(buf)
    if 'string' ~= type(buf) then
        return nil, "JSON decode failed, data type is not string: " .. type(buf)
    end
    local ok, data = pcall(cjson.decode, buf)
    if ok then
        return data
    else
        return nil, "JSON decode failed, buf=" .. buf
    end
end

return _M