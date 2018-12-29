--[[
    初始化WORKER
]]

local worker_id = ngx.worker.id()
ngx.log(ngx.ERR, "===== 初始化worker, id=", worker_id)

--local utils = require("base.common.utils")
--utils.load_json_file("lua/conf/base_conf.json")



