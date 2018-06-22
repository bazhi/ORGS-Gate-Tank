local Base = cc.import(".Base")
local Equipment = cc.class("Equipment", Base)

local Table = cc.import("#Table")

function Equipment:ctor()
    Equipment.super.ctor(self, Table.Equipment)
end

function Equipment:isOriginal(originalId)
    return self._data.oid == originalId
end

return Equipment
