local gbc = cc.import("#gbc")
local InitializeTimer = cc.class("InitializeTimer", gbc.NgxTimerBase)

function InitializeTimer:ctor(config, ...)
    InitializeTimer.super.ctor(self, config, ...)
end

function InitializeTimer:runEventLoop()
    self:getMysql()
    return InitializeTimer.super.runEventLoop(self)
end

return InitializeTimer
