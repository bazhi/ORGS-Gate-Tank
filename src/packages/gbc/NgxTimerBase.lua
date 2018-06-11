
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

local NgxTimerBase = cc.class("NgxTimerBase")

function NgxTimerBase:ctor(config)
    self.config = config
end

function NgxTimerBase:run()
    local ret = self:runEventLoop()
    self:onClose()
    return ret
end

function NgxTimerBase:runEventLoop()
    return 1
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
        
        redis:select(0)
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
            cc.printerror("HttpInstanceBase:mysql() - mysql is not set config")
            return nil
        end
        local _mysql, _err = Mysql.create(config)
        if not _mysql then
            cc.printerror("HttpInstanceBase:mysql() - can not create mysql:".._err)
            return nil
        end
        mysql = _mysql
        self._mysql = mysql
    end
    return mysql
end

function NgxTimerBase:onClose()
    if self._mysql then
        self._mysql:set_keepalive()
        self._mysql = nil
    end
    if self._redis then
        self._redis:setKeepAlive()
        self._redis = nil
    end
end

return NgxTimerBase