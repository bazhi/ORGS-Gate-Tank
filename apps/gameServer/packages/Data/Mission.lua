
local Base = cc.import(".Base")
local Mission = cc.class("Mission", Base)

local Table = cc.import("#Table")

function Mission:ctor()
    Mission.super.ctor(self, Table.Mission)
end

function Mission:isOriginal(originalId)
    return self._data.cid == originalId
end

return Mission
