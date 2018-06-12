
local gbc = cc.import("#gbc")
local MasterTimer = cc.class("MasterTimer", gbc.NgxTimerBase)
local json = cc.import("#json")

local client = require "resty.websocket.client"

function MasterTimer:ctor(config, ...)
    MasterTimer.super.ctor(self, config, ...)
end

function MasterTimer:runEventLoop()
    local wb, err
    while true do
        if not wb then
            wb, err = self:ConnectMaster()
            self:addToServer(wb)
        end
        
        if wb then
            local data, typ, _err = wb:recv_frame()
            if not data or typ == "close" then
                wb:send_close()
                wb = nil
            end
        end
        cc.printf("runEventLoop")
    end
    if wb then
        wb:send_close()
    end
    return MasterTimer.super.runEventLoop(self)
end

function MasterTimer:addToServer(wb)
    if wb then
        local serverConfig, appName = self:getNginxConfig()
        wb:send_text(json.encode({
            action = "service.add",
            port = serverConfig.port,
            name = appName,
        }))
    end
end

function MasterTimer:ConnectMaster()
    local masterConfig = self:getMasterConfig()
    local ok, err, wb
    local uri = string.format("ws://%s:%d/%s/", masterConfig.host, masterConfig.port, masterConfig.path)
    
    wb, err = client:new()
    if not wb then
        cc.printerror(err)
        return nil
    end
    
    ok, err = wb:connect(uri, {
        protocols = {
            "gbc-auth-"..self.config.server.authorization,
        },
    })
    if not ok then
        cc.printerror(err)
        return nil
    end
    
    return wb
end

return MasterTimer

