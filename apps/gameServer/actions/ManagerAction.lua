
local gbc = cc.import("#gbc")
local ManagerAction = cc.class("ManagerAction", gbc.ActionBase)
local Constants = gbc.Constants

ManagerAction.ACCEPTED_REQUEST_TYPE = "http"

function ManagerAction:ulistAction(_arg, redis)
    return redis:zrange(Constants.USERLIST, 0, -1, "WITHSCORES")
end

function ManagerAction:ucountAction(_arg, redis)
    return redis:zcard(Constants.USERLIST)
end

return ManagerAction

