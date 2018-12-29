
local Base = cc.import(".Base")
local Shop = cc.class("Shop", Base)

local dbConfig = cc.import("#dbConfig")

local Table = cc.import("#Table", ...)

function Shop:ctor()
    Shop.super.ctor(self, Table.Shop)
end

function Shop:Initialize(db, rid)
    if not db or not rid then
        return nil, "NoParam"
    end
    
    self:insertQuery(db, {rid = rid, buyTimes = 0})
    return self:load(db, {rid = rid})
end

--获取购买的配置
function Shop:CanBuy(id)
    local cfg = dbConfig.get("cfg_shop", id)
    if not cfg then
        return nil, "NoAccept"
    end
    return cfg
end

function Shop:Buy(id, role_data, props)
    local cfg, err = self:CanBuy(id)
    if not cfg then
        return nil, err
    end
    
    if not cfg or not role_data or not id or not props then
        return nil, "NoParam"
    end
    --判断钻石是否足够
    if role_data.diamond < cfg.price_diamond then
        return nil, "LessDiamond"
    end
    
    if not props:CanAddItems(cfg.items) then
        return nil, "OperationNotPermit"
    end
    
    self:add("buyTimes", 1)
    --增加道具
    return cfg
end

return Shop
