
local _M = {
    _VERSION = '0.0.1',
}

local numMap = {
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
    "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
    "U", "V", "W", "X", "Y", "Z",
}

local len = #numMap
local format = string.format
local random = math.random

function _M.seed(seed)
    if not seed then
        if ngx then
            seed = ngx.time() + ngx.worker.pid()
            
        elseif package.loaded['socket'] and package.loaded['socket'].gettime then
            seed = package.loaded['socket'].gettime() * 10000
            
        else
            seed = os.time()
        end
    end
    
    math.randomseed(seed)
    
    return seed
end

function _M.generate()
    return format("%s%s-%s%s-%s%s%s%s%s%s",
        numMap[random(1, len)],
        numMap[random(1, len)],
        numMap[random(1, len)],
        numMap[random(1, len)],
        numMap[random(1, len)],
        numMap[random(1, len)],
        numMap[random(1, len)],
        numMap[random(1, len)],
        numMap[random(1, len)],
    numMap[random(1, len)])
end

return _M
