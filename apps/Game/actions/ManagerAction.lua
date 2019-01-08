
local gbc = cc.import("#gbc")
local ManagerAction = cc.class("ManagerAction", gbc.ActionBase)
local Constants = gbc.Constants
local netpack = cc.import("#netpack")
--local net_encode = netpack.encode
local net_decode = netpack.decode

ManagerAction.ACCEPTED_REQUEST_TYPE = "http"

local pageCount = 10

function ManagerAction:ulistAction(arg, redis)
    local page = arg.page
    if page then
        page = tonumber(page)
    else
        page = 1
    end
    if page <= 0 then
        page = 1
    end
    local list = redis:zrevrange(Constants.USERLIST, pageCount * (page - 1), pageCount * page - 1)
    local result = {}
    for _, id in ipairs(list) do
        table.insert(result, net_decode(redis:get(Constants.USER..id)))
    end
    return result
end

function ManagerAction:ucountAction(_arg, redis)
    return redis:zcard(Constants.USERLIST)
end

function ManagerAction:getuserAction(arg, redis)
    local id = tonumber(arg.id)
    if id > 0 then
        local data = redis:get(Constants.USER..id)
        return net_decode(data)
    end
end

return ManagerAction

