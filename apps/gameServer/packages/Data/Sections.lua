
local BaseList = cc.import(".BaseList")
local Sections = cc.class("Sections", BaseList)
local Section = cc.import(".Section")

function Sections:createItem()
    return Section:new()
end

--获取章节的总星级
function Sections:getChapterStar(chapter_cid)
    local star = 0
    local count = 0
    local values = self._Datas or {}
    for _, v in ipairs(values) do
        if v._data.chapter_cid == chapter_cid then
            star = star + v._data.star
            if v.star > 0 then
                count = count + 1
            end
        end
    end
    return star, count
end

return Sections
