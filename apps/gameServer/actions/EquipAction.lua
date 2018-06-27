
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
local EquipAction = cc.class("EquipAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")

EquipAction.ACCEPTED_REQUEST_TYPE = "websocket"

function EquipAction:checkProp(id)
    local instance = self:getInstance()
    if not id then
        instance:sendError("NoneProp")
        return nil
    end
    local player = instance:getPlayer()
    local props = player:getProps()
    local prop = props:get(id)
    if not prop then
        instance:sendError("NoneProp")
        return nil
    end
    local prop_data = prop:get()
    if prop_data.count < 1 then
        instance:sendError("NoneProp")
        return nil
    end
    
    return prop
end

function EquipAction:checkEquipment(id)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local equipments = player:getEquipments()
    local equip = equipments:get(id)
    if not equip then
        instance:sendError("NoneEquipment")
        return nil
    end
    return equip
end

function EquipAction:onProp(args, _redis)
    cc.dump(args)
end

function EquipAction:onEquip(args, _redis)
    cc.dump(args)
end

--得到了新的装备
function EquipAction:onNewEquip(args, _redis)
    if args.err then
        cc.printf("onNewEquip:"..args.err)
        return
    end
    --cc.printf("onNewEquip")
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local equipments = player:getEquipments()
    local bupdate = equipments:updates(args)
    if bupdate then
        instance:sendPack("Equipments", {
            values = args,
        })
    end
end

--解锁新的装备成功
function EquipAction:onUnlock(args, _redis)
    if args.err then
        cc.printf("onUnlock:"..args.err)
        return
    end
    local insert_id = args.insert_id
    if insert_id then
        --cc.printf("onUnlock")
        local instance = self:getInstance()
        local player = instance:getPlayer()
        local equipments = player:getEquipments()
        local equip = equipments:getTemplate()
        local query = equip:selectQuery({id = insert_id})
        equip:pushQuery(query, instance:getConnectId(), "equip.onNewEquip")
    end
end

function EquipAction:unlockEquipment(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local cid = args.cid
    local prop_id = args.prop_id
    if not prop_id or not cid then
        instance:sendError("NoneID")
        return
    end
    --检查道具是否存在
    local prop = self:checkProp(prop_id)
    if not prop then
        return
    end
    local role = player:getRole()
    
    --获取道具配置
    local prop_data = prop:get()
    local cfg_prop = dbConfig.get("cfg_prop", prop_data.cid)
    if not cfg_prop then
        instance:sendError("ConfigError")
        return
    end
    
    --判断解锁的装备与道具对应的武器是否一致
    if cid ~= cfg_prop.eid then
        instance:sendError("OperationNotPermit")
        return
    end
    
    --类型不为武器书，错误
    if cfg_prop.type ~= 2 then
        instance:sendError("OperationNotPermit")
        return
    end
    
    --获取武器配置
    local cfg_equip = dbConfig.get("cfg_equip", cfg_prop.eid)
    if not cfg_equip or cfg_equip.level ~= 1 then
        instance:sendError("ConfigError")
        return
    end
    
    local role_data = role:get()
    --装备解锁等级，大于角色等级，无法进行解锁
    if cfg_equip.unlockLevel > role_data.level then
        instance:sendError("OperationNotPermit")
        return
    end
    
    local equipments = player:getEquipments()
    
    local equip = equipments:getOriginal(cfg_equip.originalId)
    --该装备已经存在，无法解锁该类型装备
    if equip then
        instance:sendError("OperationNotPermit")
        return
    end
    
    --好了，现在允许操作了，减少道具数量, 更新星级与品质
    prop_data.count = prop_data.count - 1
    local query = prop:updateQuery({id = prop_data.id}, {count = prop_data.count})
    prop:pushQuery(query, instance:getConnectId())
    instance:sendPack("Props", {
        values = {prop_data},
    })
    
    --解锁的装备,都是1星
    local equip = equipments:get()
    local dt = equip:get()
    dt.rid = role:getID()
    dt.cid = cfg_prop.eid
    dt.star = 1
    --cfg_prop.star
    dt.oid = cfg_equip.originalId
    query = equip:insertQuery(dt)
    equip:pushQuery(query, instance:getConnectId(), "equip.onUnlock")
end

function EquipAction:checkProps(ids)
    --cc.dump(ids)
    local countMap = {}
    for _, id in ipairs(ids) do
        if not countMap[id] then
            countMap[id] = 0
        end
        countMap[id] = countMap[id] + 1
    end
    local propMap = {}
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local props = player:getProps()
    for id, count in pairs(countMap) do
        local prop = props:get(id)
        if not prop then
            cc.printf("Prop is nil:"..id)
            instance:sendError("NoneProp")
            return nil
        end
        local prop_data = prop:get()
        if prop_data.count < count then
            cc.printf("Prop not enough")
            instance:sendError("NoneProp")
            return nil
        end
        propMap[prop] = count
    end
    return propMap
end

function EquipAction:unlockAction(args, redis)
    self:unlockEquipment(args, redis)
    return 1
end

function EquipAction:upgradeStarAction(args, _redis)
    --cc.dump(args)
    local instance = self:getInstance()
    local id = args.id
    local prop_ids = args.prop_ids
    if not prop_ids or not id then
        instance:sendError("NoneID")
        return
    end
    
    local propMap = self:checkProps(prop_ids)
    if not propMap then
        return
    end
    
    local equip = self:checkEquipment(id)
    if not equip then
        return
    end
    
    --检查武器是否存在
    local equip_data = equip:get()
    local cfg_equip = dbConfig.get("cfg_equip", equip_data.cid)
    if not cfg_equip then
        instance:sendError("ConfigError")
        return
    end
    
    --计算总的升星power
    local power = 0
    for prop, count in pairs(propMap) do
        local prop_data = prop:get()
        local cfg_prop = dbConfig.get("cfg_prop", prop_data.cid)
        
        if not cfg_prop or cfg_prop.type ~= 2 then
            instance:sendError("ConfigError")
            return
        end
        local cfg_equip_prop = dbConfig.get("cfg_equip", cfg_prop.eid)
        if cfg_equip_prop.originalId ~= cfg_equip.originalId then
            instance:sendError("ConfigError")
            return
        end
        power = power + count * cfg_prop.power
    end
    
    --类型不为武器书，错误
    
    local cfg_star = dbConfig.get("cfg_star", equip_data.star)
    if not cfg_star then
        instance:sendError("ConfigError")
        return
    end
    
    local cfg_star_next = dbConfig.get("cfg_star", equip_data.star + 1)
    if not cfg_star_next then
        instance:sendError("OperationNotPermit")
        return
    end
    
    --等级是否已经满级
    if cfg_equip.level ~= cfg_star.maxLevel then
        instance:sendError("OperationNotPermit")
        return
    end
    
    --减掉需要减去的装备
    for prop, count in pairs(propMap) do
        local prop_data = prop:get()
        prop_data.count = prop_data.count - count
        local query = prop:updateQuery({id = prop_data.id}, {count = prop_data.count})
        prop:pushQuery(query, instance:getConnectId())
        instance:sendPack("Props", {
            values = {prop_data},
        })
    end
    
    --判断是否可以升级
    local bUpStar = false
    math.randomseed(ngx.now())
    if cfg_star_next.power >= 1 then
        local randnumber = math.random(cfg_star_next.power)
        if randnumber <= power then
            bUpStar = true
        end
    end
    
    if bUpStar then
        equip_data.star = equip_data.star + 1
        local query = equip:updateQuery({id = equip_data.id}, {
            star = equip_data.star,
        })
        equip:pushQuery(query, instance:getConnectId())
    end
    instance:sendPack("Equipments", {
        values = {equip_data},
    })
    if bUpStar then
        return 1
    else
        return 0
    end
end

function EquipAction:upgradeLevelAction(args, _redis)
    local instance = self:getInstance()
    local id = args.id
    local prop_id = args.prop_id
    
    if not id or not prop_id then
        instance:sendError("NoneID")
        return
    end
    
    local prop = self:checkProp(prop_id)
    if not prop then
        return
    end
    
    local equip = self:checkEquipment(id)
    if not equip then
        return
    end
    
    local prop_data = prop:get()
    local equip_data = equip:get()
    
    --检查是否可以更新武器品质
    local cfg_prop = dbConfig.get("cfg_prop", prop_data.cid)
    local cfg_equip = dbConfig.get("cfg_equip", equip_data.cid)
    if not cfg_prop or not cfg_equip then
        instance:sendError("ConfigError")
        return
    end
    local cfg_star = dbConfig.get("cfg_star", equip_data.star)
    if not cfg_star then
        instance:sendError("ConfigError")
    end
    
    --类型不为经验书，错误
    if cfg_prop.type ~= 1 then
        instance:sendError("OperationNotPermit")
        return
    end
    
    --等级已经升满，不需要进行升级了
    if cfg_equip.level >= cfg_star.maxLevel then
        instance:sendError("OperationNotPermit")
        return
    end
    
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    --装备解锁等级，大于玩家的等级
    if cfg_equip.unlockLevel > role_data.level then
        instance:sendError("OperationNotPermit")
        return
    end
    
    equip_data.exp = cfg_prop.exp + equip_data.exp
    if equip_data.exp >= cfg_equip.updradeExp then
        equip_data.exp = 0
        equip_data.cid = cfg_equip.upgradeID
    end
    
    prop_data.count = prop_data.count - 1
    
    local query = prop:updateQuery({id = prop_data.id}, {count = prop_data.count})
    prop:pushQuery(query, instance:getConnectId())
    instance:sendPack("Props", {
        values = {prop_data},
    })
    
    query = equip:updateQuery({id = equip_data.id}, {
        exp = equip_data.exp,
        cid = equip_data.cid,
    })
    
    equip:pushQuery(query, instance:getConnectId())
    instance:sendPack("Equipments", {
        values = {equip_data},
    })
    return 1
end

return EquipAction

