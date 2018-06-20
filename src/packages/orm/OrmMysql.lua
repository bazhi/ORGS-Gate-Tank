
local OrmMysql = cc.class("OrmMysql")
local string_format = string.format
local table_concat = table.concat
local ngx_quote_sql_str = ngx.quote_sql_str
local sdDBEvent = ngx.shared.sdDBEvent
local json = cc.import("#json")
local json_encode = json.encode

function OrmMysql:ctor(tableName, define, defualt, keyinfo)
    self._TableName = tableName or ""
    self._Define = define or {}
    self._Default = defualt or {}
    self._KeyInfo = keyinfo or {}
end

local function _escapeValue(value)
    return ngx_quote_sql_str(value)
end

local function _escapeName(name)
    return string_format([[`%s`]], name)
end

function OrmMysql:getMapDefine()
    local list = {}
    for k, v in pairs(self._Define) do
        table.insert(list, _escapeName(k) .. " " .. v)
    end
    return table.concat(list, ", ")
end

function OrmMysql:Create(db)
    local query = string.format("CREATE TABLE IF NOT EXISTS %s(%s);", _escapeName(self._TableName), self:getMapDefine())
    db:query(query)
    self:Migrate(db)
end

function OrmMysql:AlterAdd(db, fieldName, fieldType)
    local query = string.format("ALTER TABLE %s ADD %s %s", _escapeName(self._TableName), _escapeName(fieldName), fieldType)
    db:query(query)
end

function OrmMysql:AlterSet(db, fieldName, value)
    local query = string.format("ALTER TABLE %s ALTER COLUMN %s SET DEFAULT %s", _escapeName(self._TableName), _escapeName(fieldName), _escapeValue(value))
    db:query(query)
end

function OrmMysql:AlterIndex(db, cmd)
    local query = string.format("ALTER TABLE %s ADD %s", _escapeName(self._TableName), cmd)
    db:query(query)
end

function OrmMysql:Desc(db)
    local query = string.format("desc %s", _escapeName(self._TableName))
    return db:query(query)
end

function OrmMysql:Migrate(db)
    local fields = self:Desc(db)
    if not fields then
        return
    end
    
    --检查增加字段
    local toBeAdd = table.copy(self._Define)
    for _, v in ipairs(fields) do
        toBeAdd[v.Field] = nil
    end
    for k, v in pairs(toBeAdd) do
        self:AlterAdd(db, k, v)
    end
    
    --修改默认值
    for k, v in pairs(self._Default) do
        self:AlterSet(db, k, v)
    end
    
    --设置key
    for _, v in pairs(self._KeyInfo) do
        self:AlterIndex(db, v)
    end
end
--------------------------------Insert------------------------------------------
function OrmMysql:insertQuery(params)
    local tableName = self._TableName
    local fieldNames = {}
    local fieldValues = {}
    
    for name, value in pairs(params) do
        fieldNames[#fieldNames + 1] = _escapeName(name)
        fieldValues[#fieldValues + 1] = _escapeValue(value)
    end
    
    return string_format("INSERT INTO %s (%s) VALUES (%s)", _escapeName(tableName), table_concat(fieldNames, ","), table_concat(fieldValues, ","))
end

---失败 返回 nil
---成功
-- {
--     affected_rows = 1,
--     insert_id = 6,
--     server_status = 2,
--     warning_count = 0,
-- },
function OrmMysql:insert(db, params)
    return db:query(self:insertQuery(params))
end
--------------------------------Insert------------------------------------------

--------------------------------Select------------------------------------------
function OrmMysql:selectQuery(where)
    local tableName = self._TableName
    local query
    if where then
        local whereFields = {}
        for name, value in pairs(where) do
            whereFields[#whereFields + 1] = _escapeName(name) .. "=" .. _escapeValue(value)
        end
        query = string_format("SELECT * FROM %s WHERE %s", _escapeName(tableName), table.concat(whereFields, " AND "))
    else
        query = string_format("SELECT * FROM %s", _escapeName(tableName))
    end
    return query
end

--{
-- [1] = {id = 1},
-- [2] = {id = 2}
-- }
function OrmMysql:select(db, where)
    return db:query(self:selectQuery(where))
end
--------------------------------Select------------------------------------------

--------------------------------Count------------------------------------------
function OrmMysql:countQuery(where)
    local tableName = self._TableName
    local query
    if where then
        local whereFields = {}
        for name, value in pairs(where) do
            whereFields[#whereFields + 1] = _escapeName(name) .. "=" .. _escapeValue(value)
        end
        query = string.format("SELECT COUNT(*) FROM %s WHERE %s", _escapeName(tableName), table.concat(whereFields, " AND "))
    else
        query = string.format("SELECT COUNT(*) FROM %s", _escapeName(tableName))
    end
    return query
end

-- 返回值
-- {
--     1 = {
--         "COUNT(*)" = "1",
--     },
-- }
function OrmMysql:count(db, where)
    local ret = db:query(self:countQuery(where))
    if not ret then
        return 0
    end
    
    return tonumber(ret[1]["COUNT(*)"])
end
--------------------------------Count------------------------------------------

--------------------------------Delete------------------------------------------
function OrmMysql:delQuery(where)
    local tableName = self._TableName
    local whereFields = {}
    
    for name, value in pairs(where) do
        whereFields[#whereFields + 1] = _escapeName(name) .. "=" .. _escapeValue(value)
    end
    
    return string_format("DElETE FROM %s WHERE %s", _escapeName(tableName), table.concat(whereFields, " AND "))
end

--{
--     affected_rows = 1,
--     insert_id = 6,
--     server_status = 2,
--     warning_count = 0,
-- },

function OrmMysql:del(db, where)
    return db:query(self:delQuery(where))
end

--------------------------------Delete------------------------------------------

--------------------------------Update------------------------------------------

function OrmMysql:updateQuery(params, where, addparams)
    local tableName = self._TableName
    local fields = {}
    local whereFields = {}
    
    for name, value in pairs(params) do
        fields[#fields + 1] = _escapeName(name) .. "=" .. _escapeValue(value)
    end
    
    if addparams then
        for name, value in pairs(addparams) do
            local escapename = _escapeName(name)
            fields[#fields + 1] = string_format("%s=%s+%s", escapename, escapename, _escapeValue(value))
        end
    end
    
    for name, value in pairs(where) do
        whereFields[#whereFields + 1] = _escapeName(name) .. "=" .. _escapeValue(value)
    end
    
    return string_format("UPDATE %s SET %s WHERE %s", _escapeName(tableName), table_concat(fields, ","), table_concat(whereFields, " AND "))
end

--返回值
-- {
--     affected_rows = 1,
--     insert_id = 6,
--     message       = "Rows matched: 0  Changed: 0  Warnings: 0"
--     server_status = 2,
--     warning_count = 0,
-- },
function OrmMysql:update(db, params, where, addparams)
    return db:query(self:updateQuery(params, where, addparams))
end

--------------------------------Update------------------------------------------

--------------------------------Insert Update------------------------------------------

function OrmMysql:insertWithUpdateQuery(params, updateparams, addparams)
    local fields = {}
    for name, value in pairs(updateparams) do
        fields[#fields + 1] = _escapeName(name) .. "=" .. _escapeValue(value)
    end
    
    if addparams then
        for name, value in pairs(addparams) do
            local escapename = _escapeName(name)
            fields[#fields + 1] = string_format("%s=%s+%s", escapename, escapename, _escapeValue(value))
        end
    end
    
    local query = self:insertQuery(params)
    query = string_format("%s ON DUPLICATE KEY UPDATE %s", query, table_concat(fields, ","))
    return query
end

--失败返回nil
-- {
--     affected_rows = 1,
--     insert_id = 6,
--     server_status = 2,
--     warning_count = 0,
-- },
function OrmMysql:insertWithUpdate(db, params, upparams, addparams)
    return db:query(self:insertWithUpdateQuery(params, upparams, addparams))
end

--------------------------------Insert Update------------------------------------------
-- query, sql语句
-- connectid, 链接id
-- action, 回调action
-- param, 回调参数
function OrmMysql:pushQuery(query, connectid, action, params)
    sdDBEvent:lpush("_MYSQL_EVENT", json_encode({
        query = query,
        connectid = connectid,
        action = action,
        params = params,
    }))
end

return OrmMysql

