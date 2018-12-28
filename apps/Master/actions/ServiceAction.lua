
local gbc = cc.import("#gbc")
local ServiceAction = cc.class("ServiceAction", gbc.ActionBase)

local ServiceManager = cc.import("#ServiceManager", ...)

-- ServiceAction.ACCEPTED_REQUEST_TYPE = "websocket"

function ServiceAction:addAction(args)
    local instance = self:getInstance()
    if instance:hasAuthority(args.authorization) then
        local name = args.name
        local uri = args.uri
        ServiceManager.Add(name, uri)
    end
end

function ServiceAction:removeAction(args)
    local instance = self:getInstance()
    if instance:hasAuthority(args.authorization) then
        local name = args.name
        local uri = args.uri
        ServiceManager.Remove(name, uri)
    end
end

function ServiceAction:allAction()
    return ServiceManager:GetAll()
end

return ServiceAction
