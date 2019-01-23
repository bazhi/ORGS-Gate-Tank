
local utf = {}

-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
function utf.chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function utf.len(str)
    local len = 0
    local mlen = #str
    local currentIndex = 1
    while currentIndex <= mlen do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + utf.chsize(char)
        len = len + 1
    end
    return len
end

-- 截取utf8 字符串
-- str:            要截取的字符串
-- start:    开始字符下标,从1开始
-- numChars:    要截取的字符长度
function utf.sub(str, start, numChars)
    local startIndex = 1
    while start > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + utf.chsize(char)
        start = start - 1
    end
    
    local currentIndex = startIndex
    
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + utf.chsize(char)
        numChars = numChars - 1
    end
    return string.sub(str, startIndex, currentIndex - 1)
end

function utf.splitall(str)
    local all = {}
    local len = #str
    local cidx = 1
    while cidx <= len do
        local char = string.byte(str, cidx)
        local size = utf.chsize(char)
        local word = string.sub(str, cidx, cidx + size - 1)
        table.insert(all, word)
        cidx = cidx + size
    end
    return all
end

return utf