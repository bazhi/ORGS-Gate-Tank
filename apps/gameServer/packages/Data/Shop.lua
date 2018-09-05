
local Base = cc.import(".Base")
local Shop = cc.class("Shop", Base)

local Table = cc.import("#Table", ...)

function Shop:ctor()
    Shop.super.ctor(self, Table.Shop)
end

return Shop
