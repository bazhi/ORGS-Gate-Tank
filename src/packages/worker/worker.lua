local worker = cc.class("worker")
local gbc = cc.import("#gbc")
-- local ngx_timer_at = ngx.timer.at

function worker:ctor()
    
end

function worker:runapp()
    --math.newrandomseed()
    cc.printf("worker runapp:"..ngx.worker.id())
    local nginxWorkerBootstrap = gbc.NginxWorkerBootstrap:new(cc.GAppKeys, cc.GConfig)
    for appname, _ in pairs(cc.GAppKeys) do
        nginxWorkerBootstrap:runapp(appname)
    end
end

return worker
