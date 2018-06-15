
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

function Base:get()
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

function Base:delQuery(where)
    return self._orm:delQuery(where)
end

function Base:updateQuery(params, where, addparams)
    return self._orm:updateQuery(params, where, addparams)
end

function Base:insertWithUpdateQuery(params, updateparams, addparams)
    return self._orm:insertWithUpdateQuery(params, updateparams, addparams)
end

function Base:pushQuery(query, connectid, action)
    self._orm:pushQuery(query, connectid, action)
end

return Base
