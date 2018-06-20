
local Cache = {}

local Data = {}

function Cache.set(key, value)
    Data[key] = value
end

function Cache.get(key)
    return Data[key]
end

function Cache.clear()
    Data = {}
end

return Cache
