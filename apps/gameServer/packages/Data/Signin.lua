
local Base = cc.import(".Base")
local Signin = cc.class("Signin", Base)

local Table = cc.import("#Table", ...)

function Signin:ctor()
    Signin.super.ctor(self, Table.Signin)
end

function Signin:Login(connectid, action, lastTime, loginTime, roleid)
    if not connectid or not lastTime or not loginTime or not roleid then
        return false, "NoParam"
    end
    
    local loginDate = os.date("*t", loginTime)
    local lastDate = os.date("*t", lastTime)
    
    if loginDate.year ~= lastDate.year or loginDate.month ~= lastDate.month then
        --月份不同或者年份不同，则重制签到
        local query = self:insertWithUpdateQuery({
            rid = roleid,
            times = 1,
            record = "",
        }, {times = 1, record = ""}, {})
        self:pushQuery(query, connectid, action)
        return true
    end
    
    if loginDate.year ~= lastDate.year or loginDate.yday ~= lastDate.yday then
        --新的一天
        local query = self:insertWithUpdateQuery({
            rid = roleid,
            times = 1,
            record = "",
        }, {}, {times = 1})
        self:pushQuery(query, connectid, action)
        return true
    end
    
    return true
end

return Signin
