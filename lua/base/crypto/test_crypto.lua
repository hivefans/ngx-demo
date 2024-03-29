--[[
    
]]
local sys_manager = require("system.sys_manager")
local utils = require("module.common.utils")
local crypto = require("module.common.crypto")
local resty_string = require "resty.string"

local _M = {}

function _M.run()
    
    local args = utils.get_args({"text"})

--     local pubkey = [[
-- -----BEGIN RSA PUBLIC KEY-----
-- MIGJAoGBALrHXmNqNl1+yecaIluQV17mOoZ/Ejn/2Af7bjdwD0UebWTXynTyBGGp
-- v8sbsxW/f4A/PHGFnhpJhXjuQEfMPnMdlWssvxc1zVQx/dgdx0sRVjjLZ8higUto
-- mvt6O5oA7PvdyMp5seiQp0OC9wMdKzBoPZ+UzGrdzIdEl7C+hV0/AgMBAAE=
-- -----END RSA PUBLIC KEY-----
-- ]]
--     local privkey = [[
-- -----BEGIN RSA PRIVATE KEY-----
-- MIICWwIBAAKBgQC6x15jajZdfsnnGiJbkFde5jqGfxI5/9gH+243cA9FHm1k18p0
-- 8gRhqb/LG7MVv3+APzxxhZ4aSYV47kBHzD5zHZVrLL8XNc1UMf3YHcdLEVY4y2fI
-- YoFLaJr7ejuaAOz73cjKebHokKdDgvcDHSswaD2flMxq3cyHRJewvoVdPwIDAQAB
-- AoGAIKhpbZKNrO1VWi4sobvsOvCgfRHM2w1L9aFV1SWn1dsLH53HjYkfkQAARAA0
-- 4PGZ1o+3/tVxHoGKb+mgna0toeBGeChVICJa38gtzy0CYk1hzZsEyLVnKJaHpv7n
-- HQ5ab67YQwzqZ77VHnRg3qW3YLmQzKZGleFLaIoUaY3rbHkCQQDyCjH7sjPAeCh/
-- tx6onsYakdwcCPym33/x/QxmZXAOrMYJZbOAh8I41cdP7YmsR9nWKe5mXXkCIdSp
-- 4andZxkVAkEAxY05cRgjQIq3xS97fTXwZ5tM6qdAkdX7gJ6/rkvmOMTSoacp5EnW
-- EXiV+B4pP2zyJrgRn6wWV8MNc8uBGNBKAwJAJh0U4d2d6KEDP5lGaqcV6vks//0q
-- S9zF+QUv/q/ahXUPektZiNPX8bs4N43gMBDgbKkNsXDmrT9GjbnLVeH2QQJAQZkt
-- k9JSEmJ9t2qW9PLuS1kUZ272T/bgNsuAFt55KiyhTLB3hqjF/rMuCV/qjnccyaKh
-- p4W7PZU1aFgRHC4+BQJADIoysOlMTds9uMfOVunPkL9TWh4GdpN4/hLfeUSanCyR
-- 41xPQcVkL/Ut8cUiswmdZgRYukLrS0hJohafLwVSmg==
-- -----END RSA PRIVATE KEY-----
-- ]]

local pubkey = [[
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAIfOXjUX6NzyQJk8TC2bVvTGN5fS39AZT+v7l2phMoKHZjIQGp2trbrG
D+wrQTFbPArOZc93UIuH8N1M7rDuMCjW1AlhH6xWdMhNLqWciJb8FkRLk6Jv2vpN
fOdY5aQccqN317ZW0TciTqg0sRUlepa430/LZODkAWeiwPO2tlyVAgMBAAE=
-----END RSA PUBLIC KEY-----
]]
local privkey = [[
-----BEGIN RSA PRIVATE KEY-----
MIICYQIBAAKBgQCHzl41F+jc8kCZPEwtm1b0xjeX0t/QGU/r+5dqYTKCh2YyEBqd
ra26xg/sK0ExWzwKzmXPd1CLh/DdTO6w7jAo1tQJYR+sVnTITS6lnIiW/BZES5Oi
b9r6TXznWOWkHHKjd9e2VtE3Ik6oNLEVJXqWuN9Py2Tg5AFnosDztrZclQIDAQAB
AoGBAIJYArloslpltLSeV+sp/eK+4Jq6jY/Yy4mOFzzF/0milOaV6EXQbT8nXB7r
QQ4TJ+SjRrpCJS9WkUqFzMRj+OeflxoOakaMtyGOSwRpY5Kowu4TiiJXYZBwSLZ3
7VgNIXE0Lqids89tZihWAx8Scbjz4phyKtiv7EH6fFaFOgXBAkUAj60qmP7AO+a4
MNJCW4Ae4qeY4jntGG8ADiOMKYFnVD2a+anT/ulsqy5Y65hiD1NdQ8RfYwIsfMR9
PqFgFlFWLHgWn6UCPQDx+hHQZ5w1WBaIiMQCnjHv/I/7ezhlRKL2TiYdswKQrbyF
xRr/Pg9ZDB8sxzp0cJLC4ReWVVs9kvPRNjECRAj3a6MksuaKHZCebpm7QzIt93KW
3t8Zfk1jlom4k7REK/nMyXgtJSUBvXbmiagfMcDa7oEFT7VxpcdU1uRNqy0XSYIp
Aj0A4+X+OSYcPTGFp3oIAd80cS6R/OyEpPwL76aSx439cH3w/JwzXQn6Mof0JJxP
NbOAxgJx0Kj7kfaBpB1BAkR1fDyBuxFmc3Zwy5QhQHbX0pgZtNt7DfoPgZqhc2Ep
KihTPIpwlsTJJbdtxM8C5/IC1HX9DJ0VWP35DZNzwojNzcjZsg==
-----END RSA PRIVATE KEY-----
]]

    -- local pubkey, privkey = crypto.rsa_genkey(1024)
    ngx.say(pubkey)
    ngx.say(privkey)

    local ciphertext = crypto.rsa_encrypt(args.text, pubkey)
    ngx.say("密文:", ngx.encode_base64(ciphertext))

    ciphertext = ngx.decode_base64('IMQNWMlc+fzqiN9GLJ9NTsK14+++ta0ioseNPqObBIPCrzF82lyQF1qZJSotMxXDoaaqIWokkQQXo4VxPpEjIzhrv3TpFKT+Lydx56ZiHfD7lo7U/Vw00CfPtVan9dqo3ktwyBWjb19KqF5QbTe5mCHX9S+txO0/GaN7UjoFkKs=');
    local plaintext = crypto.rsa_decrypt(ciphertext, privkey)
    ngx.say("明文:", plaintext)

    local signature = crypto.rsa_sign("测试文本", privkey)
    local res = crypto.rsa_verify("测试文本",signature, pubkey)

    return sys_manager.response(200, "OK", {signature, res})
end

local resty_aes = require("resty.aes")
local resty_string = require("resty.string")
function _M.aes_test()
    local args = utils.get_args({"text", "key"})

    -- while #args.key < 16 do 
    --     args.key = args.key.."\0"
    -- end
    -- while #args.text < 16 do 
    --     args.text = args.text.."\0"
    -- end

    ngx.say(#args.key, #args.text)

    ngx.say( "key=" .. args.key .. ", text=" .. args.text)
    ngx.say("ECB:128: ==>", ngx.encode_base64(resty_aes:new("123456", nil, resty_aes.cipher(128, "ecb"), {iv = "1234567890123456"}):encrypt(args.text)))
    ngx.say("ECB:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "ecb")):encrypt(args.text)))
    ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc")):encrypt(args.text)))

    -- ngx.say("ECB:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "ecb"), resty_aes.hash.md5, 1):encrypt(args.text)))
    -- ngx.say("ECB:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "ecb"), resty_aes.hash.sha1, 1):encrypt(args.text)))
    -- ngx.say("ECB:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "ecb"), resty_aes.hash.sha224, 1):encrypt(args.text)))
    -- ngx.say("ECB:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "ecb"), resty_aes.hash.sha256, 1):encrypt(args.text)))
    -- ngx.say("ECB:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "ecb"), resty_aes.hash.sha384, 1):encrypt(args.text)))
    -- ngx.say("ECB:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "ecb"), resty_aes.hash.sha512, 1):encrypt(args.text)))

    ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256):encrypt(args.text)))
    -- ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256, 1):encrypt(args.text)))
    -- ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256, 2):encrypt(args.text)))
    -- ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256, 3):encrypt(args.text)))
    -- ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256, 4):encrypt(args.text)))
    -- ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256, 5):encrypt(args.text)))
    -- ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256, 6):encrypt(args.text)))
    -- ngx.say("CBC:128: ==>", resty_string.to_hex(resty_aes:new(args.key, nil, resty_aes.cipher(128, "cbc"), resty_aes.hash.sha256, 7):encrypt(args.text)))


    -- local aes = require "resty.nettle.aes"
    -- local aes128 = aes.new "secret\0\0\0\0\0\0\0\0\0\0"
    -- local ciphertext = aes128:encrypt "hello\0\0\0\0\0\0\0\0\0\0\0"
    -- print("aes128 ecb encrypt", #ciphertext, hex(ciphertext))
    -- local aes128 = aes.new "secret\0\0\0\0\0\0\0\0\0\0"
    -- local plaintext = aes128:decrypt(ciphertext)
    -- print("aes128 ecb decrypt", #plaintext, plaintext)


    local ciphertext = crypto.aes_encrypt(args.text, args.key);
    ngx.say(ngx.encode_base64(ciphertext))
    local plaintext = crypto.aes_decrypt(ciphertext, args.key)
    ngx.say(plaintext)
end


return _M
