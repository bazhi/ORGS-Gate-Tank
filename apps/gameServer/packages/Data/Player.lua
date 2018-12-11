local Player = cc.class("Player")
local Role = cc.import(".Role")

local Props = cc.import(".Props")
local Chapters = cc.import(".Chapters")
local Boxes = cc.import(".Boxes")

local Signin = cc.import(".Signin")
local Shop = cc.import(".Shop")

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

function Player:getShop()
    if not self._Shop then
        self._Shop = Shop:new()
    end
    return self._Shop
end

function Player:updateRole(data)
    local role = self:getRole()
    role:update(data)
    return role
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
--宝箱API
--------------------------------------------------------------------------------------------------------------------

function Player:getBoxes()
    if not self._Boxes then
        self._Boxes = Boxes:new()
    end
    return self._Boxes
end

return Player
