--[[
    Created by lixy at 2019-03-01 09:27
    @brief:	 系统基础配置信息
]]

local _M = {}

_M.version = "v1.0.0"

_M.SERVER_ID = "LXY-0"

-- API接口服务状态： false:禁用， true: 启用
_M.API_ENABLE = true

-- 记录拉取服务状态： false:禁用， true: 启用
_M.RECORD_ENABLE = false

-- 定时任务状态： false:禁用， true: 启用
_M.TASK_ENABLE = false

_M.USER_ID_INDEX = 100000

_M.HTTP_TIMEOUT_T = 10 * 1000

_M.db_conf = {
    -- host = "139.196.180.249",
    -- port = 3306,
    -- database = "platform",
    -- user = "admin",
    -- password = "zhengsu@2018",
    host =  "127.0.0.1",
    port = 3306,
    database = "lxy",
    user = "root",
    password = "123456",
    max_packet_size = 1024 * 1024
}

_M.redis_conf = {
    host = "139.196.180.249",
    port = 6379,
    password = "zhengsu_redis@2018",
    max_packet_size = 1024 * 1024
}


return _M