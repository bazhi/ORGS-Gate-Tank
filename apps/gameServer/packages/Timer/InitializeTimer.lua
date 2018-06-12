local gbc = cc.import("#gbc")
local InitializeTimer = cc.class("InitializeTimer", gbc.NgxTimerBase)
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql
local Table = cc.import("#Table")

function InitializeTimer:ctor(config, ...)
    InitializeTimer.super.ctor(self, config, ...)
end

function InitializeTimer:runEventLoop()
    local db = self:getMysql()
    if not db then
        cc.printerror("create db connect error")
        return InitializeTimer.super.runEventLoop(self)
    end
    --cc.dump(self:getNginxConfig(), "config", 10)
    return InitializeTimer.super.runEventLoop(self)
end

return InitializeTimer

