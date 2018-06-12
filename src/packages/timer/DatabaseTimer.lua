
local gbc = cc.import("#gbc")
local DatabaseTimer = cc.class("DatabaseTimer", gbc.NgxTimerBase)
local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql

local Constants = gbc.Constants
local MYSQL_EVENT = Constants.MYSQL_EVENT
local json = cc.import("#json")
local json_decode = json.decode

local sdDBEvent = ngx.shared.sdDBEvent
local null = ngx.null
local ngx_sleep = ngx.sleep
local string_find = string.find

local sleeptime = 1 / 30

function DatabaseTimer:ctor(config, ...)
    DatabaseTimer.super.ctor(self, config, ...)
end

function DatabaseTimer:runEventLoop()
    while true do
        self:process(db)
    end
    
    return DatabaseTimer.super.runEventLoop(self)
end

function DatabaseTimer:process()
    local event = sdDBEvent:rpop(MYSQL_EVENT)
    if event and event ~= null then
        event = json_decode(event)
        self:processEvent(event)
    end
end

function DatabaseTimer:processEvent(event)
    local db = self:getMysql()
    local redis = self:getRedis()
    if not db then
        cc.printerror("create db connect error")
        ngx_sleep(sleeptime)
        self:closeMysql()
        self:processEvent(event)
        return
    end
    if not redis then
        cc.printerror("create redis connect error")
        ngx_sleep(sleeptime)
        self:closeRedis()
        self:processEvent(event)
        return
    end
    
    if event.query then
        local ret, err = db:query(event.query)
        if ret then
            
        else
            if string_find(err, "failed to send query:") then
                self:closeMysql()
            else
                
            end
        end
    end
end

return DatabaseTimer

