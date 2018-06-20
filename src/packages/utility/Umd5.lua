
local M = {}

local resty_md5 = require("resty.md5")
local str = require ("resty.string")

--计算文件的md5
function M.file(filepath)
    local md5 = resty_md5:new()
    local file = io.open(filepath, "rb")
    --md5:update(file:read("*a"))
    while true do
        local data = file:read(1024)
        if not data then
            break
        end
        md5:update(data)
    end
    
    file:close()
    return str.to_hex(md5:final())
end

return M
