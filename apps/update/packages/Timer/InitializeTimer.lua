local gbc = cc.import("#gbc")
local InitializeTimer = cc.class("InitializeTimer", gbc.NgxTimerBase)

function InitializeTimer:ctor(config, ...)
    InitializeTimer.super.ctor(self, config, ...)
end

function InitializeTimer:runEventLoop()
    cc.printf("website InitializeTimer:runEventLoop()")
    
    self:Initialized()
    return InitializeTimer.super.runEventLoop(self)
end

return InitializeTimer

