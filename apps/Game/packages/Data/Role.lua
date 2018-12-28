local Base = cc.import(".Base")
local Role = cc.class("Role", Base)

local Table = cc.import("#Table", ...)

--local dbConfig = cc.import("#dbConfig")

function Role:ctor()
    Role.super.ctor(self, Table.Role)
end

function Role:Initialize(db, pid)
    if not db or not pid then
        return nil, "NoParam"
    end
    return self:load(db, {pid = pid})
end

function Role:Create(db, pid, nickname, cid)
    if not db or not pid or not nickname or not cid then
        return nil, "NoParam"
    end
    
    if #nickname <= 6 then
        return nil, "NoSetNickname"
    end
    
    local data = self:get()
    data.pid = pid
    data.nickname = nickname
    data.loginTime = 0
    data.createTime = ngx.now()
    data.cid = cid
    
    local result, err = self:insertQuery(db, data)
    if err then
        cc.printf(err)
        return nil, "DBError"
    end
    if not result or not result.insert_id then
        return nil, "DBError"
    end
    return self:load(db, {id = result.insert_id})
end

return Role
