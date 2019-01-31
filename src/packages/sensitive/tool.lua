
local sensitive_tool = cc.class("sensitive_tool")
local utf = cc.import(".utf8")
local string_split = string.split

local Node = {
    children = {},
    bover = false
}

local skipmap = {
    
}

local MaxLength = 40

local function pushSkip(str)
    local words = utf.splitall(str)
    for _, v in ipairs(words) do
        skipmap[v] = true
    end
end

pushSkip("~!@#$%^&*()_+`1234567890-=[];',./<>?:\\\"。、《》？；’：”【】｛｝、|～·！￥……（）＝-+——) ")

--根据词库创建
function sensitive_tool:ctor(input, delimiter)
    self.root = table.copy(Node)
    local allwords = string_split(input, delimiter)
    for _, v in ipairs(allwords) do
        self:push(utf.splitall(v))
    end
end

--二叉树构建
function sensitive_tool:push(words)
    local len = #words
    local cnode = self.root
    for k, v in ipairs(words) do
        if not skipmap[v] then
            if not cnode.children[v] then
                cnode.children[v] = table.copy(Node)
            end
            cnode = cnode.children[v]
            if k == len then
                cnode.bover = true
            end
        end
    end
end

function sensitive_tool:replace(input, char)
    input = string.lower(input)
    if not char then
        char = "*"
    end
    local words = utf.splitall(input)
    local len = #words
    local stop
    
    local i = 1
    while i <= len do
        stop = i + MaxLength
        if len < stop then
            stop = len
        end
        local endchar = self:replacestep(words, i, stop)
        if endchar > 0 then
            for k = i, endchar do
                words[k] = char
            end
            i = endchar
        else
            i = i + 1
        end
    end
    return table.concat(words, "")
end

function sensitive_tool:replacestep(words, start, stop)
    local cnode = self.root
    local endchar = -1
    for k = start, stop do
        local v = words[k]
        if not skipmap[v] then
            if not cnode.children[v] then
                return endchar
            else
                cnode = cnode.children[v]
                if cnode.bover then
                    endchar = k
                end
            end
        end
    end
    return endchar
end

function sensitive_tool:check(input)
    input = string.lower(input)
    local words = utf.splitall(input)
    local len = #words
    local stop
    for i = 1, len do
        stop = i + MaxLength
        if len < stop then
            stop = len
        end
        if self:checkstep(words, i, stop) > 0 then
            return true
        end
    end
    return false
end

function sensitive_tool:checkstep(words, start, stop)
    local cnode = self.root
    local v
    for k = start, stop do
        v = words[k]
        if not skipmap[v] then
            if not cnode.children[v] then
                return - 1
            else
                cnode = cnode.children[v]
                if cnode.bover then
                    return k
                end
            end
        end
    end
    return - 1
end

return sensitive_tool
