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
local Table = cc.import("#Table")

--登录
function RoleAction:createAction(args, _redis)
    local instance = self:getInstance()
    local user = instance:getUser()
    local pid = user.id
    local nickname = args.nickname
    if not nickname or #nickname <= 5 then
        instance:sendError("NoSetNickname")
        return
    end
    local now = ngx.now()
    local Role = instance._Role
    if not Role then
        return
    end
    local dt = Role:get()
    dt.pid = pid
    dt.nickname = nickname
    dt.loginTime = now
    dt.createTime = now
    local query = Role:insertQuery(dt)
    Role:pushQuery(query, instance:getConnectId(), "role.oncreate")
end

function RoleAction:oncreateAction(args, _redis)
    local instance = self:getInstance()
    local Role = instance._Role
    if args.insert_id then
        local query = Role:selectQuery({id = args.insert_id})
        Role:pushQuery(query, instance:getConnectId(), "role.onrole")
    end
end

function RoleAction:loadAction(_args, _redis)
    local instance = self:getInstance()
    local user = instance:getUser()
    local pid = user.id
    local Role = Data.Role:new(Table.Role)
    instance._Role = Role
    local query = Role:selectQuery({pid = pid})
    Role:pushQuery(query, instance:getConnectId(), "role.onrole")
end

function RoleAction:onroleAction(args, _redis)
    local instance = self:getInstance()
    local Role = instance._Role
    if not Role then
        return
    end
    if #args > 0 then
        --cc.dump(Role:get())
        Role:update(args[1])
        instance:sendPack("Role", Role:get())
    else
        instance:sendError("NoneRole")
    end
    
end

return RoleAction
