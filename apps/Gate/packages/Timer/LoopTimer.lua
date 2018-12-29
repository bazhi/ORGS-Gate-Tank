
local gbc = cc.import("#gbc")
local LoopTimer = cc.class("LoopTimer", gbc.NgxTimerBase)

local MessageType = gbc.MessageType
local netpack = cc.import("#netpack")
local net_encode = netpack.encode

function LoopTimer:ctor(config, ...)
    LoopTimer.super.ctor(self, config, ...)
end

function LoopTimer:runEventLoop()
    local message = net_encode({
        format = "text",
        message = MessageType.DB_SAVE,
    })
    
    while true do
        ngx.sleep(300) --5分钟保存一次数据库
        local redis = self:getRedis()
        local ok, err = redis:publish(self.param.channel, message)
        if not ok then
            cc.printerror(err)
        end
    end
end

return LoopTimer
