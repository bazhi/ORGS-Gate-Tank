local Base = cc.import(".Base")
local Role = cc.class("Role", Base)

function Role:getID()
    return self._data.id
end

return Role
