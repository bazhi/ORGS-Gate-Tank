
local pcall = pcall
local mpack = require("cmsgpack")

local c_encode = mpack.pack
local c_decode = mpack.unpack

local _M = {
    
}

function _M.encode(var)
    local ok, res = pcall(c_encode, var)
    if ok then return res end
    return nil, res -- res is error
end

function _M.decode(text)
    local ok, res = pcall(c_decode, text)
    if ok then return res end
    return nil, res -- res is error
end

return _M
