--[[
    Create by lixy at 2019-05-07 11:33
    @brief: 
]]

local _M = {}

--[[
    系统状态定义
]]
_M.SYSTEN_STATUS = {
    OK = 0,     -- 正常
    STOP = 1,   -- 停止服务/维护
    SYNC = 2,   -- 需要同步数据
    ERROR = 3,  -- 异常
}

--[[
    用户状态定义
]]
_M.USER_STATUS = {
    OK = 1,
    DISABLE = 0,
}

--[[
    事务状态
]]
_M.TRANS_STATE = {
    SUCCESS = 0, -- 正常结束
    FAILED = 1, -- 执行失败
    WAITTING = 2, -- 等待狀態，未执行结束
    NOT_EXIST = 3,   -- 不存在
}



_M.rsa_private_key = [[
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAt8T79EFJxj9gRIfxhefOApLy/TGyRzdmOpZm2EC3SH+wlyZz
4udj9QbodnCgiHpa8dlTjWwLhUyOrzz+5KXrUwAduF02sDjGWfzCpG8jcLqnglMv
gofY3ZtDh09P7mdgd5xfh773O/FTA+YCsGC09ai3pEhUYAHhhJGza7oO3krPmUMX
pT8p/L4X1D2JuJPWlxG3X4XaN0AGUNyhyMGoMj0VN/ZGmWokmqqLtYsCkB2r+AyF
Yc4KAAmE9A9+4VXfzpRV7492LL1S709MpxI3SfyOpdJ0EAMBvfrdQdClZi5Qss5h
YjAdALRFaFRKmX7IyYNwGoh8R11gM5lzlDj0UQIDAQABAoIBAFYnlsvTlAfKjJJ0
fWn+3Ble1WaY1vEGavoKqxq1dHgbzSl/0JLPUpB8dZ2ZfdmeK2b5MW+6+Me8taQ4
X3PIycO26TgXE12YsH1dv88hf6cJCyFRaJO0ppp2gTk9mMa3VoWdHThh8jz7DaVl
P1t7aztEpxvxAQWlvBnPySM3LmNOOLWGczvcHed/NGLIPc7poxrBLSIkoY/G9jVL
DoX1OazhxL/Qn/iYGva5WNhQguU1KzMaiTNg3LJUejgxaiyM0pOwMwWI4PRBfmpg
Ur25X0BiZEZ0DM46awyuIUin8m3eDItwX2tnUHoTE6ISd+c4FHZXdfatgR6XjvzC
6RnT+wUCgYEA87Xd2o3p0+jtJUGYlYQvMSk+R7/7YQxIAqXTpVgdD4DgXb9CNFJf
atCIVIMFZq01/R1HDXKwJTkFkZX8aqqdBMosh9mS+0tlI/puSm4CcGwbKYlhI4kt
JU8WPXz9XHNFlIX6OAQ1upv0YslBcATsHR8y6hsQZdrnugETFAnPANsCgYEAwQlS
QIeYcaaw/tIpgJ9Hxphoh4RDlDfnbOyBbSWD/xmqn63IhzcJGKrPqFtUNxjFTUjs
HBMghqQgxDHPTbiq6kKuOJId66TkadCSAyF0yRwsXFBW/d8E6NBM+39TjhbTBLv2
6Dii6G1Ev9esAy9H/mPVwe2+OlVsoRIOWAkmoUMCgYEAmFPtdkTLiWOGjongmFvF
r4Gq5uftdKxbeiQyFJ/tkhooow//jnqKH1Z2T/SQ9KuBGlMpbRNpW+q3O1c3LWi0
uiCwEr2ArEdk0UcflrAKIEDB/YVbzP1Z1X8IVKiCKD34mKvhSRAAkUIXT4OhviWl
e1Jb3Y3LAw7/VfiD9ztmQo8CgYA1VVj3YT9aLz75uKEk210eXp+KyZ1ORz/WlWWQ
/WuBwNqmcYJU8Xy+5vqmvkz/SAXDO6GYhCRZbuFqs4ReKeZ3AONX1+8SWyWMosak
vMqigfkzrDLMw6B8noiWd/Bi8qVsym4GbRd9disngfQRkS+n9ndptED5pv5zZiS2
aBjXNwKBgQCbXblDc22TqEdkUuqDEv1WjQJME2qYfisUrBrnubq+tDHKQw2JP2J+
+xlZNQGrJa0/6aSqHt2PAkclPk/AhbEBRkHzWoM4qbjyQA/Kv3pzqaC6IgWNV+Pn
OatVNDROs6y7WLeSCjzpVxnovwTdXRHJo/DMIwvpjc7ybjVI74IaRA==
-----END RSA PRIVATE KEY-----
]]

_M.rsa_public_key = [[
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEAt8T79EFJxj9gRIfxhefOApLy/TGyRzdmOpZm2EC3SH+wlyZz4udj
9QbodnCgiHpa8dlTjWwLhUyOrzz+5KXrUwAduF02sDjGWfzCpG8jcLqnglMvgofY
3ZtDh09P7mdgd5xfh773O/FTA+YCsGC09ai3pEhUYAHhhJGza7oO3krPmUMXpT8p
/L4X1D2JuJPWlxG3X4XaN0AGUNyhyMGoMj0VN/ZGmWokmqqLtYsCkB2r+AyFYc4K
AAmE9A9+4VXfzpRV7492LL1S709MpxI3SfyOpdJ0EAMBvfrdQdClZi5Qss5hYjAd
ALRFaFRKmX7IyYNwGoh8R11gM5lzlDj0UQIDAQAB
-----END RSA PUBLIC KEY-----
]]



_M.REDIS_KEYS = {
    STATISTICS_API_REQUEST = "XY_STATISTICS_API_REQUEST"
}

_M.TASK_TYPE = {
    GAME_RECODE = "GAME_RECORD",    -- 游戏记录
}

return _M