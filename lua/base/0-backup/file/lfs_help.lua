--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/lfs_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: lua lfs功能封装和拓展,即文件管理 usages read https://luapower.com/lfs
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]
local cjson = require "cjson"
local lfs = require("lfs")

local _M = {}

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function getCurPath: 获得当前执行程序的执行目录

-- @return 当前执行环境的目录字符串
-- @usages:
	local lfs_help = require "resty.utils.lfs_help"
	local cur_path = lfs_help.getCurPath()  -- /opt/openresty/nginx/
--
]]
-- 抑或 _M.getCurPath = lfs.currentdir
_M.getCurPath = function()
    -- body
    return lfs.currentdir();
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function getType: 判断指定目录格式,返回file, directory, link, socket,
-- named pipe, char device, block device, other

-- @param _path: 文件/目录名称 如 /xx/xx.jpg
-- @return 文件类型 file, directory, link, socket, named pipe, char device, block device, other
-- @usages:
	local lfs_help = require "resty.utils.lfs_help"
	local file_type = lfs_help.getType("/xxx/file.jpg")
--
]]
_M.getType = function(_path)
    return lfs.attributes(_path).mode
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function getSize: 获得文件的大小

-- @param _path: 文件/目录名称 如 /xx/xx.jpg
-- @return 返回当前文件的大小
-- @usages:
	local lfs_help = require "resty.utils.lfs_help"
	local file_size = lfs_help.getSize("/xxx/file.jpg")
--
]]
_M.getSize = function(_path)
    local file, err = io.open(_path)
    if not file then
        return nil
    end
    return lfs.attributes(_path).size
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function isDir: 判断地址是否为文件目录

-- @param _path: 文件/目录名称 如 /xx/xx.jpg
-- @return 判断当前文件是否为文件夹,如果为文件夹,则返回true 否则 返回 false
-- @usages:
	local lfs_help = require "resty.utils.lfs_help"
	local is_path = lfs_help.isDir("/xxx/file.jpg")
--
]]
_M.isDir = function(_path)
    local file, err = io.open(_path)
    if not file then
        return nil
    end
    return _M.getType(_path) == "directory"
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function findx: 查找字符串中的最后一个x字符出现的位置

-- @param _str: 文件/目录名称 如 /xx/xx.jpg
-- @param _char: 查找的字符对象
-- @return  位置index
-- @usages:

]]

local findx = function(_str, _char)
    for i = 1, #_str do
        if string.sub(_str, -i, -i) == _char then
            return -i
        end
    end
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function getName: 获得文件名称

-- @param _path_str: 文件/目录名称 如 /xx/xx.jpg
-- @return 返回当前目录地址中的文件名称
-- @usages:
	local lfs_help = require "resty.utils.lfs_help"
	local is_path = lfs_help.getName("/xxx/file.jpg")
--
]]
_M.getName = function(_path_str)
    return string.sub(_path_str, findx(_path_str, "/") + 1, -1)
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function getJson: 获得指定目录下的json描述的文件关系

-- @param _path: 目录名称 如 /xx/
-- @return 返回当前目录地址中的文件名称
-- @usages:
	local lfs_help = require "resty.utils.lfs_help"
	local json_files = lfs_help.getJson("/xxx/")
--
]]
_M.getJson = function(_path)
    local tJson = {};
    local index = 1;
    for file in lfs.dir(_path) do
        local p = _path .. '/' .. file
        if file ~= "." and file ~= '..' then
            if _M.isDir(p) then
                tJson[index] = {
                    name = file, fileType = _M.getType(p)
                }
            else
                tJson[index] = {
                    name = file, fileType = _M.getType(p), size = _M.getSize(p)
                }
            end
            index = index + 1
        end
    end
    return cjson.encode(tJson)
end

return _M
