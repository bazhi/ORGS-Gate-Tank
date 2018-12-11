
local BaseList = cc.import(".BaseList")
local Missions = cc.class("Missions", BaseList)
local Mission = cc.import(".Mission")
local dbConfig = cc.import("#dbConfig")

function Missions:createItem()
    return Mission:new()
end

function Missions:Load()
    
end

return Missions
