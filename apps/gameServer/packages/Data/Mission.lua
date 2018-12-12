
local Base = cc.import(".Base")
local Mission = cc.class("Mission", Base)
local dbConfig = cc.import("#dbConfig")
local Table = cc.import("#Table", ...)

function Mission:ctor()
    Mission.super.ctor(self, Table.Mission)
end

function Mission:getConfig()
    if not self._Config or not self:equalCID(self._Config.id) then
        self._Config = dbConfig.get("cfg_mission", self:get("cid"))
    end
    return self._Config
end

return Mission
