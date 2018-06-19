local Base = cc.import(".Base")
local Equipment = cc.class("Equipment", Base)

function Equipment:update(data)
    Equipment.super.update(self, data)
end

function Equipment:isOriginal(originalId)
    return self._data.oid == originalId
end

return Equipment
