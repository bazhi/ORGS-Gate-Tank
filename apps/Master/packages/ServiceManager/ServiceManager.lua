
local ServiceManager = {}

local ServiceMap = {}

local index = 0

-- 一台服务区，只允许一个同名服务器
function ServiceManager.Add(name, uri)
    local list = ServiceMap[name]
    if not list then
        list = {}
        ServiceMap[name] = list
    end
    table.insert(list, uri)
end

function ServiceManager.Remove(name, uri)
    local list = ServiceMap[name]
    if list then
        for k, v in ipairs(list) do
            if v == uri then
                table.remove(list, k)
                break
            end
        end
    end
end

function ServiceManager.GetAll()
    return ServiceMap or {}
end

function ServiceManager.GetName()
    for name, _ in pairs(ServiceMap) do
        if name then
            return name
        end
    end
    return nil
end

function ServiceManager.Get(name)
    index = index + 1
    local list = ServiceMap[name] or {}
    
    if #list > 1 then
        local id = index % #list
        return list[id]
    end
    return list[1]
end

return ServiceManager
