--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/string_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 字符串相关功能封装,主要关于字符转化
--------------------------------------------------------华丽的分割线------------------------------------------------------------
    local string_help = require("resty.utils.string_help")
    -- 设置

--]]

local _M = {}

--将字符串按照指定字符分割，并将子串存入table并返回
function _M.string_split(str, split_char)
    local sub_str_tab = {};

    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            local size_t = table.getn(sub_str_tab)
            table.insert(sub_str_tab,size_t+1,str);
            break;
        end

        local sub_str = string.sub(str, 1, pos - 1);
        local size_t = table.getn(sub_str_tab)
        table.insert(sub_str_tab,size_t+1,sub_str);
        local t = string.len(str);
        str = string.sub(str, pos + 1, t);
    end
    return sub_str_tab;
end

return _M