
local Base = cc.import(".Base")
local Chapter = cc.class("Chapter", Base)
local Table = cc.import("#Table", ...)

function Chapter:ctor()
    Chapter.super.ctor(self, Table.Chapter)
end

function Chapter:isOriginal(originalId)
    return self._data.cid == originalId
end

return Chapter
