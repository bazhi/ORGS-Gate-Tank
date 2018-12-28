
local Struct = {
    id = 0,
    rid = 0,
    cid = 0,
    level = 0,
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int NOT NULL",
    cid = "int NOT NULL",
    level = "int NOT NULL",
}

local Indexes = {
    "UNIQUE KEY `crid` (`cid`, `rid`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Talent",
}
