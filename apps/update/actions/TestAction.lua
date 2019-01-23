
local gbc = cc.import("#gbc")
local TestAction = cc.class("TestAction", gbc.ActionBase)
local sensitive = cc.import("#sensitive")
local sensitive_library = sensitive.library

function TestAction:checkAction(args)
    if args.name then
        return sensitive_library:replace(args.name)
    end
end

return TestAction
