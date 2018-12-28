
local BaseList = cc.import(".BaseList")
local Props = cc.class("Props", BaseList)
local Prop = cc.import(".Prop", ...)

local parse = cc.import("#parse")
local ParseConfig = parse.ParseConfig
local dbConfig = cc.import("#dbConfig")

function Props:createItem()
    return Prop:new()
end

function Props:Initialize(db, rid)
    return self:load(db, {rid = rid})
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

function Props:UseItem(cid, count)
    if not cid then
        return nil, "NoParam"
    end
    local prop = self:getByCID(cid)
    if not prop then
        return nil, "NoneProp"
    end
    local data = prop:get()
    if data.count < count then
        return nil, "LessProp"
    end
    prop:add("count", -count)
    return data
end

function Props:UseItems(items_str)
    local items = ParseConfig.ParseProps(items_str)
    local list = {}
    for _, item in ipairs(items) do
        local data = self:UseItem(item.id, item.count)
        if data then
            table.insert(list, data)
        end
    end
    return list
end

function Props:AddItem(db, item, role)
    if 1 == item.tp then
        --钻石
        role:add("diamond", item.count)
    elseif 2 == item.tp then
        --科技点
        role:add("techPoint", item.count)
    else
        local cid = item.id
        local count = item.count
        local prop = self:getByCID(cid)
        if prop then
            prop:add("count", count)
            return prop:get()
        else
            local cfg = dbConfig.get("cfg_prop", cid)
            if cfg == nil then
                return nil, "NoneConfigID"
            end
            
            local rid = role:get("id")
            prop = self:get()
            local result, err = prop:insertWithUpdateQuery(db, {
                rid = rid,
                count = item.count,
                }, {
                }, {
                count = item.count,
            })
            if err then
                cc.printf(err)
                return nil, "DBError"
            end
            
            if result and result.insert_id then
                local datas = self:load(db, {id = result.insert_id})
                if #datas == 1 then
                    return datas[1]
                end
            end
        end
    end
    
    return nil, "OperationNotPermit"
end

function Props:AddRewards(db, items, role)
    if not items or not role or not db then
        return nil, "NoParam"
    end
    local itemDatas = {}
    local rewards = ParseConfig.ParseRewards(items)
    for _, item in ipairs(rewards) do
        local _ok, _err, data = self:AddItem(db, item, role)
        if data then
            table.insert(itemDatas, data)
        end
    end
    return itemDatas, nil, rewards
end

return Props
