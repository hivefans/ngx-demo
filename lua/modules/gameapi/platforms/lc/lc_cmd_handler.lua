local sys = sys

local api_def = require("gameapi.conf.api_def")
local lc_def = require("gameapi.platforms.lc.lc_def")

local gapi_manager = require("gameapi.model.gapi_manager")

local time_manager = require("common.time_manager")
-- local time_help = require "resty.utils.time.time_help"
-- local sign_help = require "resty.utils.crypto.sign_help"
local aes = require("common.crypto.aes")
-- local hash_help = require "common.crypto.hash_help"
local resty_crypto = require("common.crypto.resty_crypto")

local resty_aes = require("resty.aes")
local resty_string = require("resty.string")


local make_urlencode_str = function( _params )
	-- body
	local res = ""
	for k,v in pairs(_params) do
		if  type(v) == "table" then
            res = res..k.."=".. ngx.escape_uri(sys.utils.json_encode(v))
		else
			res = res..k.."="..ngx.escape_uri(v)
		end
		res = res.."&"
	end
	return string.sub(res,1,#res-1)
end
local make_url_str = function( _params )
	-- body
	local res = ""
	for k,v in pairs(_params) do
		if  type(v) == "table" then
			res = res..k.."=".. sys.utils.json_encode(v)
		else
			res = res..k.."="..v
		end
		res = res.."&"
	end
	return string.sub(res,1,#res-1)
end


local _M = {}

function _M.call(api_url, agent_id, des_key, md5_key, param)
    -- 获得当前时间毫秒数
    local timestamp = math.floor(ngx.now()*1000);

    -- aes 参数加密
    local str = make_urlencode_str(param)
    local aes_param = aes.aes_ecb_encryp(des_key, str)
    -- md5 加密
    local key = resty_crypto.md5(string.format("%s%s%s", agent_id, timestamp, md5_key))

    -- 组装url数据结构
    local data = {
        agent = agent_id,
        timestamp = timestamp,
        param = aes_param,
        key = key,
    }
    local url = string.format("%s?%s", api_url, make_url_str(data))
    local result, err =  sys.request.http_get(url, nil, nil, sys.conf.HTTP_TIMEOUT_T)
    return result, err, url, {
        timestamp = timestamp,
        param = param,
        data = data,
        str = str,
        aes_param = aes_param,
        url = url
    }
end


function _M.cmd_handler(args) 
    local cmd = args.cmd
    local inner_args = args.inner_args
    local agent = inner_args.platform.agent
    local uid = inner_args.user.uid

    -- if 1 then
    --     return sys.request.response(0, "测试.", args)
    -- end

    if cmd == api_def.CMD.register then
        return _M.register(agent)

    elseif cmd == api_def.CMD.login then
        return _M.login(agent, uid, args.game_id, args.amount or 0)

        -- 上分
    elseif cmd == api_def.CMD.transfer_in then
        return _M.transfer_credit_in(agent, uid, args.amount or 0, inner_args.trade_no)

        -- 下分
    elseif cmd == api_def.CMD.transfer_out then
        return _M.transfer_credit_out(agent, uid, args.amount or 0, inner_args.trade_no)

        -- 获取余额
    elseif cmd == api_def.CMD.balance then
        return _M.get_blance(agent, uid)

    elseif cmd == api_def.CMD.query_trans then
        return _M.query_trans(agent, args.trade_no)

    elseif cmd == api_def.CMD.trans_records then
        return _M.get_trans_records(agent)

    elseif cmd == api_def.CMD.game_records then
        return _M.get_game_record(agent)

    end

    -- return sys.request.response(sys.err_code.SYS_ERR, "不支持的操作.", args)
end


-- 用户注册
function _M.register(args)
    return sys.request.response(sys.err_code.SUCCESS, "注册成功.")
end

-- 登入游戏
function _M.login(agent, user_id, game_id, amount)
    local trans_id = gapi_manager.create_trans_id('BZ_GAME_LC', user_id, agent)
    if not trans_id then
        ngx.log(ngx.ERR, '生成交易订单编号失败.')
        return sys.request.response(sys.err_code.SYS_ERR, "系统繁忙,请稍后尝试.")
    end

    if amount ~= nil and amount >= 0 then
        if not trans_id then
            ngx.log(ngx.ERR, '登录游戏接口携带金额，必须提供 orderid. amount: ', amount)
            return sys.request.response(sys.err_code.PARAM_ERR, '参数错误.')
        end
    end
    local param = {
        s = lc_def.OPT_TYPE.LOGIN, -- 操作子类型
        account = user_id, -- 会员帐号
        money = amount, -- 金额
        orderid = trans_id, -- 流水号(格式:代理编号+yyyyMMddHHmmssSSS+ account)
        KindID = game_id,
        -- ip = args.user_ip,
    }

    local res, err, url, p1 = _M.call(agent.api_url, agent.agent_id, agent.des_key, agent.md5_key, param)
    if not res then
        ngx.log(ngx.ERR, "登入游戏失败： user_id=", user_id, ", error=", err, ", url=", url)
        -- return sys.request.response(sys.err_code.SYS_ERR, '登入游戏失败.', { error = err})
        return sys.request.response(-1, '系统错误， error=.' .. err)
    else
        return sys.request.response(res.status, res.body)
    end

    -- 返回失败, 通知前端 服务器业务块
    if res.status ~= 200 then
        ngx.log(ngx.ERR, "登入游戏失败： user_id=", user_id, ", err=", res.body, ' status: ', res.status)
        return sys.request.response(sys.err_code.SYS_ERR, '登入游戏失败.', { error = res.body })
    end

    local res_data = sys.utils.json_decode(res.body)
    local code = tonumber(res_data.d.code)
    local url = res_data.d.url
    -- 0 表示成功 其余数值表示失败
    if code == lc_def.ERR_CODE.SUCCESS and url then
        return sys.request.response(sys.err_code.SUCCESS, '登入游戏成功.', { url = url, user_id = user_id })
    else
        ngx.log(ngx.ERR, "登入游戏失败： user_id=", user_id, ", res=", res.body)
        return sys.request.response(sys.err_code.SYS_ERR, "登入游戏失败.", { error = "游戏平台返回错误", param = param, data = res_data})
    end
end

-- 用户上分
function _M.transfer_credit_in(agent, user_id, amount, trade_no)
    local param = {
        s = lc_def.OPT_TYPE.TRANSFER_CREDIT, -- 操作子类型
        account = user_id, -- 会员帐号
        money = amount, -- 金额
        orderid = trade_no,
    }

    local res, err = _M.call(agent.api_url, agent.agent_id, agent.des_key, agent.md5_key, param)
    if not res then
        ngx.log(ngx.ERR, "请求第三方接口错误. err: ", err)
        if 'timeout' == err then
            return sys.request.response(sys.err_code.THIRD_PARTY_TIMEOUT, "请求第三方接口超时.")
        end
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口错误.")
    end
    if 408 == res.status then
        ngx.log(ngx.ERR, "[LC] 请求上分超时：status=", res.status, ", body=", res.body)
        return sys.request.response(sys.err_code.THIRD_PARTY_TIMEOUT, "请求第三方接口超时.")
    end
    if 200 ~= res.status then
        ngx.log(ngx.ERR, "[LC] 请求上分失败：status=", res.status, ", body=", res.body)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "上分失败.")
    end

    local res_data = sys.utils.json_decode(res.body)
    local code = tonumber(res_data.d.code)

    -- 0 表示成功 其余数值表示失败
    if code == lc_def.ERR_CODE.SUCCESS then
        return sys.request.response(sys.err_code.SUCCESS, "上分成功.", { trade_no = trade_no})
    else
        ngx.log(ngx.ERR, 'resp: ', res.body)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "上分失败.", { error = "游戏平台返回错误", data = res_data})
    end
end

-- 用户下分
function _M.transfer_credit_out(agent, user_id, amount, trade_no)
    local param = {
        s = lc_def.OPT_TYPE.TAKE_NOW, -- 操作子类型
        account = user_id, -- 会员帐号
        money = amount, -- 金额
        orderid = trade_no, -- 交易订单号
    }
    local res, err = _M.call(agent.api_url, agent.agent_id, agent.des_key, agent.md5_key, param)
    if not res then
        ngx.log(ngx.ERR, "请求第三方接口错误.")
        if 'timeout' == err then
            return sys.request.response(sys.err_code.THIRD_PARTY_TIMEOUT, "请求第三方接口超时.")
        end
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口错误.")
    end
    if 408 == res.status then
        ngx.log(ngx.ERR, "[LC] 请求下分超时:status=", res.status, ",body=", res.body)
        return sys.request.response(sys.err_code.THIRD_PARTY_TIMEOUT, "请求第三方接口超时.")
    end
    if 200 ~= res.status then
        ngx.log(ngx.ERR, "[LC] 请求下分失败:status=", res.status, ",body=", res.body)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口失败.")
    end

    ngx.log(ngx.ERR,"body:",res.body)

    local res_data = sys.utils.json_decode(res.body)
    local code = tonumber(res_data.d.code)

    -- 0 表示成功 其余数值表示失败
    if code == lc_def.ERR_CODE.SUCCESS then
        return sys.request.response(sys.err_code.SUCCESS, '下分成功.', { trade_no = trade_no })
    else
        ngx.log(ngx.ERR, 'resp: ', res.body)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "下分失败.", { error = "游戏平台返回错误", data = res_data})
    end
end

-- 获取余额
function _M.get_blance(agent, user_id)
    local param = {
        s = lc_def.OPT_TYPE.GET_BALANCE, -- 操作子类型 查询可下分 余额类型
        account = user_id, -- 会员帐号
    }
    local res, err = _M.call(agent.api_url, agent.agent_id, agent.des_key, agent.md5_key, param)
    if not res then
        ngx.log(ngx.ERR, "请求第三方接口错误. err: ", err)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口错误.")
    end
    if res.status ~= 200 then
        ngx.log(ngx.ERR, "请求第三方接口失败. status: ", res.status)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口失败.")
    end
    local res_data = sys.utils.json_decode(res.body)
    local code = tonumber(res_data.d.code)

    -- 0 表示成功 其余数值表示失败
    if code == lc_def.ERR_CODE.SUCCESS then
        return sys.request.response(sys.err_code.SUCCESS, "获取用户余额成功.", { balance = res_data.d.totalMoney })
    else
        ngx.log(ngx.ERR, string.format('游戏平台返回错误: %s', res.body))
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "获取用户余额失败.", {error = "游戏平台返回错误", data=res_data})
    end
end

-- 查询订单
function _M.query_trans(agent, trade_no)
    local param = {
        s = lc_def.OPT_TYPE.GET_ORDERS, -- 操作子类型 查询可下分 余额类型
        orderid = trade_no, -- 订单ID
    }
    local res, err = _M.call(agent.api_url, agent.agent_id, agent.des_key, agent.md5_key, param)
    if not res then
        ngx.log(ngx.ERR, "请求第三方接口错误. err: ", err)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口错误.")
    end

    if res.status ~= 200 then
        ngx.log(ngx.ERR, "请求第三方接口失败. status: ", res.status)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口失败.")
    end

    local res_data = sys.utils.json_decode(res.body)
    local code = tonumber(res_data.d.code)
    local state = tonumber(res_data.d.status)
    local msg = ""
    if -1 == state then
        state = sys.basedef.TRANS_STATE.NOT_EXIST
        msg = "订单不存在"
    elseif 0 == state then
        state = sys.basedef.TRANS_STATE.SUCCESS
        msg = "订单成功"
    elseif 2 == state then
        state = sys.basedef.TRANS_STATE.FAILED
        msg = "订单错误"
    end

    -- 0 表示成功 其余数值表示失败
    if code == 0 then
        return sys.request.response(sys.err_code.SUCCESS, "查询信息成功.", { state = state, msg = msg })
    else
        ngx.log(ngx.ERR, string.format('游戏平台[LC]返回错误: %s', res.body))
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "查询信息失败.", {error = "游戏平台返回错误", param = param, data=res_data})
    end
end

-- 获取交易记录
function _M.get_trans_records(args, agent)

end

-- 获取游戏记录
function _M.get_game_record(args, agent)
    -- 检查参数
    local ok, err = sys.utils.check_keys(args, {"start_time", "end_time"})
    if not ok then
        ngx.log(ngx.ERR, '请求参数错误. error= ' .. err, ", args=", sys.utils.json_encode(args))
        return sys.request.response(sys.err_code.PARAM_ERR, "参数错误", {error = err})
    end
    local param = {
        s = lc_def.OPT_TYPE.GET_GAME_RECORD, -- 操作子类型 查询可下分 余额类型
        startTime = args.start_time, -- 开始时间
        endTime = args.end_time, -- 结束时间
    }
    local res, err = _M.call(agent.records_url, agent.agent_id, agent.des_key, agent.md5_key, param)
    if not res then
        ngx.log(ngx.ERR, "请求第三方接口错误. err: ", err)
        --return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口错误.")
        return nil, "请求第三方接口错误"
    end
    if res.status ~= 200 then
        ngx.log(ngx.ERR, "请求第三方接口失败. status: ", res.status)
        return nil, "请求第三方接口失败."
        --return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口失败.")
    end

    local res_data = sys.utils.json_decode(res.body)
    local code = tonumber(res_data.d.code)

    -- 0 表示成功 其余数值表示失败
    if code == lc_def.ERR_CODE.SUCCESS then
        --return sys.request.response(sys.err_code.SUCCESS, '获取游戏记录成功.')
        return {count = res_data.d.count, data_array = res_data.d.list}
    elseif code == lc_def.ERR_CODE.DATA_NO_EXIST then
        return {count = 0, data_array = {}}
    else
        ngx.log(ngx.ERR, 'resp: ', res.body)
        return nil, "获取游戏记录失败." .. (res.body or "")
        --return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "获取游戏记录失败.")
    end
end

-- 获取用户信息
function _M.get_user_info(args, agent)
end

-- 下线用户(踢出用户)
function _M.kick_user(args, agent)
    -- 获取基础数据
    local user_id = args.user_id
    if not user_id then
        ngx.log(ngx.ERR, '请求参数错误. posr_data: ', sys.utils.json_encode(args))
        return sys.request.response(sys.err_code.PARAM_ERR, "参数错误", "[user_id] 错误.")
    end

    local param = {
        s = lc_def.OPT_TYPE.USER_OFFLINE, -- 操作子类型 查询可下分 余额类型
        account = user_id, -- 会员帐号
    }
    local res, err = _M.call(agent.api_url, agent.agent_id, agent.des_key, agent.md5_key, param)
    if not res then
        ngx.log(ngx.ERR, "请求第三方接口错误. err: ", err)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口错误.")
    end
    if res.status ~= 200 then
        ngx.log(ngx.ERR, "请求第三方接口失败. status: ", res.status)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "请求第三方接口失败.")
    end

    ngx.log(ngx.ERR,"body:",res.body)

    local res_data = sys.utils.json_decode(res.body)
    local code = tonumber(res_data.d.code)

    -- 0 表示成功 其余数值表示失败
    if code == lc_def.ERR_CODE.SUCCESS then
        return sys.request.response(sys.err_code.SUCCESS, '注销成功.')
    else
        ngx.log(ngx.ERR, 'resp: ', res.body)
        return sys.request.response(sys.err_code.THIRD_PARTY_ERR, "注销失败.")
    end
end

-- 凍結用戶
function _M.freeze_user(args, agent)
end


return _M

