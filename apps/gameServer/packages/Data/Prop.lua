local Base = cc.import(".Base")
local Prop = cc.class("Prop", Base)

local Table = cc.import("#Table")

function Prop:ctor()
    Prop.super.ctor(self, Table.Prop)
end

return Prop
