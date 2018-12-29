
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
    ngx.log(ngx.ERR, buf)
    return buf
end

return _M