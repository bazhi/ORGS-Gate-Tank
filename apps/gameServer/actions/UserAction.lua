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
local UserAction = cc.class("UserAction", gbc.ActionBase)
local Session = cc.import("#session")

local _opensession = function(instance, args)
    local sid = args.sid
    if not sid then
        cc.throw("not set argsument: \"sid\"")
    end
    
    local session = Session:new(instance:getRedis())
    if not session:start(sid) then
        cc.throw("session is expired, or invalid session id")
    end
    
    return session
end

--登录
function UserAction:signinAction(args)
    
end

return UserAction
