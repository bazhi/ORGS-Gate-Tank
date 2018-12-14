
local gbc = cc.import("#gbc")
local ChapterAction = cc.class("ChapterAction", gbc.ActionBase)

ChapterAction.ACCEPTED_REQUEST_TYPE = "websocket"

function ChapterAction:login(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local chapters = player:getChapters()
    
    local lastTime = args.lastTime
    local loginTime = args.loginTime
    
    return chapters:Login(instance:getConnectId(), "chapter.OnLogin", lastTime, loginTime, role_data.id)
end

function ChapterAction:OnLogin(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local chapters = player:getChapters()
    chapters:updates(args)
    instance:sendPack("Chapters", {
        items = args
    })
end

--解锁关卡，判断是否能够解锁关卡
function ChapterAction:enterAction(args, _redis)
    local instance = self:getInstance()
    local cid = args.cid
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local chapters = player:getChapters()
    return chapters:Create(instance:getConnectId(), "chapter.OnEnter", cid, role_data)
end

function ChapterAction:OnEnter(args, _redis)
    if args.err or not args.insert_id or args.insert_id <= 0 then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local chapters = player:getChapters()
    local chapter = chapters:get()
    local query = chapter:selectQuery({id = args.insert_id})
    chapter:pushQuery(query, instance:getConnectId(), "chapter.OnLoad", {
        update = true,
    })
end

function ChapterAction:OnLoad(args, _redis, params)
    if not params or not params.update then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local chapters = player:getChapters()
    local bupdate = chapters:updates(args)
    if bupdate then
        instance:sendPack("Chapters", {
            items = args,
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
