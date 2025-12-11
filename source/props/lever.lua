class("Lever").extends(playdate.graphics.sprite)

local Point <const> = playdate.geometry.point

local TRIGGER_DISTANCE <const> = 50
local LEVER_IDLE_FRAME <const> = 1
local LEVER_CAN_USE_FRAME <const> = 2
local LEVER_USED_FRAME <const> = 3

local leverImages <const> = playdate.graphics.imagetable.new("assets/images/props/lever")

function Lever:init(x, y, callback)
    Lever.super.init(self)

    self.callback = callback

    self:setImage(leverImages:getImage(1))
    self:setCenter(0.5, 1)
    self:setZIndex(500)
    self:moveTo(x, y)
    self:add()

    self.position = Point.new(x, y)

    self.isUsed = false
end

function Lever:updatePlayerDistance(playerPosition)
    local dist = self.position:distanceToPoint(playerPosition)

    self.isPlayerNear = self:isVisible() and (dist < TRIGGER_DISTANCE)
end

function Lever:updateImages()
    if self.isUsed then
        self:setImage(leverImages:getImage(LEVER_USED_FRAME))
    elseif self.isPlayerNear then
        self:setImage(leverImages:getImage(LEVER_CAN_USE_FRAME))
    else
        self:setImage(leverImages:getImage(LEVER_IDLE_FRAME))
    end
end

function Lever:usage()
    if not self.isPlayerNear or self.isUsed then return end

    if playdate.buttonIsPressed(playdate.kButtonB) then
        self.isUsed = true

        if self.callback then
            EventSystem:emitEvent(self.callback)
        end
    end
end

function Lever:update()
    self:usage()
    self:updateImages()
end