
local gbc = cc.import("#gbc")
local FileAction = cc.class("FileAction", gbc.ActionBase)
local utility = cc.import("#utility")
local cache = cc.import("#cache")
local Umd5 = utility.Umd5

function FileAction:checkConfigAction(args, _redis)
    local md5 = cache.get("sqlite_file_md5")
    if not md5 then
        md5 = Umd5.file(cc.sqlite_file)
        cache.set("sqlite_file_md5", md5)
    end
    return args.md5 == md5
end

return FileAction
