local gbc = cc.import("#gbc")
local NginxWorkerInstance = cc.class("NginxWorkerInstance", gbc.NginxWorkerInstanceBase)
local Timer = cc.import("#Timer", ...)
local InitializeTimer = Timer.InitializeTimer

function NginxWorkerInstance:ctor(config, ...)
    NginxWorkerInstance.super.ctor(self, config, ...)
end

function NginxWorkerInstance:runEventLoop()
    local workerid = ngx.worker.id()
    cc.printf("loginMaster NginxWorkerInstance runEventLoop:"..workerid..":"..self.config.app.appName)
    if 0 == workerid then
        self:onWorkerFirst()
    end
    return NginxWorkerInstance.super.runEventLoop(self)
end

function NginxWorkerInstance:onWorkerFirst()
    --cc.dump(self.config)
    self:runTimer(1, InitializeTimer, self.config)
end

return NginxWorkerInstance
