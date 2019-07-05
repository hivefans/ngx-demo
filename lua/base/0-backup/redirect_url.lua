--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:lua/resty/utils/redirect_url.lua
--  版权说明:南京正溯网络科技有限公司.版权所有©copy right.
--  Version: V1.0
        author: Steven
        date: 2018-05-08
        desc: 登录授权成功之后的重定向,主要用于网页重定向功能
--------------------------------------------------------华丽的分割线------------------------------------------------------------



--]]
local request_help = require "resty.utils.request_help"
local _M = {
	
}

--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function redirect_last_url: 获取当前网页的地址,如果地址中存在surl 表示当前有地址需要在执行成功之后进行跳转, 如果当前页面与需要跳转的页面相同, 则不需要进行跳转
-- @return
-- @usages:
 	local redirect_url = require "resty.utils.redirect_url"

 	redirect_url.redirect_last_url()

 	-- ...
]]
_M.redirect_last_url = function( ... )
	-- body
	local args = ngx.req.get_uri_args()
	if not args then return end;
	local url = args["redirect_url"]
	if url then 
		-- local url = ngx.unescape_uri(url)
		-- 获得当前页面地址
		local cur_url = ngx.var.scheme.."://"..ngx.var.remote_addr..ngx.var.uri
		if cur_url ~= url then
			return ngx.redirect(url);
		end
	end
 
end


--[[
-- @author: Steven（01）
-- @date: 2018-05-07

-- @function redirect_last_url:  获取用户当前网址, 进行字符串编码处理 ,该类型主要用于网页客户端应用中
-- @return
-- @usages:
 	local redirect_url = require "resty.utils.redirect_url"

 	local redirect_url = redirect_url.make_redirect_url()

]]
_M.make_redirect_url = function (  )
	local cur_url = ngx.var.scheme.."://"..ngx.var.remote_addr..ngx.var.uri
	return "redirect_url="..ngx.escape_uri(cur_url)
end


return _M

