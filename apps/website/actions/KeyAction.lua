
local gbc = cc.import("#gbc")
local KeyAction = cc.class("KeyAction", gbc.ActionBase)
local cdkey = require 'resty.cdkey'
local lfs = require "lfs"

local CDKey_Prefix = "CD:"
local RewardKey_Prefix = "Reward:"
local NEXT_REWARD_ID_KEY = "_NEXT_REWARD_ID_KEY_"

function KeyAction:getCdkeyPath()
    local config = self:getInstanceConfig()
    return config.app.rootPath
end

function KeyAction:GenerateAction(args, redis)
    local count = tonumber(args.count)
    if not count or count <= 0 or count > 20000 then
        return {
            result = false,
            err = "count:" .. count,
        }
    end
    
    local rewards = args.rewards or ""
    local expiration = tonumber(args.expiration)
    if not expiration or expiration < ngx.now() then
        return {
            result = false,
            err = "expiration:" .. (expiration - ngx.now()),
        }
    end
    
    local path = self:getCdkeyPath()
    local end_time = os.date("%x", expiration)
    end_time = string.gsub(end_time, "/", "-")
    local localtime = ngx.localtime()
    local filename = string.format("%s===%d===%s.txt", localtime, count, end_time)
    local filedir = string.sub(localtime, 1, 10)
    
    local cdkeyPath = string.format("%s/public/cdkey/", path)
    if not io.exists(cdkeyPath) then
        lfs.mkdir(cdkeyPath)
    end
    
    local dirpath = string.format("%s/public/cdkey/%s", path, filedir)
    if not io.exists(dirpath) then
        lfs.mkdir(dirpath)
    end
    local filepath = string.format("%s/%s", dirpath, filename)
    
    expiration = math.floor(expiration - ngx.now())
    
    cdkey.seed()
    
    local RewardID = tonumber(redis:incr(NEXT_REWARD_ID_KEY))
    local RewardID_KEY = RewardKey_Prefix..RewardID
    redis:set(RewardID_KEY, rewards)
    redis:expire(RewardID_KEY, tonumber(expiration))
    
    local file = io.open(filepath, "a")
    local checkcount = count * 10
    for _ = 1, checkcount, 1 do
        local key = cdkey.generate()
        local redis_key = CDKey_Prefix..string.gsub(key, "-", "")
        if tostring(redis:exists(redis_key)) == "0" then
            redis:set(redis_key, RewardID)
            redis:expire(redis_key, tonumber(expiration))
            file:write(key..", ")
            count = count - 1
        end
        if count == 0 then
            break
        end
    end
    file:close()
    return {
        result = true,
        filename = filename,
    }
end

function KeyAction:GetAction(args, redis)
    local key = args.key
    if type(key) ~= 'string' then
        return "is not string"
    end
    
    key = string.gsub(key, "-", "")
    key = CDKey_Prefix..key
    local id = tonumber(redis:get(key))
    if not id then
        return "not id:"..key
    end
    redis:del(key)
    local rewards = redis:get(RewardKey_Prefix..id)
    return{
        rewards = rewards,
        id = id,
    }
end

return KeyAction

