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
-- local dbConfig = cc.import("#dbConfig")

local default_role_cid = 100101

--创建角色
function RoleAction:createAction(args, _redis)
    local instance = self:getInstance()
    local user = instance:getUser()
    local player = instance:getPlayer()
    
    local pid = user.id
    local nickname = args.nickname
    local cid = default_role_cid
    
    local role = player:getRole()
    if not role then
        return false, "UnExpectedError"
    end
    return role:Create(instance:getConnectId(), "role.onCreate", pid, nickname, cid)
end

function RoleAction:onCreate(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    if args.insert_id and role then
        role:LoadID(instance:getConnectId(), "role.onLoad", args.insert_id, true)
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
    if not role then
        return false, "UnExpectedError"
    end
    return role:LoadPID(instance:getConnectId(), "role.onLoad", pid)
end

function RoleAction:onLoad(args, redis, params)
    local instance = self:getInstance()
    if #args == 0 then
        instance:sendError("NoneRole")
        return
    end
    
    local player = instance:getPlayer()
    local role = player:getRole()
    role:update(args[1])
    
    local role_data = role:get()
    local loginTime = ngx.now()
    
    local timeTab = {
        lastTime = role_data.loginTime,
        loginTime = loginTime,
    }
    
    --更新登陆时间
    role:UpdateData(instance:getConnectId(), nil, loginTime)
    instance:sendPack("Role", role_data)
    
    --加载角色数据成功
    self:runAction("signin.login", timeTab, redis)
    self:runAction("mission.login", timeTab, redis)
    self:runAction("achv.login", timeTab, redis)
    self:runAction("chapter.login", timeTab, redis)
    self:runAction("shop.login", timeTab, redis)
    self:runAction("prop.login", timeTab, redis)
    self:runAction("talent.login", timeTab, redis)
    
    if params and params.initRole then
        
    end
end

return RoleAction
