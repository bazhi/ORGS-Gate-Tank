
local gbc = cc.import("#gbc")
local MasterTimer = cc.class("MasterTimer", gbc.NgxTimerBase)
local json = cc.import("#json")

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_kill = ngx.thread.kill
local table_concat = table.concat
local string_sub = string.sub

local client = require "resty.websocket_client"

function MasterTimer:ctor(config, ...)
    MasterTimer.super.ctor(self, config, ...)
end

function MasterTimer:killThread()
    if self._thread ~= nil then
        ngx_thread_kill(self._thread)
        self._thread = nil
    end
end

function MasterTimer:Clear()
    if self._socket then
        self._socket:set_keepalive()
        self._socket = nil
    end
end

function MasterTimer:Reconect()
    if self._socket and self._socket.fatal then
        local sock = self._socket
        self._socket = nil
        self:killThread()
        sock:set_keepalive()
    end
    if not self._socket then
        local wb, err = self:ConnectMaster()
        if not err then
            self._socket = wb
            self._thread = ngx_thread_spawn(MasterTimer.OnLoop, self)
            local _, err = self:addToServer(self._socket)
            if err then
                cc.printerror("wb send_frame:"..err)
            end
        end
    end
end

function MasterTimer:OnLoop()
    local frames = {}
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
            cc.printerror(err)
            break
        end
        
        if #frames > 0 then
            -- merging fragmented frames
            frames[#frames + 1] = frame
            frame = table_concat(frames)
            frames = {}
        end
        
        if ftype == "close" then
            break
        elseif ftype == "ping" then
            if self._socket then
                self._socket:send_pong()
            end
        elseif ftype == "pong" then
            -- client ponged
        elseif ftype == "text" or ftype == "binary" then
            cc.printinfo(frame)
        end
    end
end

function MasterTimer:runEventLoop()
    local running = true
    while running do
        self:Reconect()
        ngx.sleep(10)
        if self._socket then
            local _, err = self._socket:send_ping()
            if err then
                cc.printerror("wb send_frame:"..err)
            end
        end
    end
    self:Clear()
    self:killThread()
    MasterTimer.super.runEventLoop(self)
    return false
end

function MasterTimer:addToServer(wb)
    if wb then
        local serverConfig, appName = self:getNginxConfig()
        return wb:send_text(json.encode({
            action = "service.add",
            port = serverConfig.port,
            host = serverConfig.host,
            name = appName,
        }))
    end
end

function MasterTimer:ConnectMaster()
    local masterConfig = self:getMasterConfig()
    local ok, err, wb
    local uri = string.format("ws://%s:%d/%s/", masterConfig.host, masterConfig.port, masterConfig.name)
    wb, err = client:new({
        timeout = 60000
    })
    if not wb then
        return nil, err
    end
    
    ok, err = wb:connect(uri, {
        protocols = {
            "gbc-auth-"..self.config.server.authorization,
        },
    })
    if not ok then
        return nil, err
    end
    cc.printf("websocket connected:"..uri.." reusedtimes:" .. wb.sock:getreusedtimes())
    return wb
end

return MasterTimer

