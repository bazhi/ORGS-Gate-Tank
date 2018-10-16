
local BaseList = cc.import(".BaseList")
local Chapters = cc.class("Chapters", BaseList)
local Chapter = cc.import(".Chapter")

function Chapters:createItem()
    return Chapter:new()
end

-- function Chapters:getProto()
--     self._Datas = self._Datas or {}
--     local values = self._Datas
--     local ret = {}
--     for _, v in ipairs(values) do
--         v = v:get()
--         table.insert(ret, {
--             id = v.id,
--             rid = v.rid,
--             cid = v.cid,
--             status = v.status,
--         })
--     end
--     return ret
-- end

return Chapters
