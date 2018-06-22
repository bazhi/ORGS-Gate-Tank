
local BaseList = cc.import(".BaseList")
local Chapters = cc.class("Chapters", BaseList)
local Chapter = cc.import(".Chapter")

function Chapters:createItem()
    return Chapter:new()
end

return Chapters
