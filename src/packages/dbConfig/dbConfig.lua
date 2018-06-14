local sqlite3 = require("lsqlite3")
local M = {}

local db = sqlite3.open(cc.sqlite_file, sqlite3.SQLITE_OPEN_READONLY)
if not db then
    cc.printerror("can not open sqlite_file:"..cc.sqlite_file)
end

local cacheAll = {}

function M.get(tab, id, noCache)
    if noCache then
        return M.getNoCache(tab, id)
    else
        return M.getCache(tab, id)
    end
end

function M.getCache(tab, id)
    local cache = cacheAll[tab]
    if not cache then
        cache = {}
        cacheAll[tab] = cache
    end
    local result = cache[id]
    if not result and db then
        for row in db:nrows(string.format("SELECT * FROM %s WHERE id = %d", tab, id)) do
            cache[row.id] = row
        end
    end
    return cache[id]
end

function M.getNoCache(tab, id)
    for row in db:nrows(string.format("SELECT * FROM %s WHERE id = %d", tab, id)) do
        if row then
            return row
        end
    end
end

return M
