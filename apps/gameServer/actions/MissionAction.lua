
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
local MissionAction = cc.class("MissionAction", gbc.ActionBase)

MissionAction.ACCEPTED_REQUEST_TYPE = "websocket"

--登陆初始化
function MissionAction:login(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local missions = player:getMissions()
    
    local lastTime = args.lastTime
    local loginTime = args.loginTime
    
    if not missions:Login(instance:getConnectId(), "mission.onLogin", lastTime, loginTime, role_data.id) then
        self:onLogin(args)
    end
    return true
end

function MissionAction:onLogin(_args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local role_data = role:get()
    local missions = player:getMissions()
    missions:LoadAll(instance:getConnectId(), "mission.onLoad", role_data.id)
end

function MissionAction:onLoad(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local missions = player:getMissions()
    missions:updates(args)
    instance:sendPack("MissionList", {
        items = args
    })
end

function MissionAction:eventAction(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local missions = player:getMissions()
    missions:process(instance:getConnectId(), "mission.onUpdate", args.action_type, args.action_id, args.action_place, args.action_count, args.action_override)
    self:runAction("achv.event", args)
    return true
end

function MissionAction:onUpdate(_args, _redis, param)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local missions = player:getMissions()
    local id = param.id
    local mission = missions:get(id)
    instance:sendPack("MissionList", {
        items = {mission:get()},
    })
end

function MissionAction:finishAction(args)
    local id = args.id
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local missions = player:getMissions()
    if missions:Finish(instance:getConnectId(), nil, id) then
        instance:sendDelete("MissionItem", id, 0)
    end
    return true
end

return MissionAction
