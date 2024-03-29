--[[
--  作者:Steven
--  日期:2017-02-26
--  文件名:rsa.lua
--  版权说明:南国一梦科技有限公司.版权所有©copy right.
--  RSA非对称加密技术的功能,用于通信过程开始以及中间过程的加密处理,进一步保护数据的安全性
--  由于非对称加密技术的计算量比较大,所以系统在接入时进行一次加密处理,后续采用ace堆成加密
--  加 密算法通常分为对称性加密算法和非对称性加密算法，对于对称性加密算法，信息接收双方都需事先知道密匙和加解密算法且其密匙是相同的，之后便是对数据进行 加解密了。非对称算法与之不同，发送双方A,B事先均生成一堆密匙，然后A将自己的公有密匙发送给B，B将自己的公有密匙发送给A，如果A要给B发送消 息，则先需要用B的公有密匙进行消息加密，然后发送给B端，此时B端再用自己的私有密匙进行消息解密，B向A发送消息时为同样的道理。

几种对称性加密算法：AES,DES,3DES

DES是一种分组数据加密技术（先将数据分成固定长度的小数据块，之后进行加密），速度较快，适用于大量数据加密，而3DES是一种基于DES的加密算法，使用3个不同密匙对同一个分组数据块进行3次加密，如此以使得密文强度更高。

相较于DES和3DES算法而言，AES算法有着更高的速度和资源使用效率，安全级别也较之更高了，被称为下一代加密标准。

几种非对称性加密算法：RSA,DSA,ECC

RSA和DSA的安全性及其它各方面性能都差不多，而ECC较之则有着很多的性能优越，包括处理速度，带宽要求，存储空间等等。

几种线性散列算法（签名算法）：MD5,SHA1,HMAC

这几种算法只生成一串不可逆的密文，经常用其效验数据传输过程中是否经过修改，因为相同的生成算法对于同一明文只会生成唯一的密文，若相同算法生成的密文不同，则证明传输数据进行过了修改。通常在数据传说过程前，使用MD5和SHA1算法均需要发送和接收数据双方在数据传送之前就知道密匙生成算法，而HMAC与之不同的是需要生成一个密匙，发送方用此密匙对数据进行摘要处理（生成密文），接收方再利用此密匙对接收到的数据进行摘要处理，再判断生成的密文是否相同。

对于各种加密算法的选用：

由于对称加密算法的密钥管理是一个复杂的过程，密钥的管理直接决定着他的安全性，因此当数据量很小时，我们可以考虑采用非对称加密算法。

在实际的操作过程中，我们通常采用的方式是：采用非对称加密算法管理对称算法的密钥，然后用对称加密算法加密数据，这样我们就集成了两类加密算法的优点，既实现了加密速度快的优点，又实现了安全方便管理密钥的优点。

如果在选定了加密算法后，那采用多少位的密钥呢？一般来说，密钥越长，运行的速度就越慢，应该根据的我们实际需要的安全级别来选择，一般来说，RSA建议采用1024位的数字，ECC建议采用160位，AES采用128为即可。



对于几种加密算法的内部实现原理，我不想研究的太透彻，这些问题就留给科学家们去研究吧。而对于其实现而言，网上有很多开源版本，比较经典的是PorlaSSL（官网：http://en.wikipedia.org/wiki/PolarSSL ）。其它语言如JAVA,OBJC也都有相应的类库可以使用。以下附上自己用OC封装的通用加密类：
--]]

--ECB 方式无需iv,传递一个16字节的iv以便用原始key进行EVP_DecryptInit_ex初始化

--aes 算法
local aes = require "resty.aes"
local str = require "resty.string"

--ECB 方式无需iv,传递一个16字节的iv以便用原始key进行EVP_DecryptInit_ex初始化
-- local price_decode = aes:new(key,nil,aes.cipher(128,"ecb"),{iv=dspkey})
-- local base_decode_bytes = ngx.decode_base64(ad_price)
-- ngx.log(ngx.DEBUG,"base_decode_price_byte:" .. str.to_hex(base_decode_price))
-- --补充一个空块的加密结果，以适应decrypt函数的调用
-- base_decode_bytes = base_decode_bytes .. pad_bytes
-- local price =  price_decode:decrypt(base_decode_bytes)



-- local crypto = require("crypto")


local _M={}

--[[
-- aes_ecb_encryp 加密 使用 aes ecb 模式 默认使用 128 pcksc5 16位的iv进行加密 返回base64的结果
-- example
   	local hash_help = require "common.hash_help"
	local str="md5str"
	local md5str = hash_help(str)

-- @param  _key aes 加密的密码
-- @param  _str 待处理的字符串
-- @return nil,表示失败; 返回base64的数据
--]]
_M.aes_ecb_encryp = function(_key, _str)
    -- Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
    local aes_128_ecb_with_PKCS5Padding = assert(aes:new(_key,
            nil, aes.cipher(128,"ecb"), {iv="1234567890123457"},nil))
    -- AES 128 CBC with IV and no SALT
    local encrypted = aes_128_ecb_with_PKCS5Padding:encrypt(_str)
    return ngx.encode_base64(encrypted)
end

_M.aes_ecb_decryp = function(_key, _str)
    local _str = ngx.decode_base64(ngx.unescape_uri(_str))
    -- Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
    local aes_128_ecb_with_PKCS5Padding = assert(aes:new(_key,
            nil, aes.cipher(128,"ecb"), {iv="1234567890123457"},nil))
    -- AES 128 CBC with IV and no SALT
    local decrypted = aes_128_ecb_with_PKCS5Padding:decrypt(_str)
    return decrypted
end


return _M

