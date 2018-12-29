local mysql = require "resty.mysql"
local pairs = pairs
local ngx = ngx
-- local ngx_sleep = ngx.sleep
local string_format = string.format
local table_concat = table.concat
local ngx_quote_sql_str = ngx.quote_sql_str

local M = cc.class("Mysql")

local function escapeValue(value)
    return ngx_quote_sql_str(value)
end

local function escapeName(name)
    return string_format([[`%s`]], name)
end

local function countQuery(tableName, where)
    if where then
        local whereFields = {}
        
        for name, value in pairs(where) do
            whereFields[#whereFields + 1] = escapeName(name) .. "=" .. escapeValue(value)
        end
        
        return string.format("SELECT COUNT(*) FROM %s WHERE %s", escapeName(tableName), table.concat(whereFields, " AND "))
    else
        return string.format("SELECT COUNT(*) FROM %s", escapeName(tableName))
    end
end

local function selectQuery(tableName, where)
    if where then
        local whereFields = {}
        
        for name, value in pairs(where) do
            whereFields[#whereFields + 1] = escapeName(name) .. "=" .. escapeValue(value)
        end
        
        return string.format("SELECT * FROM %s WHERE %s", escapeName(tableName), table.concat(whereFields, " AND "))
    else
        return string.format("SELECT * FROM %s", escapeName(tableName))
    end
end

local function insertQuery(tableName, params)
    local fieldNames = {}
    local fieldValues = {}
    
    for name, value in pairs(params) do
        fieldNames[#fieldNames + 1] = escapeName(name)
        fieldValues[#fieldValues + 1] = escapeValue(value)
    end
    
    return string_format("INSERT INTO %s (%s) VALUES (%s)", escapeName(tableName), table_concat(fieldNames, ","), table_concat(fieldValues, ","))
end

local function updateQuery(tableName, params, where, addparams)
    local fields = {}
    local whereFields = {}
    
    for name, value in pairs(params) do
        fields[#fields + 1] = escapeName(name) .. "=" .. escapeValue(value)
    end
    
    if addparams then
        for name, value in pairs(addparams) do
            local escapename = escapeName(name)
            fields[#fields + 1] = string_format("%s=%s+%s", escapename, escapename, escapeValue(value))
        end
    end
    
    for name, value in pairs(where) do
        whereFields[#whereFields + 1] = escapeName(name) .. "=" .. escapeValue(value)
    end
    
    return string_format("UPDATE %s SET %s WHERE %s", escapeName(tableName), table_concat(fields, ","), table_concat(whereFields, " AND "))
end

local function insertWithUpdateQuery(tableName, params, upparams, addparams)
    local fields = {}
    for name, value in pairs(upparams) do
        fields[#fields + 1] = escapeName(name) .. "=" .. escapeValue(value)
    end
    
    if addparams then
        for name, value in pairs(addparams) do
            local escapename = escapeName(name)
            fields[#fields + 1] = string_format("%s=%s+%s", escapename, escapename, escapeValue(value))
        end
    end
    
    return string_format("%s ON DUPLICATE KEY UPDATE %s", insertQuery(tableName, params), table_concat(fields, ","))
end

local function delQuery(tableName, where)
    local whereFields = {}
    
    for name, value in pairs(where) do
        whereFields[#whereFields + 1] = escapeName(name) .. "=" .. escapeValue(value)
    end
    
    return string_format("DElETE FROM %s WHERE %s", escapeName(tableName), table_concat(whereFields, " AND "))
end

----------------------------
------------Mysql----------------
----------------------------

function M:ctor(config)
    if not config then
        return nil, "no config"
    end
    self.config = config
end

function M:connect()
    if self:isConnected() then
        return self.db
    end
    local db, err = mysql:new()
    if not db then
        return nil, err
    end
    local config = self.config
    db:set_timeout(3000)
    local ok, err, errcode, sqlstate = db:connect(config)
    if not ok then
        errcode = errcode or "nil"
        sqlstate = sqlstate or "nil"
        return nil, "failed to connect:"..err.." ecode: "..errcode .. " sqlstate:" .. sqlstate
    end
    
    db:query("SET NAMES 'utf8'")
    self.db = db
    return db
end

function M:set_keepalive(...)
    if self.db then
        self.db:set_keepalive(...)
    end
    self.db = nil
end

function M:close()
    if self.db then
        local ret, err = self.db:set_keepalive()
        self.db = nil
        return ret, err
    else
        return true
    end
end

function M:isConnected()
    return self.db ~= nil
end

function M:getDB()
    return self.db
end

function M:query(sql)
    if self.db then
        local ok, err, errcode, sqlstate = self.db:query(sql)
        if err and string.find(err, 'failed to send query:') then
            --数据发送不了，则判定链接断开
            self:close()
            return ok, err, errcode, sqlstate
        end
        return ok, err, errcode, sqlstate
    end
    return false, "db is not connected"
end

function M:count(tableName, where)
    return self:query(countQuery(tableName, where))
end

function M:select(tableName, where)
    return self:query(selectQuery(tableName, where))
end

function M:insert(tableName, params)
    return self:query(insertQuery(tableName, params))
end

function M:update(tableName, params, where, addparams)
    return self:query(updateQuery(tableName, params, where, addparams))
end

function M:insertWithUpdate(tableName, params, upparams, addparams)
    return self:query(insertWithUpdateQuery(tableName, params, upparams, addparams))
end

function M:del(tableName, where)
    return self:query(delQuery(tableName, where))
end

return M
