
local gbc = cc.import("#gbc")
local ServiceAction = cc.class("ServiceAction", gbc.ActionBase)

local ServiceManager = cc.import("#ServiceManager")

ServiceAction.ACCEPTED_REQUEST_TYPE = "websocket"

function ServiceAction:addAction(args)
    local instance = self:getInstance()
    instance:setServiceName(args.name)
    ServiceManager.Add(args.name, args.host or ngx.var.remote_addr, args.port)
end

-- function ServiceAction:removeAction(args)
--     local instance = self:getInstance()

-- end

return ServiceAction
