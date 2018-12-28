local Factory = cc.import(".Factory")

local NginxWorkerBootstrap = cc.class("NginxWorkerBootstrap")

function NginxWorkerBootstrap:ctor(appKeys, globalConfig)
    self._configs = Factory.makeAppConfigs(appKeys, globalConfig, package.path)
end

function NginxWorkerBootstrap:runapp(appname)
    local appConfig = self._configs[appname]
    local workerInstance = Factory.create(appConfig, "NginxWorkerInstance")
    return workerInstance:run()
end

return NginxWorkerBootstrap
