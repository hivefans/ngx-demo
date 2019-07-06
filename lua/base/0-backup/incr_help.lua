--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/incr_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 自增长功能类,主要用于各种唯一性字段增长,使用openresty自带的共享内存进行自增长
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]
local time_help = require "resty.utils.time.time_help"

local _M = {}



--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_uuid:  使用snowflake自增键进行生成唯一id,格式为 469479147790401536,注意workers不要超过32

-- @return 唯一字符串
-- @usages:
	local incr_help = require "resty.utils.incr_help"
	local union_id = incr_help.get_union_id() -- 469479147790401536
--
]]
local sf = require "snowflake"
-- works 不得超过32线程,如果系统比较强大,可以进行服务器分离操作,用代理服务器进行负载!!!!!!
local workers = ngx.worker.id() % ngx.worker.count()
sf.init(System.SERVER_ID, workers)
_M.get_uuid = function( )
	-- body
	return sf.next_id()
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_time_union_id: 获取唯一时间为起始的唯一id,格式为2018050811172432080000183

-- @param _key: 指定的自增长key
-- @param _start_index: 开始累加的字段, 起始默认为 800000
-- @return 唯一字符串
-- @usages:
	local incr_help = require "resty.utils.incr_help"
	local union_id = incr_help.get_time_union_id() -- 2018050811172432080000183
--
]]
_M.get_time_union_id = function( _key, _start_index )
	-- body
	local ngx_cache = ngx.shared.ngx_cache
	local newval, err, forcible = ngx_cache:incr(_key or "DefaultKey",1,_start_index or 800000)
	if not newval then newval = math.random(100000,999999) end
	local random_tx = math.random(1,10000)
	return string.format("%s%s%s%s%d", os.date("%Y%m%d%H%M%S", os.time()), time_help.current_millis(), SERVER_ID or '00', newval, random_tx)
end





return _M