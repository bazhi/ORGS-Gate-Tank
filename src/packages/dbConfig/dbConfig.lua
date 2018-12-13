local sqlite3 = require("lsqlite3")
local ngx_quote_sql_str = ngx.quote_sql_str
local M = {}

local db = sqlite3.open(cc.sqlite_file, sqlite3.SQLITE_OPEN_READONLY)
if not db then
    cc.printerror("can not open sqlite_file:"..cc.sqlite_file)
end

local cacheTable = {}
local cacheMap = {}

local function _escapeValue(value)
    return ngx_quote_sql_str(value)
end

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

function M.getAllCache(tableName, where)
    local cache = cacheMap[tableName]
    if not cache then
        cache = M.getAllNoCache(tableName, where)
        cacheMap[tableName] = cache
    end
    return cache
end

function M.getAllNoCache(tableName, where)
    local query
    if where then
        local whereFields = {}
        for name, value in pairs(where) do
            whereFields[#whereFields + 1] = name .. " = " .. _escapeValue(value)
        end
        query = string.format("SELECT * FROM %s WHERE %s", tableName, table.concat(whereFields, " AND "))
    else
        query = string.format("SELECT * FROM %s", tableName)
    end
    
    local temp = {}
    for row in db:nrows(query) do
        if row then
            table.insert(temp, table.readonly(row, tableName))
        end
    end
    return temp
end

function M.getAll(tableName, where, noCache)
    if noCache then
        return M.getAllNoCache(tableName, where)
    else
        return M.getAllCache(tableName, where)
    end
end

return M
