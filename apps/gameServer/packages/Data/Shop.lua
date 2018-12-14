
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
    
    local loginDate = os.date("*t", loginTime)
    local lastDate = os.date("*t", lastTime)
    
    local query = self:insertQuery({
        rid = roleid,
    })
    self:pushQuery(query, connectid, action, {ignorerr = true})
    self:LoadAll(connectid, action, roleid)
    if loginDate.year ~= lastDate.year or loginDate.yday ~= lastDate.yday then
        return true
    end
    
    return false
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

function Shop:CanBuy(id)
    local cfg = dbConfig.get(id)
    if not cfg then
        return false
    end
end

return Shop
