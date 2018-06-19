local Player = cc.class("Player")
local Equipment = cc.import(".Equipment")
local Prop = cc.import(".Prop")
local Role = cc.import(".Role")
local Table = cc.import("#Table")

--玩家所有数据的集合
function Player:ctor(user)
    self._User = user
end

function Player:getRole()
    local role = self._Role
    if not role then
        role = Role:new(Table.Role)
        self._Role = role
    end
    return role
end

function Player:updateRole(data)
    local role = self:getRole()
    role:update(data)
    return role
end

--------------------------------------------------------------------------------------------------------------------
--装备API
--------------------------------------------------------------------------------------------------------------------
--更新所有装备
function Player:updateEquipments(equipments)
    self._Equipments = {}
    local TEquip = Table.Equipment
    for _, v in ipairs(equipments) do
        local item = Equipment:new(TEquip)
        item.update(v)
        table.insert(self._Equipments, item)
    end
end

--更新单个装备
function Player:updateEquipment(equipment)
    if not equipment.id then
        return
    end
    local equipments = self._Equipments
    for _, v in ipairs(equipments) do
        if v:equal(equipment) then
            v:update(equipment)
            return v
        end
    end
    local item = Equipment:new(Table.Equipment)
    item.update(equipment)
    table.insert(self._Equipments, item)
    return item
end

function Player:getEquipment(id)
    if not id then
        local equipment = self._Equipment
        if not equipment then
            equipment = Equipment:new(Table.Equipment)
            self._Equipment = equipment
        end
        return equipment
    end
    
    local equipments = self._Equipments
    for _, v in ipairs(equipments) do
        if v:equalID(id) then
            return v
        end
    end
    return nil
end

--获取唯一装备
function Player:getEquipmentOriginal(originalId)
    local equipments = self._Equipments
    for _, v in ipairs(equipments) do
        if v:isOriginal(originalId) then
            return v
        end
    end
    return nil
end

--------------------------------------------------------------------------------------------------------------------
--道具API
--------------------------------------------------------------------------------------------------------------------

--更新所有道具
function Player:updateProps(props)
    self._Props = {}
    local TProp = Table.Prop
    for _, v in ipairs(props) do
        local item = Prop:new(TProp)
        item.update(v)
        table.insert(self._Props, item)
    end
end

--更新单个道具
function Player:updateProp(prop)
    local props = self._Props
    for _, v in ipairs(props) do
        if v:equal(prop) then
            v:update(prop)
            return v
        end
    end
    local item = Prop:new(Table.Prop)
    item.update(prop)
    table.insert(self._Props, item)
    return item
end

function Player:getProp(id)
    if not id then
        local prop = self._Prop
        if not prop then
            prop = Prop:new(Table.Prop)
            self._Prop = prop
        end
        return prop
    end
    
    local props = self._Props
    for _, v in ipairs(props) do
        if v:equalID(id) then
            return v
        end
    end
    return nil
end

return Player
