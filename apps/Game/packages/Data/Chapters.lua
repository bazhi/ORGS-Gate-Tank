
local BaseList = cc.import(".BaseList")
local Chapters = cc.class("Chapters", BaseList)
local Chapter = cc.import(".Chapter")
local dbConfig = cc.import("#dbConfig")

function Chapters:createItem()
    return Chapter:new()
end

function Chapters:Initialize(db, rid)
    local cfgs = dbConfig.getAll("cfg_chapter", {preID = 0, price = 0})
    local template = self:getTemplate()
    --插入所有需要插入的成就
    for _, cfg in ipairs(cfgs) do
        template:insertQuery(db, {rid = rid, cid = cfg.id, record1 = "", record2 = "", record3 = ""})
    end
    return self:load(db, {
        rid = rid,
    })
end

function Chapters:Save(id, seq, record)
    if not id or not seq or not record then
        return nil, "NoParam"
    end
    
    local chapter = self:getByCID(id)
    if not chapter then
        return nil, "NoAccept"
    end
    
    if 1 == seq then
        chapter:set("record1", record)
    elseif 2 == seq then
        chapter:set("record2", record)
    else
        chapter:set("record3", record)
    end
    return chapter:get()
end

return Chapters
