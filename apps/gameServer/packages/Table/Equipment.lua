
local Struct = {
    id = 0,
    rid = 0,
    cid = 0,
    star = 0,
    exp = 0,
    oid = 0,
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int",
    cid = "int",
    star = "int",
    exp = "int",
    oid = "int",
}

local Indexes = {
    "UNIQUE KEY `crid` (`cid`, `rid`)  USING HASH",
    "UNIQUE KEY `coid` (`oid`, `rid`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Equipment",
}
