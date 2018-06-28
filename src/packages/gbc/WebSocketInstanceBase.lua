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

local ngx = ngx
local ngx_log = ngx.log
local ngx_md5 = ngx.md5
local ngx_thread_spawn = ngx.thread.spawn
local req_get_headers = ngx.req.get_headers
local req_read_body = ngx.req.read_body
local string_format = string.format
local string_sub = string.sub
local table_concat = table.concat
local table_insert = table.insert
local ngx_say = ngx.say
local tostring = tostring
local type = type

local json = cc.import("#json")
local Constants = cc.import(".Constants")

local json_encode = json.encode
local json_decode = json.decode

local pb = cc.import("#protos")
local CmdToPB = pb.CmdToPB
local PBToCmd = pb.PBToCmd
local ActionMap = pb.ActionMap

local InstanceBase = cc.import(".InstanceBase")
local WebSocketInstanceBase = cc.class("WebSocketInstanceBase", InstanceBase)

local _EVENT = table.readonly({
    CONNECTED = "CONNECTED",
    DISCONNECTED = "DISCONNECTED",
    CONTROL_MESSAGE = "CONTROL_MESSAGE",
    USER_MESSAGE = "USER_MESSAGE",
})

WebSocketInstanceBase.EVENT = _EVENT

local _processMessage

function WebSocketInstanceBase:ctor(config)
    WebSocketInstanceBase.super.ctor(self, config, Constants.WEBSOCKET_REQUEST_TYPE)
    
    local appConfig = self.config.app
    if config.app.websocketMessageFormat then
        appConfig.messageFormat = config.app.websocketMessageFormat
    end
    appConfig.websocketsTimeout = appConfig.websocketsTimeout or Constants.WEBSOCKET_DEFAULT_TIME_OUT
    appConfig.websocketsMaxPayloadLen = appConfig.websocketsMaxPayloadLen or Constants.WEBSOCKET_DEFAULT_MAX_PAYLOAD_LEN
end

function WebSocketInstanceBase:run()
    local _ok
    _ok, _ = xpcall(function()
        self:runEventLoop()
        self:onClose()
        ngx.exit(ngx.OK)
    end, function(err)
        err = tostring(err)
        cc.printerror(err .. debug.traceback("", 10))
        self:onClose()
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        ngx.exit(ngx.ERROR)
    end)
end

function WebSocketInstanceBase:authConnect()
    if ngx.headers_sent then
        return nil, nil, "response header already sent"
    end
    
    req_read_body()
    local headers = ngx.req.get_headers()
    local protocols = headers["sec-websocket-protocol"]
    if type(protocols) ~= "table" then
        protocols = {protocols}
    end
    if #protocols == 0 then
        return nil, nil, "not set header: Sec-WebSocket-Protocol"
    end
    
    local pattern = Constants.WEBSOCKET_SUBPROTOCOL_PATTERN
    for _, protocol in ipairs(protocols) do
        local token = string.match(protocol, pattern)
        if token then
            return token, nil
        end
    end
    
    return nil, nil, "not found token in header: Sec-WebSocket-Protocol"
end

function WebSocketInstanceBase:afterAuth()
    --self:sendMessage("afterAuth error")
    --cc.throw("afterAuth error")
    return true
end

function WebSocketInstanceBase:onClose()
    if self._socket then
        self._socket:send_close()
        self._socket = nil
    end
    return WebSocketInstanceBase.super.onClose(self)
end

--回复消息
function WebSocketInstanceBase:sendMessage(msg)
    if self._socket then
        self._socket:send_binary(tostring(msg))
    end
end

function WebSocketInstanceBase:sendError(erroname, msgid)
    self:sendPack(PBToCmd.Error, {
        code = erroname,
    }, msgid)
end

function WebSocketInstanceBase:sendDelete(cmd, id, msgid)
    if type(cmd) == "string" then
        cmd = PBToCmd[cmd]
    end
    self:sendPack("Delete", {
        ["type"] = cmd,
        id = id,
    }, msgid)
end

function WebSocketInstanceBase:sendPack(cmd, msg, msgid)
    msgid = msgid or 0
    local ok, result = self:safeFunction(function()
        local name = cmd
        if type(name) == "number" then
            name = CmdToPB[cmd]
        else
            name = cmd
            cmd = PBToCmd[cmd]
        end
        local data
        if name then
            if msg then
                data = pb.encode("pb."..name, msg)
            end
        else
            cmd = 0
            data = tostring(msg)
        end
        
        return pb.encode("pb.Pack", {
            ["type"] = cmd,
            content = data,
            msgid = msgid,
        })
    end)
    if ok then
        self:sendMessage(result)
    end
end

function WebSocketInstanceBase:onControlMessage(event)
    local msg = event.message
    local redis = event.redis
    local _eventname = event.name
    local _channel = event.channel
    local this = self
    if msg then
        if msg ~= Constants.CLOSE_CONNECT then
            self:safeFunction(function()
                msg = json_decode(msg)
                if msg.action then
                    this:runAction(msg.action, msg.args, redis, true, msg.params)
                end
            end)
        end
    end
    
end

function WebSocketInstanceBase:runEventLoop()
    -- auth client
    local this = self
    local token, connectId, err = self:authConnect()
    if not token then
        cc.printinfo(err)
        return false
    end
    self._connectToken = token
    
    -- generate connect id and channel
    local redis = self:getRedis()
    --当没有取得链接ID时，使用自动生成的ID
    if not connectId then
        connectId = "CON_"..tostring(redis:incr(Constants.NEXT_CONNECT_ID_KEY))
    else
        connectId = "PID_"..connectId
    end
    self._connectId = connectId
    
    local connectChannel = Constants.CONNECT_CHANNEL_PREFIX .. tostring(connectId)
    self._connectChannel = connectChannel
    local controlChannel = Constants.CONTROL_CHANNEL_PREFIX .. tostring(connectId)
    self._controlChannel = controlChannel
    
    -- create websocket server
    local server = require("resty.websocket.server")
    local socket, err = server:new({
        timeout = self.config.app.websocketsTimeout,
        max_payload_len = self.config.app.websocketsMaxPayloadLen,
    })
    if err then
        cc.throw("[websocket:%s] create websocket server failed, %s", connectId, err)
    end
    self._socket = socket
    if not self:afterAuth() then
        return false
    end
    
    -- tracking socket close reason
    local closeReason = ""
    
    -- create subscribe loop
    local sub, _err = self:getRedis():makeSubscribeLoop(connectId)
    if not sub then
        cc.throw(err)
    end
    
    local event = self._event
    sub:start(function(subRedis, channel, msg)
        if channel == controlChannel then
            local evt = {
                name = _EVENT.CONTROL_MESSAGE,
                channel = channel,
                message = msg,
                redis = subRedis,
            }
            this:onControlMessage(evt)
            event:trigger(evt)
            if msg == Constants.CLOSE_CONNECT then
                closeReason = Constants.CLOSE_CONNECT
                socket:send_close()
            end
        else
            socket:send_text(msg)
        end
    end, controlChannel, connectChannel, Constants.BROADCAST_ALL_CHANNEL)
    self._subloop = sub
    
    -- connected
    cc.printinfo("[websocket:%s] connected", connectId)
    
    self:safeFunction(function()
        event:trigger(_EVENT.CONNECTED)
    end)
    
    -- event loop
    local frames = {}
    local running = true
    while running do
        self:heartbeat()
        
        while true do
            --[[
            Receives a WebSocket frame from the wire.
 
            In case of an error, returns two nil values and a string describing the error.
 
            The second return value is always the frame type, which could be
            one of continuation, text, binary, close, ping, pong, or nil (for unknown types).
 
            For close frames, returns 3 values: the extra status message
            (which could be an empty string), the string "close", and a Lua number for
            the status code (if any). For possible closing status codes, see
 
            http://tools.ietf.org/html/rfc6455#section-7.4.1
 
            For other types of frames, just returns the payload and the type.
 
            For fragmented frames, the err return value is the Lua string "again".
            ]]
            local frame, ftype, err = socket:recv_frame()
            if err then
                if err == "again" then
                    frames[#frames + 1] = frame
                    break -- recv next message
                end
                
                if string_sub(err, -7) == "timeout" then
                    break -- recv next message
                end
                
                cc.printwarn("[websocket:%s] failed to receive frame, type \"%s\", %s", connectId, ftype, err)
                closeReason = ftype
                running = false -- stop loop
                break
            end
            
            if #frames > 0 then
                -- merging fragmented frames
                frames[#frames + 1] = frame
                frame = table_concat(frames)
                frames = {}
            end
            
            if ftype == "close" then
                running = false -- stop loop
                break
            elseif ftype == "ping" then
                socket:send_pong()
            elseif ftype == "pong" then
                -- client ponged
            elseif ftype == "text" or ftype == "binary" then
                local _, err = _processMessage(self, frame, ftype)
                if err then
                    cc.printerror("[websocket:%s] process %s message failed, %s", connectId, ftype, err)
                end
            else
                cc.printwarn("[websocket:%s] unknown frame type \"%s\"", connectId, tostring(ftype))
            end
        end -- rect next message
    end -- loop
    
    sub:stop()
    self._subloop = nil
    self._socket = nil
    
    -- disconnected
    self:safeFunction(function()
        event:trigger({name = _EVENT.DISCONNECTED, reason = closeReason})
    end)
    cc.printinfo("[websocket:%s] disconnected", connectId)
end

function WebSocketInstanceBase:heartbeat()
end

function WebSocketInstanceBase:getConnectToken()
    return self._connectToken
end

function WebSocketInstanceBase:getConnectId()
    return self._connectId
end

function WebSocketInstanceBase:getConnectChannel()
    return self._connectChannel
end

function WebSocketInstanceBase:getControlChannel()
    return self._controlChannel
end

-- add methods

local _COMMANDS = {
    "subscribe", "unsubscribe",
    "psubscribe", "punsubscribe",
}

for _, cmd in ipairs(_COMMANDS) do
    WebSocketInstanceBase[cmd] = function(self, ...)
        local subloop = self._subloop
        local method = subloop[cmd]
        return method(subloop, ...)
    end
end

-- private

_processMessage = function(self, rawMessage, messageType)
    local this = self
    local messageFormat = self.config.app.websocketMessageFormat
    local ok, message = self:safeFunction(function()
        return this:parseMessage(rawMessage, messageType, messageFormat)
    end)
    if not ok then
        return nil, "parseMessage error"
    end
    
    local msgid = message.msgid
    local actionName = message.action
    
    local _ok, result = self:safeFunction(function()
        return this:runAction(actionName, message._args or message)
    end)
    
    if not _ok then
        return nil, "runAction Error:"..actionName
    end
    
    if not msgid then
        cc.printwarn("action \"%s\" return unused result", actionName)
        return true
    end
    
    if not self._socket then
        return nil, string.format("socket removed, action \"%s\"", actionName)
    end
    
    if messageFormat == "pbc" then
        local rtype = type(result)
        if rtype == "number" then
            self:sendPack("Operation", {result = result}, msgid)
        else
            self:sendPack("Operation", result or {result = 1}, msgid)
        end
    else
        local rtype = type(result)
        if rtype == "nil" then
            return
        end
        
        if rtype ~= "table" then
            cc.printwarn("action \"%s\" return invalid result", actionName)
        end
        result.msgid = msgid
        local message = json_encode(result)
        local _bytes, err = self._socket:send_text(message)
        if err then
            return nil, string.format("send message to client failed, %s", err)
        end
    end
    
    return true
end

function WebSocketInstanceBase:parseMessage(rawMessage, messageType, messageFormat)
    if messageType == Constants.WEBSOCKET_BINARY_MESSAGE_TYPE then
        if messageFormat == "pbc" then
            local message = pb.decode("pb.Pack", rawMessage)
            if type(message) == "table" then
                if message.type then
                    local name = CmdToPB[message.type]
                    if name then
                        local actionName = ActionMap[name]
                        if actionName then
                            local content = pb.decode("pb."..name, message.content)
                            return {
                                action = actionName,
                                _args = content,
                                msgid = message.msgid,
                            }
                        else
                            cc.throw("can not supported pbc messagename:"..name)
                        end
                    else
                        cc.throw("can not supported pbc messageindex:"..message.type)
                    end
                end
                return message
            else
                cc.throw("not supported message format \"%s\"", type(message))
            end
        end
    end
    
    if messageType ~= Constants.WEBSOCKET_TEXT_MESSAGE_TYPE then
        cc.throw("not supported message type \"%s\"", messageType)
    end
    
    -- TODO: support message format plugin
    if messageFormat == "json" then
        local message = json_decode(rawMessage)
        if type(message) == "table" then
            return message
        else
            cc.throw("not supported message format \"%s\"", type(message))
        end
    else
        cc.throw("not support message format \"%s\"", tostring(messageFormat))
    end
end

return WebSocketInstanceBase
