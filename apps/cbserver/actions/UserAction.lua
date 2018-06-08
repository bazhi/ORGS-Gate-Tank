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

local Session = cc.import("#session")
local gbc = cc.import("#gbc")
local UserAction = cc.class("UserAction", gbc.ActionBase)

local index = 1

function UserAction:signinAction(args)
    local username = args.username
    if not username then
        cc.throw("not set argsument: \"username\"")
    end
    
    -- start session
    local session = Session:new(self:getInstance():getRedis())
    session:start()
    session:set("username", username)
    session:set("count", 0)
    session:save()
    
    -- return result
    return {sid = session:getSid(), count = 0}
end

function UserAction:signoutAction(args)
    -- remove user from online list
    local session = _opensession(self:getInstance(), args)
    local online = Online:new(self:getInstance())
    online:remove(session:get("username"))
    -- delete session
    session:destroy()
    return {ok = "ok"}
end

function UserAction:testAction()
    index = index + 1
    return {ngx.worker.id(), index}
end

return UserAction
