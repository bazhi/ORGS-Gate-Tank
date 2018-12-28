
local BaseList = cc.import(".BaseList")
local Talents = cc.class("Talents", BaseList)
local Talent = cc.import(".Talent", ...)

local parse = cc.import("#parse")
local ParseConfig = parse.ParseConfig
local dbConfig = cc.import("#dbConfig")

function Talents:createItem()
    return Talent:new()
end

function Talents:Initialize(db, rid)
    if not db or not rid then
        return nil, "NoParam"
    end
    return self:load(db, {rid = rid})
end

function Talents:AddItem(db, cid, level, rid)
    local talent = self:get()
    local result = talent:insertQuery(db, {cid = cid, level = level, rid = rid})
    if result and result.insert_id then
        local datas = self:load(db, {id = result.insert_id})
        if #datas == 1 then
            return datas[1]
        end
    end
    return nil, "DBError"
end

function Talents:UnlockItem(db, cid, level, role, props)
    if not db or not cid or not level or not role or not props then
        return nil, "NoParam"
    end
    
    local cfg = dbConfig.get("cfg_talent", {
        id = cid,
        level = level,
    })
    if cfg == nil then
        return nil, "NoneConfig"
    end
    
    local role_data = role:get()
    --检查消耗道具
    if role_data.diamond < cfg.diamond then
        return nil, "LessDiamond"
    end
    if role_data.techPoint < cfg.tech then
        return nil, "LessTech"
    end
    
    local items = ParseConfig.ParseProps(cfg.props)
    
    if not props:HasItems(items) then
        return nil, "LessProp"
    end
    local talent = self:getByCID(cid)
    
    if talent then
        local tlevel = talent:get("level")
        if cfg.prelevel == tlevel then
            --满足条件，直接改变等级
            talent:set("level", cfg.level)
            return talent:get(), nil, cfg
        end
    else
        if cfg.preId == 0 then
            local data, err = self:AddItem(db, cid, level, role_data.id)
            if not data then
                return nil, err
            end
            return data, nil, cfg
        else
            talent = self:getByCID(cfg.preId)
            if talent then
                local tlevel = talent:get("level")
                local tcid = talent:get("cid")
                if cfg.prelevel == tlevel and cfg.preId == tcid then
                    local data, err = self:AddItem(db, cid, level, role_data.id)
                    if not data then
                        return nil, err
                    end
                    return data, nil, cfg
                end
            end
        end
    end
    
    return nil, "OperationNotPermit"
end

return Talents
