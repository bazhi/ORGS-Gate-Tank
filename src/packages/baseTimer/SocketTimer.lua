
local gbc = cc.import("#gbc")
local SocketTimer = cc.class("SocketTimer", gbc.NgxTimerBase)
local client = require "resty.websocket.client"
local ngx_sleep = ngx.sleep
local string_sub = string.sub
local table_concat = table.concat
local json = cc.import("#json")
local json_decode = json.decode

function SocketTimer:ctor(config, param, ...)
    SocketTimer.super.ctor(self, config, param, ...)
end

function SocketTimer:connect(socket)
    local ok, err = socket:connect(self.param.uri, {
        protocols = {
            "gbc-auth-"..self.param.authorization,
        },
    })
    if not ok then
        cc.printerror("wb connect:"..err)
        return false
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

function SocketTimer:runEventLoop()
    local sub, _err = self:getRedis():makeSubscribeLoop(self.param.channel)
    if not sub then
        cc.printerror("makeSubscribeLoop failure")
        return false
    end
    local connected = false
    local socket = client:new()
    sub:start(function(_subRedis, _channel, msg)
        if socket ~= nil then
            if connected then
                local _, err = socket:send_text(msg)
                if err then
                    connected = false
                end
            end
            
        end
    end, self.param.channel)
    
    local frames = {}
    while true do
        if not connected then
            connected = self:connect(socket)
        end
        
        if connected then
            while true do
                local frame, ftype, err = socket:recv_frame()
                if err then
                    if err == "again" then
                        frames[#frames + 1] = frame
                        break -- recv next message
                    end
                    if string_sub(err, -7) == "timeout" then
                        break -- recv next message
                    end
                    connected = false
                    break
                end
                if #frames > 0 then
                    -- merging fragmented frames
                    frames[#frames + 1] = frame
                    frame = table_concat(frames)
                    frames = {}
                end
                if ftype == "close" then
                    connected = false
                    break
                elseif ftype == "ping" then
                    socket:send_pong()
                elseif ftype == "pong" then
                    -- client ponged
                elseif ftype == "text" or ftype == "binary" then
                    self:ProcessMessage(frame, ftype)
                else
                    cc.printwarn("[websocket:%s] unknown frame type \"%s\"", self.param.channel, tostring(ftype))
                end
            end
            
        else
            ngx_sleep(1)
            connected = self:connect(socket)
        end
    end
end

return SocketTimer

