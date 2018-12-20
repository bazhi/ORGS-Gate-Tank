
local gbc = cc.import("#gbc")
local ManagerAction = cc.class("ManagerAction", gbc.ActionBase)
local Constants = gbc.Constants

ManagerAction.ACCEPTED_REQUEST_TYPE = "http"

function ManagerAction:ulistAction(_arg, redis)
    return redis:smembers(Constants.USERLIST)
end

return ManagerAction

