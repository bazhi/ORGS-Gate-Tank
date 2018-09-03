local mysql = require "resty.mysql"
local pairs = pairs
local ngx = ngx
-- local ngx_sleep = ngx.sleep
local string_format = string.format
local table_concat = table.concat
local ngx_quote_sql_str = ngx.quote_sql_str
local sdDBEvent = ngx.shared.sdDBEvent
local json = cc.import("#json")
local json_encode = json.encode
--local json_decode = json.decode

local _M = {}

function _M.create(config)
    if not config then
        cc.printerror("can not find config:")
        return nil, "can not find config:"
    end
    
    local db, err = mysql:new()
    if not db then
        return nil, err
    end
    db:set_timeout(3000) -- 1 sec
    local ok, err, errcode, sqlstate = db:connect(config)
    if not ok then
        errcode = errcode or "nil"
        sqlstate = sqlstate or "nil"
        return nil, "failed to connect:"..err.." ecode: "..errcode .. " sqlstate:" .. sqlstate
    end
    
    db:query("SET NAMES 'utf8'")
    return db
end

function _M.pushSql(sql, connectid, action, key)
    sdDBEvent:lpush("_MYSQL_EVENT", json_encode({
        sql = sql,
        connectid = connectid,
        action = action,
        key = key
    }))
end

function _M.close(db)
    --放到sql池
    local ret, err = db:set_keepalive()
    if not ret then
        cc.showinfo(err)
    end
    return ret, err
end

function _M.countSql(tableName, where)
    local sql
    if where then
        local whereFields = {}
        
        for name, value in pairs(where) do
            whereFields[#whereFields + 1] = _M._escapeName(name) .. "=" .. _M._escapeValue(value)
        end
        
        sql = string.format("SELECT COUNT(*) FROM %s WHERE %s",
            _M._escapeName(tableName),
        table.concat(whereFields, " AND "))
    else
        sql = string.format("SELECT COUNT(*) FROM %s",
        _M._escapeName(tableName))
    end
    return sql
end

function _M.count(db, tableName, where)
    return db:query(_M.countSql(tableName, where))
end

function _M.selectSql(tableName, where)
    local sql
    if where then
        local whereFields = {}
        
        for name, value in pairs(where) do
            whereFields[#whereFields + 1] = _M._escapeName(name) .. "=" .. _M._escapeValue(value)
        end
        
        sql = string.format("SELECT * FROM %s WHERE %s",
            _M._escapeName(tableName),
        table.concat(whereFields, " AND "))
    else
        sql = string.format("SELECT * FROM %s",
        _M._escapeName(tableName))
    end
    return sql
end

function _M.select(db, tableName, where)
    return db:query(_M.selectSql(tableName, where))
end

function _M.insertSql(tableName, params)
    local fieldNames = {}
    local fieldValues = {}
    
    for name, value in pairs(params) do
        fieldNames[#fieldNames + 1] = _M._escapeName(name)
        fieldValues[#fieldValues + 1] = _M._escapeValue(value)
    end
    
    local sql = string_format("INSERT INTO %s (%s) VALUES (%s)",
        _M._escapeName(tableName),
        table_concat(fieldNames, ","),
    table_concat(fieldValues, ","))
    return sql
end

function _M.insert(db, tableName, params)
    return db:query(_M.insertSql(tableName, params))
end

function _M.updateSql(tableName, params, where, addparams)
    local fields = {}
    local whereFields = {}
    
    for name, value in pairs(params) do
        fields[#fields + 1] = _M._escapeName(name) .. "=" .. _M._escapeValue(value)
    end
    
    if addparams then
        for name, value in pairs(addparams) do
            local escapename = _M._escapeName(name)
            fields[#fields + 1] = string_format("%s=%s+%s", escapename, escapename, _M._escapeValue(value))
        end
    end
    
    for name, value in pairs(where) do
        whereFields[#whereFields + 1] = _M._escapeName(name) .. "=" .. _M._escapeValue(value)
    end
    
    local sql = string_format("UPDATE %s SET %s WHERE %s",
        _M._escapeName(tableName),
        table_concat(fields, ","),
    table_concat(whereFields, " AND "))
    return sql
end

function _M.update(db, tableName, params, where, addparams)
    return db:query(_M.updateSql(tableName, params, where, addparams))
end

function _M.insertWithUpdateSql(tableName, params, upparams, addparams)
    local fields = {}
    for name, value in pairs(upparams) do
        fields[#fields + 1] = _M._escapeName(name) .. "=" .. _M._escapeValue(value)
    end
    
    if addparams then
        for name, value in pairs(addparams) do
            local escapename = _M._escapeName(name)
            fields[#fields + 1] = string_format("%s=%s+%s", escapename, escapename, _M._escapeValue(value))
        end
    end
    
    local sql = _M.insertSql(tableName, params)
    sql = string_format("%s ON DUPLICATE KEY UPDATE %s", sql, table_concat(fields, ","))
    return sql
end

function _M.insertWithUpdate(db, tableName, params, upparams, addparams)
    return db:query(_M.insertWithUpdateSql(tableName, params, upparams, addparams))
end

function _M.delSql(tableName, where)
    local whereFields = {}
    
    for name, value in pairs(where) do
        whereFields[#whereFields + 1] = _M._escapeName(name) .. "=" .. _M._escapeValue(value)
    end
    
    local sql = string_format("DElETE FROM %s WHERE %s",
        _M._escapeName(tableName),
    table_concat(whereFields, " AND "))
    return sql
end

function _M.del(db, tableName, where)
    return db:query(_M.delSql(tableName, where))
end

function _M._escapeValue(value)
    return ngx_quote_sql_str(value)
end

function _M._escapeName(name)
    return string_format([[`%s`]], name)
end

return _M
