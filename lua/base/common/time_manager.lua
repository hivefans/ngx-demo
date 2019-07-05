--[[
--]]

local ffi = require("ffi")
if pcall(ffi.typeof, "struct timeval") then
    -- already defined! do nothing here...
else
    -- undefined! let's define it!
    ffi.cdef[[
        struct timeval {
            long int tv_sec;
            long int tv_usec;
        };
    ]];
end

ffi.cdef[[
    int gettimeofday(struct timeval *tv, void *tz);
]];
local tm = ffi.new("struct timeval");


local _M = {};

--[[
    当前时间的毫秒
]]
function _M.millisecond()   
    ffi.C.gettimeofday(tm,nil);
    -- local sec =  tonumber(tm.tv_sec);    -- 秒
    -- local usec =  tonumber(tm.tv_usec);  -- 微妙
    -- return sec*1000 + usec * 10^-3;
    return tonumber(tm.tv_usec/1000);
end


--[[
    当前时间的微秒
]]
function _M.microsecond()   
    ffi.C.gettimeofday(tm, nil);
    local sec = tonumber(tm.tv_sec);    -- 秒
    local usec = tonumber(tm.tv_usec);  -- 微妙
    -- return sec*1000000 + usec;
    -- ffi.C.gettimeofday(tm,nil);  
    return  tonumber(tm.tv_usec);
end


--[[
    获取当前日期
]]
function _M.date() 
    return os.date("%Y-%m-%d", os.time())
end

--[[
    获取当前时间
]]
function _M.time()   
    return os.date("%H:%M:%S", os.time())
end

--[[
    获取当前日期时间
]]
function _M.datetime()  
    return os.date("%Y-%m-%d %H:%M:%S" ,os.time())
end


--[[
    将datatime字符串转换成时间戳
]]
function _M.to_timestamp(dt)  
    local time_parten = "(%d+)%-(%d+)%-(%d+)%s(%d+):(%d+):(%d+)"
    local s1,s2,Y,m,d,H,M,S = string.find(dt,time_parten)
    return  os.time({year=Y, month=m, day=d, hour=H,min=M,sec=S}) 
end

function _M.get_remote_system_time()
    -- local script = [[
    --     local a = redis.call('TIME')
    --     if tonumber(a[1]) == nil then
    --         return nil
    --     else
    --         return {a[1], a[2]}
    --     end
    -- ]]

    -- local redis_cli = redis_help:new();
    -- if not redis_cli then
    --     ngx.log(ngx.ERR, 'redis new 失败.')
    --     return nil, 'redis new失败.'
    -- end

    -- local res, err = redis_cli:eval(script, 0)
    -- if not res then
    --     ngx.log(ngx.ERR, 'redis_cli:eval fail. err: ', err)
    --     return nil, '获取时间失败.'
    -- end

    -- local time1 = tonumber(res[1])
    -- local time2 = tonumber(res[2])
    -- if time1 == nil or time2 == nil then
    --     ngx.log(ngx.ERR, '获取时间失败，时间格式错误.')
    --     return nil, '获取时间失败'
    -- end

    -- local t1,t2 = math.modf(tonumber(time2)/1000);
    -- return {time1, t1}
end


return _M;