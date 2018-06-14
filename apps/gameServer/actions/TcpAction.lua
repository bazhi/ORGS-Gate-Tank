local gbc = cc.import("#gbc")
local TcpAction = cc.class("TcpAction", gbc.ActionBase)

TcpAction.ACCEPTED_REQUEST_TYPE = "websocket"

--匹配命令
function TcpAction:onAction(args, _redis)
    --local instance = self:getInstance()
    self:getInstance():sendPack(nil, "fskfjldsfjdf");
end

return TcpAction
