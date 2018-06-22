
local BaseList = cc.import(".BaseList")
local Sections = cc.class("Sections", BaseList)
local Section = cc.import(".Section")

function Sections:createItem()
    return Section:new()
end

return Sections
