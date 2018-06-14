local WorkerBootstrap = cc.class("WorkerBootstrap")
local gbc = cc.import("#gbc")
-- local ngx_timer_at = ngx.timer.at

function WorkerBootstrap:ctor()
    
end

function WorkerBootstrap:runapp()
    --math.newrandomseed()
    cc.printf("WorkerBootstrap runapp:"..ngx.worker.id())
    local nginxWorkerBootstrap = gbc.NginxWorkerBootstrap:new(cc.GAppKeys, cc.GConfig)
    for path, _ in pairs(cc.GAppKeys) do
        nginxWorkerBootstrap:runapp(path)
    end
end

return WorkerBootstrap
