--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/xml/xml_help.lua
--  版权说明:
--  Version: V1.0
		date: 2018-05-08
        author:Steven
         xml 转 lua表 或 lua表 转 xml
--------------------------------------------------------华丽的分割线------------------------------------------------------------

--]]
require("LuaXML")

local _M = {

}

_M.__index = _M

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function new: 根据 xml string 创建lua的xml对象
-- @param _xml_str: xml 字符串
-- @return
-- @usages:
	local xml_help = require "resty.utils.xml.xml_help"
	local xml_str = "<root><name>steven</name></root>"
	local xml_obj = xml_help:new(xml_str);
]]
function _M:new(_xml_str)
	-- body
	local xml_impl =  setmetatable({}, _M);  
	
	if _xml_str then 
		xml_impl.xml_data = xml.eval(_xml_str) 
	end  
	return xml_impl;
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function load_str: 加载 xml string
-- @param _xml_str: xml 字符串
-- @return
-- @usages:
	local xml_help = require "resty.utils.xml.xml_help"
	local xml_str = "<root><name>steven</name></root>"
	local xml_obj = xml_help:new();
	xml_obj:load_str(xml_str)

]]
function _M:load_str( _xml_str )
	-- body
	self.xml_data = xml.eval(_xml_str)
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_key: 从xml结构中查找指定key的对象内容,
-- @param _key_name: xml key
-- @param _data: xml_data对象,如果xml有多级,多级之间存在相同字段,为了查找下层字段则进行指定xml_data
-- @return
-- @usages:
	local xml_help = require "resty.utils.xml.xml_help"
	local xml_str = "<root><name>steven</name></root>"
	local xml_obj = xml_help:new(xml_str);
	xml_obj:get_key("name")

]]
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
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function set_key: 从xml结构中查找指定key的对象内容,
-- @param _key_name: xml key
-- @param _value: 新添加的xml key的值 如果添加多级结构,则需要传递lua表结构,而非xml字符串
-- @param _data: xml_data对象,如果xml有多级,多级之间存在相同字段,默认由root级下,用户可以指定其层级
-- @return
-- @usages:
	local xml_help = require "resty.utils.xml.xml_help"
	local xml_str = "<root><name>steven</name></root>"
	local xml_obj = xml_help:new(xml_str);
	xml_obj:set_key("name","hello")
]]
function _M:set_key( _key_name,_value, _data  )
	-- body
	if not _data then _data = self.xml_data end
	local ss = xml.find(_data,_key_name)
	if not ss then
		self.xml_data:append(_key_name)[1]= _value
		return
	end
	ss[1] = _value
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_att: 从xml结构中查找指定key对象的指定属性
-- @param _key_name: xml key
-- @param _att_name: xml key对应的属性名称,如果同级中存在多个则建议单独处理
-- @param _data: xml_data对象,如果xml有多级,多级之间存在相同字段,为了查找下层字段则进行指定xml_data
-- @return
-- @usages:
	local xml_help = require "resty.utils.xml.xml_help"
	local xml_str = "<root><name lan='en' sex='sss'>steven</name></root>"
	local xml_obj = xml_help:new(xml_str);
	local lan = xml_obj:get_att("name","lan")

]]
function _M:get_att( _key_name, _att_name, _data  )
	-- body
	if not _att_name then
		return nil
	end
	if not _data then _data = self.xml_data end
	local ss = xml.find(_data,_key_name)
	if not ss then return nil end
	return ss[_att_name]
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_att: 从xml结构中查找指定key的对象的指定属性
-- @param _key_name: xml key
-- @param _att_name: xml key对应的属性名称,如果同级中存在多个则建议单独处理
-- @param _att_val: xml key对应的属性值
-- @param _data: xml_data对象,如果xml有多级,多级之间存在相同字段,为了查找下层字段则进行指定xml_data
-- @return
-- @usages:
	local xml_help = require "resty.utils.xml.xml_help"
	local xml_str = "<root><name lan='en' sex='sss'>steven</name></root>"
	local xml_obj = xml_help:new(xml_str);
	xml_obj:set_att("name","lan","zh-cn")
	local lan = xml_obj:get_att("name","lan")
]]
function _M:set_att( _key_name, _att_name,_att_val, _data  )
	-- body
	if not _att_name then
		return nil
	end
	if not _data then _data = self.xml_data end
	local ss = xml.find(_data,_key_name)
	if not ss then return nil end
	ss[_att_name] = _att_val
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function save2str: 将当前xml对象转为xml字符串
-- @return
-- @usages:
	local xml_help = require "resty.utils.xml.xml_help"
	local xml_str = "<root><name>steven</name></root>"
	local xml_obj = xml_help:new(xml_str);
	local xml_str = xml_obj:save2str()
]]
function _M:save2str(  )
	-- body
	if not self.xml_data then return nil end
	return xml.str(self.xml_data)
end

return _M