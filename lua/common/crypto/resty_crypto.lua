--[[
]]

local str = require "resty.string"
local resty_md5 = require "resty.md5"
local resty_sha1 = require "resty.sha1"
local resty_sha224 = require "resty.sha224"
local resty_sha256 = require "resty.sha256"
local resty_sha384 = require "resty.sha384"
local resty_sha512 = require "resty.sha512"


local _M = {}


--[[
	md5 加密
	@param  buf	 待处理的字符串
	@return nil,表示失败;非 nil 表示md5 hash之后的数据
]] 
function _M.md5( buf )
	local md5 = resty_md5:new()
	md5:update(buf)
	local digest = md5:final() 
	return str.to_hex(digest)  
end

--[[
	sha1 加密
	@param  buf	 待处理的字符串
	@return nil,表示失败;非 nil 表示sha1 hash之后的数据
]] 
function _M.sha1( buf	 )
	local sha1 = resty_sha1:new()
	sha1:update(buf	)
	local digest = sha1:final() 
	return str.to_hex(digest)  
end    

--[[
	sha224 加密
	example 
   	同md5
	@param  buf	 待处理的字符串
	@return nil,表示失败;非 nil 表示 sha224 hash之后的数据
]] 
function _M.sha224( buf	 )
	local sha224 = resty_sha224:new()
	sha224:update(buf	)
	local digest = sha224:final() 
	return str.to_hex(digest)  
end 


--[[
	sha224 加密
	example 
   	同md5
	@param  buf	 待处理的字符串
	@return nil,表示失败;非 nil 表示 sha224 hash之后的数据
]] 
function _M.sha256( buf	 )
	local sha256 = resty_sha256:new()
	sha256:update(buf	)
	local digest = sha256:final() 
	return str.to_hex(digest)  
end 


--[[
	sha224 加密
	example 
   	同md5
	@param  buf	 待处理的字符串
	@return nil,表示失败;非 nil 表示 sha224 hash之后的数据
]] 
function _M.sha384( buf	 )
	local sha384 = resty_sha384:new()
	sha384:update(buf	)
	local digest = sha384:final() 
	return str.to_hex(digest)  
end 


--[[
	sha224 加密
	example 
   	同md5
	@param  buf	 待处理的字符串
	@return nil,表示失败;非 nil 表示 sha224 hash之后的数据
]] 
function _M.sha512( buf	 )
	local sha512 = resty_sha512:new()
	sha512:update(buf	)
	local digest = sha512:final() 
	return str.to_hex(digest)  
end 


return _M