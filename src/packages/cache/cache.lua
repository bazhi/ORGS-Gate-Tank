
local Cache = {}
local ngx_now = ngx.now

local Data = {}

function Cache.set(key, value, time)
    Data[key] = {
        [1] = value,
        [2] = time + ngx_now(),
    }
end

function Cache.get(key)
    local var = Data[key]
    if var then
        if not var[2] or ngx_now() < var[2] then
            return var[1]
        end
    end
    return nil
end

function Cache.clear()
    Data = {}
end

return Cache
