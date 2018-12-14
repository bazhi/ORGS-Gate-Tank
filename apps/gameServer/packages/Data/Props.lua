
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

function Props:AddItem(connectid, action, item, role)
    
    if 1 == item.tp then
        --钻石
        role:AddData(connectid, nil, 0, item.count, 0)
    elseif 2 == item.tp then
        --科技点
        role:AddData(connectid, nil, item.count, 0, 0)
    else
        local rid = role:get("id")
        --道具
        local cfg = dbConfig.get("cfg_prop", item.id)
        if cfg ~= nil then
            local prop = self:get()
            local query = prop:insertWithUpdateQuery({
                rid = rid,
                count = item.count,
            }, {}, {count = item.count})
            prop:pushQuery(query, connectid, action)
        end
    end
end

function Props:AddRewards(connectid, action, items, role)
    if not connectid or not items or not role then
        return false, "NoParam"
    end
    
    local rewards = ParseConfig.ParseRewards(items)
    for _, item in ipairs(rewards) do
        self:AddItem(connectid, action, item, role)
    end
    return true, rewards
end

return Props
