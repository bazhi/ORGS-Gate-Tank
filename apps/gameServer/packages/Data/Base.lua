
local Base = cc.class("Base")
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql

function Base:ctor(Tab)
    self._orm = OrmMysql:new(Tab.Name, Tab.Define, Tab.Struct, Tab.Indexes)
    self._data = table.copy(Tab.Struct)
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

function Base:get(key)
    if key then
        return self._data[key]
    end
    return self._data
end

function Base:insertQuery(params)
    return self._orm:insertQuery(params)
end

function Base:selectQuery(where)
    return self._orm:selectQuery(where)
end

function Base:countQuery(where)
    return self._orm:countQuery(where)
end

function Base:deleteQuery(where)
    return self._orm:delQuery(where)
end

function Base:updateQuery(where, params, addparams)
    return self._orm:updateQuery(where, params, addparams)
end

function Base:insertWithUpdateQuery(params, updateparams, addparams)
    return self._orm:insertWithUpdateQuery(params, updateparams, addparams)
end

function Base:pushQuery(query, connectid, action, params)
    self._orm:pushQuery(query, connectid, action, params)
end

return Base
