
local User = cc.class("User")
local Data = cc.import("#Data", ...)
local Role = Data.Role

local ngx_now = ngx.now

local gbc = cc.import("#gbc")
local Constants = gbc.Constants

local netpack = cc.import("#netpack")
local net_encode = netpack.encode

local sensitive = cc.import("#sensitive")
local sensitive_library = sensitive.library

function User:ctor(id)
    self.id = id
end

function User:loadUser(db, instance, rid, lastTime, loginTime)
    
end

function User:Login(db, instance)
    --玩家连接上了
    local redis = instance:getRedis()
    if redis then
        --在在线玩家列表中加入
        redis:zadd(Constants.USERLIST, math.floor(ngx.now()), self.id)
    end
    cc.printf("User Login:"..self.id)
    
    local role = Role:new()
    local data, err = role:Initialize(db, self.id)
    if err then
        --发生错误，返回错误代码
        instance:sendError(self.id, err)
        return false
    end
    if not data then
        instance:sendError(self.id, "NoneRole")
        return false
    end
    self._Role = role
    
    --角色数据加载成功
    instance:sendPack(self.id, "Role", self._Role:get())
    
    --加载用户数据
    self:loadUser(db, instance, role:get("id"), role:get("loginTime"), ngx_now())
    
    --更新登录时间
    role:set("loginTime", ngx_now())
    --设置玩家信息缓存
    if redis then
        local data = role:get()
        redis:set(Constants.USER..self.id, net_encode(data))
    end
end

--保存玩家数据
function User:Logout(db, instance)
    cc.printf("User Logout:"..self.id)
    self:Save(db)
    --玩家下线了
    local redis = instance:getRedis()
    if redis then
        redis:zrem(Constants.USERLIST, self.id)
    end
end

function User:Save(db)
    if self._Role then
        
    end
end

function User:Process(db, message, instance, action, msgid)
    local func = "on"..action
    if self[func] then
        self[func](self, db, message, instance, msgid)
    else
        cc.dump(message, action)
    end
end

--[[
    所以处理协议的函数
]]--
--创建角色
function User:onCreateRole(db, msg, instance, msgid)
    --敏感字检测
    if sensitive_library:check(msg.nickname) then
        instance:sendError(self.id, "SensitiveWord")
        return false
    end
    
    --创建角色
    local role = Role:new()
    local data, err = role:Create(db, self.id, msg.nickname, 100101)
    if err then
        instance:sendError(self.id, err)
        return false
    end
    if not data then
        instance:sendError(self.id, "DBError")
        return false
    end
    instance:sendPack(self.id, "Role", data, msgid)
    self._Role = role
    self:loadUser(db, instance, role:get("id"), role:get("loginTime"), ngx_now())
    role:set("loginTime", ngx_now())
end

return User
