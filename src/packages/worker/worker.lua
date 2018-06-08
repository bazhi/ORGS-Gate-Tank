local WorkerBootstrap = cc.class("WorkerBootstrap")
local gbc = cc.import("#gbc")
-- local ngx_timer_at = ngx.timer.at

function WorkerBootstrap:ctor()

end

function WorkerBootstrap:runapp()
    math.newrandomseed()
    local nginxWorkerBootstrap = gbc.NginxWorkerBootstrap:new(cc.exports.GAppKeys, cc.exports.GConfig)
    for path, _ in pairs(cc.exports.GAppKeys) do
        nginxWorkerBootstrap:runapp(path)
    end
end

return WorkerBootstrap