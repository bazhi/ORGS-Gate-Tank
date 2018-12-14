local Base = cc.import(".Base")
local Role = cc.class("Role", Base)

local Table = cc.import("#Table", ...)

local dbConfig = cc.import("#dbConfig")

function Role:ctor()
    Role.super.ctor(self, Table.Role)
end

function Role:Create(connectid, action, pid, nickname, cid)
    if not connectid then
        return false, "NoParam"
    end
    
    if not action or not pid or not nickname or not cid then
        return false, "NoParam"
    end
    
    if #nickname <= 6 then
        return false, "NoSetNickname"
    end
    
    local data = self:get()
    data.pid = pid
    data.nickname = nickname
    data.loginTime = 0
    data.createTime = ngx.now()
    data.cid = cid
    
    local query = self:insertQuery(data)
    self:pushQuery(query, connectid, action)
    return true
end

function Role:update(data)
    Role.super.update(self, data)
end

function Role:LoadID(connectid, action, id, binit)
    if not connectid or not action or not id then
        return false, "NoParam"
    end
    
    local query = self:selectQuery({id = id})
    self:pushQuery(query, connectid, action, {
        initRole = binit
    })
    return true
end

function Role:LoadPID(connectid, action, pid, binit)
    if not connectid or not action or not pid then
        return false, "NoParam"
    end
    
    local query = self:selectQuery({pid = pid})
    self:pushQuery(query, connectid, action, {
        initRole = binit
    })
    return true
end

function Role:UpdateData(connectid, action, logintime)
    if not connectid then
        return false, "NoParam"
    end
    if not logintime then
        return false, "NoParam"
    end
    
    local data = self:get()
    local query = self:updateQuery({id = data.id}, {
        logintime = logintime,
    })
    self:pushQuery(query, connectid, action)
    return true
end

function Role:AddData(connectid, action, gold, diamond, exp)
    if not connectid then
        return false, "NoParam"
    end
    
    gold = gold or 0
    diamond = diamond or 0
    exp = exp or 0
    
    local data = self:get()
    
    --升级下一级的配置
    if exp > 0 then
        local next_cfg = dbConfig.get("cfg_levelup", data.level + 1)
        local cfg = dbConfig.get("cfg_levelup", data.level)
        if next_cfg and cfg then
            data.exp = data.exp + exp
            if data.exp >= cfg.exp then
                data.level = data.level + 1
                data.exp = data.exp - cfg.exp
            end
        end
    end
    
    data.diamond = data.diamond + diamond
    data.gold = data.gold + gold
    
    local query = self:updateQuery({id = data.id}, {exp = data.exp, level = data.level}, {diamond = diamond, gold = gold})
    return self:pushQuery(query, connectid, action)
end

return Role
