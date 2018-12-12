
local Random = {}

--从talbe中random 出n个数据
function Random.Table(tab, count)
    local t = table.clone(tab)
    local result = {}
    math.randomseed(os.time())
    for _ = 1, count, 1 do
        local cnt = #t
        if cnt > 0 then
            local index = math.random(1, cnt)
            local cfg = t[index]
            table.insert(result, cfg)
            table.remove(t, index)
        end
    end
    return result
end

return Random
