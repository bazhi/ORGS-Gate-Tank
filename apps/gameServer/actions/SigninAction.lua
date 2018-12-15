
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
        
        --已经签到了，不能再签到
        for _, d in ipairs(record) do
            if d == day then
                return false, "NoAccept"
            end
        end
        
        --获取签到奖励
        local cfg_signin = dbConfig.get("cfg_signin", day)
        if cfg_signin ~= nil then
            role:AddData(instance:getConnectId(), nil, cfg_signin.tech, cfg_signin.diamond)
            self:runAction("prop.addProps", {
                items = cfg_signin.items,
                diamond = cfg_signin.diamond,
                techPoint = cfg_signin.tech,
            }, redis)
        end
        
        --更新签到结果
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
    
    return signin:Login(instance:getConnectId(), "signin.onLogin", lastTime, loginTime, role_data.id)
end

return SigninAction
