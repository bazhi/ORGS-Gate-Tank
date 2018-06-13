local gbc = cc.import("#gbc")
local InitializeTimer = cc.class("InitializeTimer", gbc.NgxTimerBase)
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql
local Table = cc.import("#Table")
local Role = Table.Role
local Constants = gbc.Constants

function InitializeTimer:ctor(config, ...)
    InitializeTimer.super.ctor(self, config, ...)
end

function InitializeTimer:runEventLoop()
    local db = self:getMysql()
    if not db then
        cc.printerror("create db connect error")
        return InitializeTimer.super.runEventLoop(self)
    end
    
    local ormRole = OrmMysql:new(Role.Name, Role.Define, Role.Struct, Role.Indexes)
    ormRole:Create(db)
    
    local redis = self:getRedis()
    redis:set(Constants.NEXT_CONNECT_ID_KEY, 0)
    return InitializeTimer.super.runEventLoop(self)
end

return InitializeTimer

