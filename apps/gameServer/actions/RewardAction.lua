
local gbc = cc.import("#gbc")
local RewardAction = cc.class("RewardAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")
local parse = cc.import("#parse")
local ParseConfig = parse.ParseConfig

RewardAction.ACCEPTED_REQUEST_TYPE = "websocket"

--分解
function RewardAction:open(args, redis)
    local instance = self:getInstance()
    local id = args.id
    if type(id) ~= "number" then
        instance:sendError("NoParam")
        return false
    end
    
    local cfg_reward = dbConfig.get("cfg_reward", id)
    if not cfg_reward then
        instance:sendError("NoneConfig")
        return false
    end
    
    --获取总的道具
    local list = ParseConfig.ParseProbability(cfg_reward.items)
    local addPropIDList = {}
    math.randomseed(ngx.now())
    for _ = 1, cfg_reward.times do
        local randnumber = math.random(cfg_reward.maxProbability)
        for _, v in ipairs(list) do
            if randnumber <= v.probability then
                table.insert(addPropIDList, v.id)
                break
            end
            randnumber = randnumber - v.probability
        end
    end
    
    --
    return self:runAction("prop.addPropsWithList", {ids = addPropIDList}, redis)
end

return RewardAction
