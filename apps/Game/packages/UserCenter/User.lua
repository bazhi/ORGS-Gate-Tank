
local User = cc.class("User")
local Data = cc.import("#Data", ...)
local Role = Data.Role
local Chapters = Data.Chapters
local Missions = Data.Missions
local Props = Data.Props
local Shop = Data.Shop
local Talents = Data.Talents
local Achvs = Data.Achvs

local ngx_now = ngx.now

function User:ctor(id)
    self.id = id
end

function User:loadUser(db, instance, rid, lastTime, loginTime)
    --章节数据
    self._Chatpers = Chapters:new()
    local chapters_data = self._Chatpers:Initialize(db, rid)
    if chapters_data then
        instance:sendPack(self.id, "Chapters", {items = chapters_data})
    end
    
    --任务数据
    self._Missions = Missions:new()
    local missions_data = self._Missions:Initialize(db, rid, lastTime, loginTime)
    if missions_data then
        instance:sendPack(self.id, "MissionList", {items = missions_data})
    end
    
    --成就
    self._Achvs = Achvs:new()
    local achvs_data = self._Achvs:Initialize(db, rid)
    if achvs_data then
        instance:sendPack(self.id, "AchvList", {items = achvs_data})
    end
    
    self._Props = Props:new()
    local props_data = self._Props:Initialize(db, rid)
    if props_data then
        instance:sendPack(self.id, "Props", {items = props_data})
    end
    
    self._Talents = Talents:new()
    local talents_data = self._Talents:Initialize(db, rid)
    if talents_data then
        instance:sendPack(self.id, "Talents", {items = talents_data})
    end
    
    self._Shop = Shop:new()
    local shop_data = self._Shop:Initialize(db, rid)
    if shop_data then
        instance:sendPack(self.id, "ShopRecord", {id = shop_data})
    end
end

function User:Login(db, instance)
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
    role:add("diamond", 300)
    --角色数据加载成功
    instance:sendPack(self.id, "Role", self._Role:get())
    
    self:loadUser(db, instance, role:get("id"), role:get("loginTime"), ngx_now())
    role:set("loginTime", ngx_now())
end

--保存玩家数据
function User:Logout(db, _instance)
    self:Save(db)
end

function User:Save(db)
    if self._Role then
        self._Role:save(db)
        self._Chatpers:save(db)
        self._Missions:save(db)
        self._Achvs:save(db)
        self._Props:save(db)
        self._Talents:save(db)
        self._Shop:save(db)
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

----

--商店购买
function User:onShopBuy(db, msg, instance, msgid)
    if not db or not msg or not instance then
        instance:sendError(self.id, "NoParam", msgid)
        return false
    end
    
    if not self._Shop or not self._Role then
        instance:sendError(self.id, "OperationNotPermit", msgid)
        return false
    end
    
    local role_data = self._Role:get()
    local cfg, err = self._Shop:Buy(msg.id, role_data)
    if err then
        instance:sendError(self.id, err)
        return false
    end
    
    if cfg then
        --增加任务奖励
        local items, err, rewards = self._Props:AddRewards(db, cfg.items, self._Role)
        if err then
            instance:sendError(self.id, err, msgid)
        end
        if items then
            instance:sendPack(self.id, "Props", {items = items}, msgid)
        end
        if items then
            instance:sendPack(self.id, "Rewards", {items = rewards}, msgid)
        end
        --减少钻石
        self._Role:add("diamond", -cfg.price_diamond)
        instance:sendPack(self.id, "Role", self._Role:get(), msgid)
    end
    instance:sendPack(self.id, "ShopRecord", {id = self._Shop:getProto()}, msgid)
end

--完成任务
function User:onFinishMission(db, msg, instance, msgid)
    if not db or not msg or not instance then
        instance:sendError(self.id, "NoParam", msgid)
        return false
    end
    
    if not self._Missions then
        instance:sendError(self.id, "OperationNotPermit", msgid)
        return false
    end
    
    local data, err, cfg = self._Missions:Finish(msg.id)
    if err then
        instance:sendError(self.id, err, msgid)
        return false
    end
    instance:sendPack(self.id, "MissionList", {items = {data}}, msgid)
    if cfg and cfg.rewards and self._Props then
        --增加任务奖励
        local items, err, rewards = self._Props:AddRewards(db, cfg.rewards, self._Role)
        if err then
            instance:sendError(self.id, err, msgid)
            return false
        end
        instance:sendPack(self.id, "Props", {items = items}, msgid)
        instance:sendPack(self.id, "Role", self._Role:get(), msgid)
        instance:sendPack(self.id, "Rewards", {items = rewards}, msgid)
    end
end
--完成成就
function User:onFinishAchv(db, msg, instance, msgid)
    if not db or not msg or not instance then
        instance:sendError(self.id, "NoParam", msgid)
        return false
    end
    
    if not self._Achvs then
        instance:sendError(self.id, "OperationNotPermit", msgid)
        return false
    end
    
    local data, err, cfg = self._Achvs:Finish(msg.id)
    if err then
        instance:sendError(self.id, err, msgid)
        return false
    end
    instance:sendPack(self.id, "AchvList", {items = {data}}, msgid)
    if cfg and cfg.rewards and self._Props then
        --增加任务奖励
        local items, err, rewards = self._Props:AddRewards(db, cfg.rewards, self._Role)
        if err then
            instance:sendError(self.id, err, msgid)
            return false
        end
        instance:sendPack(self.id, "Props", {items = items}, msgid)
        instance:sendPack(self.id, "Role", self._Role:get(), msgid)
        instance:sendPack(self.id, "Rewards", {items = rewards}, msgid)
    end
end

--任务事件
function User:onMissionEvent(db, msg, instance, msgid)
    if not db or not msg or not instance then
        instance:sendError(self.id, "NoParam", msgid)
        return false
    end
    
    if self._Missions then
        local list = self._Missions:process(msg.action_id, msg.action_place, msg.action_count, msg.action_type, msg.action_override)
        instance:sendPack(self.id, "MissionList", {items = list}, msgid)
    end
    
    if self._Achvs then
        local list = self._Achvs:process(msg.action_id, msg.action_place, msg.action_count, msg.action_type, msg.action_override)
        instance:sendPack(self.id, "AchvList", {items = list}, msgid)
    end
end

--天赋解锁
function User:onTalentUnlock(db, msg, instance, msgid)
    if not db or not msg or not instance then
        instance:sendError(self.id, "NoParam", msgid)
        return false
    end
    
    if not self._Talents then
        instance:sendError(self.id, "OperationNotPermit", msgid)
        return false
    end
    
    local data, err, cfg = self._Talents:UnlockItem(db, msg.cid, msg.level, self._Role, self._Props)
    if err then
        instance:sendError(self.id, err, msgid)
        return false
    end
    instance:sendPack(self.id, "Talents", {items = {data}}, msgid)
    
    if cfg then
        --消耗钻石和科技点
        self._Role:add("diamond", -cfg.diamond)
        self._Role:add("techPoint", -cfg.tech)
        instance:sendPack(self.id, "Role", self._Role:get(), msgid)
        
        --消耗道具
        local list = self._Props:UseItems(cfg.props)
        instance:sendPack(self.id, "Props", {items = list}, msgid)
    end
end

--进入章节
function User:onEnterChapter(db, msg, instance, msgid)
    if not db or not msg or not instance then
        instance:sendError(self.id, "NoParam", msgid)
        return false
    end
    if self._Chatpers then
        
    end
end

--保存存档
function User:onMapRecordSave(db, msg, instance, msgid)
    if not db or not msg or not instance then
        instance:sendError(self.id, "NoParam", msgid)
        return false
    end
    if not self._Chatpers then
        instance:sendError(self.id, "OperationNotPermit", msgid)
        return false
    end
    local data, err = self._Chatpers:Save(msg.id, msg.seq, msg.record)
    if err then
        instance:sendError(self.id, err, msgid)
        return false
    end
    instance:sendPack(self.id, "Chapters", {items = {data}}, msgid)
end

return User