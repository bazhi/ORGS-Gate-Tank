--[[
Copyright (c) 2015 gameboxcloud.com
Permission is hereby granted, free of chargse, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 
]]

local gbc = cc.import("#gbc")
local RoleAction = cc.class("RoleAction", gbc.ActionBase)

RoleAction.ACCEPTED_REQUEST_TYPE = "websocket"
local Data = cc.import("#Data", ...)
local dbConfig = cc.import("#dbConfig")

local default_role_cid = 100101

--登录
function RoleAction:createAction(args, _redis)
    local instance = self:getInstance()
    local user = instance:getUser()
    local player = instance:getPlayer()
    local pid = user.id
    local nickname = args.nickname
    local cid = default_role_cid
    if not nickname or #nickname <= 5 then
        instance:sendError("NoSetNickname")
        return
    end
    local now = ngx.now()
    
    local role = player:getRole()
    if not role then
        return
    end
    local dt = role:get()
    dt.pid = pid
    dt.nickname = nickname
    dt.loginTime = now
    dt.createTime = now
    dt.cid = cid
    local query = role:insertQuery(dt)
    role:pushQuery(query, instance:getConnectId(), "role.onCreate")
    
    return 1
end

function RoleAction:onCreate(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    if args.insert_id then
        local query = role:selectQuery({id = args.insert_id})
        role:pushQuery(query, instance:getConnectId(), "role.onRole", {
            initRole = true
        })
    end
end

--登陆游戏
function RoleAction:loadAction(_args, _redis)
    local instance = self:getInstance()
    local user = instance:getUser()
    local player = Data.Player:new(user)
    instance:setPlayer(player)
    local pid = user.id
    local role = player:getRole()
    local query = role:selectQuery({pid = pid})
    role:pushQuery(query, instance:getConnectId(), "role.onRole")
    return 1
end

function RoleAction:update(args, _redis)
    local instance = self:getInstance()
    local loginTime = args.loginTime
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local query = role:updateQuery({id = role_data.id}, {
        loginTime = loginTime,
    })
    role_data.loginTime = loginTime
    role:pushQuery(query, instance:getConnectId())
end

function RoleAction:add(args, _redis)
    local instance = self:getInstance()
    local exp = args.exp or 0
    local gold = args.gold or 0
    local diamond = args.diamond or 0
    
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    
    local nextLevel = role_data.level
    --升级下一级的配置
    local cfg = dbConfig.get("cfg_levelup", nextLevel)
    if not cfg then
        --找不到下一等级的配置，说明已经满级
        return
    end
    role_data.exp = role_data.exp + exp
    if role_data.exp >= cfg.exp then
        --等级提升
        role_data.level = nextLevel
        role_data.exp = role_data.exp - cfg.exp
    end
    
    local query = role:updateQuery({
        id = role_data.id
        }, {
        exp = exp,
        level = role_data.level,
        }, {
        diamond = diamond,
        gold = gold,
    })
    role_data.diamond = role_data.diamond + diamond
    role_data.gold = role_data.gold + gold
    role:pushQuery(query, instance:getConnectId())
    instance:sendPack("Role", role_data)
end

function RoleAction:onRole(args, redis, params)
    local instance = self:getInstance()
    if #args == 0 then
        instance:sendError("NoneRole")
        return
    end
    
    local player = instance:getPlayer()
    local role = player:updateRole(args[1])
    local role_data = role:get()
    local loginTime = ngx.now()
    --加载角色数据成功
    self:runAction("signin.login", {
        lastTime = role_data.loginTime,
        loginTime = loginTime,
    }, redis)
    self:runAction("shop.login", {
    }, redis)
    
    --更新登陆时间
    self:update({loginTime = loginTime}, redis)
    instance:sendPack("Role", role_data)
    self:loadOthersAction(args, redis)
    if params then
        --初始化数据
        if params.initRole then
            local cfg_role = dbConfig.get("cfg_role", role_data.cid)
            if cfg_role then
                if cfg_role.initProps then
                    self:runAction("prop.addProps", {
                        items = cfg_role.initProps,
                    }, redis)
                end
                if cfg_role.missionid then
                    self:runAction("mission.add", {
                        cid = cfg_role.missionid,
                    }, redis)
                end
            end
        end
    end
end

function RoleAction:loadOthersAction(_args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    if not role then
        return
    end
    
    local query
    
    local rid = role:getID()
    
    local props = player:getProps()
    local Prop = props:getTemplate()
    query = Prop:selectQuery({rid = rid})
    Prop:pushQuery(query, instance:getConnectId(), "role.onProp")
    
    local chapters = player:getChapters()
    local chapter = chapters:getTemplate()
    query = chapter:selectQuery({rid = rid})
    chapter:pushQuery(query, instance:getConnectId(), "role.onChapter")
    
    local missions = player:getMissions()
    local mission = missions:getTemplate()
    query = mission:selectQuery({rid = rid})
    mission:pushQuery(query, instance:getConnectId(), "role.onMission")
    
    local boxes = player:getBoxes()
    local box = boxes:getTemplate()
    query = box:selectQuery({rid = rid})
    box:pushQuery(query, instance:getConnectId(), "role.onBox")
end

function RoleAction:onProp(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local props = player:getProps()
    props:set(args)
    instance:sendPack("Props", {
        values = args
    })
end

function RoleAction:onChapter(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local chapters = player:getChapters()
    chapters:set(args)
    instance:sendPack("Chapters", {
        values = args
    })
end

function RoleAction:onMission(args, redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local missions = player:getMissions()
    missions:set(args)
    instance:sendPack("Missions", {
        values = args
    })
    
    self:runAction("mission.resetMission", {}, redis)
end

function RoleAction:onBox(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local boxes = player:getBoxes()
    boxes:set(args)
    instance:sendPack("Boxes", {
        values = args
    })
end

return RoleAction
