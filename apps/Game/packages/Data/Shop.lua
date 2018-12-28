
local Base = cc.import(".Base")
local Shop = cc.class("Shop", Base)

local cmsgpack = require "cmsgpack"
local cmsgpack_pack = cmsgpack.pack
local cmsgpack_unpack = cmsgpack.unpack

local dbConfig = cc.import("#dbConfig")

local Table = cc.import("#Table", ...)

function Shop:ctor()
    Shop.super.ctor(self, Table.Shop)
end

function Shop:Initialize(db, rid)
    if not db or not rid then
        return nil, "NoParam"
    end
    
    self:insertQuery(db, {rid = rid, uniques = ""})
    local ok, err = self:load(db, {rid = rid})
    if not ok or err then
        return nil, "NoParam"
    end
    self:Deserialize()
    return self.buys
end

function Shop:getProto()
    return self.buys
end

function Shop:Deserialize()
    self.buys = cmsgpack_unpack(self:get("uniques") or "") or {}
    if type(self.buys) ~= "table" then
        self.buys = {}
    end
end

function Shop:Serialize()
    local uniques = cmsgpack_pack(self.buys)
    self:set("uniques", uniques)
end

function Shop:save(db)
    if self:isDirty() then
        self:Serialize()
    end
    return Shop.super.save(self, db)
end

function Shop:HadBuy(id)
    for _, v in ipairs(self.buys) do
        if v == id then
            return true
        end
    end
    return false
end

--获取购买的配置
function Shop:CanBuy(id)
    local cfg = dbConfig.get("cfg_shop", id)
    if not cfg then
        return nil, "NoAccept"
    end
    if cfg.unique == 1 and self:HadBuy(id) then
        return nil, "NoAccept"
    end
    return cfg
end

function Shop:Buy(id, role_data)
    local cfg, err = self:CanBuy(id)
    if not cfg then
        return nil, err
    end
    
    if not cfg or not role_data or not id then
        return nil, "NoParam"
    end
    --判断钻石是否足够
    if role_data.diamond < cfg.price_diamond then
        return nil, "LessDiamond"
    end
    --减少钻石
    --role:add("diamond", -cfg.price_diamond)
    if cfg.unique == 1 then
        table.insert(self.buys, cfg.id)
        self:dirty()
    end
    --增加道具
    return cfg
end

return Shop
