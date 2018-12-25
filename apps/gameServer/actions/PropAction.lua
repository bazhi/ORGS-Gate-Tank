
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
local PropAction = cc.class("PropAction", gbc.ActionBase)

PropAction.ACCEPTED_REQUEST_TYPE = "websocket"

function PropAction:login(args)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local props = player:getProps()
    local lastTime = args.lastTime
    local loginTime = args.loginTime
    
    return props:Login(instance:getConnectId(), "prop.OnLoad", lastTime, loginTime, role:get("id"))
end

function PropAction:OnLoad(args)
    if #args == 0 then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local props = player:getProps()
    props:updates(args)
    instance:sendPack("Props", {
        items = args
    })
end

function PropAction:OnProps(args, _redis, item)
    if args.insert_id then
        local instance = self:getInstance()
        local player = instance:getPlayer()
        local props = player:getProps()
        props:IncreaseUpdate(instance:getConnectId(), "prop.OnLoad", args.insert_id, item)
    end
end

return PropAction
