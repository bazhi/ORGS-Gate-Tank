
local gbc = cc.import("#gbc")
local ManagerAction = cc.class("ManagerAction", gbc.ActionBase)
local Constants = gbc.Constants
local netpack = cc.import("#netpack")
--local net_encode = netpack.encode
local net_decode = netpack.decode

ManagerAction.ACCEPTED_REQUEST_TYPE = "http"

function ManagerAction:ulistAction(_arg, redis)
    return redis:zrange(Constants.USERLIST, 0, -1, "WITHSCORES")
end

function ManagerAction:ucountAction(_arg, redis)
    return redis:zcard(Constants.USERLIST)
end

function ManagerAction:getuserAction(arg, redis)
    local id = tonumber(arg.id)
    if id > 0 then
        local data = redis:get(Constants.USER..id)
        return net_decode(data)
    end
end

return ManagerAction

