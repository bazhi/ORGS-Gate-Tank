
local BaseList = cc.class("BaseList")

function BaseList:ctor()
    
end

function BaseList:createItem()
    return nil
end

function BaseList:getTemplate()
    if not self._Template then
        self._Template = self:createItem()
    end
    return self._Template
end

function BaseList:set(values)
    self._Datas = {}
    for _, v in ipairs(values) do
        local item = self:createItem()
        if item then
            item:update(v)
            table.insert(self._Datas, item)
        end
    end
end

function BaseList:delete(id)
    self._Datas = self._Datas or {}
    local values = self._Datas
    for k, v in ipairs(values) do
        if v:equalID(id) then
            table.remove(values, k)
            return
        end
    end
end

function BaseList:getIDList()
    local ids = {}
    local values = self._Datas or {}
    for _, v in ipairs(values) do
        table.insert(ids, v:getID())
    end
    return ids
end

function BaseList:updates(values)
    local bupdate = false
    for _, v in ipairs(values) do
        bupdate = true
        self:update(v)
    end
    return bupdate
end

function BaseList:update(value)
    self._Datas = self._Datas or {}
    local values = self._Datas
    for _, v in ipairs(values) do
        if v:equal(value) then
            v:update(value)
            return v
        end
    end
    local item = self:createItem()
    if item then
        item:update(value)
        table.insert(self._Datas, item)
    end
    return item
end

function BaseList:get(id)
    if not id then
        return self:createItem()
    end
    
    local values = self._Datas or {}
    for _, v in ipairs(values) do
        if v:equalID(id) then
            return v
        end
    end
    return nil
end

function BaseList:getByCID(cid)
    if not cid then
        return nil
    end
    
    local values = self._Datas or {}
    for _, v in ipairs(values) do
        if v:equalCID(cid) then
            return v
        end
    end
    return nil
end

function BaseList:getOriginal(cid)
    if not cid then
        return nil
    end
    
    local values = self._Datas or {}
    for _, v in ipairs(values) do
        if v.isOriginal and v:isOriginal(cid) then
            return v
        end
    end
    return nil
end

return BaseList
