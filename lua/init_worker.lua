--[[
    初始化WORKER
]]

local worker_id = ngx.worker.id()
ngx.log(ngx.ERR, "===== 初始化worker, id=", worker_id)

local time_manager = require("common.time_manager")
local cache_manager = require("system.cache_manager")

local function on_timer() 
    -- local cache_manager = require("system.cache_manager")
    -- cache_manager.cache()


    -- local monitor = require("system.monitor")
    -- monitor.startup()

    -- -- local uuid = time_manager.uuid()
    -- -- monitor.add_statistics(uuid, {})

    -- local res, err = monitor.get_alive_request()
    -- if not res then
    --     ngx.log(ngx.ERR, "错误: error=", err)
    -- else
    --     ngx.log(ngx.ERR, "当前请求数量: ", #res/2)
    --     ngx.log(ngx.ERR, ">>> ", sys.utils.json_encode(res))
    -- end
    

    -- local nums, err = monitor.get_alive_nums()
    -- if not nums then
    --     ngx.log(ngx.ERR, "错误: error=", err)
    -- else
    --     ngx.log(ngx.ERR, "当前请求数量: ", nums)
    -- end

    -- monitor.test()

    -- local db_postgres = require("common.db.db_postgres")

    -- local db, err = db_postgres.conn()
    -- if not db then
    --     ngx.log(ngx.ERR, "连接Postgres失败, error=", err)
    -- else
    --     ngx.log(ngx.ERR, "连接Postgres成功")
    -- end


    -- local biz, err = cache_manager.get_biz("222129735621423104")
    -- if biz then
    --     ngx.log(ngx.ERR, sys.cjson.encode(biz))
    -- elseif not err then
    --     ngx.log(ngx.ERR, "222129735621423104 不存在")
    -- end

    -- local platform, err = cache_manager.get_platform("BZ_GAME_HB")
    -- if platform then
    --     ngx.log(ngx.ERR, sys.cjson.encode(platform))
    -- elseif not err then
    --     ngx.log(ngx.ERR, "BZ_GAME_HB 不存在")
    -- end

    -- local user, err = cache_manager.get_user("10009")
    -- if user then
    --     ngx.log(ngx.ERR, sys.cjson.encode(user))
    -- elseif not err then
    --     ngx.log(ngx.ERR, "10009 不存在")
    -- end

    -- local user, err = cache_manager.get_biz_user("lxy001")
    -- if user then
    --     ngx.log(ngx.ERR, sys.cjson.encode(user))
    -- elseif not err then
    --     ngx.log(ngx.ERR, "lxy001 不存在")
    -- end

    -- local game, err = cache_manager.get_game("BZ_GAME_AG", "BAC")
    -- if game  then
    --     ngx.log(ngx.ERR, sys.cjson.encode(game))
    -- elseif not err then
    --     ngx.log(ngx.ERR, "BZ_GAME_AG：BAC 不存在")
    -- end

end



local ok, err = ngx.timer.at(1, on_timer)


local aes = require("common.crypto.aes")
local text = ngx.unescape_uri(aes.aes_ecb_encryp('AJIFWKCK6MQTISX2', '123456'))
ngx.log(ngx.ERR, ">>>>>>>>>>>>>>>>>> AES-ECB: ", text)

local resty_crypto = require("common.crypto.resty_crypto")
local timestamp = math.floor(ngx.now()*1000);
local key = resty_crypto.md5("123456")
ngx.log(ngx.ERR, ">>>>>>>>>>>>>>>>>> MD5: ", key)




-- local total_min = 10000
-- local total_max = 30000

-- local total = 0

-- local bet_min = 10

-- local max_nums = 20
-- for i=1, max_nums, 1 do
--     local single_max = math.ceil((total_max - total) / (max_nums - i + 1))
--     local single_min = math.floor((total_min - total) / (max_nums - i + 1))
--     if single_min < bet_min then 
--         single_min = bet_min
--     end
    
--     local v = math.random(single_min, single_max)
--     total = total + v

--     ngx.log(ngx.ERR, string.format(" >> %s : [%s ~ %s]   %s  总计: %s", i, single_min, single_max, v, total))
-- end


