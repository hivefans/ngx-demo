local _M = {}

_M.CMD = {
    register = "register",
    login = "login",
    transfer_in = "transfer_in",
    transfer_out = "transfer_out",
    balance = "balance",
    query_trans = "query_trans",
    trans_records = "trans_records",
    game_records = "game_records",
    kick_user = "kick_user" 
}



local cmd_def = {
    [_M.CMD.register] = { handler = "/gameapi/handler/register.do"},
    [_M.CMD.login] = { handler = "/gameapi/handler/login.do"},
    [_M.CMD.transfer_in] = { handler = "/gameapi/handler/transfer_in.do"},
    [_M.CMD.transfer_out] = { handler = "/gameapi/handler/transfer_out.do"},
    [_M.CMD.balance] = { handler = "/gameapi/handler/balance.do"},
    [_M.CMD.query_trans] = { handler = "/gameapi/handler/query_trans.do"},
    [_M.CMD.trans_records] = { handler = "/gameapi/handler/trans_records.do"},
    [_M.CMD.game_records] = { handler = "/gameapi/handler/game_records.do"},
}

local support = {
    api = {
        [_M.CMD.login] = true, 
        [_M.CMD.register] = true,
        [_M.CMD.transfer_in] = true,
        [_M.CMD.transfer_out] = true,
        [_M.CMD.balance] = true,
        [_M.CMD.query_trans] = true
    },
    
    record = {
        [_M.CMD.trans_records] = true,
        [_M.CMD.game_records] = true
    },

    task = {}
}

function _M.get_cmd(code)
    local cmd = cmd_def[code]
    if not cmd then
        return nil
    end
    if (sys.conf.API_ENABLE) then
        if not support.api[code] then
            return nil
        end     
    end
    if (sys.conf.RECORD_ENABLE) then
        if not support.record[code] then
            return nil
        end
    end
    if (sys.conf.TASK_ENABLE) then
        return nil
    end
    return cmd
end

function _M.get_support() 
    local buf = {}
    local api = {}
    if (sys.conf.API_ENABLE) then
        api = support.api
    elseif (sys.conf.RECORD_ENABLE) then
        api = support.record
    elseif (sys.conf.TASK_ENABLE) then
        api = support.task
    end
    for k, v in pairs(api or {}) do
        table.insert(buf, k)
    end
    return buf
end

_M.platform_gateway = "/gameapi/gateway_platform.do"

_M.PLATFORM = {
    BZ_GAME_KY_XSJ = "BZ_GAME_KY_XSJ",
    BZ_GAME_KY_LY = 'BZ_GAME_KY_LY',
    BZ_GAME_WM = 'BZ_GAME_WM',
    BZ_GAME_WM_LOTTERY = 'BZ_GAME_WM_LOTTERY',
    BZ_GAME_JDB = "BZ_GAME_JDB",
    BZ_GAME_LC = "BZ_GAME_LC",
}


local platform_def = {
    ['BZ_GAME_JDB'] = {
        agent_def = {"gateway","parent","iv","dc","key"}, -- 代理参数定义
        handler = "gameapi.platforms.jdb.jdb_cmd_handler", -- 处理游戏平台API接口的文件，其中实现相关函数操作
        cmd_handler = "cmd_handler",    -- 接口处理函数，该函数在handler指定的文件中实现
    },
    ['BZ_GAME_WM'] = {
        agent_def = {'gateway', 'agent_id', 'signature'}, -- 代理参数定义
        handler = "gameapi.platforms.wm.wm_cmd_handler", -- 处理游戏平台API接口的文件，其中实现相关函数操作
        cmd_handler = "cmd_handler",    -- 接口处理函数，该函数在handler指定的文件中实现
    },
    ['BZ_GAME_WM_LOTTERY'] = {
        agent_def = {"gateway","merchant","key","version"}, -- 代理参数定义
        handler = "gameapi.platforms.wm_lottery.wmlot_cmd_handler", -- 处理游戏平台API接口的文件，其中实现相关函数操作
        cmd_handler = "cmd_handler",    -- 接口处理函数，该函数在handler指定的文件中实现
    },
    ['BZ_GAME_LC'] = {
        agent_def = {"agent_id","des_key","md5_key","api_url","records_url"}, -- 代理参数定义
        handler = "gameapi.platforms.lc.lc_cmd_handler", -- 处理游戏平台API接口的文件，其中实现相关函数操作
        cmd_handler = "cmd_handler",    -- 接口处理函数，该函数在handler指定的文件中实现
    },
}

function _M.get_platform(platform_id) 
    return platform_def[platform_id]
end








return _M