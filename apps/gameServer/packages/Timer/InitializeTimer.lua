local gbc = cc.import("#gbc")
local InitializeTimer = cc.class("InitializeTimer", gbc.NgxTimerBase)
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql
local Table = cc.import("#Table")
local Role = Table.Role
local Equipment = Table.Equipment
local Prop = Table.Prop

function InitializeTimer:ctor(config, ...)
    InitializeTimer.super.ctor(self, config, ...)
end

function InitializeTimer:runEventLoop()
    local db = self:getMysql()
    if not db then
        cc.printerror("create db connect error")
        return InitializeTimer.super.runEventLoop(self)
    end
    
    self:createTable(db, Role)
    self:createTable(db, Equipment)
    self:createTable(db, Prop)
    
    return InitializeTimer.super.runEventLoop(self)
end

function InitializeTimer:createTable(db, type)
    local ormdef = OrmMysql:new(type.Name, type.Define, type.Struct, type.Indexes)
    ormdef:Create(db)
end

return InitializeTimer

