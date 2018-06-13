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
local json = cc.import("#json")
--local json_encode = json.encode
local json_decode = json.decode

function WebSocketInstance:ctor(config)
    WebSocketInstance.super.ctor(self, config)
    self._event:bind(WebSocketInstance.EVENT.CONNECTED, cc.handler(self, self.onConnected))
    self._event:bind(WebSocketInstance.EVENT.DISCONNECTED, cc.handler(self, self.onDisconnected))
    self._event:bind(WebSocketInstance.EVENT.CONTROL_MESSAGE, cc.handler(self, self.onControlMessage))
end

function WebSocketInstance:authConnect()
    local master = self.config.server.master
    local token, pid, err = WebSocketInstance.super.authConnect(self)
    if not token then
        return nil, pid, err
    end
    --cc.printf("authConnect")
    local ret = http.Post(master.host, master.port, master.name.."/?action=user.verify", {
        sid = token,
        authorization = self:GetAuthority(),
    })
    if ret and ret.id then
        return token, ret.id
    end
    
    return nil, nil, "authConnect failed"
end

function WebSocketInstance:afterAuth()
    --self:sendMessage("afterAuth error")
    cc.throw("afterAuth error")
    return WebSocketInstance.super.afterAuth(self)
end

function WebSocketInstance:onConnected()
    cc.printf("onConnected:"..self:getConnectId())
end

function WebSocketInstance:onControlMessage(event)
    local msg = event.message
    local redis = event.redis
    local _eventname = event.name
    local _channel = event.channel
    
    if msg then
        if msg ~= Constants.CLOSE_CONNECT then
            local ok, err = pcall(function()
                msg = json_decode(msg)
                if msg.action then
                    self:runAction(msg.action, msg.args, redis)
                end
            end)
            if not ok then
                cc.printerror(err)
            end
        end
    end
    
end

function WebSocketInstance:onDisconnected(event)
    cc.printf("onDisconnected:"..self:getConnectId())
    if event.reason ~= gbc.Constants.CLOSE_CONNECT then
        
    end
end

function WebSocketInstance:heartbeat()
    
end

return WebSocketInstance