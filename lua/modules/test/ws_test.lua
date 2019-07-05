--[[
    @url:   ws://10.0.0.220:12340/ws_test.do
]]

local db_redis = require("common.db.db_redis")
local websocket = require("base.net.websocket")


-- 回调处理对象 实现on_event(type, ws, data)处理消息
-- local ws_handler = require("socket.ws_handler")

local args = ngx.req.get_uri_args()
local code = args["user_id"]

ngx.log(ngx.ERR, "===>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Websocket client connect: ", code)
-- if not code then
--     ngx.log(ngx.ERR, "[WEBSOCKET] Parameter [user_id] is not set")
--     ngx.say("[WEBSOCKET] Parameter [user_id] is not set")
--     return
-- end

-- 客户端的个人频道
-- local channel = sys.CHANNEL_WS_CLIENT .. code


local ws_handler = {}

function ws_handler.on_event(type, ws, data) 
    if type == "WS_EVENT_MESSAGE" then
        ws:send("Hello")
    end
end


-- 创建websocket
local ws, err = websocket:create(code, "CHANNEL_WS_TEST", ws_handler)
if not ws then
    ngx.log(ngx.ERR, "===>>  Websocket init failed. " .. err)
    return
end

-- 保存用户信息（订阅频道信息）
-- local redis_manager = require("lua.resty.utils.redis_manager")
-- redis_manager.execute(nil, "hset", sys.REDIS_KEY_WS_CLIENT, code, channel)


-- 开启定时器监测状态
-- local function on_timer(pp)
-- end
-- ngx.timer.at(1, on_timer)

local function on_publish(channel, buf)
    ws_handler.on_event("WS_EVENT_PUBLISH", ws, buf)
end

-- 订阅个人频道
-- redis_manager:subscribe(channel, on_publish)

-- 订阅公共频道
-- redis_manager:subscribe(sys.CHANNEL_WS_PUBLIC, on_publish)

--ws:subscribe(channel)
--ws:subscribe("WS:PUBLIC:HELLOWORLD")

ws:run(2000)
ngx.log(ngx.ERR, "===>> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Websocket end")

