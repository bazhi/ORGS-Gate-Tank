
local Struct = {
    id = 0,
    rid = 0,
    cid = 0,
    --star = 0, --星星总数
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int",
    cid = "int",
    --star = "int",
}

local Indexes = {
    "UNIQUE KEY `crid` (`cid`, `rid`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Chapter",
}
