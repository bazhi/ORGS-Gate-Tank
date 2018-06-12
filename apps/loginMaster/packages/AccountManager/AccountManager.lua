local orm = cc.import("#orm")
local OrmMysql = orm.OrmMysql
local Table = cc.import("#Table")
local Account = Table.Account
local OrmAccount = OrmMysql:new(Account.Name, Account.Define, Account.Struct, Account.Indexes)

local AccountManager = {}

local accountList = {}

--获取帐号信息
function AccountManager.Get(username, platform)
    local users = accountList[platform]
    if not users then
        users = {}
        accountList[platform] = users
    end
    --cc.dump(accountList)
    return users[username]
end

function AccountManager.Add(user)
    local platform = user.platform
    local username = user.username
    
    local users = accountList[platform]
    if not users then
        users = {}
        accountList[platform] = users
    end
    users[username] = user
end

function AccountManager.Load(db, username, platform)
    local users = OrmAccount:select(db, {
        username = username,
        platform = platform,
    })
    if not users or #users == 0 then
        return nil
    end
    for _, user in ipairs(users) do
        AccountManager.Add(user)
    end
    return users[1]
end

function AccountManager.UpdateUser(db, user)
    user.logintime = ngx.now()
    OrmAccount:update(db, {logintime = user.logintime}, {id = user.id})
end

-- function AccountManager.Save(db, user)
--     OrmAccount:update(db, {id = user.id})
-- end

function AccountManager.Register(db, user)
    local ret = OrmAccount:insert(db, user)
    if ret and ret.insert_id > 0 then
        return AccountManager.Load(db, user.username, user.platform)
    else
        cc.printinfo("can not create Account")
        return nil
    end
end

return AccountManager

