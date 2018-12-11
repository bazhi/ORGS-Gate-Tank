
local Struct = {
    id = 0,
    pid = 0,
    cid = 0,
    nickname = "",
    level = 1,
    gold = 0,
    diamond = 0,
    loginTime = 0,
    createTime = 0,
    exp = 0,
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    pid = "int",
    cid = "int",
    nickname = "varchar(255)",
    level = "int",
    gold = "int",
    diamond = "int",
    loginTime = "int",
    createTime = "int",
    exp = "int",
}

local Indexes = {
    "UNIQUE KEY `nickname` (`nickname`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Role",
}
