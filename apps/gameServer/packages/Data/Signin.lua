
local Base = cc.import(".Base")
local Signin = cc.class("Signin", Base)

local Table = cc.import("#Table", ...)

function Signin:ctor()
    Signin.super.ctor(self, Table.Signin)
end

return Signin
