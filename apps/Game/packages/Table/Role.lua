
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
    pid = "int NOT NULL",
    cid = "int NOT NULL",
    nickname = "varchar(255) NOT NULL",
    level = "int NOT NULL",
    gold = "int NOT NULL",
    diamond = "int NOT NULL",
    loginTime = "int NOT NULL",
    createTime = "int NOT NULL",
    exp = "int NOT NULL",
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
