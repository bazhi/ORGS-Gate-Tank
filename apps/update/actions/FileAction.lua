
local gbc = cc.import("#gbc")
local FileAction = cc.class("FileAction", gbc.ActionBase)
local utility = cc.import("#utility")
local cache = cc.import("#cache")
local Umd5 = utility.Umd5

function FileAction:checkConfigAction(args, _redis)
    local md5 = cache.get("sqlite_file_md5")
    if not md5 then
        md5 = Umd5.file(cc.sqlite_file)
        cache.set("sqlite_file_md5", md5, 60)
    end
    return {
        result = string.lower(args.md5) == string.lower(md5),
    }
end

function FileAction:checkMD5(path, file, md5)
    local key = "MD5_"..file
    local md5_c = cache.get(key)
    if not md5_c then
        md5_c = Umd5.file(path..file)
        cache.set(key, md5_c, 60)
    end
    return string.lower(md5_c) == string.lower(md5)
end

function FileAction:checkUpdateAction(args, _redis)
    local cfg = self:getInstanceConfig()
    local path = cfg.app.rootPath .. "/public/download/"
    local checklist = args.checklist or {}
    local result = {}
    
    for _, item in ipairs(checklist) do
        if item.file and item.md5 then
            if not self:checkMD5(path, item.file, item.md5) then
                table.insert(result, item.file)
            end
        end
    end
    
    return {updates = result}
end

return FileAction
