
--[[
 
Copyright (c) 2015 gameboxcloud.com
 
Permission is hereby granted, free of charge, to any person obtaining a copy
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
local Redis = cc.import("#redis")
local Mysql = cc.import("#mysql")
local Constants = cc.import(".Constants")
local NgxTimerBase = cc.class("NgxTimerBase")
local json = cc.import("#json")
local json_encode = json.encode
local sdSIG = ngx.shared.sdSIG

function NgxTimerBase:ctor(config, param)
    self.config = config
    self.param = param
end

function NgxTimerBase:run()
    self:runEventLoop()
    self:onClose()
end

function NgxTimerBase:safeFunction(func)
    return xpcall(func, function(err)
        err = tostring(err)
        cc.printerror(err .. debug.traceback("", 1))
    end)
end

function NgxTimerBase:runEventLoop()
    return true
end

function NgxTimerBase:sendMessageToAll(redis, message)
    return redis:publish(Constants.BROADCAST_ALL_CHANNEL, message)
end

function NgxTimerBase:sendControlMessage(connectId, message)
    local redis = self._redis
    if not redis then
        return
    end
    
    if type(message) == "table" then
        message = json_encode(message)
    end
    
    local controlChannel = Constants.CONTROL_CHANNEL_PREFIX..self.config.app.appName .. "-" .. connectId
    local ok, err = redis:publish(controlChannel, message)
    if not ok then
        cc.printerror(err)
        return nil, err
    end
    return true
end

function NgxTimerBase:sendMessageToConnectID(connectId, message)
    local redis = self._redis
    if not redis then
        return
    end
    
    if type(message) == "table" then
        message = json_encode(message)
    end
    
    local connectChannel = Constants.CONNECT_CHANNEL_PREFIX ..self.config.app.appName .. "-" .. connectId
    local ok, err = redis:publish(connectChannel, message)
    if not ok then
        cc.printerror(err)
        return nil, err
    end
    return true
end

function NgxTimerBase:getRedis()
    if not Redis then
        return nil
    end
    local redis = self._redis
    if not redis then
        local redisConfig = self.config.server.redis
        redis = Redis:new()
        
        local ok, err
        if redisConfig.socket then
            ok, err = redis:connect(redisConfig.socket)
        else
            ok, err = redis:connect(redisConfig.host, redisConfig.port)
        end
        if not ok then
            cc.printerror("NgxTimerBase:getRedis() - %s", err)
            return nil
        end
        redis:Select(self.config.app.appIndex)
        self._redis = redis
    end
    return redis
end

function NgxTimerBase:getMysql()
    local mysql = self._mysql
    if not mysql then
        local config = self.config.app.mysql
        if not config then
            cc.printerror("NgxTimerBase:mysql() - mysql is not set config")
            return nil
        end
        mysql = Mysql:new(config)
        self._mysql = mysql
    end
    local ok, err = mysql:connect()
    if not ok then
        cc.printerror(err)
        self._mysql:close()
        self._mysql = nil
        return nil
    end
    return mysql
end

function NgxTimerBase:onClose()
    self:closeMysql()
    self:closeRedis()
end

function NgxTimerBase:Initialized()
    local redis = self:getRedis()
    redis:set(Constants.NEXT_CONNECT_ID_KEY, 0)
    sdSIG:set(Constants.SIGINIT, true)
end

function NgxTimerBase:closeMysql()
    if self._mysql then
        self._mysql:set_keepalive()
        self._mysql = nil
    end
end

function NgxTimerBase:closeRedis()
    if self._redis then
        self._redis:setKeepAlive()
        self._redis = nil
    end
end

--获取server.nginx
function NgxTimerBase:getNginxConfig()
    local config = self.config
    local appName = config.app.appName
    local ngxServers = config.server.nginx
    for _k, v in ipairs(ngxServers) do
        if v.apps[appName] then
            return v, appName
        end
    end
    return nil, nil
end

--获取server.master
function NgxTimerBase:getMasterConfig()
    return self.config.server.master
end

return NgxTimerBase
