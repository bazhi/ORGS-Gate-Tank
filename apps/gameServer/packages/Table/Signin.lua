
local Struct = {
    id = 0,
    rid = 0,
    times = 0,
    record = "",
}

local Define = {
    id = "int NOT NULL AUTO_INCREMENT PRIMARY KEY",
    rid = "int",
    times = "int",
    record = "varchar(1024)",
}

local Indexes = {
    "UNIQUE KEY `unid` (`rid`)  USING HASH",
}

return {
    Struct = Struct,
    Define = Define,
    Indexes = Indexes,
    Name = "Signin",
}
