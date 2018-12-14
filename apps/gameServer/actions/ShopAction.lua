
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

return ShopAction
