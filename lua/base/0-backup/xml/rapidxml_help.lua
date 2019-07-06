--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/xml/rapidxml_help.lua
--  版权说明:
--  Version: V1.0
 		author:Steven
		date: 2018-05-08
        desc:基于rapidxml的luaxml功能类封装 xml 转 lua表 或 lua表 转 xml
--------------------------------------------------------华丽的分割线------------------------------------------------------------

--]]
local lub    = require 'lub'
local lut    = require 'lut'
local xml    = require 'xml'
local cjson	= require "cjson"
local _M = {

}

_M.__index = _M


--[[
-- 创建生成xml对象,该对象用于对于xml和lua表的转化和xml数据处理
-- ]]
function _M:new(_xml_str)
	-- body
	local rapid_xml =  setmetatable({}, _M);
	if _xml_str then 
		rapid_xml.xml_data = xml.load(_xml_str) 
	end  
	return rapid_xml;
end

--[[
--	save2str 将xmldata 转为xml字符串
-- ]]
function _M:load_str( _xml_str )
	-- body
	self.xml_data = xml.load(_xml_str) 

end

--[[
--	get_key 获得key 字段内容 可能为字符串,也可能为xml对象本身,用户自行进行处理
-- ]]
function _M:get_key( _key_name, _data  )
	-- body
	if not _data then _data = self.xml_data end
 	local ss = xml.find(_data,_key_name)
	if not ss then return nil end 
	if type(ss[1]) == "table" then
		return ss
	end
	return ss[1] 
end 

--[[
--	set_key 设置key数据,key数据为字符串,或者符合xml的lua表结构,字符串不可!!!!! 
-- ]]
function _M:set_key( _key_name,_value, _data  )
	-- body
	if not _data then _data = self.xml_data end
 	local ss = xml.find(_data,_key_name)
	if ss then
		ss[1] = _value 
	else
		local _xml_note = {
			xml=_key_name 
		}
		table.insert(_xml_note,_value)
		table.insert(_data,_xml_note)
	end
  	
end 

--[[
--	save2str 将xmldata 转为xml字符串 
-- ]]
function _M:save2str(  )
	-- body
	if not self.xml_data then return nil end
	return xml.dump(self.xml_data)
end

--[[
--	save2json 将xmldata 转换为json,其中注意属性作为特殊的内嵌元素存在,
	不建议转换为子键存在 
-- ]]
function _M:save2json()
	-- body
	local resT = self:save2lua()
	if not resT then return nil end
	return cjson.encode(resT)
end

--[[
--	save2lua 将xmldata 存储为 lua 普通表结构
	不建议转换为子键存在
	{"1":{"1":"SUCCESS","xml":"return_code","att":"zhang"},"2":{"xml":"return_msg","1":{"xml":"testkey","1":"child"}},"3":{"xml":"appid","1":"wxd3b8cc82b9a39267"},"4":{"xml":"mch_id","1":"1493694012"},"5":{"xml":"nonce_str","1":"NwuqdsAWM38dtVbc"},"6":{"xml":"sign","1":"DE19349DF04B06E04A5B622EB9DD604D"},"7":{"xml":"result_code","1":"SUCCESS"},"8":{"xml":"prepay_id","1":"wx140954428643595d85f766eb2073015511"},"9":{"xml":"trade_type","1":"NATIVE"},"10":{"xml":"code_url","1":"weixin:\/\/wxpay\/bizpayurl?pr=Ne0BDHZ"},"xml":"xml"}

	lua 结构中数据如下 数据按照数组的方式进行储存
	每个对象 键值为xml 即 lua的 表示键值
		属性作为该 lua的key存在 注意 如果属性中有 xml 则key将被代替，注意xml数据 如果存在请进行一次处理
 	xml的子节点按照 lua数组的方式进行存储，可能为字符串，可能为lua表结构

-- ]]
function _M:save2lua(_xml_data,_t_des)
	-- body
	_t_des = _t_des or {}
	_xml_data = _xml_data or self.xml_data
	_t_des[_xml_data["xml"]] = {}
	for k,v in pairs(_xml_data) do
		if k ~= "xml" then
			if type(v) == "table" then
				local v_data = {}
				_t_des[_xml_data["xml"]][k] = v_data
				self:save2lua(v,v_data)
			else
				_t_des[_xml_data["xml"]]=v
			end
		end
	end
	return _t_des
end


--[[
--	save2lua 将xmldata 转为xml字符串 
-- ]]
function _M:lua2xml(resp_data)
	-- body
	 local xml_data = xml.new("xml")
    for key, val in pairs(resp_data) do
        xml_data:append(key)[1] = val
    end
    return xml_data
end 


return _M