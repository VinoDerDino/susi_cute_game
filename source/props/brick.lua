class("Brick").extends(playdate.graphics.sprite)

local DIMENSION <const> = 20

function Brick:init(x, y, disappearsOn)
    local trueX, trueY = x + DIMENSION / 2, y + DIMENSION

    self:setImage(playdate.graphics.image.new("assets/images/props/brick"))

    self:setCollideRect(0, 0, DIMENSION, DIMENSION)
    self:setCenter(0.5, 1)
    self:setZIndex(500)
    self:moveTo(trueX, trueY)

    self.isWall = true

    self.disappearsOn = disappearsOn or nil

    EventSystem:addListener(self)
end

function Brick:catchEvent(eventName, data)
    if not self.disappearsOn then return end

    if eventName == self.disappearsOn then
        self:remove()
    end
end