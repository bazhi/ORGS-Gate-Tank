
local BaseList = cc.import(".BaseList")
local Boxes = cc.class("Boxes", BaseList)
local Box = cc.import(".Box")

function Boxes:createItem()
    return Box:new()
end

return Boxes
