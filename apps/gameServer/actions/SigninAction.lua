
local gbc = cc.import("#gbc")
local SigninAction = cc.class("SigninAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")
-- local parse = cc.import("#parse")
-- local ParseConfig = parse.ParseConfig

local json = cc.import("#json")
local json_encode = json.encode
local json_decode = json.decode

SigninAction.ACCEPTED_REQUEST_TYPE = "websocket"

function SigninAction:getAction(args, redis)
    local day = args.day or 1
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local signin = player:getSignin()
    local signin_Data = signin:get()
    if day >= 1 and day <= signin_Data.times then
        local record = json_decode(signin_Data.record)
        if nil == record then
            record = {}
        end
        
        for _, d in ipairs(record) do
            if d == day then
                return false, "NoAccept"
            end
        end
        
        --增加到家
        local cfg_signin = dbConfig.get("cfg_signin", day)
        if cfg_signin ~= nil then
            role:AddData(instance:getConnectId(), nil, cfg_signin.gold, cfg_signin.diamond)
            self:runAction("prop.addProps", {
                items = cfg_signin.items,
                diamond = cfg_signin.diamond,
                gold = cfg_signin.gold,
            }, redis)
        end
        
        --可以领取，计算道具
        table.insert(record, day)
        signin_Data.record = json_encode(record)
        local query = signin:updateQuery({rid = signin_Data.rid}, {record = signin_Data.record})
        signin:pushQuery(query, instance:getConnectId())
        instance:sendPack("SigninRecord", {
            times = signin_Data.times,
            record = record,
        })
    end
    return true
end

function SigninAction:onData(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local signin = player:getSignin()
    local signin_Data = signin:get()
    if #args > 0 then
        signin:update(args[1])
        --self:getAction({day = 2})
        instance:sendPack("SigninRecord", {
            times = signin_Data.times,
            record = json_decode(signin_Data.record) or {},
        })
    end
end

function SigninAction:onLogin(_args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local signin = player:getSignin()
    local role = player:getRole()
    local role_data = role:get()
    local query = signin:selectQuery({rid = role_data.id})
    signin:pushQuery(query, instance:getConnectId(), "signin.onData")
end

function SigninAction:login(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local signin = player:getSignin()
    
    local lastTime = args.lastTime
    local loginTime = args.loginTime
    
    local loginDate = os.date("*t", loginTime)
    local lastDate = os.date("*t", lastTime)
    if loginDate.year ~= lastDate.year or loginDate.month ~= lastDate.month then
        --月份不同或者年份不同，则重制签到
        local query = signin:insertWithUpdateQuery({
            rid = role_data.id,
            times = 1,
            record = "",
        }, {times = 1, record = ""}, {})
        signin:pushQuery(query, instance:getConnectId(), "signin.onLogin")
        return
    end
    
    if loginDate.year ~= lastDate.year or loginDate.yday ~= lastDate.yday or 1 then
        --新的一天
        local query = signin:insertWithUpdateQuery({
            rid = role_data.id,
            times = 1,
            record = "",
        }, {}, {times = 1})
        signin:pushQuery(query, instance:getConnectId(), "signin.onLogin")
        return
    end
end

return SigninAction
