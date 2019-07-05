--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/db/db_json_help.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: log 日志收集功能,用于上下文上的日志引入,该模块采用ngx 本次链接的共享上下文作为传输通道
        注意log分两类,一种本地log;一种网络log;循环保持订阅类的业务非常不建议在调用本功能函数
--------------------------------------------------------华丽的分割线------------------------------------------------------------
--  Version: V1.1
        author: Steven
        date: 2018-11-05
        desc: 添加日志标准描述,当前系统标准化输出能力
--------------------------------------------------------华丽的分割线------------------------------------------------------------

--]]

local cjson = require "cjson"
cjson.encode_empty_table_as_object(false)
local ctx = ngx.ctx
local _M = {}

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function log: 生成log程序

-- @param _err: 错误编号,主要类型包含ngx错误类型和用户扩展的错误类型,日志用于最后log输出,如果中间出现错误则无法执行最后log
-- @param _msg: 日志内容
-- @return 无
-- @usages:

--]]
_M.log = function(_err, _msg)
	if not ctx.logsArray then ctx.logsArray = {} ctx.logs_counts = 0 end
 	-- 未来可以增加消息的样式,本次业务使用json字符串格式进行保存
	ctx.logs_counts = ctx.logs_counts + 1
	ctx.logsArray[ ctx.logs_counts ] = {err_type = _err, log = _log}
end
 

_M.getMsg = function()
	-- body
	return ctx.logsArray
end 

_M.getJsonMsg = function()
	-- body
	-- 未来可以增加消息的样式,本次业务使用json字符串格式进行保存
	return cjson.encode(ctx.logsArray)
end

_M.kafka_log = function(_msg, _key, _topic,_partitions)
	local log_data = {
		topic = _topic,		-- 主题
		key = _key,		-- 消息key
		msg = _msg,		-- 消息主体数据
		partitions = _partitions, -- 分片id
	}
	local res = ngx.location.capture(
			"/log/api/send_kafka.in",
			{ method = ngx.HTTP_POST, body = cjson.encode(log_data) }
	)

	if not res or res.status ~= 200 then
		ngx.log(ngx.ERR,"kafka log server err:"..res.body)
		return nil
	else
		if tonumber(res.body) == 1 then
			return true
		else
			return nil
		end
	end
end


-------------log 定义函数 减少编写的数量----------------------------------
-- 定义常用log

--[[
ngx 错误日志类型
]]
local NGX_LOG_TYPE = {
	 NGX_STDERR 	= ngx.STDERR,
	 NGX_EMERG 		= ngx.EMERG,
	 NGX_ALERT 		= ngx.ALERT,
	 NGX_CRIT 		= ngx.CRIT,
	 NGX_ERR 		= ngx.ERR,
	 NGX_WARN 		= ngx.WARN,
	 NGX_NOTICE 	= ngx.NOTICE,
	 NGX_INFO 		= ngx.INFO,
	 NGX_DEBUG 		= ngx.DEBUG,
}

local NGX_STDERR 	= ngx.STDERR
local NGX_EMERG 	= ngx.EMERG
local NGX_ALERT 	= ngx.ALERT
local NGX_CRIT 		= ngx.CRIT
local NGX_ERR 		= ngx.ERR
local NGX_WARN 		= ngx.WARN
local NGX_NOTICE 	= ngx.NOTICE
local NGX_INFO 		= ngx.INFO
local NGX_DEBUG 	= ngx.DEBUG


_M.NGX_LOG_TYPE = NGX_LOG_TYPE

--[[
日志错误类型的名称
]]
local NGX_LOG_TYPE_MAP = {
	"STDERR",
	"EMERG",
	"ALERT",
	"CRIT",
	"ERR",
	"WARN",
	"NOTICE",
	"INFO",
	"DEBUG",
}


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function make_log: 创建日志内容, 返回多个返回, 用于nginx的日志打印
					为了方便当前系统的日志输出与记录, 日志的格式定义如下:
					系统错误类型: LOG_TYPE
					1 模块名称/服务器号/ SERVER_ID
					2 错误文件名称
					3 错误函数名称
					4 错误详细
					5 发生时间

数据结构如下:
ngx.log(LOG_TYPE, 1,2,3,4,5,6)

-- @param _err: 错误编号,主要类型包含
-- @param _msg: int 数值
-- @return BIT OBJ
-- @usages:
	local bit_help = require "resty.utils.bit_help"
	local bitObj = bit_help.new(0x20) --  32 --> 0x20
]]
local function make_log(_log_type,_module_name,_file_name,_func_name,...)
	return _log_type,
	"[module]:".._module_name or "系统模块",
	", [file]:".._file_name,
	", [func]:".._func_name or "api",
	", [err] ",...
end
_M.make_log = make_log

local function log_stderr(_module_name,_file_name,_func_name,...)
	return make_log(NGX_STDERR,_module_name,_file_name,_func_name,...)
end
_M.log_stderr = log_stderr

local function log_emerg(_module_name,_file_name,_func_name,...)
	return make_log(NGX_EMERG,_module_name,_file_name,_func_name,...)
end
_M.log_emerg = log_emerg

local function log_alert(_module_name,_file_name,_func_name,...)
	return make_log(NGX_ALERT,_module_name,_file_name,_func_name,...)
end
_M.log_alert = log_alert

local function log_crit(_module_name,_file_name,_func_name,...)
	return make_log(NGX_CRIT,_module_name,_file_name,_func_name,...)
end
_M.log_crit = log_crit

local function log_err(_module_name,_file_name,_func_name,...)
	return make_log(NGX_ERR,_module_name,_file_name,_func_name,...)
end
_M.log_err = log_err

local function log_warn(_module_name,_file_name,_func_name,...)
	return make_log(NGX_WARN,_module_name,_file_name,_func_name,...)
end
_M.log_warn = log_warn

local function log_notice(_module_name,_file_name,_func_name,...)
	return make_log(NGX_NOTICE,_module_name,_file_name,_func_name,...)
end
_M.log_notice = log_notice

local function log_info(_module_name,_file_name,_func_name,...)
	return make_log(NGX_INFO,_module_name,_file_name,_func_name,...)
end
_M.log_info = log_info

local function log_debug(_module_name,_file_name,_func_name,...)
	return make_log(NGX_DEBUG,_module_name,_file_name,_func_name,...)
end
_M.log_debug = log_debug


return _M