
local UserCenter = cc.class("UserCenter")

local gbc = cc.import("#gbc")
local User = cc.import(".User")
local MessageType = gbc.MessageType
local Constants = gbc.Constants
local sdLogin = ngx.shared.sdLogin

function UserCenter:ctor(instance)
    self.users = {}
    self.instance = instance
end

function UserCenter:canLogin(connectid)
    connectid = "PID:"..connectid
    local lgcnt = sdLogin:incr(connectid, 1, 0)
    if lgcnt > 1 then
        sdLogin:incr(connectid, -1, 0)
        return false
    else
        return true
    end
end

function UserCenter:userLogin(connectid, mysql)
    if self:canLogin(connectid) then
        local user = self.users[connectid]
        if not user then
            user = User:new(connectid)
            self.users[connectid] = user
            user:Login(mysql, self.instance)
        end
    else
        if self.instance then
            self.instance:sendError(connectid, "UserLoggedIn")
            self.instance:sendToGate(connectid, Constants.CLOSE_CONNECT, 1)
        end
    end
end

function UserCenter:userLogout(connectid, mysql)
    local user = self.users[connectid]
    if user then
        user:Logout(mysql, self.instance)
    end
    self.users[connectid] = nil
    sdLogin:incr("PID:"..connectid, -1, 0)
end

function UserCenter:Process(connectid, message, mysql, msgtype, msgid)
    if MessageType.ONCONNECTED == message then --用户登陆
        self:userLogin(connectid, mysql)
    elseif MessageType.ONDISCONNECTED == message then --断开链接
        self:userLogout(connectid, mysql)
    elseif MessageType.DB_SAVE == message then --存储到数据库
        self:SaveAll(mysql)
    else
        local user = self.users[connectid]
        if user then
            user:Process(mysql, message, self.instance, msgtype, msgid)
        end
    end
end

function UserCenter:SaveAll(mysql)
    for _, user in pairs(self.users) do
        user:Save(mysql)
    end
end

function UserCenter:Save(connectid, mysql)
    local user = self.users[connectid]
    if user then
        user:Save(mysql)
    end
end

function UserCenter:RemoveAll()
    for id, _ in pairs(self.users) do
        sdLogin:incr("PID:"..id, -1, 0)
    end
    self.users = {}
end

return UserCenter
