--[[
 
Copyright (c) 2015 gameboxcloud.com
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
]]

local gbc = cc.import("#gbc")
local http = cc.import("#http")
local WebSocketInstance = cc.class("WebSocketInstance", gbc.WebSocketInstanceBase)
local Constants = gbc.Constants
-- local json = cc.import("#json")
--local json_encode = json.encode
-- local json_decode = json.decode
local sdSIG = ngx.shared.sdSIG
local sdLogin = ngx.shared.sdLogin

function WebSocketInstance:ctor(config)
    WebSocketInstance.super.ctor(self, config)
    self._event:bind(WebSocketInstance.EVENT.CONNECTED, cc.handler(self, self.onConnected))
    self._event:bind(WebSocketInstance.EVENT.DISCONNECTED, cc.handler(self, self.onDisconnected))
    --self._event:bind(WebSocketInstance.EVENT.CONTROL_MESSAGE, cc.handler(self, self.onControlMessage))
end

function WebSocketInstance:authConnect()
    if not sdSIG:get(Constants.SIGINIT) then
        return nil, nil, "SIGINIT is not set"
    end
    local master = self.config.server.master
    local token, pid, err = WebSocketInstance.super.authConnect(self)
    if not token then
        return nil, pid, err
    end
    --cc.printf("authConnect")
    -- local user = http.Post(master.host, master.port, master.name.."/?action=user.verify", {
    --     sid = token,
    --     authorization = self:GetAuthority(),
    -- })
    self._User = user
    if user and user.id then
        return token, user.id
    else
        --cc.printf("authConnect failed:"..token)
    end
    
    return nil, nil, "authConnect failed"
end

function WebSocketInstance:afterAuth()
    local con_id = self:getConnectId()
    if con_id then
        local lgcnt = sdLogin:incr(con_id, 1, 0)
        if lgcnt > 1 then
            sdLogin:incr(con_id, -1, 0)
            self:sendError("UserLoggedIn")
            return false
        end
        self._locked = true
    end
    return WebSocketInstance.super.afterAuth(self)
end

function WebSocketInstance:onClose()
    local con_id = self:getConnectId()
    if self._locked and con_id then
        sdLogin:incr(con_id, -1, 0)
    end
    return WebSocketInstance.super.onClose(self)
end

function WebSocketInstance:onConnected()
    cc.printf("onConnected:"..self:getConnectId())
    self:runAction("role.load", {})
end

function WebSocketInstance:onDisconnected(event)
    cc.printf("onDisconnected:"..self:getConnectId())
    if event.reason ~= gbc.Constants.CLOSE_CONNECT then
        
    end
end

function WebSocketInstance:heartbeat()
    
end

function WebSocketInstance:getUser()
    return self._User
end

function WebSocketInstance:setPlayer(player)
    self._Player = player
end

function WebSocketInstance:getPlayer()
    return self._Player
end

return WebSocketInstance
