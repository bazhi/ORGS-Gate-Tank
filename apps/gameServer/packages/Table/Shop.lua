
local Struct = {
    id = 0,
    rid = 0,
    idList = "",
    timesList = "",
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int",
    idList = "varchar(4096)",
    timesList = "varchar(4096)",
}

local Indexes = {
    "UNIQUE KEY `unid` (`rid`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Shop",
}
