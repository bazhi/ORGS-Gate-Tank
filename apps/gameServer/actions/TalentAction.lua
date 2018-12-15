
local gbc = cc.import("#gbc")
local TalentAction = cc.class("TalentAction", gbc.ActionBase)
-- local dbConfig = cc.import("#dbConfig")
-- local parse = cc.import("#parse")
-- local ParseConfig = parse.ParseConfig

TalentAction.ACCEPTED_REQUEST_TYPE = "websocket"

function TalentAction:OnLoad(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local talents = player:getTalents()
    if args then
        talents:update(args)
    end
end

function TalentAction:login(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local talents = player:getTalents()
    
    local lastTime = args.lastTime
    local loginTime = args.loginTime
    
    return talents:Login(instance:getConnectId(), "talent.OnLoad", lastTime, loginTime, role_data.id)
end

function TalentAction:unlockAction(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local talents = player:getTalents()
    
    return talents:Unlock(instance:getConnectId(), "talent.OnUnlock", args.cid, args.level, role)
end

function TalentAction:OnUnlock(args)
    cc.dump(args)
end

return TalentAction
