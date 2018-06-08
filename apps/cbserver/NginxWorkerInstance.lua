local gbc = cc.import("#gbc")
local NginxWorkerInstance = cc.class("NginxWorkerInstance", gbc.NginxWorkerInstanceBase)


function NginxWorkerInstance:ctor(config, ...)
	NginxWorkerInstance.super.ctor(self, config, ...)
end

function NginxWorkerInstance:run()
	local workerid = ngx.worker.id()
	if 0 == workerid then
		cc.dump(self.config)
	end
	return NginxWorkerInstance.super.run(self)
end

return NginxWorkerInstance
