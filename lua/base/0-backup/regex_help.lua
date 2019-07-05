--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/regex_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 正则表达式相关封装,主要关于邮箱, 手机号, 身份证 等类型
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]

local _M = {}

local MOBILE_AREA_CODE_REG = {
}
MOBILE_AREA_CODE_REG["0086"] = "^[1][0-9]"

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function is_email:
-- @breif: 判断字符串是否为邮箱格式
-- @param   _email:  邮箱
-- @return   true 表示是邮箱格式 ;其余返回 表示失败;
-- @usages:
	local regex_help = require "resty.utils.regex_help"
	local email1 = "zhang@qq.com"
	local email2 = "zhangqq.com"
	local email3 = "zhang@cc"
	local res1 = regex_help.is_email(email1) true
    local res2 = regex_help.is_email(email2) false
    local res3 = regex_help.is_email(email3) false
]]
function _M.is_email(_email)
    if not _email then
        return nil
    end
    if(_email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
        return true
    else
        return false
    end
end



--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function is_user_name(_user_name):
-- @breif: 判断是否为用户账号格式
-- @param   _user_name: 用户名称 以字符串开头,6-16个字符长度
-- @return   true 验证正确 ;其余返回 表示失败;
-- @usages:
	local regex_help = require "resty.utils.regex_help"
	local user_name1 = "zhang123"
	local user_name2 = "123zhang"
    local user_name3 = "zhang@22"
	local res1 = regex_help.is_user_name(user_name1) true
    local res2 = regex_help.is_user_name(user_name2) false
    local res3 = regex_help.is_user_name(user_name3) false
]]
function _M.is_user_name(_user_name)
    if not _user_name then
        return nil
    end
    local str_len = string.len(_user_name)
    if(_user_name:match("^[A-Za-z_]+[A-Za-z0-9_]+$")) and str_len > 5 and str_len < 17 then
        return true
    else
        return false
    end
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function is_tel:
-- @breif: 判断是否为用户手机格式,当前版本只判断中国大陆地区手机号码格式
            后续版本系统将进行配置方案,用户通过area_code 进行一次对应的手机格式进行验证!!
-- @param   _tel: 手机号码
-- @param   _area_code: 地区编号

-- @return   true 验证正确 ;其余返回 表示失败;
-- @usages:
	local regex_help = require "resty.utils.regex_help"
    local tel1 = "18913826664"
    local tel2 = "28913826664"
    local tel3 = "1891326664"
    ngx.say(regex_help.is_tel(tel1)) true
    ngx.say(regex_help.is_tel(tel2)) false
    ngx.say(regex_help.is_tel(tel3)) false
]]
function _M.is_phone_number(_tel, _area_code)
    if not _tel then
        return nil
    end
    if(_tel:match("^[1][3,4,5,7,8][0-9]+")) and string.len(_tel) == 11 then
        return true
    else
        return false
    end
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function is_password:
-- @breif: 是否为sha256之后的密码格式
-- @param   _sha256ed_password:  邮箱
-- @return   true 验证正确 ;其余返回 表示失败;
-- @usages:
	local regex_help = require "resty.utils.regex_help"

]]
function _M.is_password(_sha256ed_password)
    if not _sha256ed_password  then
        return nil
    end
    if(_sha256ed_password:match("[A-Za-z0-9]+")) and string.len(_sha256ed_password) == 64 then
        return true
    else
        return false
    end
end

return _M