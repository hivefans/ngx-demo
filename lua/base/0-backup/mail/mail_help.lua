---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dongyf.
--- DateTime: 2018/11/8 上午10:02
---

local mail = require 'resty.mail'

local _M = {}

--[[
    @brief:
            发送邮件
    @params:
            options 邮件服务器地址信息 用户名密码信息
                {
                    host = "smtp.gmail.com",
                    port = 587,
                    starttls = true,
                    username = "example@gmail.com",
                    password = "password",
                }
            data  邮件内容 包含发送者 接送者等信息
                {
                    from = "Master Splinter <splinter@example.com>",
                    to = { "michelangelo@example.com" },
                    cc = { "leo@example.com", "Raphael <raph@example.com>", "donatello@example.com" },
                    subject = "Pizza is here!",
                    text = "There's pizza in the sewer.",
                    html = "<h1>There's pizza in the sewer.</h1>",
                    attachments = {
                        {
                            filename = "toppings.txt",
                            content_type = "text/plain",
                            content = "1. Cheese\n2. Pepperoni",
                        },
                    },
                }
    @return:
            true
            nil
]]

_M.send_mail = function (options, data)
    local mailer, err = mail.new(options)
    if not mailer then
        ngx.log(ngx.ERR, '[email -> send_mail] 创建邮件句柄失败. err: ', err)
        return nil, '创建邮件句柄失败.'
    end

    --[[
        {
            from = "Master Splinter <splinter@example.com>",
            to = { "michelangelo@example.com" },
            cc = { "leo@example.com", "Raphael <raph@example.com>", "donatello@example.com" },
            subject = "Pizza is here!",
            text = "There's pizza in the sewer.",
            html = "<h1>There's pizza in the sewer.</h1>",
            attachments = {
                {
                    filename = "toppings.txt",
                    content_type = "text/plain",
                    content = "1. Cheese\n2. Pepperoni",
                },
            },
        }
    ]]
    local ok, err = mailer:send(data)
    if not ok then
        ngx.log(ngx.ERR, '[email -> send_mail] 发送邮件失败. err: ', err)
        return nil, '发送邮件失败.'
    else
        return true
    end
end

--[[
    @brief：
            生成邮件数据包
    @params:
            from 发送者邮箱
            to  接收者邮箱 数组
                {}
            cc  抄送者邮箱 数组
                {}
            subject 主题
            content 内容
            attachments 附件
                    {
                        type jpg | text
                        filename
                        origin_file_path
                        content
                    }
    @return:
            mail_body 邮件数据包
]]
_M.generate_mail_body = function (from, to, cc, subject, content, attachments)
    local attachment_info = {}

    local count = #attachments
    if count ~= 0 then
        for i = 1, count do
            local info = {}
            local item = attachments[i]
            if item.type == 'text' then
                info.filename = item.filename
                info.content_type = "text/plain"
                info.content = item.content
            elseif item.type == 'jpg' then
                local file = io.open(item.origin_file_path, 'rb')
                if file then
                    local pic = file:read("*all")
                    file:close()

                    info.filename = item.filename
                    info.content_type = "image/jpeg"
                    info.content = pic
                end
            end
            if info.filename then
                table.insert(attachment_info, info)
            end
        end
    end

    if #attachment_info == 0 then
        attachment_info = nil
    end

    return {
        from = from,
        to = to,
        cc = cc,
        subject = subject,
        text = content,
        attachments = attachment_info
    }
end

return _M