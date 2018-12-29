
local BaseList = cc.import(".BaseList")
local Achvs = cc.class("Achvs", BaseList)
local Achv = cc.import(".Achv")
local dbConfig = cc.import("#dbConfig")

function Achvs:createItem()
    return Achv:new()
end

function Achvs:Initialize(db, rid)
    local achvs = dbConfig.getAll("cfg_achievement", {pre_id = 0})
    local achv = self:get()
    --插入所有需要插入的成就
    for _, cfg in ipairs(achvs) do
        achv:insertQuery(db, {rid = rid, cid = cfg.id})
    end
    return self:load(db, {
        rid = rid,
        got = 0,
    })
end

function Achvs:insertAchvs(db, rid, pre_id)
    local achvs = dbConfig.getAll("cfg_achievement", {pre_id = pre_id})
    local achv = self:get()
    --插入所有需要插入的成就
    local results = {}
    for _, cfg in ipairs(achvs) do
        local result, _ = achv:insertQuery(db, {rid = rid, cid = cfg.id})
        if result and result.insert_id then
            local data, _err = self:load(db, {id = result.insert_id})
            if data then
                table.insert(results, data)
            end
        end
    end
    return results
end

function Achvs:Finish(id)
    local achv = self:get(id)
    if not achv then
        return nil, "NoneID"
    end
    if achv:isFinished() then
        achv:set("got", 1)
        local cfg = achv:getConfig()
        return achv:get(), nil, cfg
    else
        return nil, "OperationNotPermit"
    end
end

function Achvs:process(id, place, count, tp, override)
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

return Achvs
