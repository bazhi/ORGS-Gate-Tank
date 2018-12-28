
local gbc = cc.import("#gbc")
local WebSocketInstance = cc.class("WebSocketInstance", gbc.WebSocketInstanceBase)
local Constants = gbc.Constants
local MessageType = gbc.MessageType

local http = cc.import("#http")

function WebSocketInstance:ctor(config)
    WebSocketInstance.super.ctor(self, config)
    local gate = self:GetConfig() --本身的配置
    self._GATE_CN = Constants.SOCKET_CONNECT_CHANNLE..gate.name
end

function WebSocketInstance:authConnect()
    local master = self:GetConfig("Master")
    if not master then
        return nil, nil, "can not find master"
    end
    local token, pid, err = WebSocketInstance.super.authConnect(self)
    if not token then
        return nil, pid, err
    end
    --cc.printf("authConnect")
    local user = http.Post(master.host, master.port, master.name.."/?action=user.verify", {
        sid = token,
        authorization = self:GetAuthority(),
    })
    
    if user and user.id then
        self.pid = user.id
        return token, user.id
    end
    return nil, nil, "authConnect failed"
end

function WebSocketInstance:onConnected()
    cc.printf("onConnected user:"..self:getConnectId())
    self:sendToGameServer({
        connectid = self.pid,
        format = "text",
        message = MessageType.ONCONNECTED,
    })
end

function WebSocketInstance:onDisconnected(closeReason)
    cc.printf("onDisconnected user:"..self:getConnectId())
    self:sendToGameServer({
        connectid = self.pid,
        format = "text",
        message = MessageType.ONDISCONNECTED,
    })
    if closeReason ~= Constants.CLOSE_CONNECT then
        --服务器主动关闭
    end
end

function WebSocketInstance:sendToGameServer(msg)
    local ok, err = self:sendToChannel(self._GATE_CN, msg)
    if not ok then
        cc.printf(err)
    end
    return ok
end

function WebSocketInstance:onProtobuf(rawMessage)
    if rawMessage then
        return self:sendToGameServer({
            connectid = self.pid,
            message = rawMessage,
            format = "pbc",
        })
    end
    return nil, "rawMessage is nil"
end

function WebSocketInstance:onControlMessage(_msg, _subRedis)
    
end

function WebSocketInstance:heartbeat()
    
end

return WebSocketInstance
