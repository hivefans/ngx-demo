
local cjson = require "cjson"


local _M = {}

local MSG_ID = {
    MSG_LOGIN_C2S = 0x10, -- 登录请求 客户端-->服务端
    MSG_LOGIN_S2C = 0x20, -- 登录响应
}

function _M:new()
    local o = {}
    setmetatable(o, { __index = _M })
    return o
end

-- 消息格式转换
function _M.convert(ffi_buf, len)
    local data = {}
    for i = 1, len, 1 do
        data[i] = tonumber(ffi_buf[i - 1])
    end
    return data
end

--[[
    发送消息
    @params: 
        sock: 通讯socket对象
        msgid：消息ID
        body：数据体
]] 

function _M.send(sock, msgid, body)
    local buf = {}
    local msglen = #body
    buf[1] = string.format("%c", msgid)
    buf[2] = string.format("%c", msglen)
    for i=1, #body, 1 do
        buf[2+i] =  string.format("%c", body[i])
    end
    sock:send(buf)
end


--[[
    登录连接请求， 客户端 ==> 服务端 0x10 len=4
    码流:         0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36
    客户端->服务端 10 04 00 00 00 0F 
    服务端->客户端 20 04 00 00 00 FF 
]]
_M[MSG_ID.MSG_LOGIN_C2S] = function(sock, msgid, data)
    ngx.log(ngx.ERR, "===>> 处理登录消息: msgid=", msgid)

    -- 登录请求消息(msgid=0x10, len=4)

    -- 登录回应消息(msgid=0x20, len=0x04)
    local body = {}
    body[1] = 0x01
    body[2] = 0x01
    body[3] = 0x01
    body[4] = 0x11
    body[5] = 0xFF
    
    _M.send(sock, MSG_ID.MSG_LOGIN_S2C, body)
end

return _M
