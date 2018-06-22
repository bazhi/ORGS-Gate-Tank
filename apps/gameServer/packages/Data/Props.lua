
local BaseList = cc.import(".BaseList")
local Props = cc.class("Props", BaseList)
local Prop = cc.import(".Prop")

function Props:createItem()
    return Prop:new()
end

return Props
