
local BaseList = cc.import(".BaseList")
local Equipments = cc.class("Equipments", BaseList)
local Equipment = cc.import(".Equipment")

function Equipments:createItem()
    return Equipment:new()
end

return Equipments
