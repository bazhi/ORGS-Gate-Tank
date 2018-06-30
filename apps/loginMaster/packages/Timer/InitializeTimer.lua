local gbc = cc.import("#gbc")
local InitializeTimer = cc.class("InitializeTimer", gbc.NgxTimerBase)
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql
local Table = cc.import("#Table")
local Account = Table.Account

function InitializeTimer:ctor(config, ...)
    InitializeTimer.super.ctor(self, config, ...)
end

function InitializeTimer:runEventLoop()
    local db = self:getMysql()
    if not db then
        cc.printerror("InitializeTimer:runEventLoop() create db connect error")
        return InitializeTimer.super.runEventLoop(self)
    end
    local ormAccount = OrmMysql:new(Account.Name, Account.Define, Account.Struct, Account.Indexes)
    ormAccount:Create(db)
    
    return InitializeTimer.super.runEventLoop(self)
end

return InitializeTimer

