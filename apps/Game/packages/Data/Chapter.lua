
local Base = cc.import(".Base")
local Chapter = cc.class("Chapter", Base)
local Table = cc.import("#Table", ...)

function Chapter:ctor()
    Chapter.super.ctor(self, Table.Chapter)
end

return Chapter
