
local M = {}

function M.ParseDecompose(decompose)
    local result = {}
    local items = string.split(decompose, "|")
    for _, v in ipairs(items) do
        local info = string.split(v, "_")
        table.insert(result, {
            id = tonumber(info[1]),
            count = tonumber(info[2]),
        })
    end
    
    return result
end

function M.ParseIDList(idstr)
    local result = {}
    if not idstr then
        return result
    end
    
    local items = string.split(idstr, "|")
    for _, v in ipairs(items) do
        table.insert(result, tonumber(v))
    end
    return result
end

function M.ParseProbability(idstr)
    local result = {}
    local items = string.split(idstr, "|")
    for _, v in ipairs(items) do
        local info = string.split(v, "_")
        table.insert(result, {
            id = tonumber(info[1]),
            probability = tonumber(info[2]),
        })
    end
    
    return result
end

return M
