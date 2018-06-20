
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

return M
