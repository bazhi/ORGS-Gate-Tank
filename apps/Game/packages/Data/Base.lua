
local Base = cc.class("Base")
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql

function Base:ctor(Tab)
    self._orm = OrmMysql:new(Tab.Name, Tab.Define, Tab.Struct, Tab.Indexes)
    self._data = table.copy(Tab.Struct)
    self._dirty = false
end

function Base:dirty()
    self._dirty = true
end

function Base:isDirty()
    return self._dirty
end

function Base:load(db, where)
    local result, err = self:selectQuery(db, where)
    if err then
        cc.printf(err)
        return nil, "DBError"
    end
    if #result == 1 then
        self:update(result[1])
        return result[1]
    end
    return nil
end

function Base:update(data)
    table.safeMerge(self._data, data)
end

function Base:equal(item, key)
    key = key or "id"
    return self._data[key] == item[key]
end

function Base:equalID(id)
    return self._data["id"] == id
end

function Base:equalCID(cid)
    return self._data["cid"] == cid
end

function Base:getID()
    return self._data.id
end

function Base:set(key, value)
    self._data[key] = value
    self:dirty()
end

function Base:add(key, value)
    if not self._data[key] then
        self._data[key] = 0
    end
    self._data[key] = self._data[key] + value
    self:dirty()
end

function Base:get(key)
    if key then
        return self._data[key]
    end
    return self._data
end

function Base:save(db)
    if not self:isDirty() then
        return true
    end
    
    local id = self:getID()
    if id > 0 then
        local ok, err = self:updateQuery(db, {id = id}, self._data)
        if ok then
            self._dirty = false
        end
        return ok, err
    end
    return false, "id is not set"
end

function Base:insertQuery(db, params)
    local statement = self._orm:insertQuery(params)
    return db:query(statement)
end

function Base:selectQuery(db, where)
    local statement = self._orm:selectQuery(where)
    return db:query(statement)
end

function Base:countQuery(db, where)
    local statement = self._orm:countQuery(where)
    return db:query(statement)
end

function Base:deleteQuery(db, where)
    local statement = self._orm:delQuery(where)
    return db:query(statement)
end

function Base:updateQuery(db, where, params, addparams)
    local statement = self._orm:updateQuery(where, params, addparams)
    return db:query(statement)
end

function Base:insertWithUpdateQuery(db, insertParams, updateparams, addparams)
    local statement = self._orm:insertWithUpdateQuery(insertParams, updateparams, addparams)
    return db:query(statement)
end

return Base
