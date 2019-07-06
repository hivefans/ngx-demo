--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/online_help.lua
--  版权说明:
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 系统业务唯一ID在线状态功能封装, 主要用websocket等长链接场合,利用redis的分布式锁进行用户唯一性登陆
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]

local ZS_ERROR_CODE = require "conf.error_conf"
local redis_help = require "resty.utils.db.redis_help"

local _M = {
	
}

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function set_online: 设置唯一在线id, 判定业务模块需要对在线模块进行实时心跳更新,以此保持该记录有效
-- @param   _union_id: 业务唯一id
-- @param   _value: 字段设置有效说明,默认设置为空字符串即可
-- @param   _timeout:  超时秒数
-- @return  1 表示成功;0 表示用户已经在线,此时可以强制将用户T下线; nil 表示系统错误,稍后再试;
-- @usages:
	local online_help = require "resty.utils.online_help"
	local res = online_help.set_online("xxxid", "xxval", 5)
--
]]
_M.set_online = function (_union_id, _value, _timeout )
	-- body
	local redis_cli = redis_help:new();
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NEW_ERR);
        return nil
    end 

   	local res,err = redis_cli:setnx(_union_id,_value)
   	if not res then 
   		ngx.log(ngx.ERR,"setnx error:",err,".",_union_id," ",_value)
   		return nil
   	end
   	local vale = nil 
   	if res == 0 then
   		vale,err = redis_cli:get(_union_id)
   		if not vale then
   			ngx.log(ngx.ERR,"get error:",err,".")
   			return nil
   		end
    else
       redis_cli:expire(_union_id,_timeout)
  	end
	 
   	return res ,vale
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function keep_online: 保持当前指定id在线状态
-- @param   _union_id: 业务唯一id
-- @param   _timeout:  超时秒数
-- @param   _value: 字段设置有效说明,默认设置为空字符串即可
-- @return  true 表示成功 其他表示失败
-- @usages:
	local online_help = require "resty.utils.online_help"
	local res = online_help.keep_online("xxxid", 5)
--
]]
_M.keep_online = function ( _union_id, _timeout, _value )
	-- body
    local redis_cli = redis_help:new();
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NEW_ERR);
        return nil
    end

    local res , err=  redis_cli:expire(_union_id,_timeout)
    if not res or res == 0 then
    	return nil
    end

    if _value then
        local res , err = redis_cli:set(_union_id, _value)
        if not res then
            return nil
        end
    end
 
   	return true 
end
 

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function is_online: 判断当前指定id 是否在线
-- @param   _union_id: 业务唯一id
-- @return  nil 表示发生错误 ; true 表示成功
-- @usages:
	local online_help = require "resty.utils.online_help"
	local res,err = online_help.is_online("xxxid")
--
]]

_M.is_online = function ( _union_id )
	-- body
    local redis_cli = redis_help:new();
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NEW_ERR);
        return nil
    end

    local res, err =  redis_cli:ttl(_union_id)
    if not res then
    	return nil
    end
    
 	if res == -2 then 
		 return nil,res
 	end

 	if res == -1 then
 		redis_cli:expire(_union_id,15)
 		return 15
 	end
 	return res
end

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function update_online: 更新唯一id, 如果不存在则直接创建一个唯一在线id
-- @param   _union_id: 业务唯一id
-- @param   _value: 字段设置有效说明,默认设置为空字符串即可
-- @param   _timeout:  超时秒数

-- @return  nil 表示发生错误
-- @return  res -2 表示不存在; 其他数值表示当前有效时间 其中redis 返回-1 表示存在但未设置超时,本系统将会自动未其设置15秒超时;
-- @usages:
	local online_help = require "resty.utils.online_help"
	local res = online_help.update_online("xxxid","VVV",5)
--
]]

_M.update_online = function ( _union_id, _value, _timeout )
	-- body
    local redis_cli = redis_help:new();
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NEW_ERR);
        return nil
    end

    local res,err = redis_cli:setnx(_union_id, _value)
    if not res then
        return nil
    end
    return _M.keep_online(_union_id,_timeout,res == 1 and nil or _value)
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function delete_online: 删除指定id的唯一在线状态
-- @param   _union_id: 业务唯一id

-- @return  nil 表示发生错误
-- @usages:
	local online_help = require "resty.utils.online_help"
	local res = online_help.delete_online("xxxid")
--
]]
_M.delete_online = function ( _union_id )
	-- body
    local redis_cli = redis_help:new();
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NEW_ERR);
        return nil
    end

    local res,err = redis_cli:del(_union_id)
   	if not res then 
   		return nil
   	end  

  	return true
end



--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_online_value: 获得业务唯一id存储的数据
-- @param   _union_id: 业务唯一id

-- @return  nil 表示发生错误;非 nil 表示用户数据
-- @return  err 错误信息
-- @usages:
	local online_help = require "resty.utils.online_help"
	local res = online_help.delete_online("xxxid")
--
]]
_M.get_online_value = function ( _union_id )
	-- body
    local redis_cli = redis_help:new();
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NEW_ERR);
        return nil
    end
   	
    local res,err = redis_cli:get(_union_id)
   	if not res then 
   		return nil,err
   	end   
  	return res
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function get_left_time: 获得业务唯一id剩余时间
-- @param   _union_id: 业务唯一id

-- @return  nil 表示发生错误;非 nil 表示有效时间
-- @return  err 错误信息 -2 表示不存在key 返回 0 ; -1 表示未设置超时,系统自动设置15秒超时
-- @usages:
	local online_help = require "resty.utils.online_help"
	local res = online_help.get_left_time("xxxid")
--
]]
_M.get_left_time = function ( _union_id )
    -- body
    local redis_cli = redis_help:new();
    if not redis_cli then
        ngx.log(ngx.ERR,ZS_ERROR_CODE.REDIS_NEW_ERR);
        return nil
    end
    
    local res,err = redis_cli:ttl(_union_id)
    if not res then 
      return nil,err
    end   
    if res == -2 then 
        return 0
    elseif res == -1 then
        redis_cli:expire(_union_id,15)
        return 15
    end
    return res
end

return _M

