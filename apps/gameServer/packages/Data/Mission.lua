
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

function Mission:process(connectid, action, action_type, action_id, action_place, action_count, action_override)
    local cfg = self:getConfig()
    if cfg then
        if cfg.action_type ~= action_type then
            --类型不一样
            return
        end
        if cfg.action_id ~= 0 and cfg.action_id ~= action_id then
            --id不为0 或者id不相等
            return
        end
        if cfg.action_place ~= 0 and cfg.action_place ~= action_place then
            --位置不匹配
            return
        end
        
        local process = self:get("process")
        if process < cfg.action_count then
            if action_override then
                self:set("process", action_count)
            else
                self:add("process", action_count)
            end
        end
    end
end

return Mission
