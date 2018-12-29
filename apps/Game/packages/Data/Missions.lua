
local BaseList = cc.import(".BaseList")
local Missions = cc.class("Missions", BaseList)
local Mission = cc.import(".Mission")
local dbConfig = cc.import("#dbConfig")
local utility = cc.import("#utility")
local Random = utility.Random

function Missions:createItem()
    return Mission:new()
end

function Missions:Initialize(db, rid, lastTime, loginTime)
    if not db or not lastTime or not loginTime or not rid then
        return nil, "NoParam"
    end
    
    local loginDate = os.date("*t", loginTime)
    local lastDate = os.date("*t", lastTime)
    
    if loginDate.year ~= lastDate.year or loginDate.yday ~= lastDate.yday then
        local template = self:getTemplate()
        --删除所有旧的数据
        template:deleteQuery(db, {rid = rid})
        
        local cfgs = dbConfig.getAll("cfg_mission")
        
        --随机增加5条日常任务
        local lsitAdd = Random.Table(cfgs, 5)
        for _, cfg in ipairs(lsitAdd) do
            template:insertQuery(db, {rid = rid, cid = cfg.id})
        end
        -- for _, cfg in ipairs(cfgs) do
        --     template:insertQuery(db, {rid = rid, cid = cfg.id})
        -- end
    end
    return self:load(db, {
        rid = rid,
    })
end

function Missions:Finish(id)
    local mission = self:get(id)
    
    if not mission then
        return nil, "NoneID"
    end
    if mission:isFinished() then
        mission:set("got", 1)
        local cfg = mission:getConfig()
        return mission:get(), nil, cfg
    else
        return nil, "OperationNotPermit"
    end
end

function Missions:process(id, place, count, tp, override)
    local result = {}
    local list = self._Datas
    for _, item in ipairs(list) do
        local data = item:process(tp, id, place, count, override)
        if data then
            table.insert(result, data)
        end
    end
    return result
end

return Missions
