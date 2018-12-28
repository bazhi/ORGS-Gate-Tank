
local gbc = cc.import("#gbc")
local SocketTimer = cc.class("SocketTimer", gbc.NgxTimerBase)
local client = require "resty.websocket_client"
local ngx_sleep = ngx.sleep
local string_sub = string.sub
local table_concat = table.concat
local cmsgpack = require "cmsgpack"
local cmsgpack_unpack = cmsgpack.unpack

--param
--[[
    uri -- 服务器地址
    authorization --授权码
    channel --共享通道
    msg --附带消息
]]--

function SocketTimer:ctor(config, param, ...)
    SocketTimer.super.ctor(self, config, param, ...)
end

function SocketTimer:connect()
    if self._socket == nil then
        local socket = client:new()
        local ok, err = socket:connect(self.param.uri, {
            protocols = {
                "gbc-auth-"..self.param.authorization,
                "gbc-msg-"..self.param.msg,
            },
        })
        if not ok then
            cc.printerror("wb connect:"..err)
            return false
        end
        cc.printf(string.format("%s is connect success", self.param.uri))
        self._socket = socket
        return true
    end
    return true
end

function SocketTimer:ProcessMessage(frame, ftype)
    self:safeFunction(function ()
        if #frame > 0 then
            local data = cmsgpack_unpack(frame)
            if type(data) == "table" and data.connectid then
                if data.tp == 1 then
                    self:sendControlMessage(data.connectid, data.message)
                else
                    self:sendMessageToConnectID(data.connectid, data.message)
                end
            else
                cc.printf(frame.."-----type:"..ftype)
            end
        end
    end)
end

function SocketTimer:closeSocket()
    if self._socket ~= nil then
        local socket = self._socket
        self._socket = nil
        socket:set_keepalive()
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
            local _, err = this._socket:send_binary(msg)
            if err then
                cc.printf("sub close socket:"..err)
                this:closeSocket()
            end
        else
            cc.printf("send_binary failed:"..msg)
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
                    cc.printf("close socket:"..err)
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
                    if self._socket then
                        self._socket:send_pong()
                    end
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
            ngx_sleep(5)
        end
    end
end

return SocketTimer

