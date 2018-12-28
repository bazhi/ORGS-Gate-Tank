
local Struct = {
    id = 0,
    platform = 0,
    username = "",
    password = "",
    createtime = 0,
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    platform = "int",
    username = "varchar(255)",
    password = "varchar(255)",
    createtime = "bigint",
}

local Indexes = {
    "UNIQUE KEY `userid` (`username`, `platform`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Account",
}
