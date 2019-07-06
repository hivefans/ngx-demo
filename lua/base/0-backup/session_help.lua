--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/session_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: openresty session&cookie 功能服务
        完成web平台的session服务
        需要在对应的接口进行状态管理
--------------------------------------------------------华丽的分割线------------------------------------------------------------
    local session_help = require("resty.utils.session_help")
    -- 设置
    local res = session_help.set_attribute("user_name","zhang")
    local user_name = session_help.get_attribute("user_name")


--]]

local uuid_help = require "resty.utils.uuid_help"
local SESSION_SECRET = SESSION_SECRET

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function set_attribute(_key,_value):
-- @breif: 用户session管理
-- @param   _key: 存储到session中的数据key,新添加的数据覆盖上一次存储的数据,注意!!
-- @param   _value: 存储的数据,可以是数字/字符串/LUA表结构
-- @return  true 表示成功 ;其余返回 表示失败;
-- @usages:
    local session_help = require("resty.utils.session_help")
    -- 设置
    local res = session_help.set_attribute("user_name","zhang")
]]
local function set_attribute(_key,_value)
    local session,err = require "resty.session".start({secret=SESSION_SECRET})
    if not session then
        ngx.log(ngx.ERR, err)
    end

    session.data[_key] = _value
    session:save();
    return true
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_attribute(_key)
-- @breif:获取存储在session中的数据
-- @param: _key     session中的数据的key
-- @param: _value   存储的数据,可以是数字/字符串/纯表结构
-- @return:  true   表示成功 ;其余返回 表示失败;
-- @usages:
	local session_help = require("resty.utils.session_help")
    -- 设置
    local res = session_help.get_attribute("user_name")
]]
local function get_attribute(_key)
    local session,err = require "resty.session".open({secret=SESSION_SECRET})
    return  session.data[_key]
end


-------------------------------------------------------华丽的分割线------------------------------------------------------------


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_session_id()
-- @breif:获取存储在session中的ID字段,经过一次base64编码
-- @param: _key     session中的数据的key
-- @param: _value   存储的数据,可以是数字/字符串/纯表结构
-- @return: true    表示成功 ;其余返回 表示失败;
-- @usages:
	local session_help = require("resty.utils.session_help")

    local session_id = session_help.get_session_id("user_name")
]]
local function get_session_id()
    local session,err = require "resty.session".open({secret=SESSION_SECRET})
    if session then
        return ngx.encode_base64(session.id)
    end
end




--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function destroy()
-- @breif:释放当前session环境
-- @return:
-- @usages:
	l    local session_help = require("resty.utils.session_help")

    session_help.destroy()
]]
local function destroy()
    local session,err = require "resty.session".start({secret=SESSION_SECRET})
    if session then
        session:destroy()
    end
end


local _M = {}
-- one content only call one time!!!!
_M.set_attribute = set_attribute
_M.get_attribute = get_attribute

_M.SESSION_SECRET = SESSION_SECRET
_M.get_session_id = get_session_id
_M.destroy = destroy


return _M