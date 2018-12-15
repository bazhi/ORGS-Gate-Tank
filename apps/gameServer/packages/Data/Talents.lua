
local BaseList = cc.import(".BaseList")
local Talents = cc.class("Talents", BaseList)
local Talent = cc.import(".Talent", ...)

-- local parse = cc.import("#parse")
-- local ParseConfig = parse.ParseConfig
-- local dbConfig = cc.import("#dbConfig")

function Talents:createItem()
    return Talent:new()
end

function Talents:Unlock(connectid, action, cid, level, role)
    if not connectid or not cid or not level then
        return false, "NoParam"
    end
    
    local talent = self:getByCID(cid)
    if talent then
        
    else
        
    end
end

return Talents
