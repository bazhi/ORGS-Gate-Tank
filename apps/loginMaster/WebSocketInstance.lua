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
local WebSocketInstance = cc.class("WebSocketInstance", gbc.WebSocketInstanceBase)
local ServiceManager = cc.import("#ServiceManager", ...)
local Constants = gbc.Constants
local sdSIG = ngx.shared.sdSIG

function WebSocketInstance:ctor(config)
    WebSocketInstance.super.ctor(self, config)
    self._event:bind(WebSocketInstance.EVENT.CONNECTED, cc.handler(self, self.onConnected))
    self._event:bind(WebSocketInstance.EVENT.DISCONNECTED, cc.handler(self, self.onDisconnected))
end

function WebSocketInstance:authConnect()
    if not sdSIG:get(Constants.SIGINIT) then
        return nil, nil, "SIGINIT is not set"
    end
    
    local authorization = WebSocketInstance.super.authConnect(self)
    if not self:hasAuthority(authorization) then
        return nil, nil, "authorization is error"
    end
    
    return authorization
end

function WebSocketInstance:onConnected()
    cc.printf("ON CONNECTED:%s|%s", ngx.var.remote_addr, self:getConnectId())
end

function WebSocketInstance:onDisconnected(event)
    cc.printf("ON Disconnected:%s|%s", ngx.var.remote_addr, self:getConnectId())
    if self._ServiceName then
        ServiceManager.Remove(self._ServiceName, self._Host or ngx.var.remote_addr)
    end
    
    if event.reason ~= gbc.Constants.CLOSE_CONNECT then
        
    end
end

function WebSocketInstance:setServiceName(name)
    self._ServiceName = name
end

function WebSocketInstance:setHost(host)
    self._Host = host
end

function WebSocketInstance:getServiceName()
    return self._ServiceName
end

function WebSocketInstance:heartbeat()
    
end

return WebSocketInstance
