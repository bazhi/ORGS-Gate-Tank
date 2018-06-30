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
        cc.printerror("InitializeTimer:runEventLoop() create db connect error")
        return InitializeTimer.super.runEventLoop(self)
    end
    
    self:createTable(db, Table.Role)
    self:createTable(db, Table.Equipment)
    self:createTable(db, Table.Prop)
    self:createTable(db, Table.Chapter)
    self:createTable(db, Table.Section)
    self:createTable(db, Table.Mission)
    self:createTable(db, Table.Box)
    
    return InitializeTimer.super.runEventLoop(self)
end

function InitializeTimer:createTable(db, type)
    local ormdef = OrmMysql:new(type.Name, type.Define, type.Struct, type.Indexes)
    ormdef:Create(db)
end

return InitializeTimer

