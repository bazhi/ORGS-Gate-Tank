
local gbc = cc.import("#gbc")
local Timer = cc.import("#baseTimer")

local GateSocketTimer = cc.class("GateSocketTimer", Timer.SocketTimer)

local sdSIG = ngx.shared.sdSIG
local Constants = gbc.Constants

function GateSocketTimer:OnClosed(redis)
    GateSocketTimer.super.OnClosed(self, redis)
    sdSIG:set(Constants.SIGNET, false)
    self:sendMessageToAll(redis, Constants.CLOSE_CONNECT)
end

function GateSocketTimer:OnConnected()
    GateSocketTimer.super.OnConnected(self)
    sdSIG:set(Constants.SIGNET, true)
end

return GateSocketTimer
