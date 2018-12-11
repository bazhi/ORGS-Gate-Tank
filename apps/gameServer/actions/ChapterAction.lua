
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

ChapterAction.ACCEPTED_REQUEST_TYPE = "websocket"

--解锁关卡，判断是否能够解锁关卡
function ChapterAction:enterAction(args, _redis)
    local instance = self:getInstance()
    local cid = args.cid
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local chapters = player:getChapters()
    return chapters:Create(instance:getConnectId(), "chapter.OnCreate", cid, role_data)
end

function ChapterAction:OnCreate(args, _redis)
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

function ChapterAction:saveAction(args)
    local id = args.id
    local seq = args.seq
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local chapters = player:getChapters()
    local result, err = chapters:Save(instance:getConnectId(), nil, id, seq, args.record)
    if result then
        instance:sendPack("MapRecordSave", {
            id = id,
            seq = seq,
            record = args.record,
        })
    end
    return result, err
end

return ChapterAction
