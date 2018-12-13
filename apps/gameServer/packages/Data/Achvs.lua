
local BaseList = cc.import(".BaseList")
local Achvs = cc.class("Achvs", BaseList)
local Achv = cc.import(".Achv")
local dbConfig = cc.import("#dbConfig")

function Achvs:createItem()
    return Achv:new()
end

function Achvs:InitializeAll(connectid, action, roleid)
    local achvs = dbConfig.getAll("cfg_achievement", {pre_id = 0})
    local achv = self:get()
    local endIndex = #achvs
    for i, cfg in ipairs(achvs) do
        local query = achv:insertQuery({rid = roleid, cid = cfg.id})
        if endIndex == i then
            achv:pushQuery(query, connectid, action)
        else
            achv:pushQuery(query, connectid, nil)
        end
    end
end

function Achvs:LoadAll(connectid, action, roleid)
    if not connectid or not action or not roleid then
        return false, "NoParam"
    end
    local achv = self:get()
    local query = achv:selectQuery({rid = roleid, got = 0})
    achv:pushQuery(query, connectid, action)
    return true
end

function Achvs:Login(connectid, action, lastTime, loginTime, roleid)
    if not connectid or not lastTime or not loginTime or not roleid then
        return false, "NoParam"
    end
    
    local loginDate = os.date("*t", loginTime)
    local lastDate = os.date("*t", lastTime)
    
    if loginDate.year ~= lastDate.year or loginDate.yday ~= lastDate.yday then
        --新的一天
        self:InitializeAll(connectid, action, roleid)
        return true
    end
    
    --return false
end

function Achvs:Finish(connectid, action, id)
    local achv = self:get(id)
    
    if not achv then
        return true
    end
    if achv:isFinished() then
        local query = achv:deleteQuery({id = id})
        achv:pushQuery(query, connectid, action)
        self:delete(id)
        return true
    else
        return false
    end
end

function Achvs:process(connectid, action, tp, id, place, count, override)
    local list = self._Datas
    for _, item in ipairs(list) do
        item:process(connectid, action, tp, id, place, count, override)
    end
end

return Achvs
