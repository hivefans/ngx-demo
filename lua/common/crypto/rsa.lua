--[[
    作者:Steven 
    日期:2017-02-26
    文件名:rsa.lua
    版权说明:南国一梦科技有限公司.版权所有©copy right.
    RSA非对称加密技术的功能,用于通信过程开始以及中间过程的加密处理,进一步保护数据的安全性
    由于非对称加密技术的计算量比较大,所以系统在接入时进行一次加密处理,后续采用ace堆成加密

    技巧:  
        一.将BEGIN PUBLIC KEY的公钥拼接成格式如下:
-----BEGIN PUBLIC KEY-----
MIGJAoGBAKDdUTw0Vfho0wvvVdaFuNX7t2IL8CiEz19rderRwOU8X2JTRc5hEbch
JlGcBUNPfT/kJD49pCkWJsj5Tyg9swDh1cqyq7GAtkdYyB44lKvpEZecExu7MCwmj
7hUq1MzfyBlY63523ROWDaBK2x4QPPTPsUBxF/UtWojz61FIil3BAgMBAAE=
-----END PUBLIC KEY-----

    存储为文件pub.key   

    二. 用命令解析出BEGIN RSA PUBLIC KEY格式的公钥
        openssl rsa -pubin -in pub.key -RSAPublicKey_out

    对于公钥私钥的提取，详细请看http://www.cnblogs.com/dreamer-One/p/5621134.html
    另外付在线加解密工具链接：http://tool.chacuo.net/cryptrsaprikey

    生成或者已经生成的公key 格式如下: 
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAJ9YqFCTlhnmTYNCezMfy7yb7xwAzRinXup1Zl51517rhJq8W0wVwNt+
mcKwRzisA1SIqPGlhiyDb2RJKc1cCNrVNfj7xxOKCIihkIsTIKXzDfeAqrm0bU80
BSjgjj6YUKZinUAACPoao8v+QFoRlXlsAy72mY7ipVnJqBd1AOPVAgMBAAE=
-----END RSA PUBLIC KEY-----

    私钥或者系统生成的私钥 格式如下: 
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

 
--[[
    私钥 pkcs1格式的私钥结构,java 需要使用pkcs8格式的

    PKCS#8 私钥加密格式:
    -----BEGIN ENCRYPTED PRIVATE KEY-----  
    BASE64私钥内容  
    -----ENDENCRYPTED PRIVATE KEY-----  

    PKCS#8 私钥非加密格式:
    -----BEGIN PRIVATE KEY-----  
    BASE64私钥内容  
    -----END PRIVATEKEY----- 

    Openssl ASN格式
    -----BEGIN RSA PRIVATE KEY-----  
    Proc-Type: 4,ENCRYPTED  
    DEK-Info:DES-EDE3-CBC,4D5D1AF13367D726  
    BASE64私钥内容  
    -----END RSA PRIVATE KEY-----  
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

local opts = {
    rsa_public_key = RSA_PUBLIC_KEY,
    rsa_private_key = RSA_PRIV_KEY,
    algorithm = "SHA1",
    padding = resty_rsa.PADDING.RSA_PKCS1_PADDING, 
} 


local _M = {}
_M.__index = _M

local rsa_private_key_match = "-----BEGIN RSA PRIVATE KEY(a*)END RSA PRIVATE KEY-----"
local rsa_public_key_match = "-----BEGIN RSA PRIVATE KEY(a*)END RSA PRIVATE KEY-----"

local rsa_private_key_match1 = "-----BEGIN RSA PRIVATE KEY-----"
local rsa_private_key_match2 = "-----END RSA PRIVATE KEY-----"

local rsa_public_key_match1 = "-----BEGIN RSA PUBLIC KEY-----"
local rsa_public_key_match2 = "-----END RSA PUBLIC KEY-----"


local rsa_keys_pre = function(_rsa_public_key, _rsa_private_key )
    local pubst2,pubre2 = string.find(_rsa_public_key, rsa_public_key_match2,1,true)
    local str_public = string.sub(_rsa_public_key,1,pubre2)

    -- local prist1,prise1 = string.find(_rsa_private_key, rsa_private_key_match1,1,true)
    local prist2,prise2 = string.find(_rsa_private_key, rsa_private_key_match2,1,true)
    -- local temp_private = string.gsub(string.sub(rsa_private_key_match2,1,se2),"\n","")
    local str_private = string.sub(_rsa_private_key,1,prise2)

    return str_public,str_private
end

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
    ngx.log(ngx.ERR,"public: ",_rsa_public_key)
    ngx.log(ngx.ERR,"private: ",_rsa_private_key)
    -- 清理后缀无用字符串
    return rsa_keys_pre(rsa_public_key,rsa_private_key)
end




--[[
    将非 pkcs8 格式的 rsa 私钥 转换为 字符串  需要调用一次rsa_public_key_to_not_pkcs8 进行转换
    @param _private_key_not_pkcs8  非 pkcs8 格式key 
    @return  _private_key_str
]]
function _M.rsa_private_key_to_str(_private_key_not_pkcs8)
    local st1,se1 = string.find(_private_key_not_pkcs8, rsa_private_key_match1,1,true)
    local st2,se2 = string.find(_private_key_not_pkcs8, rsa_private_key_match2,1,true)
    -- return string.gsub(string.sub(_private_key_not_pkcs8,se1+1,st2-1),"\n","")
    local res_str = string.gsub(string.sub(string.sub(_private_key_not_pkcs8,se1+1,st2-1),se1+1,st2-1),"\n","")
    return res_str
end

--[[
--  将非 pkcs8 格式的 rsa 公钥 转换为 字符串  需要调用一次rsa_public_key_to_not_pkcs8 进行转换
-- example 
 
-- @param _public_key_not_pkcs8  非 pkcs8 格式key 
-- @return  _public_key_str
]]
function _M.rsa_public_key_to_str(_public_key_not_pkcs8)
    local st1,se1 = string.find(_public_key_not_pkcs8, rsa_public_key_match1,1,true)
    local st2,se2 = string.find(_public_key_not_pkcs8, rsa_public_key_match2,1,true)
    local res_str = string.gsub(string.sub(_public_key_not_pkcs8,se1+1,st2-1),"\n","")
    return res_str
end


--[[
--  将 rsa 私钥字符串  转换为 非 pkcs8 格式的 key格式  
-- example 
 
-- @param _rsa_private_str_ rsa 私钥字符串
-- @return  _private_key_not_pkcs8
]]
function _M.rsa_private_str_to_key(_rsa_private_str_)
    local begin_str = rsa_private_key_match1
    local end_str = rsa_private_key_match2
    local len =  string.len(_rsa_private_str_)
   -- for i=0,
end

function _M:encrypt( str )
    if not self.m_rsa or type(str) ~= "string" then return nil end

    local encrypted, err = self.m_rsa:encrypt(str)
    if not encrypted then
        ngx.log(ngx.ERR,"failed to encrypt: ", err)
        return
    end
    return encrypted 
end

function _M:decrypt( encrypted )
    if not self.m_rsa then return nil end

    local decrypted, err = self.m_rsa:decrypt(encrypted)
    if not decrypted then
        ngx.log(ngx.ERR,"failed to decrypt: ", err)
        return
    end
    return decrypted 
end


local sort_object = function ( v1, v2 )
	local v1_str = v1[1]
	local v2_str = v2[1]
	local len1 = string.len(v1_str)
	local len2 = string.len(v2_str)
	local iLenLit = len1 > len2 and len2 or len1
	local index = 1

	while index <= iLenLit do
		if string.sub(v1_str, index, index) < string.sub(v2_str, index, index) then
			return true
		elseif string.sub(v1_str, index, index) > string.sub(v2_str, index, index) then
			return false
		else
			index = index + 1
		end
	end
	if len1 < len2 then
		return true
	else
		return false
	end
end

--[[
    签名对象排序后组装成字符串，格式: p1=v1&p2=v2
]]
function _M:get_sort_buf( params )
	local t_src = {}
	for k,v in pairs(params) do
		table.insert(t_src,{k,v})
	end
	table.sort(t_src, sort_object)
	local res = ""
	for i=1,#t_src  do
		if  type(t_src[i][2]) == "table" then
			res = res..t_src[i][1].."={".. _M:get_sort_buf(t_src[i][2]).."}"
		else
			res = res..t_src[i][1].."="..t_src[i][2]
		end
		if i ~= #t_src then
			res = res.."&"
		end
    end
	return res
end

--[[
    RSA 私钥签名
    @params: 
        priv_key:   私钥 pkcs1
        algorithm:  算法, md4 md5 ripemd160 sha0 sha1 sha224 sha256 sha384 sha512
        password:   密钥
        buf:        待签名字符串 
    @return: 
        $1: [string] 签名， nil表示签名错误
        $2: [string] 错误信息
]]
function _M:sign(priv_key, algorithm, password, buf) 
    local opts = {
        private_key = priv_key or RSA_PRIV_KEY,
        -- public_key = pub_key or RSA_PUBLIC_KEY,
        algorithm = algorithm or "SHA1",
        password = password or nil
    }
    local rsa_priv, err = resty_rsa:new(opts)
    if not rsa_priv then
        ngx.log(ngx.ERR, "RSA 签名对象初始化失败, error", err)
        return
    end
    local sign, err = rsa_priv:sign(buf)
    if not sign then
        ngx.log(ngx.ERR, "RSA 签名失败, error=", err)
        return
    end
    return sign
end
 
--[[
    RSA 公钥签名验证
    @params: 

    @return: 
        $1: [string] 签名验证结果， nil表示签名验证错误
        $2: [string] 错误信息
]]
function _M:verify(pub_key, algorithm, buf, sign)
    local opts = {
        -- private_key = priv_key or RSA_PRIV_KEY,
        public_key = pub_key or RSA_PUBLIC_KEY,
        algorithm = algorithm or "SHA1",
        -- password = pwd or nil
    }
    local rsa_pub, err = resty_rsa:new(opts)
    if not rsa_pub then
        ngx.log(ngx.ERR, "RSA 签名对象初始化失败, error", err)
        return
    end
    local verify, err = rsa_pub:verify(buf, sign)
    if not verify then
        ngx.log(ngx.ERR, "RSA 签名验证失败, error=", err)
        return
    end
    return verify
end 

return _M