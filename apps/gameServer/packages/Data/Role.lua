local Base = cc.import(".Base")
local Role = cc.class("Role", Base)

local Table = cc.import("#Table")

function Role:ctor()
    Role.super.ctor(self, Table.Role)
end

return Role
