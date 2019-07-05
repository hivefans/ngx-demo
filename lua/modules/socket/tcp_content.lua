---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by lixy.
--- DateTime: 2018/5/27 12:06
---

--[[
    使用说明
    nginx.conf 文件添加如下配置
    stream {
        # 定义 TCP server 服务:
        server {
            # 监听端口
            listen 9001;
            # 处理消息文件
            content_by_lua_file lua/socket/tcp_content.lua;
        }
    }

    测试： 
        TCP客户端发送码流： 10 04 00 00 00 0F
        TCP服务的回应码流： 20 05 01 01 01 11 FF 
]]


local ffi = require "ffi"
local cjson = require "cjson"

local tcp_handler = require("lua.modules.socket.tcp_handler")

local sock = ngx.req.socket()
ngx.log(ngx.ERR, "\n\n****************************************************************** TCP client connect.")

-- TCP消息处理对象
local handler = tcp_handler:new()

--[[ ==============================================================================================
    TCP 连接处理
    TCP 通讯数据格式：  
        消息ID | 消息长度 | 数据区 
]]

-- 消息头长度定义，2位，第一位表示消息ID，第二位表示数据体长度
local head_len = 2 

-- 缓冲区
local ffi_buf = ffi.new("unsigned char[?]", 128)

-- 循环接受处理TCP消息
while true do
    if not sock then
        ngx.log(ngx.ERR, "===>> 系统错误, 获取通讯sock对象失败")
        return
    end

    -- sock:settimeout(0.1)
    -- 读取消息头
    local buf, err = sock:receive(2)
    if (buf) then
        ngx.log(ngx.ERR, "[TCP]收到消息")
        
        -- 解析消息头数据，转换成LUA数据（number 数组）
        ffi.copy(ffi_buf, buf, head_len)

        -- 消息头第一位: 消息ID
        local msgid = tonumber(ffi_buf[0])
        -- 消息头第二位: 消息体长度
        local msglen = tonumber(ffi_buf[1])
        ngx.log(ngx.ERR, string.format("msgid: %s, length=%s", msgid, msglen))

        -- 读取消息体
        local msgbuf, err = sock:receive(msglen)
        if msgbuf then
            -- 解析数据体
            ffi.copy(ffi_buf, msgbuf, msglen)
            local body = tcp_handler.convert(ffi_buf, msglen)
            
            -- 打印消息内容
            local s = ""
            for i=1, msglen, 1 do
                if s ~= "" then s = s .. ' ' end
                s = s .. string.format("0x%02X", body[i])
            end
            s = '[' .. s .. ']'
            ngx.log(ngx.ERR, "msg body: ", s)

            -- 从消息处理对象获取消息ID对应的处理函数
            local handler = tcp_handler[msgid]
            if handler then
                handler(sock, msgid, body)
            else
                ngx.log(ngx.ERR, "未定义消息处理函数：msgid=", msgid)
            end
        else
            ngx.log(ngx.ERR, "Read data: buf_data is nil")
        end
    else
        if (err == "closed") then
            ngx.log(ngx.ERR, "TCP closed")
            if (handler and handler.close) then
                handler.close(handler)
            end
            break
        elseif ("timeout" == err) then
        else
            ngx.log(ngx.ERR, "Read data error: buf=nil, err=" .. err or "nil")
        end
    end
end

ngx.log(ngx.ERR, "TCP thread end")