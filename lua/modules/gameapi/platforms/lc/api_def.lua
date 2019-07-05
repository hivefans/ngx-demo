local trade_currency_type = require("gapi_platform/bundles/trade_def").CURRENCY_TYPE

--牌型对照表
--           1(A) 2    3    4    5    6    7    8    9    10(a) J(b) Q(c)  K(d)
--
--方块(0)    1    2    3    4    5    6    7    8    9    10    11   12    13
--梅花(1)    14   15   16   17   18   19   20   21   22   23    24   25    26
--红桃(3)    27   28   29   30   31   32   33   34   35   36    37   38    39
--黑桃(4)    40   41   42   43   44   45   46   47   48   49    50   51    52
--小猴   53       大猴  54

local _M = {}

_M.OPT_TYPE = {
    LOGIN = 0,
    TRANSFER_CREDIT = 2,
    TAKE_NOW = 3,
    GET_BALANCE = 7,
    GET_ORDERS = 4,
    USER_OFFLINE = 8,
    GET_GAME_RECORD = 6,
}

_M.ERR_CODE = {
    SUCCESS = 0, --    0 成功
    --1 TOKEN 丢失（ 重新调用登录接口获取）
    --2 渠道不存在（ 请检查渠道 ID 是否正确）
    --3 验证时间超时（ 请检查 timestamp 是否正确）
    --4 验证错误
    --5 渠道白名单错误（ 请联系客服添加服务器白名单）
    --6 验证字段丢失（ 请检查参数完整性）
    --8 不存在的请求（ 请检查子操作类型是否正确）
    --15 渠道验证错误（ 1.MD5key 值是否正确； 2.生成 key 值中的 timestamp 与参数中的是否一致； 3. 生成 key 值中的 timestamp 与代理编号以字符串形式拼接）
    DATA_NO_EXIST = 16,--16 数据不存在（ 当前没有注单）
    --20 账号禁用
    --22 AES 解密失败
    --24 渠道拉取数据超过时间范围
    --26 订单号不存在
    --27 数据库异常
    --28 ip 禁用
    --29 订单号与订单规则不符
    --30 获取玩家在线状态失败
    --31 更新的分数小于或者等于 0
    --32 更新玩家信息失败
    --33 更新玩家金币失败
    --34 订单重复
    --35 获取玩家信息失败（ 请调用登录接口创建账号）
    --36 KindID 不存在
    --37 登录瞬间禁止下分， 导致下分失败
    --38 余额不足导致下分失败
    --39 禁止同一账号登录带分、 上分、 下分并发请求， 后一个请求被拒
    --40 单次上下分数量不能超过一千万
    --41 拉取对局汇总统计时间范围有误
    --42 代理被禁用
    --43 拉单过于频繁(两次拉单时间间隔必须大于 1 秒)
    --999 请求失败
    --1001 注册会员账号系统异常
    --1002 代理商金额不足
    --1003 玩家大厅上分/下分异常
    --1004 代理商渠道不存在
    --1005 会员金额不足
    --1006 会员游戏上分/下分异常
    --1007 玩家登录游戏上分异常
    --1008 玩家登出游戏下分异常
    --1009 上下分出现负数(非法值)
    --1010 会员退出大厅异常
    --1011 订单已存在
    --1012 订单号不符合规则
    --1013 后台上分/下分异常
    --1014 上级代理金额不足
    --1015 会员代理充值异常(不能跨代理给会员充值)
    --1016 玩家账户被锁
    --1017 更新会员、 浏览器信息异常
    --1018 存储过程参数格式不正确或参数为空
    --1019 更新会员玩过的游戏信息异常
    --1020 玩家大厅进(出)游戏上分(下分)生成订单异常
    --1021 会员订单失效或不存在
    --1022 会员订单已经处理过， 不能重复处理
    --1023 玩家正在游戏中， 不能上下分
    --1024 大厅会员账号不存在
    --1025 参数错误， 子渠道标识不能为空
}

_M.CURRENCY_MAP = {
    --"" = trade_currency_type.
    USD = trade_currency_type.USD,		-- 美元
    RMB = trade_currency_type.CNY,		-- 人民币
    TWD = trade_currency_type.TWD,
    MYR = trade_currency_type.MYR,		-- 马币
    IDR = trade_currency_type.IDR,		-- 印度尼西亚卢比
    THB = trade_currency_type.THB,     -- 泰铢
    VDN = trade_currency_type.VND,		-- 越南盾
}

_M.GAME_INFO = {
    DZPK = {
        card_value_bytes = 46,
        player_num = 9,
        card_count = 2,
        p_start_index = 37,
        p_end_index = 46,
        p_card_count = 5,
        empty_card = "0000",
    },
    EBR = {
        card_value_bytes = 9,
        player_num = 4,
        card_count = 2,
        empty_card = "00",
    },
    QZNN = {
        card_value_bytes = 41,
        player_num = 4,
        card_count = 5,
        empty_card = "0000000000",
    },
    ZJH = {
        card_value_bytes = 31,
        player_num = 5,
        card_count = 3,
        empty_card = "000000",
    },
    SG = {
        card_value_bytes = 31,
        player_num = 5,
        card_count = 3,
        empty_card = "000000",
    },
    TBNN = {
        card_value_bytes = 61,
        player_num = 6,
        card_count = 5,
        empty_card = "0000000000",
    },
    QZPJ = {
        card_value_bytes = 17,
        player_num = 4,
        card_count = 2,
        empty_card = "0000",
    },
    JSZJH = {
        card_value_bytes = 55,
        player_num = 9,
        card_count = 3,
        empty_card = "000000",
    },
    DDZ = {
        card_value_bytes = 109,
        player_num = 3,
        card_count = 17,
        p_start_index = 103,
        p_end_index = 108,
        p_card_count = 3,
    },
    XYWZ = {
        --card_value_bytes = 109,
        player_num = 1,
        card_count = 5,
        after_start_index = 11,
    },
    KSZ = {
        card_value_bytes = 41,
        player_num = 4,
        card_count = 5,
        empty_card = "0000000000",
    },
    BJL = {
        banker_start_index = 7,
        banker_end_index = 12,
        player_start_index = 1,
        player_end_index = 6,
        card_count = 3,
        empty_card = "00",
    },
}

_M.JOKER_MAP = {
    ["42"] = 53,
    ["43"] = 54,
}

_M.SUIT_MAP = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
}

_M.NUMBER_MAP = {
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 10,
    ["a"] = 10,
    ["B"] = 11,
    ["b"] = 11,
    ["C"] = 12,
    ["c"] = 12,
    ["D"] = 13,
    ["d"] = 13,
}

_M.EBR_CARD_MAP = {
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 0,
    ["a"] = 0,
}

-- 游戏类型和简称映射
_M.GAME_KIND_MAP = {
    --620 德州扑克 完成
    --720 二八杠 完成
    --830 抢庄牛牛 完成
    --220 炸金花 完成
    --860 三公 完成
    --900 押庄龙虎 完成
    --600 21 点 完成
    --870 通比牛牛 完成
    --230 极速炸金花 完成
    --730 抢庄牌九 完成
    --630 十三水 完成
    --610 斗地主 完成
    --890 看三张抢庄牛牛 完成
    --910 百家乐 即将开启
    --740 二人麻将 开发中
    --950 红黑大战 开发中
    --930 百人牛牛 即将上线
    --390 射龙门 即将上线
    --380 幸运五张 即将上线
    ["620"] = "DZPK",
    ["720"] = "EBR",
    ["830"] = "QZNN",
    ["220"] = "ZJH",
    ["860"] = "SG",
    ["900"] = "YZLH",
    ["600"] = "TOP",
    ["870"] = "TBNN",
    ["730"] = "QZPJ",
    ["230"] = "JSZJH",
    ["610"] = "DDZ",
    ["630"] = "SSS",
    ["380"] = "XYWZ",
    ["390"] = "SLM",
    ["890"] = "KSZ",
    ["910"] = "BJL",
}

return _M