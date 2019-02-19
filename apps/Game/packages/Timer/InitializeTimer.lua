local gbc = cc.import("#gbc")
local InitializeTimer = cc.class("InitializeTimer", gbc.NgxTimerBase)
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql
local Table = cc.import("#Table", ...)
local Constants = gbc.Constants

function InitializeTimer:ctor(config, ...)
    InitializeTimer.super.ctor(self, config, ...)
end

function InitializeTimer:runEventLoop()
    local db = self:getMysql()
    if not db then
        cc.printerror("InitializeTimer:runEventLoop() create db connect error")
        return InitializeTimer.super.runEventLoop(self)
    end
    
    self:createTable(db, Table.Role)
    
    self:clearUserList()
    self:Initialized()
    return InitializeTimer.super.runEventLoop(self)
end

function InitializeTimer:clearUserList()
    local redis = self:getRedis()
    if redis then
        redis:del(Constants.USERLIST)
    end
end

function InitializeTimer:createTable(db, type)
    local ormdef = OrmMysql:new(type.Name, type.Define, type.Struct, type.Indexes)
    ormdef:Create(db)
end

return InitializeTimer

