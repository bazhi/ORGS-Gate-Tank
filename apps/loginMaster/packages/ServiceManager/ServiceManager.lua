
local ServiceManager = {}

local ServiceMap = {}

-- 一台服务区，只允许一个同名服务器
function ServiceManager.Add(name, host, port)
    local collect = ServiceMap[name]
    if not collect then
        collect = {}
        ServiceMap[name] = collect
    end
    collect[host] = port
end

function ServiceManager.Remove(name, host)
    local collect = ServiceMap[name]
    if collect then
        collect[host] = nil
    end
end

function ServiceManager.GetAll()
    return ServiceMap or {}
end

function ServiceManager.Get(name)
    return {
        name = name,
        addr = ServiceMap[name],
    }
end

return ServiceManager
