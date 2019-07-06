--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:lua/resty/utils/time/time_help.lua
--  版权说明:
--  Version: V1.0
        author:Steven 常用时间相关函数封装,主要包含获取当前系统毫秒时间,微秒时间,当前毫秒值,常用时间格式转换等功能
--------------------------------------------------------华丽的分割线------------------------------------------------------------
--  Version: V1.1
        date: 2018-05-08
        author:Steven 增加string类型的时间格式转为秒数
--------------------------------------------------------华丽的分割线------------------------------------------------------------


--]]

local ffi = require("ffi")
ffi.cdef[[
    struct timeval {
        long int tv_sec;
        long int tv_usec;
    };
    int gettimeofday(struct timeval *tv, void *tz);
]];
local tm = ffi.new("struct timeval");


local _M = {};
-- 返回毫秒级时间戳
-- function _M.current_time_millis()   
--     ffi.C.gettimeofday(tm,nil);
--     local sec =  tonumber(tm.tv_sec);
--     local usec =  tonumber(tm.tv_usec);
--     return sec*1000 + usec * 10^-3;
-- end



--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function current_time_millis: 返回本地系统毫秒级时间戳

-- @return
-- @usages:
local time_help = require "resty.utils.time.time_help"
local current_millis = time_help.current_time_millis()
--
]]
function _M.current_time_millis()
    return math.floor(ngx.now()*1000);
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function current_time_micro: 返回当前下系统微秒级时间戳

-- @return
-- @usages:
local time_help = require "resty.utils.time.time_help"
local current_micros = time_help.current_time_micro()
--
]]
function _M.current_time_micros()
    ffi.C.gettimeofday(tm,nil);
    local sec =  tonumber(tm.tv_sec);
    local usec =  tonumber(tm.tv_usec);
    return sec*10^6 + usec;
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function current_millis: 返回当前下系统毫秒时间值,与current_time_millis返回不同

-- @return
-- @usages:
    local time_help = require "resty.utils.time.time_help"
    local current_millis = time_help.current_millis()
--
]]
function _M.current_millis()   
    ffi.C.gettimeofday(tm,nil);  
    return  tonumber(tm.tv_usec/1000);
end

-- 返回年月日 数据格式
--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function current_date: 返回当前下系统毫秒时间值,与current_time_millis返回不同

-- @param _date_temp:时间模版参数 默认参数为 "%Y-%m-%d"
-- @return
-- @usages:
    local time_help = require "resty.utils.time.time_help"
    local current_date = time_help.current_date()
--
]]
function _M.current_date(_date_temp) 

    return os.date( _date_temp  and  _date_temp or  "%Y-%m-%d" ,os.time())
end

-- 返回时分秒数据格式
function _M.current_time(_time_temp)   
      
    return os.date( _time_temp  and  _time_temp or "%H:%M:%S",os.time())
end

-- 返回年月日 时分秒
function _M.current_date_time(_time_temp)  
    -- os.date("%Y-%m-%d %H:%M:%S",os.time())
    -- return  ngx.localtime()
    return os.date( _time_temp  and  _time_temp or "%Y-%m-%d %H:%M:%S" ,os.time())
end

local time_parten = "(%d+)%-(%d+)%-(%d+)%s(%d+):(%d+):(%d+)"
-- 将data_time 转当前秒数
function _M.date_time_to_second(_data_time)  
    -- os.date("%Y-%m-%d %H:%M:%S",os.time())
    -- return  ngx.localtime()
    local s1,s2,Y,m,d,H,M,S = string.find(_data_time,time_parten)
    return  os.time({year=Y, month=m, day=d, hour=H,min=M,sec=S}) 
end
local cjson = require "cjson"
local time_parten1 = "(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)"
-- 将data_time 将其他数据格式的时间 转换为 "%Y-%m-%d %H:%M:%S" 格式
function _M.date_time_to_default_time(_data_time)
    -- os.date("%Y-%m-%d %H:%M:%S",os.time())
    -- return  ngx.localtime()
    local s1,s2,Y,m,d,H,M,S = string.find(_data_time,time_parten1)
    return  string.format("%s-%s-%s %s:%s:%s",Y,m,d,H,M,S)
end


return _M;