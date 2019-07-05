--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/crypto/sign_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 关于签名相关应用帮助类,主要提供字段的字典排序,字段组装等功能函数
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]
local cjson = require "cjson"
local rsa = require "resty.utils.crypto.rsa"

local _M = {}

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function sign_compare: 字段比较函数,从第一个字符串开始对比,如果第一个字符串相等则进行下一位置的比较;如果某个其中一个字符串是指定用户字符串则比较长度
长度长的往后排序,注意lua的比较函数的返回以小于或者大于为比较对象;只排序单层表
-- @param v1:字符串1
-- @param v2:字符串2
-- @return boolean:如果true：表示小于，false:表示大于等于  默认lua排序为从小到大 返回值 小于返回true; >= 返回false ;
			如果从大到小则 小于的时候返回 false; 其他情况返回 true
-- @usages:

]]
local sign_compare = function ( v1,v2 ) 
	-- body
    local v1_str = v1[1]
    local v2_str = v2[1]

    local iLen_1 = #v1_str
    local iLen_2 = #v2_str
    local iLenLit = iLen_1 > iLen_2 and iLen_2 or iLen_1
    local _char_index = 1

    while _char_index <= iLenLit do
        if string.sub(v1_str,_char_index,_char_index) < string.sub(v2_str,_char_index,_char_index) then 
            return true
        elseif string.sub(v1_str,_char_index,_char_index) > string.sub(v2_str,_char_index,_char_index) then 
            return false
        else
            _char_index = _char_index + 1
        end 
    end 

    if iLen_1 < iLen_2 then  
        return true
    else 
        return false
    end
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function make_sign_str_sort: make _unsigned_map(lua key-value table) to the sorted str with key1=value1&key2=value2
								PS:函数将修改入参的数据类型,注意!!!
-- @param _unsigned_map: the data map of user
-- @return string: the signed string from _unsigned_map with the "key1=value1&key2=value2" style
-- @usages:
]]
_M.make_sign_str_sort = function( _unsigned_map )
	-- body
	local t_src = {}
	local index = 0
	-- make it to array
	for k,v in pairs(_unsigned_map) do
		index = index + 1
		t_src[index] = {k,v}
	end
	-- sort
	table.sort(t_src,sign_compare)

	-- put together
	local signed_str = ""
	for i=1,#t_src  do
		local item = t_src[i]
		local val = item[2]
		if  type(val) == "table" then
			local str_temp =  cjson.encode(val)
			_unsigned_map[item[1]] =str_temp
			signed_str = signed_str..item[1].."="..str_temp
		else
			signed_str = signed_str..item[1].."="..val
		end
		if i ~= index then
			signed_str = signed_str.."&"
		end
	end 
	return signed_str
end


--[[
make_urlencode_sort_str 创建排序之后的字符串,该字符串为的每个字段需要进行一次urlencode!!!!!
PS:函数将修改入参的数据类型,注意!!!
]]
_M.make_urlencode_sort_str = function( _params )
	-- body
	local t_src = {}
	local index = 0
	-- make it to array
	for k,v in pairs(_params) do
		index = index + 1
		t_src[index] = {k,v}
	end
	-- sort
	table.sort(t_src,sign_compare)

	-- put together
	local signed_str = ""
	for i=1,#t_src  do
		local item = t_src[i]
		local val = item[2]
		if  type(val) == "table" then
			local str_temp = ngx.escape_uri(cjson.encode(t_src[i][2]))
			_unsigned_map[item[1]] =str_temp
			signed_str = signed_str..item[1].."="..str_temp
		else
			signed_str = signed_str..item[1].."="..ngx.escape_uri(t_src[i][2])
		end
		if i ~= index then
			signed_str = signed_str.."&"
		end
	end
	return signed_str
end

--[[
将参数打包成key=value&key=value的格式
]]
_M.make_params_url = function( _params )
	-- body
	local signed_str = ""
	local index = 0
	-- make it to array
	for k,v in pairs(_params) do
		index = index + 1
		if index > 1 then
			signed_str = signed_str.."&"
		end
		if  type(v) == "table" then
			signed_str = signed_str..k.."="..cjson.encode(v)
		else
			signed_str = signed_str..k.."="..v
		end
	end
	return signed_str
end

--[[
make_urlencode_params_url a=b&c=d参数组合 该字符串为的每个字段需要进行一次urlencode!!!!!
]]
_M.make_urlencode_params_url = function( _params )
	-- body
	local signed_str = ""
	local index = 0
	-- make it to array
	for k,v in pairs(_params) do
		index = index + 1
		if index > 1 then
			signed_str = signed_str.."&"
		end
		if  type(v) == "table" then
			signed_str = signed_str..k.."="..ngx.escape_uri(cjson.encode(v))
		else
			signed_str = signed_str..k.."="..ngx.escape_uri(v)
		end
	end
	return signed_str
end

--[[
-- rsa_sign 用指定密钥签名字符串,返回base64 字符串
--
-- example
   	local sign_help = require "pay.model.sign_help"
   	local _unsign_str = "hello"
   	local _private_key = '-----BEGIN RSA PRIVATE KEY-----  xxxxx -----BEGIN RSA PRIVATE KEY-----'
   	local _algorithm = "SHA256"
    local base64_signed_str = sign_help.rsa_sign(_unsign_str, _private_key ,_algorithm )

-- @param  _unsign_str 		未加密的字符串
-- @param  _private_key		私钥key
-- @param  _algorithm  		hash方式 默认使用SHA256
-- @return  base64编码之后的字符串 或者 nil 代表错误
--]]
_M.rsa_sign = function(_unsign_str,_private_key, _algorithm)
	if not _algorithm then _algorithm = "SHA256" end
	local private_cli = rsa:new_rsa_private(_private_key, _algorithm)
	if not private_cli then return nil end
	local signed_str = private_cli:sign(_unsign_str)
	return ngx.encode_base64(signed_str)
end


--[[
-- rsa_verify 使用RSA公钥匙验证 加密字段, 成功返回true; 其他表示错误
--  
-- example 
   	local sign_help = require "pay.model.sign_help"
   	local _sign_str = "xxxx"
   	local _public_key = '-----BEGIN RSA PUBLIC KEY-----  xxxxx -----END RSA PUBLIC KEY-----'
   	local _algorithm = "SHA256"
    local res = sign_help.rsa_verify(_sign_str, _public_key ,_algorithm )
	
-- @param  _unsign_str 		未加密的字符串
-- @param  _signed_str 		签名字符串
-- @param  _public_key		对于私钥签名的公钥 key
-- @param  _algorithm  		hash方式 默认使用SHA256
-- @return true  表示成功; false or nil  表示失败
--]]
_M.rsa_verify = function(_unsign_str, _signed_str, _public_key, _algorithm)
	if not _algorithm then _algorithm = "SHA256" end

	local public_cli =  rsa:new_rsa_public(_public_key, _algorithm)
	if not public_cli then return nil end
	local res,err = public_cli:verify(_unsign_str,_signed_str)
	return res
end


--[[
-- make_rsa_sign_sort 将lua数据结构表进行签名操作,字段为表的数据自动转为字符串。PS:函数将修改入参的数据类型,注意!!!
-- 签名字符串为base64
-- example
   	local sign_help = require "pay.model.sign_help"
   	local _t_src = {}
   	local _private_key = '-----BEGIN RSA PRIVATE KEY-----  xxxxx -----BEGIN RSA PRIVATE KEY-----'
   	local _algorithm = "SHA256"
    local base64_signed_str = sign_help.make_rsa_sign_sort(_t_src, _private_key ,_algorithm )

-- @param  _t_src 		未加密的字符串
-- @param  _private_key		私钥key
-- @param  _algorithm  		hash方式 默认使用SHA256
-- @param  _sign_key_name	存放签名字符串的表key名称
-- @return  返回添加rsa签名的key=value&key=value的字符串 nil 表示失败
--]]
_M.make_rsa_sign_sort = function(_t_src, _private_key, _algorithm, _sign_key_name)
	if not _algorithm then _algorithm = "SHA256" end
	local private_cli = rsa:new_rsa_private(_private_key, _algorithm)
	if not private_cli then
		ngx.log(ngx.ERR,"-------new_rsa_private error,rsa 私钥格式不正确,请检查!")
		return nil
	end

	local unsign_str = _M.make_sign_str_sort(_t_src)
	local signed_str = private_cli:sign(unsign_str)
	local signed_base64_str = ngx.encode_base64(signed_str)
	_t_src[_sign_key_name or "sign"] = signed_base64_str
	return _M.make_urlencode_params_url(_t_src)
end


--[[
-- make_rsa_verify 使用RSA公钥匙验证 加密字段, 成功返回true; 其他表示错误
-- 签名字符串为base64
-- example
   	local sign_help = require "pay.model.sign_help"
   	local _sign_str = "xxxx"
   	local _public_key = '-----BEGIN RSA PUBLIC KEY-----  xxxxx -----END RSA PUBLIC KEY-----'
   	local _algorithm = "SHA256"
    local res = sign_help.make_rsa_verify(_sign_str, _public_key ,_algorithm )

-- @param  _t_src 			待签名数据结构
-- @param  _public_key		对于私钥签名的公钥 key
-- @param  _algorithm  		hash方式 默认使用SHA256
-- @param  _sign_key_name	存放签名字符串的表key名称
-- @return true  表示成功; false or nil  表示失败
--]]
_M.make_rsa_verify = function(_t_src, _public_key, _algorithm, _sign_key_name)
	if not _algorithm then _algorithm = "SHA256" end
	local signed_str = ngx.decode_base64(_t_src.sign)
	_t_src[_sign_key_name or "sign"] = nil
	local unsign_str = _M.make_sign_str_sort(_t_src)
	local public_cli =  rsa:new_rsa_public(_public_key, _algorithm)
	if not public_cli then return nil end
	local res,err = public_cli:verify(unsign_str,signed_str)
	return res
end

return _M