
local gbc = cc.import("#gbc")
local ShopAction = cc.class("ShopAction", gbc.ActionBase)
local dbConfig = cc.import("#dbConfig")
-- local parse = cc.import("#parse")
-- local ParseConfig = parse.ParseConfig

local json = cc.import("#json")
local json_encode = json.encode
local json_decode = json.decode

ShopAction.ACCEPTED_REQUEST_TYPE = "websocket"

function ShopAction:getAction(args, redis)
    local instance = self:getInstance()
    local id = args.id
    if not id then
        return false, "NoneID"
    end
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local cfg_shop = dbConfig.get("cfg_shop", id)
    local nowtime = ngx.now()
    if cfg_shop.startTime > 0 and nowtime < cfg_shop.startTime then
        return false, "OutOfDate"
    end
    
    if cfg_shop.endTime > 0 and nowtime > cfg_shop.endTime then
        return false, "OutOfDate"
    end
    if role_data.diamond < cfg_shop.diamond then
        return false, "LessDiamond"
    end
    
    if role_data.gold < cfg_shop.gold then
        return false, "LessGold"
    end
    
    local shop = player:getShop()
    local shop_Data = shop:get()
    local idList = json_decode(shop_Data.idList) or {}
    local timesList = json_decode(shop_Data.timesList) or {}
    
    local bInsert = false
    if cfg_shop.buyTimes > 0 then
        bInsert = true
        for i, oid in ipairs(idList) do
            if oid == id then
                if timesList[i] >= cfg_shop.buyTimes then
                    instance:sendError("LessTimes")
                    return
                else
                    timesList[i] = timesList[i] + 1
                    bInsert = false
                    break
                end
            end
        end
    end
    if bInsert then
        table.insert(idList, id)
        table.insert(timesList, 1)
    end
    
    --扣除金钱
    self:runAction("role.add", {diamond = -cfg_shop.diamond, gold = cfg_shop.getGold - cfg_shop.gold}, redis)
    self:runAction("prop.addProps", {
        items = cfg_shop.items,
        diamond = 0,
        gold = cfg_shop.getGold,
    }, redis)
    self:runAction("box.addBoxes", {ids = cfg_shop.boxid}, redis)
    
    instance:sendPack("ShopRecord", {
        id = idList,
        times = timesList,
    })
    shop_Data.idList = json_encode(idList)
    shop_Data.timesList = json_encode(timesList)
    self:saveData()
    return true
end

function ShopAction:saveData()
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local shop = player:getShop()
    local shop_Data = shop:get()
    local query = shop:updateQuery({rid = shop_Data.rid}, {idList = shop_Data.idList, timesList = shop_Data.timesList})
    shop:pushQuery(query, instance:getConnectId())
end

function ShopAction:onData(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local shop = player:getShop()
    local shop_Data = shop:get()
    if #args > 0 then
        shop:update(args[1])
        --检测shop的数据
        local idList = json_decode(shop_Data.idList) or {}
        local timesList = json_decode(shop_Data.timesList) or {}
        
        local nowtime = ngx.now()
        local cnt = #idList
        for index = cnt, 1, -1 do
            local id = idList[index]
            local cfg = dbConfig.get("cfg_shop", id)
            if cfg == nil then
                table.remove(idList, index)
                table.remove(timesList, index)
            elseif cfg.endTime > 0 and nowtime > cfg.endTime then
                table.remove(idList, index)
                table.remove(timesList, index)
            end
        end
        
        instance:sendPack("ShopRecord", {
            id = idList,
            times = timesList,
        })
        shop_Data.idList = json_encode(idList)
        shop_Data.timesList = json_encode(timesList)
        self:saveData()
    end
end

function ShopAction:onLogin(_args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local shop = player:getShop()
    local role = player:getRole()
    local role_data = role:get()
    local query = shop:selectQuery({rid = role_data.id})
    shop:pushQuery(query, instance:getConnectId(), "shop.onData")
end

function ShopAction:login(_args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local shop = player:getShop()
    
    local query = shop:insertWithUpdateQuery({
        rid = role_data.id,
        idList = "",
        timesList = "",
    }, {rid = role_data.id}, {})
    shop:pushQuery(query, instance:getConnectId(), "shop.onLogin")
end

return ShopAction
