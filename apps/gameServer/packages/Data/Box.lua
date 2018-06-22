
local Base = cc.import(".Base")
local Box = cc.class("Box", Base)
local Table = cc.import("#Table")

function Box:ctor()
    Box.super.ctor(self, Table.Box)
end

function Box:isOriginal(originalId)
    return self._data.cid == originalId
end

return Box
