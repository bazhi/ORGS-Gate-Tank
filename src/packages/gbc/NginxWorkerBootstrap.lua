local Factory = cc.import(".Factory")

local NginxWorkerBootstrap = cc.class("NginxWorkerBootstrap")

function NginxWorkerBootstrap:ctor(appKeys, globalConfig)
    self._configs = Factory.makeAppConfigs(appKeys, globalConfig, package.path)
end

function NginxWorkerBootstrap:runapp(appRootPath)
    --cc.dump(self._configs)
    local appConfig = self._configs[appRootPath]
    local workerInstance = Factory.create(appConfig, "NginxWorkerInstance")
    return workerInstance:run()
end

return NginxWorkerBootstrap
