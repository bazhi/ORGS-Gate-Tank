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
local AccountManager = cc.import("#AccountManager")
local ServiceManager = cc.import("#ServiceManager")
local dbConfig = cc.import("#dbConfig")

local _opensession = function(redis, args)
    local sid = args.sid
    if not sid then
        cc.throw("not set argsument: \"sid\"")
    end
    
    local session = Session:new(redis)
    if not session:start(sid) then
        cc.throw("session is expired, or invalid session id")
    end
    
    return session
end

--登录
function UserAction:signinAction(args, redis)
    local username = args.username
    local password = args.password
    local platform = args.platform or 0
    if not username then
        cc.throw("not set argsument: \"username\"")
    end
    if not password then
        cc.throw("not set argsument: \"password\"")
    end
    local user = AccountManager.Get(username, platform)
    if not user then
        local db = self:getInstance():getMysql()
        user = AccountManager.Load(db, username, platform)
    end
    
    if not user then
        cc.throw("can not find user")
    end
    
    local session = Session:new(redis)
    session:start()
    session:set("username", user.username)
    session:set("platform", user.platform)
    session:save()
    
    -- return result
    return {sid = session:getSid(), server = ServiceManager.Get("gameServer")}
end

--注册
function UserAction:signupAction(args, redis)
    local username = args.username
    local password = args.password
    local platform = args.platform or 0
    if not username or #username < 5 then
        cc.throw("not set argsument: \"username\"")
    end
    if not password or #password < 5 then
        cc.throw("not set argsument: \"password\"")
    end
    
    local db = self:getInstance():getMysql()
    local user = AccountManager.Register(db, {
        username = username,
        password = password,
        platform = platform,
        createtime = ngx.now(),
    })
    if not user then
        cc.throw("create account failded")
    end
    local session = Session:new(redis)
    session:start()
    session:set("username", user.username)
    session:set("platform", user.platform)
    session:save()
    
    return {sid = session:getSid(), server = ServiceManager.Get("gameServer")}
end

function UserAction:verifyAction(args, redis)
    local sid = args.sid
    local authorization = args.authorization
    if not sid then
        cc.throw("not set argsument: \"sid\"")
    end
    
    if not self:hasAuthority(authorization) then
        cc.throw("not Authority")
    end
    
    local session = _opensession(redis, args)
    local username = session:get("username")
    local platform = session:get("platform")
    local user = AccountManager.Get(username, platform)
    return user
end

-- function UserAction:testAction()
--     return dbConfig.get("cfg_bind", 10010)
-- end

return UserAction
