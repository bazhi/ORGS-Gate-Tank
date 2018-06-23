
local Struct = {
    id = 0,
    rid = 0,
    cid = 0,
    chapter_cid = 0,
    star = 0,
    tryTimes = 0, --进入次数
    finishTimes = 0, --完成次数
    enterTime = 0, --进入时间
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int",
    cid = "int",
    chapter_cid = "int",
    star = "int",
    tryTimes = "int",
    finishTimes = "int",
    enterTime = "int",
}

local Indexes = {
    "UNIQUE KEY `crid` (`cid`, `rid`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Section",
}
