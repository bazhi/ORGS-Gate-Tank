local gbc = cc.import("#gbc")
local NginxWorkerInstance = cc.class("NginxWorkerInstance", gbc.NginxWorkerInstanceBase)

function NginxWorkerInstance:ctor(config, ...)
    NginxWorkerInstance.super.ctor(self, config, ...)
end

function NginxWorkerInstance:runEventLoop()
    local workerid = ngx.worker.id()
    if 0 == workerid then
        cc.dump(self.config)
        self:onWorkerFirst()
    end
    return NginxWorkerInstance.super.runEventLoop(self)
end

function NginxWorkerInstance:onWorkerFirst()
    local mysql = self:getMysql()
end

return NginxWorkerInstance
