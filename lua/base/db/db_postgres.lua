
local resty_postgres = require("resty.postgres")

local _M = {}




local db_config = {
    -- host="192.168.1.32",
    host="192.168.1.32",
    port=5432, 
    database="lxy",
    user="postgres",
    password="123456",
    compact=false
}

function _M.conn()
    local db = resty_postgres:new()
    db:set_timeout(3000)

    local ok, err = db:connect(db_config)
    if not ok then
        return nil, err
    end
    return db

    -- local res, err = db:query("select id,name from test")
    -- db:set_keepalive(0,100)
end

function _M.exec(db, sql)
    local db_c, err = db or _M.conn()
    if not db_c then
        return nil, err 
    end
    if not db then
        db_c:close();
    end
    return db_c:query(sql)
end



return _M