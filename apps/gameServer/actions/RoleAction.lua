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
local Data = cc.import("#Data")
local dbConfig = cc.import("#dbConfig")

local default_role_cid = 100001

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

function RoleAction:loadAction(_args, _redis)
    local instance = self:getInstance()
    local user = instance:getUser()
    local player = Data.Player:new(user)
    instance:setPlayer(player)
    local pid = user.id
    local role = player:getRole()
    local query = role:selectQuery({pid = pid})
    role:pushQuery(query, instance:getConnectId(), "role.onRole")
end

function RoleAction:onRole(args, redis, params)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    if #args > 0 then
        local role = player:updateRole(args[1])
        local role_data = role:get()
        instance:sendPack("Role", role_data)
        self:loadOthersAction(args, _redis)
        if params then
            --初始化数据
            if params.initRole then
                local cfg_role = dbConfig.get("cfg_role", role_data.cid)
                if cfg_role then
                    instance:runAction("prop.addProps", {
                        items = cfg_role.initProps,
                    }, redis, true)
                end
            end
        end
    else
        instance:sendError("NoneRole")
    end
end

function RoleAction:loadOthersAction(_args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    if not role then
        return
    end
    local rid = role:getID()
    local Equipment = player:getEquipment()
    local Prop = player:getProp()
    
    local query = Equipment:selectQuery({rid = rid})
    Equipment:pushQuery(query, instance:getConnectId(), "role.onEquipment")
    
    query = Prop:selectQuery({rid = rid})
    Prop:pushQuery(query, instance:getConnectId(), "role.onProp")
end

function RoleAction:onEquipment(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    player:updateEquipments(args)
    instance:sendPack("Equipments", {
        values = args,
    })
end

function RoleAction:onProp(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    player:updateProps(args)
    instance:sendPack("Props", {
        values = args
    })
end

return RoleAction
