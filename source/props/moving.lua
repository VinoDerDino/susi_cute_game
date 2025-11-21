class("Moving").extends(playdate.graphics.sprite)

local Point <const> = playdate.geometry.point
local vector2D <const> = playdate.geometry.vector2D

function Moving:init(startX, startY, endX, endY)
    Moving.super.init(self)

    self.currentPosition = Point.new(startX, startY)
    self.startingPosition = Point.new(startX, startY)
    self.endPosition = Point.new(endX, endY)

    self.direction = vector2D.new(self.endPosition.x - self.startingPosition.x, self.endPosition.y - self.startingPosition.y)
    self.direction:normalize()
    self.crankValue = 0
    self.canMove = true

    self:setZIndex(100)
    self:moveTo(startX, startY)
end

function Moving:setCrankValue(value)
    if not self.canMove then return end
    self.crankValue = value

    local totalDistance = self.startingPosition:distanceToPoint(self.endPosition)
    local moveDistance = (self.crankValue / 100) * totalDistance

    self.currentPosition.x = self.startingPosition.x + self.direction.x * moveDistance
    self.currentPosition.y = self.startingPosition.y + self.direction.y * moveDistance

    self:moveTo(self.currentPosition.x, self.currentPosition.y)
end

function Moving:setCanMove(flag)
    self.canMove = flag
end