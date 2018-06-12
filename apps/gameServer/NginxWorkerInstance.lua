local gbc = cc.import("#gbc")
local NginxWorkerInstance = cc.class("NginxWorkerInstance", gbc.NginxWorkerInstanceBase)
local Timer = cc.import("#Timer")
local InitializeTimer = Timer.InitializeTimer
local MasterTimer = Timer.MasterTimer

function NginxWorkerInstance:ctor(config, ...)
    NginxWorkerInstance.super.ctor(self, config, ...)
end

function NginxWorkerInstance:runEventLoop()
    local workerid = ngx.worker.id()
    cc.printf("NginxWorkerInstance runEventLoop:"..workerid)
    if 0 == workerid then
        self:onWorkerFirst()
    end
    return NginxWorkerInstance.super.runEventLoop(self)
end

function NginxWorkerInstance:onWorkerFirst()
    self:runTimer(1, InitializeTimer, self.config)
    self:runTimer(5, MasterTimer, self.config)
end

return NginxWorkerInstance
