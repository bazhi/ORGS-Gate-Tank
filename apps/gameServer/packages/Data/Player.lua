local Player = cc.class("Player")
local Role = cc.import(".Role")

local Equipments = cc.import(".Equipments")
local Props = cc.import(".Props")
local Chapters = cc.import(".Chapters")
local Sections = cc.import(".Sections")
local Missions = cc.import(".Missions")
local Boxes = cc.import(".Boxes")

local Signin = cc.import(".Signin")

--玩家所有数据的集合
function Player:ctor(user)
    self._User = user
    
    self._Role = Role:new()
end

function Player:getRole()
    return self._Role
end

function Player:getSignin()
    if not self._Signin then
        self._Signin = Signin:new()
    end
    return self._Signin
end

function Player:updateRole(data)
    local role = self:getRole()
    role:update(data)
    return role
end

--------------------------------------------------------------------------------------------------------------------
--装备API
--------------------------------------------------------------------------------------------------------------------
--更新所有装备

function Player:getEquipments()
    if not self._Equipments then
        self._Equipments = Equipments:new()
    end
    return self._Equipments
end

--------------------------------------------------------------------------------------------------------------------
--道具API
--------------------------------------------------------------------------------------------------------------------

function Player:getProps()
    if not self._Props then
        self._Props = Props:new()
    end
    return self._Props
end

--------------------------------------------------------------------------------------------------------------------
--章节API
--------------------------------------------------------------------------------------------------------------------

function Player:getChapters()
    if not self._Chapters then
        self._Chapters = Chapters:new()
    end
    return self._Chapters
end

--------------------------------------------------------------------------------------------------------------------
--小节API
--------------------------------------------------------------------------------------------------------------------
function Player:getSections()
    if not self._Sections then
        self._Sections = Sections:new()
    end
    return self._Sections
end

--------------------------------------------------------------------------------------------------------------------
--小节API
--------------------------------------------------------------------------------------------------------------------

function Player:getMissions()
    if not self._Missions then
        self._Missions = Missions:new()
    end
    return self._Missions
end

--------------------------------------------------------------------------------------------------------------------
--宝箱API
--------------------------------------------------------------------------------------------------------------------

function Player:getBoxes()
    if not self._Boxes then
        self._Boxes = Boxes:new()
    end
    return self._Boxes
end

return Player
