
local gbc = cc.import("#gbc")
local DatabaseTimer = cc.class("DatabaseTimer", gbc.NgxTimerBase)

local Constants = gbc.Constants
local MYSQL_EVENT = Constants.MYSQL_EVENT
local json = cc.import("#json")
local json_decode = json.decode

local sdDBEvent = ngx.shared.sdDBEvent
local null = ngx.null
local string_find = string.find

function DatabaseTimer:ctor(config, ...)
    DatabaseTimer.super.ctor(self, config, ...)
end

function DatabaseTimer:runEventLoop()
    local len = sdDBEvent:llen(MYSQL_EVENT)
    for _ = 1, len do
        self:process()
    end
    return DatabaseTimer.super.runEventLoop(self)
end

function DatabaseTimer:process()
    local event = sdDBEvent:rpop(MYSQL_EVENT)
    if event and event ~= null then
        local msg = json_decode(event)
        if not self:processEvent(msg) then
            sdDBEvent:lpush(MYSQL_EVENT, event)
        end
    end
end

function DatabaseTimer:processEvent(event)
    local db = self:getMysql()
    local redis = self:getRedis()
    if not db then
        cc.printerror("create db connect error")
        self:closeMysql()
        return false
    end
    if not redis then
        cc.printerror("create redis connect error")
        self:closeRedis()
        return false
    end
    
    if event.query then
        local result, err = db:query(event.query)
        if err then
            cc.printerror(err.."|_____|"..event.query)
        end
        if err and string_find(err, "failed to send query:") then
            self:closeMysql()
            return false
        end
        
        if event.connectid and event.action then
            --数据库处理完之后，是否需要发送到链接ID
            self:sendControlMessage(event.connectid, {
                action = event.action,
                args = result or {err = err},
                params = event.params,
            })
        end
    end
    return true
end

return DatabaseTimer

