
local BaseList = cc.import(".BaseList")
local Props = cc.class("Props", BaseList)
local Prop = cc.import(".Prop", ...)

local parse = cc.import("#parse")
local ParseConfig = parse.ParseConfig
local dbConfig = cc.import("#dbConfig")

function Props:createItem()
    return Prop:new()
end

function Props:Login(connectid, action, lastTime, loginTime, roleid)
    if not connectid or not lastTime or not loginTime or not roleid then
        return false, "NoParam"
    end
    
    local prop = self:get()
    local query = prop:selectQuery({rid = roleid})
    prop:pushQuery(query, connectid, action)
    return true
end

function Props:LoadOne(connectid, action, id)
    if not connectid or not id then
        return false, "NoParam"
    end
    
    local prop = self:get()
    local query = prop:selectQuery({id = id})
    prop:pushQuery(query, connectid, action)
    return true
end

function Props:HasItems(items)
    for _, item in ipairs(items) do
        if not item then
            return false
        end
        if not self:HasItem(item.id, item.count) then
            return false
        end
    end
    return true
end

function Props:HasItem(cid, count)
    if not cid or not count then
        return false
    end
    local prop = self:getByCID(cid)
    if not prop then
        return false
    end
    local data = prop:get()
    if data.count < count then
        return false
    end
    return true
end

function Props:UseItem(connectid, action, cid, count)
    if not connectid or not cid then
        return false, "NoParam"
    end
    local prop = self:getByCID(cid)
    if not prop then
        return false, "NoneProp"
    end
    local data = prop:get()
    if data.count < count then
        return false, "LessProp"
    end
    
    data.count = data.count - count
    local query = prop:updateQuery({id = data.id}, {}, {count = -count})
    prop:pushQuery(query, connectid, action)
    return true, nil, data
end

function Props:UseItems(connectid, action, items)
    local list = {}
    for _, item in ipairs(items) do
        local _, _, data = self:UseItem(connectid, action, item.id, item.count)
        if data then
            table.insert(list, data)
        end
    end
    return true, nil, list
end

--直接增加道具
function Props:IncreaseItem(connectid, action, item)
    local prop = self:getByCID(item.id)
    if not prop then
        return false
    end
    local data = prop:get()
    data.count = data.count + item.count
    local query = prop:updateQuery({id = data.id}, {}, {count = item.count})
    prop:pushQuery(query, connectid, action)
    return true, nil, data
end

--更新道具
function Props:IncreaseUpdate(connectid, action, insertid, item)
    local prop = self:getByCID(item.id)
    if prop then
        local data = prop:get()
        data.count = data.count + item.count
        return true, nil, data
    end
    self:LoadOne(connectid, action, insertid)
end

--
function Props:AddItem(connectid, action, item, role)
    if 1 == item.tp then
        --钻石
        role:AddData(connectid, nil, 0, item.count, 0)
    elseif 2 == item.tp then
        --科技点
        role:AddData(connectid, nil, item.count, 0, 0)
    else
        local ok, err, itemData = self:IncreaseItem(connectid, nil, item)
        if ok then
            return ok, err, itemData
        end
        --道具
        local cfg = dbConfig.get("cfg_prop", item.id)
        if cfg ~= nil then
            local rid = role:get("id")
            local prop = self:get()
            local query = prop:insertWithUpdateQuery({
                rid = rid,
                count = item.count,
                }, {
                }, {
                count = item.count,
            })
            prop:pushQuery(query, connectid, action, item)
            return true
        end
    end
end

function Props:AddRewards(connectid, action, items, role)
    if not connectid or not items or not role then
        return false, "NoParam"
    end
    local itemDatas = {}
    local rewards = ParseConfig.ParseRewards(items)
    for _, item in ipairs(rewards) do
        local _ok, _err, data = self:AddItem(connectid, action, item, role)
        if data then
            table.insert(itemDatas, data)
        end
    end
    return true, nil, itemDatas, rewards
end

return Props
