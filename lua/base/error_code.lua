--[[
    Created by lixy at 2019-03-05 09:17
    @brief:	 错误码定义
]]


local _M = {
    SUCCESS = 200,

    SYS_ERR = 400,
    SYS_OFF = 401,

    REQ_TYPE_ERR = 410, -- 请求方式错误
    PARAM_ERR = 411,    -- 参数错误
    RSA_ERR = 412,      -- RSA 签名错误

    AGENT_NOT_EXIST = 500,  -- 代理不存在
    AGENT_DISABLE = 501,
    AGENT_ACCOUNT_NOT_EXIST = 502,
    AGENT_ACCOUNT_DISABLE = 503,

    PLATFOMR_NOT_EXIST = 550,       -- 游戏平台不存在
    PLATFOMR_GAME_NOT_EXIST = 551,  -- 游戏不存在
    PLATFOMR_DISABLE = 552,         -- 游戏平台状态异常


    USER_NOT_EXIST = 600,       -- 用户不存在
    USER_REPEAT_RESIGER = 601,  -- 用户重复注册
    USER_DISABLE= 602,
    USER_ACCOUNT_DISABLE = 603, -- 用户账户状态异常
}






return _M