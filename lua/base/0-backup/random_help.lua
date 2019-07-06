--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/random_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: lua的随机数计算,该计算主要涉及给予指定比例权重的数组，返回选择随机值的对象index
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]

local _M = {}

_M.__index = _M

-- 设置随机种子
math.randomseed(os.time())
--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function random: 返回当前指定权重下的, 随机返回的权重对象位置, 该随机为人品随机法
-- @param   _weight_array: 权重有效数组
-- @return  返回当前权限下面的随机到的权重对象的index
-- @usages:
	local random_help = require "resty.utils.random_help"
	local _weight_array = {1,1,2,6} -- 权重的大小为总大小为10,4个对象的比例分别为10%,10%,20%,60%
	local wei_index = random_help.random(_weight_array)	-- 返回值即为有效的对象值

]]
_M.random = function(_weight_array)
	local MAX_NUMBER = 1000000
	local threshold_map = {} -- 阀值map
	local maxWeight = 0
	local len = table.getn(_weight_array)
	for i=1,len  do 
		maxWeight = maxWeight + _weight_array[i]
		threshold_map[i] = maxWeight
	end

	local randomIndex = math.random(1,MAX_NUMBER)
	for i=1,len do 
		local threshold =  threshold_map[i] / maxWeight
		if randomIndex <= threshold*MAX_NUMBER then
			return i
		end
	end
	return len
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function pseudorandom: 返回当前指定权重下的, 随机返回的权重对象位置, 伪随机实现-- 暂未实现
-- @param   _weight_array: 权重有效数组
-- @return  返回当前权限下面的随机到的权重对象的index
-- @usages:
	local random_help = require "resty.utils.random_help"
	local _weight_array = {1,1,2,6} -- 权重的大小为总大小为10,4个对象的比例分别为10%,10%,20%,60%
	local wei_index = random_help.random(_weight_array)	-- 返回值即为有效的对象值

]]
_M.pseudorandom = function(_weight_array)
	local MAX_NUMBER = 1000000
	local threshold_map = {} -- 阀值map
	local maxWeight = 0
	local len = table.getn(_weight_array)
	for i=1,len  do
		maxWeight = maxWeight + _weight_array[i]
		threshold_map[i] = maxWeight
	end

	local randomIndex = math.random(1,MAX_NUMBER)
	for i=1,len do
		local threshold =  threshold_map[i] / maxWeight
		if randomIndex <= threshold*MAX_NUMBER then
			return i
		end
	end
	return len
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function random_by_len: 根据给定的范围 返回该范围下的随机index位置比如6 则返回 100000 - 999999的有效值
-- @param   _weight_array: 权重有效数组
-- @return  返回当前权限下面的随机到的权重对象的index
-- @usages:
	local random_help = require "resty.utils.random_help"
	local wei_index = random_help.random_by_len(6)	-- 888899

]]
_M.random_by_len = function( _len )
	if not _len then _len = 6 end
	local maxWeight = math.pow(10,_len)  - 1
	local tWeight = math.pow(10,_len-1)
	return math.random(tWeight,maxWeight)
end


-- 随机字符串
local CHARS_ARRAY="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$_"
local CHARS_ARRAY_LEN = string.len(CHARS_ARRAY)

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function random_chars: 返回指定长度的随机字符串
-- @param   _bits: 字符位数
-- @return  返回随机字符串
-- @usages:
	local random_help = require "resty.utils.random_help"
	local random_str = random_help.random_chars(6)	-- vyea3q

]]
_M.random_chars = function ( _bits  )
	local random_str = ""
    for i=1, _bits do
		local index = math.random(1,CHARS_ARRAY_LEN)
		random_str = random_str..string.sub(CHARS_ARRAY, index, index)
	end
    return random_str
end


-- 随机数字字符串
local NUMBER_ARRAY={0,1,2,3,4,5,6,7,8,9}
local NUMBER_ARRAY_LEN = #NUMBER_ARRAY


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function random_numbers: 返回指定长度数组的数字随机值
-- @param   _bits: 随机数字数组位数
-- @return  返回随机字符串
-- @usages:
	local random_help = require "resty.utils.random_help"
	local random_numbs = random_help.random_numbers(6) [4,2,1,6,0,9]

]]
_M.random_numbers = function ( _bits  )
    -- body 
    if not _bits then _bits = 6 end
    local res = {}
    for i=1, _bits do
		local index = math.random(1,NUMBER_ARRAY_LEN) 
		res[i] = NUMBER_ARRAY[index]
	end
	return res
end



return _M