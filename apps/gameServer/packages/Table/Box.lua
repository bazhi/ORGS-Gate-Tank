
local Struct = {
    id = 0,
    rid = 0,
    cid = 0,
    unlockTime = 0,
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int",
    cid = "int",
    unlockTime = "int",
}

local Indexes = {
    "UNIQUE KEY `crid` (`cid`, `rid`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Box",
}
