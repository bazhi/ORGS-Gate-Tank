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

-- local io_flush      = io.flush
-- local os_date       = os.date
-- local os_time       = os.time
-- local string_format = string.format
-- local string_lower  = string.lower
-- local tostring      = tostring
-- local type          = type

-- local json      = cc.import("#json")
-- local Constants = cc.import(".Constants")

local NginxWorkerInstanceBase = cc.class("NginxWorkerInstanceBase")

function NginxWorkerInstanceBase:ctor(config, _args)
    self.config = table.copy(cc.checktable(config))
end

function NginxWorkerInstanceBase:run()
    return self:runEventLoop()
end

function NginxWorkerInstanceBase:runEventLoop()
	-- if ngx ~= nil then
	-- 	cc.printinfo("init worker:" .. ngx.worker.id())
	-- end
    return 1
end

return NginxWorkerInstanceBase
