
local Base = cc.import(".Base")
local Talent = cc.class("Talent", Base)

local Table = cc.import("#Table", ...)

function Talent:ctor()
    Talent.super.ctor(self, Table.Talent)
end

return Talent
