
local library = {}
local library_str = cc.import(".sensitive_library")
local Tool = cc.import(".tool")

function library:init()
    if not self.tool then
        self.tool = Tool:new(library_str, "|")
    end
end

function library:replace(input, char)
    self:init()
    return self.tool:replace(input, char)
end

function library:check(input)
    self:init()
    return self.tool:check(input)
end

return library
