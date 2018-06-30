
local Base = cc.import(".Base")
local Section = cc.class("Section", Base)

local Table = cc.import("#Table", ...)

function Section:ctor()
    Section.super.ctor(self, Table.Section)
end

function Section:isOriginal(originalId)
    return self._data.cid == originalId
end

return Section
