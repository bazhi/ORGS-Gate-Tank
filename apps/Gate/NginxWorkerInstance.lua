
local gbc = cc.import("#gbc")
local NginxWorkerInstance = cc.class("NginxWorkerInstance", gbc.NginxWorkerInstanceBase)

local Timer = cc.import("#Timer", ...)
local LoopTimer = Timer.LoopTimer
local GateSocketTimer = Timer.GateSocketTimer

local Constants = gbc.Constants

function NginxWorkerInstance:ctor(config, ...)
    NginxWorkerInstance.super.ctor(self, config, ...)
end

function NginxWorkerInstance:runEventLoop()
    local workerid = ngx.worker.id()
    if 0 == workerid then
        self:onWorkerFirst()
    end
    return NginxWorkerInstance.super.runEventLoop(self)
end

function NginxWorkerInstance:onWorkerFirst()
    local authorization = self.config.server.authorization
    local game = self:GetConfig("Game")
    local uri = string.format("ws://%s:%d/%s/", game.host, game.port, game.name)
    local gate = self:GetConfig() --本身的配置
    local gateuri = string.format("ws://%s:%d/%s/", gate.host, gate.port, "Gate")
    local channel = Constants.SOCKET_CONNECT_CHANNLE..gate.name
    
    --消息通道
    self:runTimer(0.5, GateSocketTimer, self.config, {
        uri = uri,
        authorization = authorization,
        channel = channel,
        msg = gateuri,
    })
    
    --保存数据库命令
    self:runTimer(1, LoopTimer, self.config, {
        channel = channel
    })
end

return NginxWorkerInstance
