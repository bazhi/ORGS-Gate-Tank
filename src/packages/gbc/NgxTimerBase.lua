
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

function NgxTimerBase:ctor(config, bInit)
    self.config = config
    self.bInit = bInit
end

function NgxTimerBase:run()
    self:runEventLoop()
    self:onClose()
end

function NgxTimerBase:runEventLoop()
    if self.bInit then
        self:initOver()
        self.bInit = false
    end
    return true
end

function NgxTimerBase:sendControlMessage(connectId, message)
    local redis = self._redis
    if not redis then
        return
    end
    
    if type(message) == "table" then
        message = json_encode(message)
    end
    
    local controlChannel = Constants.CONTROL_CHANNEL_PREFIX .. connectId
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
    
    local connectChannel = Constants.CONNECT_CHANNEL_PREFIX .. connectId
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
        local config = self.config.server.redis
        redis = Redis:new()
        
        local ok, err
        if config.socket then
            ok, err = redis:connect(config.socket)
        else
            ok, err = redis:connect(config.host, config.port)
        end
        if not ok then
            cc.throw("InstanceBase:getRedis() - %s", err)
        end
        redis:Select(self.config.app.appIndex)
        self._redis = redis
    end
    return redis
end

function NgxTimerBase:getMysql()
    if not Mysql then
        return nil
    end
    local mysql = self._mysql
    if not mysql then
        local config = self.config.app.mysql
        if not config then
            cc.printerror("NgxTimerBase:getMysql() - mysql is not set config:"..self.config.app.appName)
            cc.printerror("package.path:"..package.path)
            return nil
        end
        local _mysql, _err = Mysql.create(config)
        if not _mysql then
            cc.printerror("NgxTimerBase:getMysql() - can not create mysql:".._err)
            return nil
        end
        mysql = _mysql
        self._mysql = mysql
    end
    return mysql
end

function NgxTimerBase:onClose()
    self:closeMysql()
    self:closeRedis()
end

function NgxTimerBase:initOver()
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

function NgxTimerBase:getMasterConfig()
    return self.config.server.master
end

return NgxTimerBase
