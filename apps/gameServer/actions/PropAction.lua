
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

--分解
function PropAction:decomposeAction(args, redis)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local props = player:getProps()
    local prop = props:get(args.prop_id)
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
    local query = prop:updateQuery({id = prop_data.id}, {count = prop_data.count})
    prop:pushQuery(query, instance:getConnectId())
    instance:sendPack("Props", {
        values = {prop_data},
    })
    
    self:addProps({items = cfg_prop.decompose}, redis)
end

function PropAction:addProps(args, _redis)
    if not args.items then
        cc.printerror("PropAction:addProps args is not support")
        return
    end
    local items = ParseConfig.ParseDecompose(args.items)
    for _, item in ipairs(items) do
        self:addProp(item.id, item.count)
    end
end

function PropAction:addPropsWithList(args, _redis)
    local instance = self:getInstance()
    local ids = args.ids
    if type(ids) ~= "table" then
        instance:sendError("NoParam")
        return - 1
    end
    local idMap = {}
    
    for _, id in ipairs(ids) do
        if not idMap[id] then
            idMap[id] = 0
        end
        idMap[id] = idMap[id] + 1
    end
    
    for id, count in pairs(idMap) do
        self:addProp(id, count)
    end
end

function PropAction:addProp(cid, count)
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local role = player:getRole()
    local props = player:getProps()
    local prop = props:getByCID(cid)
    if prop then
        local prop_data = prop:get()
        prop_data.count = prop_data.count + count
        local query = prop:updateQuery({id = prop_data.id}, {count = prop_data.count})
        prop:pushQuery(query, instance:getConnectId())
        instance:sendPack("Props", {
            values = {prop_data},
        })
    else
        local cfg_prop = dbConfig.get("cfg_prop", cid)
        if not cfg_prop then
            instance:sendError("ConfigError")
            return - 1
        end
        
        prop = props:get()
        local dt = prop:get()
        dt.rid = role:getID()
        dt.cid = cid
        dt.count = count
        local query = prop:insertQuery(dt)
        prop:pushQuery(query, instance:getConnectId(), "prop.onPropNew")
    end
    return 1
end

function PropAction:onProp(args, redis, params)
    --cc.dump(args)
    if params and params.update then
        local instance = self:getInstance()
        local player = instance:getPlayer()
        local props = player:getProps()
        local bupdate = props:updates(args)
        if bupdate then
            instance:sendPack("Props", {
                values = args,
            })
        end
    end
end

function PropAction:onPropNew(args, redis)
    if args.err or not args.insert_id or args.insert_id <= 0 then
        return
    end
    local instance = self:getInstance()
    local player = instance:getPlayer()
    local props = player:getProps()
    local prop = props:getTemplate()
    local query = prop:selectQuery({id = args.insert_id})
    prop:pushQuery(query, instance:getConnectId(), "prop.onProp", {
        update = true,
    })
end

return PropAction
