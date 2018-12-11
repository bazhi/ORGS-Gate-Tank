
local gbc = cc.import("#gbc")
local BoxAction = cc.class("BoxAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")
local parse = cc.import("#parse")
local ParseConfig = parse.ParseConfig

BoxAction.ACCEPTED_REQUEST_TYPE = "websocket"

--分解
function BoxAction:add(args, _redis)
    --local instance = self:getInstance()
    local id = args.id
    if type(id) ~= "number" or id <= 0 then
        return false, "NoParam"
    end
    
    return self:addBox(id)
end

function BoxAction:addBox(id)
    local instance = self:getInstance()
    --检查是否在真的存在该box
    local cfg_box = dbConfig.get("cfg_box", id)
    if not cfg_box then
        return false, "NoneConfig"
    end
    
    local player = instance:getPlayer()
    local role = player:getRole()
    local boxes = player:getBoxes()
    local box = boxes:get()
    
    local dt = box:get()
    dt.rid = role:getID()
    dt.cid = id
    local query = box:insertQuery(dt)
    box:pushQuery(query, instance:getConnectId(), "box.onBoxNew")
    return true
end

function BoxAction:addBoxes(args, _redis)
    --local instance = self:getInstance()
    local ids = args.ids
    if type(ids) ~= "string" then
        return false, "NoParam"
    end
    ids = ParseConfig.ParseIDList(ids)
    for _, id in ipairs(ids) do
        self:addBox(id)
    end
    return true
end

function BoxAction:onBoxNew(args, _redis, _param)
    if args.err then
        cc.printf(args.err)
        return
    end
    local insert_id = args.insert_id
    if not insert_id then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local boxes = player:getBoxes()
    local box = boxes:getTemplate()
    local query = box:selectQuery({id = insert_id})
    box:pushQuery(query, instance:getConnectId(), "box.onBox")
end

function BoxAction:onBox(args, _redis, _param)
    if type(args) ~= "table" then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local boxes = player:getBoxes()
    local bupdate = boxes:updates(args)
    if bupdate then
        instance:sendPack("Boxes", {
            values = args,
        })
    end
end

function BoxAction:openAction(args, _redis)
    local instance = self:getInstance()
    local id = args.id
    if type(id) ~= "number" or id <= 0 then
        return false, "NoParam"
    end
    local player = instance:getPlayer()
    local boxes = player:getBoxes()
    local box = boxes:get(id)
    if not box then
        return false, "NoneBox"
    end
    local box_data = box:get()
    
    --箱子已经在打开过程中，不允许再次打开
    if box_data.unlockTime > 0 then
        return false, "OperationNotPermit"
    end
    
    local cfg_box = dbConfig.get("cfg_box", box_data.cid)
    if not cfg_box then
        return false, "NoneConfig"
    end
    
    --
    box_data.unlockTime = ngx.now() + cfg_box.time
    local query = box:updateQuery({id = box_data.id}, {unlockTime = box_data.unlockTime})
    box:pushQuery(query, instance:getConnectId())
    instance:sendPack("Boxes", {
        values = {
            box_data
        },
    })
    
    return true
end

function BoxAction:deleteBox(id)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local boxes = player:getBoxes()
    
    local box = boxes:get(id)
    if box then
        local query = box:deleteQuery({id = id})
        box:pushQuery(query, instance:getConnectId())
        boxes:delete(id)
        instance:sendDelete("Box", id)
    end
end

function BoxAction:gainAction(args, redis)
    local instance = self:getInstance()
    local id = args.id
    if type(id) ~= "number" or id <= 0 then
        return false, "NoParam"
    end
    local player = instance:getPlayer()
    local boxes = player:getBoxes()
    local box = boxes:get(id)
    if not box then
        return false, "NoneBox"
    end
    local box_data = box:get()
    
    --箱子正在打开中, 或者没有打开
    if box_data.unlockTime > ngx.now() or box_data.unlockTime <= 0 then
        return false, "OperationNotPermit"
    end
    
    --时间到了，允许收取物品了
    local cfg_box = dbConfig.get("cfg_box", box_data.cid)
    if not cfg_box then
        return false, "NoneConfig"
    end
    --删除箱子
    self:deleteBox(id)
    --处理物品
    return self:runAction("reward.open", {id = cfg_box.rewardID}, redis)
end

return BoxAction

