
local account = {}

local data = {
    Logintimes = 0
}

function account.getLoginTimes()
    return data.Logintimes
end

function account.addLoginTimes()
    data.Logintimes = data.Logintimes + 1
end

--获取帐号信息
function account.get(username)
    
end

return account
