--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:hash_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  MD5 SHA1 SHA256 等各种HASH功能函数封装
--  
--]]

local str = require "resty.string"
local resty_md5 = require "resty.md5"
local resty_sha1 = require "resty.sha1"
local resty_sha224 = require "resty.sha224"
local resty_sha256 = require "resty.sha256"
local resty_sha384 = require "resty.sha384"
local resty_sha512 = require "resty.sha512"




local _M = {}



--[[
-- md5 加密
-- example 
   	local hash_help = require "common.hash_help"
	local str="md5str"
	local md5str = hash_help(str)

-- @param  _str 待处理的字符串
-- @return nil,表示失败;非 nil 表示md5 hash之后的数据
--]] 
function _M.md5( _str )
	local md5 = resty_md5:new()
	md5:update(_str)
	local digest = md5:final() 
	return str.to_hex(digest)  
end

--[[
-- sha1 加密
-- example 
   	同md5
-- @param  _str 待处理的字符串
-- @return nil,表示失败;非 nil 表示sha1 hash之后的数据
--]] 
function _M.sha1( _str )
	local sha1 = resty_sha1:new()
	sha1:update(_str)
	local digest = sha1:final() 
	return str.to_hex(digest)  
end    

--[[
-- sha224 加密
-- example 
   	同md5
-- @param  _str 待处理的字符串
-- @return nil,表示失败;非 nil 表示 sha224 hash之后的数据
--]] 
function _M.sha224( _str )
	local sha224 = resty_sha224:new()
	sha224:update(_str)
	local digest = sha224:final() 
	return str.to_hex(digest)  
end 


--[[
-- sha224 加密
-- example 
   	同md5
-- @param  _str 待处理的字符串
-- @return nil,表示失败;非 nil 表示 sha224 hash之后的数据
--]] 
function _M.sha256( _str )
	local sha256 = resty_sha256:new()
	sha256:update(_str)
	local digest = sha256:final() 
	return str.to_hex(digest)  
end 


--[[
-- sha224 加密
-- example 
   	同md5
-- @param  _str 待处理的字符串
-- @return nil,表示失败;非 nil 表示 sha224 hash之后的数据
--]] 
function _M.sha384( _str )
	local sha384 = resty_sha384:new()
	sha384:update(_str)
	local digest = sha384:final() 
	return str.to_hex(digest)  
end 


--[[
-- sha224 加密
-- example 
   	同md5
-- @param  _str 待处理的字符串
-- @return nil,表示失败;非 nil 表示 sha224 hash之后的数据
--]] 
function _M.sha512( _str )
	local sha512 = resty_sha512:new()
	sha512:update(_str)
	local digest = sha512:final() 
	return str.to_hex(digest)  
end 


return _M