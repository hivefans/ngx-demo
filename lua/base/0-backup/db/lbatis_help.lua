--[[
--  作者:Steven
--  日期:2018-11-19
--  文件名:lua/resty/utils/db/lbatis_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-11-19
        desc: 本文件作为db json服务的帮助函数实现,主要用于数据库返回数据集,
--  数据单条记录为需要形成1 对 n 的场景下, 其集合的数据为父子关系
--------------------------------------------------------华丽的分割线------------------------------------------------------------

Usages:

local test_records = {
    {a_id=1,b_id=1,c_id=1},
    {a_id=1,b_id=1,c_id=2},
    {a_id=1,b_id=1,c_id=3},
    {a_id=1,b_id=2,c_id=4},
    {a_id=2,b_id=3,c_id=5},
    {a_id=2,b_id=3,c_id=6},
    {a_id=2,b_id=3,c_id=7},

}

local lbatis_help = require "resty.utils.db.lbatis_help"
local clazz_name = "C"
local primary_keys = {"c_id"}
local properties = {}
local C = lbatis_help.creat_object(clazz_name,primary_keys,properties)

local clazz_name = "B"
local primary_keys = {"b_id"}
local properties = {[1]={'as',C}}
local B = lbatis_help.creat_object(clazz_name,primary_keys,properties)

local clazz_name = "A"
local primary_keys = {"a_id"}
local properties = {[1]={'bs',B}}

local A = lbatis_help.creat_object(clazz_name,primary_keys,properties)

local convertjson = lbatis_help:new(A, test_records)
print(cjson.encode(convertjson))

--]]

local function new(_self, _row_res, _g_objs)
    local properties = _self.__properties
    local primary_keys = _self.__primary_keys
    local parent_keys = _self.__parent_keys
    local primary_len = #primary_keys
    if not primary_keys then return nil end;
    -- 如果该类没有存在则
    local obj_id = _self.__clazz_name
    for i=1,primary_len do
        local primary_key = primary_keys[i]
        local primary_value = _row_res[primary_key]
        obj_id = obj_id.."::"..primary_value
    end

    local obj = _g_objs[obj_id]
    local is_first = false
    if not obj then
        obj = {__id = obj_id}

        for i=1,primary_len do
            local primary_key = primary_keys[i]
            obj[primary_key] = _row_res[primary_key]
        end
        setmetatable(obj,_self)
        is_first = true
        -- 查询父键
        local parent_id = nil
        if parent_keys then
            parent_id = _self.__clazz_name
            for i=1,#parent_keys do
                local parent_key = parent_keys[i]
                parent_id = parent_id.."::".._row_res[parent_key]
            end
            obj.__pid = parent_id
            obj.__child_list = {}
        end
    end

    for i=1,#properties do
        local property = properties[i]
        if type(property) == "table" then
            local property_name = property[1]
            local child_obj = property[2]:new(_row_res, _g_objs)
            if child_obj then
                if not obj[property_name] then
                    obj[property_name] = {}
                end
                table.insert(obj[property_name], child_obj)
            end
        else
            if is_first then
                obj[property] = _row_res[property]
            end
        end

    end
    if not _g_objs[obj_id] then
        _g_objs[obj_id] = obj
        table.insert(_g_objs,obj)
        return obj
    end
    return nil
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function creat_object: 生成用于数据库转化的基础类对象
-- @param   _clazz_name: 类名称,在当前多级关联信息下,类名称不能重复
-- @param   _primary_keys: 类外键数组,至少包含一个主键
-- @param   _properties:  属性,即属于指定该模型的属性,如该属性为对象,该字段为数组,数组[1]为当前属性所在名称,[2]为对象类
-- @return  nil 表示失败; 其他表示类对象
-- @usages:

    local lbatis_help = require "resty.utils.db.lbatis_help"

	local clazz_name = "A"
	local primary_keys = {"a_id"}
	local properties = {[1]="a_id_1"}
	local A = lbatis_help.creat_object(clazz_name,primary_keys,properties)


    local clazz_name = "B"
	local primary_keys = {"b_id"}
	local properties = {[1]="b_id_1",[2]={'as',A}}
	local B = lbatis_help.creat_object(clazz_name,primary_keys,properties)


--
]]
local function creat_object(_clazz_name, _primary_keys, _properties,_parent_keys)
    local clazz = {
        __clazz_name    = _clazz_name,
        __primary_keys  = _primary_keys,
        __properties    = _properties or { },
        __parent_keys   = _parent_keys,
        __id = nil,     -- 主键id 类名:主键1:主键2
        __pid = nil,    -- 父id 父类名:主键1:主键2 或者所属父id
        __child_list = nil
    }
    clazz.new = new
    clazz.__index = clazz
    return clazz
end

local _M = {}
_M.__index = _M
_M.creat_object = creat_object

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function creat_object: 生成用于数据库转化的基础类对象
-- @param   _clazz_name: 类名称,在当前多级关联信息下,类名称不能重复
-- @param   _records: 数据库结果集
-- @return  nil 表示失败; 返回其他处理的结果，包含
    collect.res_list  -- 包含关系的结构
    collect.obj_list  -- 所有对象数组
    collect.pc_list   -- 父子关系的结果 集合
-- @usages:
    local test_records = {
        {a_id=1,b_id=1,c_id=1},
        {a_id=1,b_id=1,c_id=2},
        {a_id=1,b_id=1,c_id=3},
        {a_id=1,b_id=2,c_id=4},
        {a_id=2,b_id=3,c_id=5},
        {a_id=2,b_id=3,c_id=6},
        {a_id=2,b_id=3,c_id=7},

    }

    local lbatis_help = require "resty.utils.db.lbatis_help"
    local clazz_name = "C"
    local primary_keys = {"c_id"}
    local properties = {}
    local C = lbatis_help.creat_object(clazz_name,primary_keys,properties)

    local clazz_name = "B"
    local primary_keys = {"b_id"}
    local properties = {[1]={'as',C}}
    local B = lbatis_help.creat_object(clazz_name,primary_keys,properties)

    local clazz_name = "A"
    local primary_keys = {"a_id"}
    local properties = {[1]={'bs',B}}

    local A = lbatis_help.creat_object(clazz_name,primary_keys,properties)

    local convertjson = lbatis_help:new(A, test_records)
    print(cjson.encode(convertjson))



    local lbatis_help = require "resty.utils.db.lbatis_help"
local collects = {
    {a_id=1,b_p=1,p_id=0},
    {a_id=2,b_p=21,p_id=1},
    {a_id=3,b_p=22,p_id=1},
}
local clazz_name = "A"
local primary_keys = {"a_id"}
local properties = {[1]="b_p"}
local parent_keys = {[1]="p_id"}
local A = lbatis_help.creat_object(clazz_name,primary_keys,properties,parent_keys)

    local convertjson = lbatis_help:new(A, collects)
    print(cjson.encode(convertjson))
--
]]

local cjson = require "cjson"



function _M:new( _clazz, _records )
    local obj_list = {
    }
    local res_list = {
    }
    local collect = setmetatable({},self)
    for i = 1, #_records do
        local record = _records[i]
        local res = _clazz:new(record, obj_list)
        if res then
            table.insert(res_list, res)
        end
    end
    collect.res_list = res_list
    collect.obj_list = obj_list
    collect.pc_list = {}
    ---- 父子关系进行关联

    for i=#obj_list,1,-1 do
        local obj = obj_list[i]
        local pid = obj.__pid;
        if pid and obj_list[pid] then
            table.insert(obj_list[pid].__child_list,obj)
            table.remove(obj_list,i)
        else
            table.insert(collect.pc_list,obj)
        end
    end

    return collect
end



local cjson = require "cjson"
function _M:order_parent()



end

return _M