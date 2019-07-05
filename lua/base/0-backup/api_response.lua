--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/api_response.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc:本文件主要用于初始化系统api的数据返回接口数据的初始化
-- 						比如系统默认返回的数据为json格式, 本格式主要用于包含返回编号
-- 						解释信息，以及需要返回的数据结体
--------------------------------------------------------华丽的分割线------------------------------------------------------------

--]]
local cjson = require "cjson"
local ZS_ERROR_CODE = require "conf.error_conf".ZS_ERROR_CODE

local _M = {}
local _SUCCESS_DATA = {code = ZS_ERROR_CODE.RE_SUCCESS, msg = "data success",data = {}};
local _FAILED_DATA = {code = ZS_ERROR_CODE.RE_FAILED,	msg = "data failed",data = {}};
_M.ZS_ERROR_CODE = ZS_ERROR_CODE
--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function response: create a table for api service response with code/msg/data struct
-- @param _err_code: the error code , 200 is success others are error
-- @param _msg: the error info resume
-- @param _data: valued response data
-- @return
-- @usages:
--	local ZS_ERROR_CODE = require "conf.error_conf"
--	local api_response = require "resty.utils.api_response"
--	local res_data = {name="steven",sex=1}
--  local response_str = api_response.response(ZS_ERROR_CODE.RE_SUCCESS, "opt success!", res_data) --{"code":200,"msg":"opt success!","data":{"sex":1,"name":"steven"}}
--

]]

function _M.response(_err_code , _msg , _data)
	local api_response_data = {
		code = _err_code or ZS_ERROR_CODE.PARAM_NULL_ERR,
		msg = _msg,
		data = _data,
	};
	return cjson.encode(api_response_data)
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function response_ok: create a success table for api service response;default code is ZS_ERROR_CODE.RE_SUCCESS

-- @param _msg: the error info resume
-- @param _data: valued response data
-- @return
-- @usages:
--	local ZS_ERROR_CODE = require "conf.error_conf"
--	local api_response = require "resty.utils.api_response"
--	local res_data = {name="steven",sex=1}
--  local response_str = api_response.response_ok(res_data,"opt success!") --{"code":200,"msg":"opt success!","data":{"sex":1,"name":"steven"}}
--
]]

function _M.response_ok(_data , _msg )
	local api_response_data = {
		code = ZS_ERROR_CODE.RE_SUCCESS,
		msg = _msg,
		data = _data,
	};
	return cjson.encode(api_response_data)
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function response_err: create a err table for api service response;default code is ZS_ERROR_CODE.RE_FAILED

-- @param _msg: the error info resume
-- @param _data: valued response data
-- @return
-- @usages:
--	local ZS_ERROR_CODE = require "conf.error_conf"
--	local api_response = require "resty.utils.api_response"
--	local res_data = {name="steven",sex=1}
--  local response_str = api_response.response_err("opt error!",res_data) --{"code":400,"msg":"opt error!","data":{"sex":1,"name":"steven"}}
--
]]
function _M.response_err(_msg, _data)
	local api_response_data = {
		code = ZS_ERROR_CODE.RE_FAILED,
		msg = _msg,
		data = _data,
	};
	return cjson.encode(api_response_data)
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function system_error: create a system_err table for api service response;default code is ZS_ERROR_CODE.SYSTEM_ERR

-- @param _msg: the error info resume
-- @return
-- @usages:
--	local ZS_ERROR_CODE = require "conf.error_conf"
--	local api_response = require "resty.utils.api_response"
--	local res_data = {name="steven",sex=1}
--  local response_str = api_response.system_error() --{"code":401,"msg":"system busy,please try after a moment!"}
--
]]
function _M.system_error(_msg)
	-- body
	return _M.response(ZS_ERROR_CODE.SYSTEM_ERR,_msg or 'system busy,please try after a moment!')
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function response_null: 输出缺少关键参数的返回函数

-- @param _msg: 消息内容
-- @return
-- @usages:
--	local ZS_ERROR_CODE = require "conf.error_conf"
--	local api_response = require "resty.utils.api_response"
--  local response_str = api_response.response_null("缺少字符串xxx!") --{"code":402,"msg":"缺少字符串xxx!"}
--
]]
function _M.response_null( _msg )
	local api_response_data = {
		code = _err_code or ZS_ERROR_CODE.PARAM_NULL_ERR,
		msg = _msg,
		data = _data,
	};
	return cjson.encode(api_response_data)
end
--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function null_param: 检查必要的参数是否存在,如果不存在则返回当前缺少的字段信息

-- @param _params_l: 必要的参数列表
-- @param _params_m: 参数数据
-- @return
-- @usages:
--	local ZS_ERROR_CODE = require "conf.error_conf"
--	local api_response = require "resty.utils.api_response"
--	local res_data = {name="steven",sex=1}
--  local response_str = api_response.system_error() --{"code":401,"msg":"system busy,please try after a moment!"}
--
]]
function _M.null_param(_params_l,_params_m)
	-- body

	if not _params_l or not _params_m then
		return _M.response(ZS_ERROR_CODE.PARAM_NULL_ERR,"params is nil!")
	end
 
	for i=1,#_params_l do
		if not _params_m[_params_l[i]] then
			return _M.response(ZS_ERROR_CODE.PARAM_NULL_ERR,_params_l[i].." is nil!")
		end
	end


end


--[[
    @author: Created by Lixy at 2018-12-14 14:30:26
    @brief: 检查参数表(table)中是否存在关键key
    @param:
		args: 检查的参数集合(table), 例: {name="xx", id=123}
		keys: 关键key数组，例： ["name", "id"]
    @return:
    	$1:
    	$2:
]]
function _M.check_keys(args, keys)
	if not args then
		return nil, "Args is null"
	end
	if not keys then
		return nil, "Keys is null"
	end
	local buf = ""
	for k, v in pairs(keys) do
		if not args[v] then
			if buf ~= "" then
				buf = buf .. ","
			end
			buf = buf .. v
		end
	end
	if buf ~= "" then
		return nil, "参数[" .. buf .. "]缺失"
	end
	return true
end


return _M	