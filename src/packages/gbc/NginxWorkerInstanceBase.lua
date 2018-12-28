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

local NginxWorkerInstanceBase = cc.class("NginxWorkerInstanceBase")

function NginxWorkerInstanceBase:ctor(config, _args)
    self.config = table.copy(cc.checktable(config))
end

function NginxWorkerInstanceBase:run()
    local ret = self:runEventLoop()
    self:onClose()
    return ret
end

function NginxWorkerInstanceBase:runEventLoop()
    return true
end

function NginxWorkerInstanceBase:GetConfig(name)
    if not name then
        name = self:getAppName()
    end
    local configs = self.config.server.nginx
    if configs then
        for _, v in ipairs(configs) do
            if v.apps and v.apps[name] then
                return v
            end
        end
    end
end

function NginxWorkerInstanceBase:getAppName()
    return self.config.app.appName
end

function NginxWorkerInstanceBase:runTimer(delay, timer, param, isInit)
    ngx.timer.at(delay, function(premature, config)
        if premature then
            cc.printf("premature")
            return
        end
        local instance = timer:new(config, isInit)
        instance:run()
    end, param)
end

function NginxWorkerInstanceBase:runEveryTimer(delay, timer, param, isInit)
    ngx.timer.every(delay, function(premature, config)
        if premature then
            cc.printf("premature")
            return
        end
        local instance = timer:new(config, isInit)
        instance:run()
    end, param)
end

function NginxWorkerInstanceBase:onClose()
    
end

return NginxWorkerInstanceBase
