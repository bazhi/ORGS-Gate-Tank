
local BaseList = cc.import(".BaseList")
local Missions = cc.class("Missions", BaseList)
local Mission = cc.import(".Mission")

function Missions:createItem()
    return Mission:new()
end

return Missions
