
local BaseList = cc.import(".BaseList")
local Chapters = cc.class("Chapters", BaseList)
local Chapter = cc.import(".Chapter")
local dbConfig = cc.import("#dbConfig")

function Chapters:createItem()
    return Chapter:new()
end

function Chapters:Create(connectid, action, cid, roleData)
    if not connectid or not roleData then
        return false, "NoParam"
    end
    
    if type(cid) ~= "number" then
        return false, "NoneConfigID"
    end
    
    local chapter = self:getByCID(cid)
    if chapter then
        --已经有了该章节数据，无需进行再增加
        return true
    end
    
    --检查是否有该章节的配置
    local cfg_chapter = dbConfig.get("cfg_chapter", cid)
    if not cfg_chapter then
        return false, "NoneConfig"
    end
    
    --1.检查解锁等级
    if cfg_chapter.unlockLevel > roleData.level then
        return false, "NoAccept"
    end
    
    --2.检查解锁星级
    if cfg_chapter.preID > 0 then
        local pre_chapter = self:getByCID(cfg_chapter.preID)
        if not pre_chapter then
            --前置关卡未解锁
            return false, "NoAccept"
        end
        
        local pre_chapter_data = pre_chapter:get()
        if pre_chapter_data.status ~= 2 then
            --前置关卡未完结
            return false, "NoAccept"
        end
    end
    
    --3.是否需要购买
    if cfg_chapter.price > 0 then
        return false, "NotBuy"
    end
    
    local chapter = Chapters:get()
    local data = chapter:get()
    data.rid = roleData.id
    data.cid = cid
    data.status = 0
    data.record1 = ""
    data.record2 = ""
    data.record3 = ""
    local query = chapter:insertQuery(data)
    chapter:pushQuery(query, connectid, action)
    return true
end

function Chapters:Save(connectid, action, id, seq, record)
    if not connectid then
        return false, "NoParam"
    end
    if not id or not seq or not record then
        return false, "NoParam"
    end
    
    local chapter = self:getByCID(id)
    if not chapter then
        return false, "NoAccept"
    end
    
    local data = chapter:get()
    local query
    if 1 == seq then
        query = chapter:updateQuery({id = data.id}, {record1 = record})
        data.record1 = record
    elseif 2 == seq then
        query = chapter:updateQuery({id = data.id}, {record2 = record})
        data.record2 = record
    else
        query = chapter:updateQuery({id = data.id}, {record3 = record})
        data.record3 = record
    end
    chapter:pushQuery(query, connectid, action)
    return true
end

return Chapters
