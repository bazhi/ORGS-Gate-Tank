
local BaseList = cc.import(".BaseList")
local Missions = cc.class("Missions", BaseList)
local Mission = cc.import(".Mission")
local dbConfig = cc.import("#dbConfig")
local utility = cc.import("#utility")
local Random = utility.Random

function Missions:createItem()
    return Mission:new()
end

function Missions:InitializeAll(connectid, action, roleid)
    local missions = dbConfig.getAll("cfg_mission")
    local lsitAdd = Random.Table(missions, 5)
    local endIndex = #lsitAdd
    local mission = self:get()
    for i, cfg in ipairs(lsitAdd) do
        local query = mission:insertQuery({rid = roleid, cid = cfg.id})
        if endIndex == i then
            mission:pushQuery(query, connectid, action)
        else
            mission:pushQuery(query, connectid, nil)
        end
    end
end

function Missions:LoadAll(connectid, action, roleid)
    if not connectid or not action or not roleid then
        return false, "NoParam"
    end
    local mission = self:get()
    local query = mission:selectQuery({rid = roleid})
    mission:pushQuery(query, connectid, action)
    return true
end

function Missions:Login(connectid, action, lastTime, loginTime, roleid)
    if not connectid or not lastTime or not loginTime or not roleid then
        return false, "NoParam"
    end
    
    local loginDate = os.date("*t", loginTime)
    local lastDate = os.date("*t", lastTime)
    
    if loginDate.year ~= lastDate.year or loginDate.yday ~= lastDate.yday then
        --新的一天
        self:DeleteAll(connectid, nil, roleid)
        self:InitializeAll(connectid, action, roleid)
        return true
    end
    
    return false
end

function Missions:DeleteAll(connectid, action, roleid)
    local mission = self:get()
    local query = mission:deleteQuery({rid = roleid})
    mission:pushQuery(query, connectid, action)
    return true
end

function Missions:process(connectid, action, tp, id, place, count, override)
    local list = self._Datas
    for _, item in ipairs(list) do
        item:process(connectid, action, tp, id, place, count, override)
    end
end

return Missions
