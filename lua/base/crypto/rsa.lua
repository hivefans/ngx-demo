--[[
--  作者:Steven 
--  日期:2017-02-26
--  文件名:rsa.lua
--  版权说明:
--  RSA非对称加密技术的功能,用于通信过程开始以及中间过程的加密处理,进一步保护数据的安全性
--  由于非对称加密技术的计算量比较大,所以系统在接入时进行一次加密处理,后续采用ace堆成加密
--  
--]]

-- 对于公钥私钥的提取，详细请看http://www.cnblogs.com/dreamer-One/p/5621134.html
-- 另外付在线加解密工具链接：http://tool.chacuo.net/cryptrsaprikey

-- 生成或者已经生成的公key 格式如下

-- rsa_public_key = [[
--     -----BEGIN RSA PUBLIC KEY-----
--     MIGJAoGBAJ9YqFCTlhnmTYNCezMfy7yb7xwAzRinXup1Zl51517rhJq8W0wVwNt+
--     mcKwRzisA1SIqPGlhiyDb2RJKc1cCNrVNfj7xxOKCIihkIsTIKXzDfeAqrm0bU80
--     BSjgjj6YUKZinUAACPoao8v+QFoRlXlsAy72mY7ipVnJqBd1AOPVAgMBAAE=
--     -----END RSA PUBLIC KEY-----
-- ]]
    -- 私钥或者系统生成的私钥 格式如下
-- rsa_private_key = [[
--     -----BEGIN RSA PRIVATE KEY-----
--     MIICXAIBAAKBgQCfWKhQk5YZ5k2DQnszH8u8m+8cAM0Yp17qdWZedede64SavFtM
--     FcDbfpnCsEc4rANUiKjxpYYsg29kSSnNXAja1TX4+8cTigiIoZCLEyCl8w33gKq5
--     tG1PNAUo4I4+mFCmYp1AAAj6GqPL/kBaEZV5bAMu9pmO4qVZyagXdQDj1QIDAQAB
--     AoGBAJega3lRFvHKPlP6vPTm+p2c3CiPcppVGXKNCD42f1XJUsNTHKUHxh6XF4U0
--     7HC27exQpkJbOZO99g89t3NccmcZPOCCz4aN0LcKv9oVZQz3Avz6aYreSESwLPqy
--     AgmJEvuVe/cdwkhjAvIcbwc4rnI3OBRHXmy2h3SmO0Gkx3D5AkEAyvTrrBxDCQeW
--     S4oI2pnalHyLi1apDI/Wn76oNKW/dQ36SPcqMLTzGmdfxViUhh19ySV5id8AddbE
--     /b72yQLCuwJBAMj97VFPInOwm2SaWm3tw60fbJOXxuWLC6ltEfqAMFcv94ZT/Vpg
--     nv93jkF9DLQC/CWHbjZbvtYTlzpevxYL8q8CQHiAKHkcopR2475f61fXJ1coBzYo
--     suAZesWHzpjLnDwkm2i9D1ix5vDTVaJ3MF/cnLVTwbChLcXJSVabDi1UrUcCQAmn
--     iNq6/mCoPw6aC3X0Uc3jEIgWZktoXmsI/jAWMDw/5ZfiOO06bui+iWrD4vRSoGH9
--     G2IpDgWic0Uuf+dDM6kCQF2/UbL6MZKDC4rVeFF3vJh7EScfmfssQ/eVEz637N06
--     2pzSvvB4xq6Gt9VwoGVNsn5r/K6AbT+rmewW57Jo7pg=
--     -----END RSA PRIVATE KEY-----
-- ]]
-- rsa_private_password = "password", 
-- algorithm = "SHA1",  -- md4 md5 ripemd160 sha0 sha1 sha224 sha256 sha384 sha512
-- padding = resty_rsa.PADDING.RSA_PKCS1_PADDING, -- 

-- bits = 2048

   
local resty_rsa = require "resty.rsa"

--公钥
local RSA_PUBLIC_KEY = [[
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAJ9YqFCTlhnmTYNCezMfy7yb7xwAzRinXup1Zl51517rhJq8W0wVwNt+
mcKwRzisA1SIqPGlhiyDb2RJKc1cCNrVNfj7xxOKCIihkIsTIKXzDfeAqrm0bU80
BSjgjj6YUKZinUAACPoao8v+QFoRlXlsAy72mY7ipVnJqBd1AOPVAgMBAAE=
-----END RSA PUBLIC KEY-----
]]

local RSA_PRIV_KEY = [[
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCfWKhQk5YZ5k2DQnszH8u8m+8cAM0Yp17qdWZedede64SavFtM
FcDbfpnCsEc4rANUiKjxpYYsg29kSSnNXAja1TX4+8cTigiIoZCLEyCl8w33gKq5
tG1PNAUo4I4+mFCmYp1AAAj6GqPL/kBaEZV5bAMu9pmO4qVZyagXdQDj1QIDAQAB
AoGBAJega3lRFvHKPlP6vPTm+p2c3CiPcppVGXKNCD42f1XJUsNTHKUHxh6XF4U0
7HC27exQpkJbOZO99g89t3NccmcZPOCCz4aN0LcKv9oVZQz3Avz6aYreSESwLPqy
AgmJEvuVe/cdwkhjAvIcbwc4rnI3OBRHXmy2h3SmO0Gkx3D5AkEAyvTrrBxDCQeW
S4oI2pnalHyLi1apDI/Wn76oNKW/dQ36SPcqMLTzGmdfxViUhh19ySV5id8AddbE
/b72yQLCuwJBAMj97VFPInOwm2SaWm3tw60fbJOXxuWLC6ltEfqAMFcv94ZT/Vpg
nv93jkF9DLQC/CWHbjZbvtYTlzpevxYL8q8CQHiAKHkcopR2475f61fXJ1coBzYo
suAZesWHzpjLnDwkm2i9D1ix5vDTVaJ3MF/cnLVTwbChLcXJSVabDi1UrUcCQAmn
iNq6/mCoPw6aC3X0Uc3jEIgWZktoXmsI/jAWMDw/5ZfiOO06bui+iWrD4vRSoGH9
G2IpDgWic0Uuf+dDM6kCQF2/UbL6MZKDC4rVeFF3vJh7EScfmfssQ/eVEz637N06
2pzSvvB4xq6Gt9VwoGVNsn5r/K6AbT+rmewW57Jo7pg=
-----END RSA PRIVATE KEY-----
]]
local  opts = {
        rsa_public_key = RSA_PUBLIC_KEY,
        rsa_private_key = RSA_PRIV_KEY,
        algorithm = "SHA1",
        padding = resty_rsa.PADDING.RSA_PKCS1_PADDING, 
   } 



--[[
-- 定义rsa简单封装函数 简化数据加密通信服务
    -- _M = {  
    public_obj 
    -- or private_obj
-- } 

-- ]]


local _M = {  
   bits = 2048,
}
_M.__index = _M
 
--[[
-- _M.generate_rsa_keys() 
--  创建服务端随机的 public_key and private_key ,通过key进行后续操作
-- example
    local rsaImpl = require "common.crypto.rsa":generate_rsa_keys(2048)
 
-- @param bits    specifying the number of bits. 
-- @return  public_key,private_key
--]]
function _M.generate_rsa_keys(bits)
     
    local rsa_public_key, rsa_private_key, err = resty_rsa:generate_rsa_keys(bits)
    if not rsa_public_key then
       ngx.log(ngx.ERR,"rsa error ,err is ",err)
       return nil
    end 
    return rsa_public_key,rsa_private_key
end


--[[
-- _M.new_rsa_public(self,public_key)  _M:new_rsa_public(public_key) 
--  创建服务端随机的 public_key and private_key ,通过key进行后续操作
-- example
    local rsaImpl = require "common.crypto.rsa":generate_rsa_keys(2048)
 
-- @param bits    specifying the number of bits. 
-- @return  public_key,private_key
--]]
function _M:new_rsa_public(public_key,algorithm)
    -- body 
    local opts = { 
    }
    opts.public_key = public_key and public_key or RSA_PUBLIC_KEY
    opts.algorithm = algorithm and algorithm or "SHA1"

    local pub, err = resty_rsa:new(opts)
    if not pub then
        ngx.log(ngx.ERR, "new public rsa err: ", err)
        return
    end
    local _rsaImp = setmetatable({}, _M)   
    _rsaImp.rsa_obj = pub
    return _rsaImp
end
function _M:new_rsa_private(private_key,algorithm,pwd)
    -- body 
    local opts = { 
    }
    opts.private_key = private_key and private_key or RSA_PRIV_KEY
    opts.algorithm = algorithm and algorithm or "SHA1"

    opts.password = pwd and pwd or nil

    local priv, err = resty_rsa:new(opts)
    if not priv then
        ngx.log(ngx.ERR, "new private rsa err: ", err)
        return
    end
    local _rsaImp = setmetatable({}, _M)   
    _rsaImp.rsa_obj = priv
    return _rsaImp
end


function _M:encrypt( str )
    -- body
    if not self.rsa_obj or type(str) ~= "string" then return nil end

    local encrypted, err = self.rsa_obj:encrypt(str)
    if not encrypted then
        ngx.log(ngx.ERR,"failed to encrypt: ", err)
        return
    end
    return encrypted 
end

function _M:decrypt( encrypted )
    -- body
    if not self.rsa_obj then return nil end

    local decrypted, err = self.rsa_obj:decrypt(encrypted)
    if not decrypted then
        ngx.log(ngx.ERR,"failed to decrypt: ", err)
        return
    end
    return decrypted 
end


function _M:sign(str) 

    local sig, err = self.rsa_obj:sign(str)
    if not sig then
        ngx.say("failed to sign:", err)
        return
    end
    return sig
end
 

function _M:verify(str,sig)
    local verify, err = self.rsa_obj:verify(str, sig)
    if not verify then
        ngx.say("verify err: ", err)
        return
    end
    return verify
end 


return _M