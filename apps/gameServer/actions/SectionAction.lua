
local gbc = cc.import("#gbc")
local SectionAction = cc.class("SectionAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")
--local parse = cc.import("#parse")
--local ParseConfig = parse.ParseConfig

SectionAction.ACCEPTED_REQUEST_TYPE = "websocket"

--解锁关卡，判断是否能够解锁关卡
function SectionAction:enterAction(args, _redis)
    local instance = self:getInstance()
    local cid = args.cid
    if not cid then
        instance:sendError("NoneConfigID")
        return
    end
    
    local player = instance:getPlayer()
    
    local sections = player:getSections()
    local section = sections:getByCID(cid)
    local nowtime = ngx.now()
    if not section then
        local cfg_section = dbConfig.get("cfg_section", cid)
        if not cfg_section then
            instance:sendError("NoneConfig")
            return
        end
        local role = player:getRole()
        local role_data = role:get()
        local chapters = player:getChapters()
        local chapter = chapters:getByCID(cfg_section.chapterID)
        if not chapter then
            --章节还没解锁，无法进入
            instance:sendError("NoAccept")
            return
        end
        
        --玩家等级不够，无法进入
        if cfg_section.unlockLevel > role_data.level then
            instance:sendError("NoAccept")
            return
        end
        
        --检查前置关卡是否通关
        if cfg_section.preID > 0 then
            local pre_section = sections:getByCID(cfg_section.preID)
            if not pre_section or pre_section.star <= 0 then
                --章节还没解锁，无法进入
                instance:sendError("NoAccept")
                return
            end
        end
        
        --检查本章通关星级总数
        local star, _ = sections:getChapterStar(cfg_section.chapterID)
        if star < cfg_section.unlockStar then
            --星级条件不够，无法进入
            instance:sendError("NoAccept")
            return
        end
        
        --所有条件允许，插入小节数据库
        section = sections:get()
        local dt = section:get()
        dt.rid = role_data.id
        dt.cid = cid
        dt.chapter_cid = cfg_section.chapterID
        dt.enterTime = nowtime
        dt.tryTimes = 1
        local query = section:insertQuery(dt)
        section:pushQuery(query, instance:getConnectId(), "section.onSectionNew")
        return
    end
    
    local dt = section:get()
    dt.enterTime = nowtime
    dt.tryTimes = dt.tryTimes + 1
    local query = section:updateQuery({id = dt.id}, dt)
    section:pushQuery(query, instance:getConnectId())
    instance:sendPack("EnterSection", {
        cid = cid
    })
end

function SectionAction:onSectionNew(args, _redis)
    if args.err or not args.insert_id or args.insert_id <= 0 then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local sections = player:getSections()
    local section = sections:get()
    local query = section:selectQuery({id = args.insert_id})
    section:pushQuery(query, instance:getConnectId(), "section.onSection", {
        update = true,
    })
end

function SectionAction:onSection(args, _redis, params)
    if not params or not params.update then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local sections = player:getSections()
    local bupdate = sections:updates(args)
    if bupdate then
        instance:sendPack("Sections", {
            values = args,
        })
        
        instance:sendPack("EnterSection", {
            cid = args[1].cid
        })
    end
end

function SectionAction:finishAction(args, redis)
    local instance = self:getInstance()
    local id = args.id
    local star = args.star
    if not id or not star then
        instance:sendError("NoneID")
        return
    end
    
    local player = instance:getPlayer()
    local sections = player:getSections()
    local section = sections:get(id)
    if not section then
        instance:sendError("NoAccept")
        return
    end
    local section_data = section:get()
    local now = ngx.now()
    if now - section_data.enterTime < 20 or section_data.enterTime == 0 then
        instance:sendError("NoAccept")
        return
    end
    
    local cfg_section = dbConfig.get("cfg_section", section_data.cid)
    
    section_data.enterTime = 0
    section_data.finishTimes = section_data.finishTimes + 1
    section_data.star = star
    local query = section:updateQuery({id = section_data.id}, section_data)
    section:pushQuery(query, instance:getConnectId())
    instance:sendPack("Sections", {
        values = {section_data},
    })
    
    self:runAction("role.add", {exp = cfg_section.exp}, redis)
    instance:sendPack("SectionResult", {
        id = id,
        star = star,
        exp = cfg_section.exp,
    })
end

return SectionAction
