
local sys = require("base.sys")
local dao_game = require("gameapi.dao.dao_game")
local dao_task = require("gameapi.dao.dao_task")
local dao_platform = require("gameapi.dao.dao_platform")


local _M = {}

--[[
    Create by lixy at 2019-05-22 14:15
    @brief:  获取游戏列表
    @params: 
        args [object] 参数表对象
    @return: 
]]
function _M.list_game(args)

end

--[[
    Create by lixy at 2019-05-22 14:16
    @brief:  
    @params: 
        args [object]  参数表对象
    @return: 
]]
function _M.add_game(args)
end

--[[
    Create by lixy at 2019-05-22 14:16
    @brief:  
    @params: 
        args [object]
    @return: 
]]
function _M.modify_game(args)
end

--[[
    Create by lixy at 2019-05-22 14:17
    @brief:  
    @params: 
        args [object]
    @return: 
]]
function _M.delete_game(args)
end



--[[
    Create by lixy at 2019-06-21 14:10
    @uri:   
    @brief:	
    @params:
    @return:
]]
function _M.add_platform(args)
    local gpid = args.gpid
    local gpname = args.gpname
    local srv_type = args.srv_type
    local srv_addr = args.srv_addr

    if not gpid or gpid == "" then
        return sys.request.response(sys.err_code.SYS_ERR, "参数[gpid]不能为空")
    end
    if not gpname or gpname == "" then
        return sys.request.response(sys.err_code.SYS_ERR, "参数[gpname]不能为空")
    end
    if not srv_type or srv_type == "" then
        return sys.request.response(sys.err_code.SYS_ERR, "参数[srv_type]不能为空")
    end
    if srv_type == "REMOTE" then
        if not srv_addr or srv_addr == "" then
            return sys.request.response(sys.err_code.SYS_ERR, "参数[srv_addr]不能为空")
        end
    end

    local res, err = dao_platform.add_platform(gpid, gpname, srv_type, srv_addr)
    if not res then
        return sys.request.response(sys.err_code.SYS_ERR, err)
    else
        return sys.request.response(sys.err_code.SUCCESS, "添加游戏平台成功")
    end
end

--[[
    Create by lixy at 2019-06-21 14:10
    @brief:	
    @params:
    @return:
]]
function _M.modify_platform(args)
end

--[[
    Create by lixy at 2019-06-21 14:11
    @brief:	
    @params:
    @return:
]]
function _M.delete_platform(args)

end


--[[
    Create by lixy at 2019-06-21 15:50
    @brief:	
    @params:
    @return:
]]
function _M.list_platform()
    local res, err = dao_platform.list_platform()
    if not res then
        return sys.request.response(sys.err_code.SYS_ERR, "获取游戏平台列表信息失败", {error = err})
    else
        return sys.request.response(sys.err_code.SUCCESS, "获取游戏平台列表信息成功", res)
    end
end



--[[
    Create by lixy at 2019-06-25 17:04
    @brief:	
    @params:
    @return:
]]
function _M.add_task(args)
    local tid = args.tid
    local ttype = args.ttype
    local bizid = args.bizid
    local gpid = args.gpid
    local setting = args.setting

    if not tid or tid=='' then
        return sys.request.response(sys.err_code.SYS_ERR, "参数[tid]不能为空")
    end
    if not ttype or ttype=='' then
        return sys.request.response(sys.err_code.SYS_ERR, "参数[ttype]不能为空")
    end
    if setting then
        local data = sys.utils.json_decode(setting)
        if not data then
            return sys.request.response(sys.err_code.SYS_ERR, "参数[setting]需要是JSON字符串")
        end
    end
    local res, err = dao_task.add_task(tid, ttype, bizid, gpid, setting)
    if not res then
        return sys.request.response(sys.err_code.SYS_ERR, err)
    else
        return sys.request.response(sys.err_code.SUCCESS, "添加任务成功")
    end
end


--[[
    Create by lixy at 2019-06-25 19:01
    @brief:	
    @params:
    @return:
]]
function _M.modify_task(args)
    local tid = args.tid
    local gpid = args.gpid
    local bizid = args.bizid
    local interval = args.interval
    local setting = args.setting 
    local status = args.status
    if not tid or tid == "" then
        return sys.request.response(sys.err_code.SYS_ERR, "参数[tid]不能为空")
    end
    if not gpid and not bizid and not interval and not setting and not status then
        return sys.request.response(sys.err_code.SYS_ERR, "参数不能为空")
    end
    local res, err = dao_task.modify_task(tid, gpid, bizid, interval, setting, status)
    if not res then
        return sys.request.response(sys.err_code.SYS_ERR, err)
    else
        return sys.request.response(sys.err_code.SUCCESS, "修改任务成功")
    end
end

--[[
    Create by lixy at 2019-06-25 16:45
    @brief:	
    @params:
    @return:
]]
function _M.list_task()
    local res, err = dao_task.list_task()
    if not res then
        return sys.request.response(sys.err_code.SYS_ERR, err)
    else
        return sys.request.response(sys.err_code.SUCCESS, "获取任务列表成功", res)
    end
end


return _M