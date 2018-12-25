
local gbc = cc.import("#gbc")
local ShopAction = cc.class("ShopAction", gbc.ActionBase)
-- local dbConfig = cc.import("#dbConfig")
-- local parse = cc.import("#parse")
-- local ParseConfig = parse.ParseConfig

-- local json = cc.import("#json")
-- local json_encode = json.encode
-- local json_decode = json.decode

ShopAction.ACCEPTED_REQUEST_TYPE = "websocket"

function ShopAction:OnLoad(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local shop = player:getShop()
    if args[1] then
        shop:update(args[1])
        shop:Deserialize()
        instance:sendPack("ShopRecord", shop:GetProto())
    end
end

function ShopAction:login(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local shop = player:getShop()
    
    local lastTime = args.lastTime
    local loginTime = args.loginTime
    
    return shop:Login(instance:getConnectId(), "shop.OnLoad", lastTime, loginTime, role_data.id)
end

function ShopAction:buyAction(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local props = player:getProps()
    local shop = player:getShop()
    local id = args.id
    
    local ok, err, cfg = shop:Buy(instance:getConnectId(), "shop.OnBuy", id, role, props)
    if not ok then
        return ok, err
    end
    
    if cfg then
        role:AddData(instance:getConnectId(), nil, 0, -cfg.price_diamond, 0)
        local ret, err, items, rewards = props:AddRewards(instance:getConnectId(), "prop.OnProps", cfg.items, role)
        instance:sendPack("Role", role:get())
        if items then
            --直接更新的道具
            instance:sendPack("Props", {
                items = items,
            })
        end
        if rewards then
            instance:sendPack("Rewards", {
                items = rewards,
            })
        end
        return ret, err
    end
    
    return false
end

function ShopAction:OnBuy(_args)
    --更新商店数据
    local instance = self:getInstance()
    local player = instance:getPlayer()
    
    local shop = player:getShop()
    instance:sendPack("ShopRecord", shop:GetProto())
end

return ShopAction
