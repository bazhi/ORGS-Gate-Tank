
local Base = cc.import(".Base")
local Shop = cc.class("Shop", Base)

local json = cc.import("#json")
local json_encode = json.encode
local json_decode = json.decode

local dbConfig = cc.import("#dbConfig")

local Table = cc.import("#Table", ...)

function Shop:ctor()
    Shop.super.ctor(self, Table.Shop)
end

function Shop:Login(connectid, action, lastTime, loginTime, roleid)
    if not connectid or not lastTime or not loginTime or not roleid then
        return false, "NoParam"
    end
    
    -- local loginDate = os.date("*t", loginTime)
    -- local lastDate = os.date("*t", lastTime)
    
    local query = self:insertQuery({
        rid = roleid,
    })
    self:pushQuery(query, connectid, action, {ignorerr = true})
    self:LoadAll(connectid, action, roleid)
    return true
end

function Shop:LoadAll(connectid, action, roleid)
    if not connectid or not action or not roleid then
        return false, "NoParam"
    end
    
    local query = self:selectQuery({rid = roleid})
    self:pushQuery(query, connectid, action)
    return true
end

function Shop:Deserialize()
    self.BuyIds = json_decode(self:get("uniques") or "") or {}
end

function Shop:GetProto()
    return {
        id = self.BuyIds,
    }
end

function Shop:Serialize()
    self:set("uniques", json_encode(self.BuyIds))
end

function Shop:HadBuy(id)
    for _, v in ipairs(self.BuyIds) do
        if v == id then
            return true
        end
    end
    return false
end

function Shop:CanBuy(id)
    local cfg = dbConfig.get("cfg_shop", id)
    if not cfg then
        return false
    end
    if cfg.unique == 1 and self:HadBuy(id) then
        return false
    end
    return true, cfg
end

function Shop:Buy(connectid, action, id, role)
    local result, cfg = self:CanBuy(id)
    if not result then
        return false, "NoAccept"
    end
    
    if not connectid or not cfg or not role or not id then
        return false, "NoParam"
    end
    
    local role_data = role:get()
    --判断钻石是否足够
    if role_data.diamond < cfg.price_diamond then
        return false, "LessDiamond"
    end
    
    if cfg.unique == 1 then
        table.insert(self.BuyIds, cfg.id)
        --保存数据
        self:Serialize()
        local query = self:updateQuery({
            id = self:get("id"),
            }, {
            uniques = self:get("uniques"),
        })
        self:pushQuery(query, connectid, action)
    end
    --增加道具
    return true, cfg
end

return Shop
