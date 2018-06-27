
--[[
Copyright (c) 2015 gameboxcloud.com
Permission is hereby granted, free of chargse, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
]]

local gbc = cc.import("#gbc")
local ChapterAction = cc.class("ChapterAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")
--local parse = cc.import("#parse")
--local ParseConfig = parse.ParseConfig

ChapterAction.ACCEPTED_REQUEST_TYPE = "websocket"

--解锁关卡，判断是否能够解锁关卡
function ChapterAction:enterAction(args, _redis)
    local instance = self:getInstance()
    local cid = args.cid
    if type(cid) ~= "number" then
        instance:sendError("NoneConfigID")
        return - 1
    end
    
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local chapters = player:getChapters()
    local chapter = chapters:getByCID(cid)
    --已经解锁该章节了, 不用理会
    if chapter then
        return 0
    end
    
    --检查是否有该章节的配置
    local cfg_chapter = dbConfig.get("cfg_chapter", cid)
    if not cfg_chapter then
        instance:sendError("NoneConfig")
        return - 1
    end
    --取到config之后，检查config是否解锁
    --1.检查解锁等级
    if cfg_chapter.unlockLevel > role_data.level then
        instance:sendError("NoAccept")
        return - 1
    end
    --2.检查解锁星级
    if cfg_chapter.preID > 0 then
        local pre_chapter = chapters:getByCID(cfg_chapter.preID)
        if not pre_chapter then
            --前置关卡未解锁
            instance:sendError("NoAccept")
            return - 1
        end
        local sections = player:getSections()
        local star, count = sections:getChapterStar(cfg_chapter.preID)
        if star < cfg_chapter.unlockStar then
            --没达到解锁星级
            instance:sendError("NoAccept")
            return - 1
        end
        if count < cfg_chapter.unlockCount then
            --没达到前置通关数量
            instance:sendError("NoAccept")
            return - 1
        end
    end
    
    --3.是否需要购买
    if cfg_chapter.price > 0 then
        return 0
    end
    
    --所有条件都满足，插入新的关卡
    chapter = chapters:get()
    local dt = chapter:get()
    dt.rid = role_data.id
    dt.cid = cid
    local query = chapter:insertQuery(dt)
    chapter:pushQuery(query, instance:getConnectId(), "chapter.onChapterNew")
    return 1
end

function ChapterAction:onChapterNew(args, _redis)
    if args.err or not args.insert_id or args.insert_id <= 0 then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local chapters = player:getChapters()
    local chapter = chapters:get()
    local query = chapter:selectQuery({id = args.insert_id})
    chapter:pushQuery(query, instance:getConnectId(), "chapter.onChapter", {
        update = true,
    })
end

function ChapterAction:onChapter(args, _redis, params)
    if not params or not params.update then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local chapters = player:getChapters()
    local bupdate = chapters:updates(args)
    if bupdate then
        instance:sendPack("Chapters", {
            values = args,
        })
    end
end

return ChapterAction
