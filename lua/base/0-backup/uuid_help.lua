--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/uuid_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 关于uuid的简单封装,主要用于各式各样的uuid唯一键值的场合,可用于其他多进制的数据转化形成唯一编码信息的输出情形
					根据系统多个版本进行升级使用
					uuid_help.lua  依赖jit-uuid , lua-resty-UUID( 扩展了64进制和94进制, 94进制作为系统唯一code存储使用,不作为用户级使用,注意数据不可逆

--------------------------------------------------------华丽的分割线------------------------------------------------------------

--]]
local jit_uuid = require 'resty.jit-uuid'
local uuid = require 'resty.uuidx'

local _M = {}

_M.__index = _M
jit_uuid.seed()

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function new: 创建一个uuid对象,该对象主要用于创建指定的命名空间,方便使用
-- @param   _uuid_namespace: uuid 命名空间
-- @return
-- @usages:
	local uuid_help = require "resty.utils.uuid_help"
	local file_uuid_namespace = "8a4072bd-03bc-4694-b2dd-55f028f16f37"
	local uuid_imp = uuid_help:new(file_uuid_namespace);
	uuid_imp:get64();--返回当前64进制,如果没有uuid_str则系统通过随机址产生唯一id
]]
function _M:new(_uuid_namespace)
	-- body
	local uuid_impl =  setmetatable({uuid_namespace = _uuid_namespace}, _M);

	return uuid_impl;
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get64: 获得64进制的uuid的组成格式 一般用于文件命名,网页地址或其他区域 长度一般为21-22字节
-- @param   _str:  邮箱
-- @return  返回64进制处理的编码信息
-- @usages:
	local uuid_help = require "resty.utils.uuid_help"
	local file_uuid = "8a4072bd-03bc-4694-b2dd-55f028f16f37"
	local uuid_imp = uuid_help:new(file_uuid);
	uuid_imp:get64();--返回当前64进制,如果没有uuid_str则系统通过随机址产生唯一id
]]
function _M:get64( _str )
	-- body 
	local new_uuid = nil
	if self.uuid_namespace and _str then
		-- local newuuid = uuid.generate_v5(self.uuid_str,_str)
		new_uuid = jit_uuid.generate_v5(self.uuid_namespace,_str)
	else
    -- local u1 = uuid()             ---> __call metamethod
    -- local u2 = uuid.generate_v4()
		new_uuid = jit_uuid.generate_v4()
	end
	 
	return uuid.gen64hex(new_uuid);

end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get94: 获得94进制的uuid的组成格式 一般用于文件命名,网页地址或其他区域 长度一般为21-22字节
-- @param   _str:  邮箱
-- @return  返回64进制处理的编码信息
-- @usages:
	local uuid_help = require "resty.utils.uuid_help"
	local file_uuid = "8a4072bd-03bc-4694-b2dd-55f028f16f37"
	local uuid_imp = uuid_help:new(file_uuid);
	uuid_imp:get94();--返回当前94进制,如果没有uuid_str则系统通过随机址产生唯一id
]]
function _M:get94( _str )
	-- body
	local new_uuid = nil

	if self.uuid_namespace and _str then
		-- local newuuid = uuid.generate_v5(self.uuid_str,_str)
		new_uuid = jit_uuid.generate_v5(self.uuid_namespace,_str)
	else
		-- jit_uuid.seed()
		new_uuid = jit_uuid.generate_v4()
	end 

	return uuid.gen94hex(new_uuid);
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_uuid: 获得一个标准的uuid字符串 "8a4072bd-03bc-4694-b2dd-55f028f16f37"
-- @return  uuid_str
-- @usages:
	local uuid_help = require "resty.utils.uuid_help"
	uuid_help.get_uuid();--返回当前64进制,如果没有uuid_str则系统通过随机址产生唯一id
]]
function _M.get_uuid()
	-- body
	-- jit_uuid.seed()
	return jit_uuid.generate_v4()
end




return _M


