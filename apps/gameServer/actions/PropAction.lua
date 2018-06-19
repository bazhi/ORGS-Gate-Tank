
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
local dbConfig = cc.import("#dbConfig")
local parse = cc.import("#parse")
local ParseConfig = parse.ParseConfig

PropAction.ACCEPTED_REQUEST_TYPE = "websocket"

--登录
function PropAction:decomposeAction(args, _redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local prop = player:getProp(args.prop_id)
    if not prop or prop.count < 1 then
        instance:sendError("NoneProp")
        return
    end
    local prop_data = prop:get()
    local cfg_prop = dbConfig.get("cfg_prop", prop_data.cid)
    if not cfg_prop then
        instance:sendError("ConfigError")
        return
    end
    if not cfg_prop.decompose or cfg_prop.type ~= 2 or #(cfg_prop.decompose) <= 0 then
        instance:sendError("OperationNotPermit")
        return
    end
    
    prop_data.count = prop_data.count - 1
    local query = prop:updateQuery({count = prop_data.count}, {id = prop_data.id})
    prop:pushQuery(query, instance:getConnectId(), "prop.onProp")
    instance:sendPack("Prop", prop_data)
    
    --id_count|id_count
    local items = ParseConfig.ParseDecompose(cfg_prop.decompose)
    for _, item in ipairs(items) do
        self:addProp(item.id, item.count)
    end
end

function PropAction:addProp(id, count)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local prop = player:getProp(id)
    if prop then
        local prop_data = prop:get()
        prop_data.count = prop_data.count + count
        local query = prop:updateQuery({count = prop_data.count}, {id = prop_data.id})
        prop:pushQuery(query, instance:getConnectId(), "prop.onProp")
        instance:sendPack("Prop", prop_data)
    else
        prop = player:getProp()
        local dt = prop:get()
        dt.rid = role:getID()
        dt.cid = id
        dt.count = count
        local query = prop:insertQuery(dt)
        prop:updateQuery(query, instance:getConnectId(), "prop.onPropNew")
    end
end

function PropAction:onProp(args, _redis)
    cc.dump(args)
end

function PropAction:onPropNew(args, _redis)
    if args.err or #(args) < 1 then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local prop = player:updateProp(args[1])
    instance:sendPack("Prop", prop:get())
end

return PropAction
