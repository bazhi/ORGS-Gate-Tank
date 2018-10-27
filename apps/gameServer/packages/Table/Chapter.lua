
local Struct = {
    id = 0,
    rid = 0,
    cid = 0,
    status = 0, --章节状态， 0未解锁，1已经解锁，2已经完成
    record1 = "",
    record2 = "",
    record3 = "",
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int NOT NULL",
    cid = "int NOT NULL",
    status = "int NOT NULL",
    record1 = "longblob",
    record2 = "longblob",
    record3 = "longblob",
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
