local sqlite3 = require("lsqlite3")
local M = {}

local db = sqlite3.open(cc.sqlite_file, sqlite3.SQLITE_OPEN_READONLY)
if not db then
    cc.printerror("can not open sqlite_file:"..cc.sqlite_file)
end

local cacheTable = {}
local cacheMap = {}

function M.get(tableName, id, noCache)
    if noCache then
        return M.getNoCache(tableName, id)
    else
        return M.getCache(tableName, id)
    end
end

function M.getCache(tableName, id)
    local cache = cacheTable[tableName]
    if not cache then
        cache = {}
        cacheTable[tableName] = cache
    end
    local result = cache[id]
    if not result and db then
        cache[id] = M.getNoCache(tableName, id)
    end
    return cache[id]
end

function M.getNoCache(tableName, id)
    for row in db:nrows(string.format("SELECT * FROM %s WHERE id = %d", tableName, id)) do
        if row then
            return table.readonly(row, tableName)
        end
    end
end

function M.getAllCache(tableName)
    local cache = cacheMap[tableName]
    if not cache then
        cache = M.getAllNoCache(tableName)
        cacheMap[tableName] = cache
    end
    return cache
end

function M.getAllNoCache(tableName)
    local temp = {}
    for row in db:nrows(string.format("SELECT * FROM %s", tableName)) do
        if row then
            table.insert(temp, table.readonly(row, tableName))
        end
    end
    return temp
end

function M.getAll(tableName, noCache)
    if noCache then
        return M.getAllNoCache(tableName)
    else
        return M.getAllCache(tableName)
    end
end

return M
