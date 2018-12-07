
local gbc = cc.import("#gbc")
local MasterTimer = cc.class("MasterTimer", gbc.NgxTimerBase)
local json = cc.import("#json")

local client = require "resty.websocket.client"

function MasterTimer:ctor(config, ...)
    MasterTimer.super.ctor(self, config, ...)
end

function MasterTimer:runEventLoop()
    local wb, err
    local running = true
    while running do
        if not wb then
            wb, err = self:ConnectMaster()
            if err then
                cc.printerror("wb connect:"..err)
            else
                local _, err = self:addToServer(wb)
                if err then
                    cc.printerror("wb send_frame:"..err)
                end
            end
        end
        
        if wb and not wb.fatal then
            --wb:send_ping()
            local _data, typ, err = wb:recv_frame()
            if typ == "close" then
                wb:set_keepalive()
                wb = nil
            elseif typ == "pong" then
            elseif err then
                cc.printerror("wb recv_frame:"..err)
            end
        else
            if wb and wb.fatal then
                wb:set_keepalive()
                wb = nil
            end
        end
        ngx.sleep(10)
    end
    if wb then
        wb:set_keepalive()
    end
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
    cc.printf("MasterTimer connect to:"..uri)
    wb, err = client:new()
    if not wb then
        cc.printerror("client new:"..err)
        return nil
    end
    
    ok, err = wb:connect(uri, {
        protocols = {
            "gbc-auth-"..self.config.server.authorization,
        },
    })
    if not ok then
        cc.printerror("wb connect:"..err)
        return nil
    end
    
    return wb
end

return MasterTimer

