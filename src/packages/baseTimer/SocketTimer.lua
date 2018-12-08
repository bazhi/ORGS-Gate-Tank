
local gbc = cc.import("#gbc")
local SocketTimer = cc.class("SocketTimer", gbc.NgxTimerBase)
local client = require "resty.websocket_client"
local ngx_sleep = ngx.sleep
local string_sub = string.sub
local table_concat = table.concat
local json = cc.import("#json")
local json_decode = json.decode

function SocketTimer:ctor(config, param, ...)
    SocketTimer.super.ctor(self, config, param, ...)
end

function SocketTimer:connect()
    if self._socket == nil then
        local socket = client:new()
        local ok, err = socket:connect(self.param.uri, {
            protocols = {
                "gbc-auth-"..self.param.authorization,
            },
        })
        if not ok then
            cc.printerror("wb connect:"..err)
            return false
        end
        self._socket = socket
        return true
    end
    return true
end

function SocketTimer:ProcessMessage(frame, _ftype)
    self:safeFunction(function ()
        local data = json_decode(frame)
        if data then
            self:sendMessageToConnectID(data.connectid, data.message)
        end
    end)
end

function SocketTimer:closeSocket()
    if self._socket ~= nil then
        self._socket:set_keepalive()
        self._socket = nil
    end
end

function SocketTimer:runEventLoop()
    local sub, _err = self:getRedis():makeSubscribeLoop(self.param.channel)
    if not sub then
        cc.printerror("makeSubscribeLoop failure")
        return false
    end
    local this = self
    sub:start(function(_subRedis, _channel, msg)
        if this._socket ~= nil then
            local _, err = this._socket:send_text(msg)
            if err then
                this:closeSocket()
            end
        end
    end, self.param.channel)
    
    local frames = {}
    while true do
        if self._socket then
            while self._socket do
                local frame, ftype, err = self._socket:recv_frame()
                if err then
                    if err == "again" then
                        frames[#frames + 1] = frame
                        break -- recv next message
                    end
                    if string_sub(err, -7) == "timeout" then
                        break -- recv next message
                    end
                    self:closeSocket()
                    break
                end
                if #frames > 0 then
                    -- merging fragmented frames
                    frames[#frames + 1] = frame
                    frame = table_concat(frames)
                    frames = {}
                end
                if ftype == "close" then
                    self:closeSocket()
                    break
                elseif ftype == "ping" then
                    self._socket:send_pong()
                elseif ftype == "pong" then
                    -- client ponged
                elseif ftype == "text" or ftype == "binary" then
                    self:ProcessMessage(frame, ftype)
                else
                    cc.printwarn("[websocket:%s] unknown frame type \"%s\"", self.param.channel, tostring(ftype))
                end
            end
        else
            self:connect()
            ngx_sleep(1)
        end
    end
end

return SocketTimer

