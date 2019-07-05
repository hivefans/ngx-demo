
local _M = {
    
RSA_PUBLIC_KEY = 
[[
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA0vERfP+16HEQH7v0nnHjtT7XmOgJTB4ZiWDqKEV7VqV6SfS0vFce
O7GEcGkNjsH1u9C3nlxjbMzLqRqirfIffV38xeEu4uRL4Fi/5HlpIit3kAW3+Vwm
2mALWpt56qEHduWVYz5InCgTO2BDb/QZbxc1gMgZdt/RB+s+8DOc8vfEybOF2lzO
mqgPYgealV5ULMmF5HrTdvr2UZSpRzCO+SnXnZjwc/7/gJa9Na9HmbT6zdJqph9U
BlI9r2CKkxp5fyNisqG6i+1NFOU/zL28W4YOD/5KK27v0jBO+wXvigxrHh3GJTw0
jTCOpgckrWHp6ZpcGipbVaLklf8/JnjvVQIDAQAB
-----END RSA PUBLIC KEY-----
]],

RSA_PRIVATE_KEY =
[[
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA0vERfP+16HEQH7v0nnHjtT7XmOgJTB4ZiWDqKEV7VqV6SfS0
vFceO7GEcGkNjsH1u9C3nlxjbMzLqRqirfIffV38xeEu4uRL4Fi/5HlpIit3kAW3
+Vwm2mALWpt56qEHduWVYz5InCgTO2BDb/QZbxc1gMgZdt/RB+s+8DOc8vfEybOF
2lzOmqgPYgealV5ULMmF5HrTdvr2UZSpRzCO+SnXnZjwc/7/gJa9Na9HmbT6zdJq
ph9UBlI9r2CKkxp5fyNisqG6i+1NFOU/zL28W4YOD/5KK27v0jBO+wXvigxrHh3G
JTw0jTCOpgckrWHp6ZpcGipbVaLklf8/JnjvVQIDAQABAoIBAQCQUzBL/glQSEtn
6wmrfvD1iVGp5Ni3o8CFJjIP67o/xmitQSiH1HNzFDoxTy9fhYXEQ0HesAe24UhX
I0o7CXZSKIRSP4f85YaksRRaFlfAcU0U1VTS4CIVN7GNBOOdjR+2Uc6sYGj9rs25
yltZtgHQ6GhK/J2vn+M9L8+YOTghY/aVqa0mSqW1Jfuc99KNDWqKHzB4kF7GdHJb
AroQbBDIVf1PjNyh5u1xSsz3dvQEcxUWEGWeHYUsL8DgsY8wG5u8fcj83HXacQLA
Gua8b/Jr1Tr/5Hz8W4uKeqdNdBi6dwS97PecSvh4nUO8mmzdLxK8f1q57TRQ4hqD
A2EIwbkBAoGBAPIknbKWvC8XYxSsQ5G8bFJPRL9zU0deolgtMa35f86agNa+WEGy
PNjfMUMCE38H6Nvqyht93kFci0P9dGuo4a16Gc6HjqoKFnIhdTIxO89ifkcuFStx
MAO21hi4/etW8fsMkHWS4r49aeygpbqdH5cpDZMJreZrG3Fz34MdRXqZAoGBAN8D
WpfvOVUcnrkyhrKiOooFSlgM8SdkSGYmRqKWadBI4YPVAmfg7t53DkA6nq/LiKbx
EY9WRnGQIFRat7vin8TNfWAhixQ2h7gYfgkuT0fACCYgzlPXSoYhEmcsdDoxpKZ7
r/63shZUxGps+oDnCgIeNuDC+oaOmOxeA5OXXewdAoGAYM9W5UHytvkouektkqS8
wiPDHrAjCZPCYHKhPCdWe+m1vSWY75stTJ/feCTqWo11AgfbCibGp2cyntpEo45/
u/XnP3VfCojB9Jt/2bNpcD62sgqwmA/G3JVK/9NmYaL/WBnr37X8RYcURHDuEbAk
IzFcpf7msgr8i92B7U/UqXECgYEAzw6eHlLOOGfKNsjipxhYoa0nyXi6rog9cBo5
mttsgyYnu+8ZvLjrD0IaySekDjQ7PES2uQ6xeN8IJUnVLWzMSj1AGvEJ4EqA2Dxl
SMDmewegiUYMS2uolcA/BewQPbe515kfXq/PeUxa0TU9oFDiyfSjnytoz2W2Nj9T
ssTnP0ECgYEAi7WT0YgaBx4JoafvX4YXKVXK0Occi0o7pZaIkypYz/OiS4IeKgbd
N5kBZkTEp6pZYl2qpuKhQczMBflXgGlVffEgm+zGfi34eZpmkfGAc4/8GnvMExch
HzuxMMPpdyIj1awpmPL1m48MpJ426UeZM/MQG4iwQ1HDukGwqmGj6I4=
-----END RSA PRIVATE KEY-----
]]
}


-- local resty_sha256 = require "resty.sha256"
-- local resty_string = require "resty.string"
-- function _M.sha256(str)
--     local sha256 = resty_sha256:new()
--     sha256:update(str)
--     return resty_string.to_hex(sha256:final())
-- end

--[[ ==============================================================================================
    RSA 方式加解密
]]
local resty_rsa = require("resty.rsa")

-- 生成公钥和私钥
function _M.rsa_genkey(len)
    local pubkey, privkey = resty_rsa:generate_rsa_keys(len or 1024)
    return pubkey, privkey
end

-- 使用公钥加密
function _M.rsa_encrypt(text, pubkey)
    local rsa_pub, err = resty_rsa:new({public_key = pubkey or _M.RSA_PUBLIC_KEY})
    if not rsa_pub then
        return nil, err
    end
    return rsa_pub:encrypt(text)
end

-- 使用私钥解密密
function _M.rsa_decrypt(text, privkey, algorithm)
    local rsa_priv, err = resty_rsa:new({private_key = privkey or _M.RSA_PRIVATE_KEY})
    return rsa_priv:decrypt(text)
end

-- 使用私钥签名
function _M.rsa_sign(text, privkey, algorithm)
    local rsa_priv, err = resty_rsa:new({private_key = privkey or _M.RSA_PRIVATE_KEY, algorithm = algorithm or "SHA1"})
    return rsa_priv:sign(text)
end

-- 使用公钥解签
function _M.rsa_verify(text, sig, pubkey, algorithm)
    local rsa_pub, err = resty_rsa:new({public_key = pubkey or _M.RSA_PUBLIC_KEY, algorithm = algorithm or "SHA1"})
    return rsa_pub:verify(text, sig)
end

--[[ ==============================================================================================
    AES 方式加解密
]]
local resty_aes = require("resty.aes")

-- len: 128, 192, 256,
-- type: ecb, cbc, cfb1, cfb8, cfb128, ofb, ctr
function _M.aes_encrypt(text, key)
    local aes_e = resty_aes:new(key, nil, resty_aes.cipher(128, "ecb"))
    return aes_e:encrypt(text)
end

function _M.aes_decrypt(text, key)
    local aes_d = resty_aes:new(key, nil, resty_aes.cipher(128, "ecb"))
    return aes_d:decrypt(text)
end

-- local resty_aes = require "resty.aes"
-- local resty_str = require "resty.string"
-- -- hash = {
-- --     md5 ,
-- --     sha1 ,
-- --     sha224 ,
-- --     sha256 ,
-- --     sha384 ,
-- --     sha512
-- -- }

-- function aes_encrypt()
--     -- the default cipher is AES 128 CBC with 1 round of MD5
--     -- for the key and a nil salt
--     local aes = resty_aes:new("AKeyForAES")
--     local encrypted = aes:encrypt("Secret message!")
--     ngx.say("AES 128 CBC (MD5) Encrypted HEX: ", resty_str.to_hex(encrypted))
--     ngx.say("AES 128 CBC (MD5) Decrypted: ", aes:decrypt(encrypted))
-- end

-- function aes_encrypt()
--     -- AES 256 CBC with 5 rounds of SHA-512 for the key
--     -- and a salt of "MySalt!!"
--     -- Note: salt can be either nil or exactly 8 characters long
--     -- key, salt, _cipher, _hash, hash_rounds
--     local aes = resty_aes:new("AKeyForAES-256-CBC", "MySalt!!", resty_aes.cipher(256, "cbc"), aes.hash.sha512, 5)
--     local encrypted = aes:encrypt("Really secret message!")
--     ngx.say("AES 256 CBC (SHA-512, salted) Encrypted HEX: ", resty_str.to_hex(encrypted))
--     ngx.say("AES 256 CBC (SHA-512, salted) Decrypted: ", aes:decrypt(encrypted))
-- end

-- function aes_encrypt()
--     -- AES 128 CBC with IV and no SALT
--     local aes = resty_aes:new("1234567890123456", nil, resty_aes.cipher(128, "cbc"), {iv = "1234567890123456"})
--     local encrypted = aes:encrypt("Really secret message!")
--     ngx.say("AES 128 CBC (WITH IV) Encrypted HEX: ", resty_str.to_hex(encrypted))
--     ngx.say("AES 128 CBC (WITH IV) Decrypted: ", aes:decrypt(encrypted))
-- end

-- -- len: 128, 192, 256,
-- -- type: ecb, cbc, cfb1, cfb8, cfb128, ofb, ctr
-- function aes_encrypt(text, key, cipherlen, ciphertype)
--     local aes = resty_aes:new(key, nil, resty_aes.cipher(cipherlen, ciphertype))
--     aes:encrypt(text)
-- end

--[[ ==============================================================================================
    SHA1
]]
local resty_sha1 = require "resty.sha1"

function _M.sha1_encrypt(text)
    local sha1 = resty_sha1:new()
    if not sha1 then
        ngx.say("failed to create the sha1 object")
        return
    end

    local ok = sha1:update("hello, ")
    if not ok then
        ngx.say("failed to add data")
        return
    end

    ok = sha1:update("world")
    if not ok then
        ngx.say("failed to add data")
        return
    end

    local digest = sha1:final() -- binary digest

    local str = require "resty.string"
    ngx.say("sha1: ", str.to_hex(digest))
    -- output: "sha1: b7e23ec29af22b0b4e41da31e868d57226121c84"
end

--[[ ==============================================================================================

]]
function _M.md5_encrypt()
    local resty_md5 = require "resty.md5"
    local md5 = resty_md5:new()
    if not md5 then
        ngx.say("failed to create md5 object")
        return
    end

    local ok = md5:update("hel")
    if not ok then
        ngx.say("failed to add data")
        return
    end

    ok = md5:update("lo")
    if not ok then
        ngx.say("failed to add data")
        return
    end

    local digest = md5:final()

    local str = require "resty.string"
    ngx.say("md5: ", str.to_hex(digest))
    -- yield "md5: 5d41402abc4b2a76b9719d911017c592"
end

--[[ ==============================================================================================

]]
function _M.sha224_encrypt()
    local resty_sha224 = require "resty.sha224"
    local str = require "resty.string"
    local sha224 = resty_sha224:new()
    ngx.say(sha224:update("hello"))
    local digest = sha224:final()
    ngx.say("sha224: ", str.to_hex(digest))
end

--[[ ==============================================================================================

]]
function _M.sha256_encrypt()
    local resty_sha256 = require "resty.sha256"
    local str = require "resty.string"
    local sha256 = resty_sha256:new()
    ngx.say(sha256:update("hello"))
    local digest = sha256:final()
    ngx.say("sha256: ", str.to_hex(digest))
end

--[[ ==============================================================================================
]]
function _M.sha384_encrypt()
    local resty_sha384 = require "resty.sha384"
    local str = require "resty.string"
    local sha384 = resty_sha384:new()
    ngx.say(sha384:update("hel"))
    ngx.say(sha384:update("lo"))
    local digest = sha384:final()
    ngx.say("sha384: ", str.to_hex(digest))
end

--[[ ==============================================================================================
]]
function _M.sha512_encrypt()
    local resty_sha512 = require "resty.sha512"
    local str = require "resty.string"
    local sha512 = resty_sha512:new()
    ngx.say(sha512:update("hello"))
    local digest = sha512:final()
    ngx.say("sha512: ", str.to_hex(digest))
end

--[[ ==============================================================================================

]]
function _M._encrypt()
    local resty_random = require "resty.random"
    local str = require "resty.string"
    local random = resty_random.bytes(16)
    -- generate 16 bytes of pseudo-random data
    ngx.say("pseudo-random: ", str.to_hex(random))
end

--[[ ==============================================================================================
]]
function _M._encrypt()
    local resty_random = require "resty.random"
    local str = require "resty.string"
    local strong_random = resty_random.bytes(16, true)
    -- attempt to generate 16 bytes of
    -- cryptographically strong random data
    while strong_random == nil do
        strong_random = resty_random.bytes(16, true)
    end
    ngx.say("random: ", str.to_hex(strong_random))
end


return _M