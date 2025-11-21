import 'props/moving'

class("MovingTile").extends(Moving)

local DIMENSION <const> = 20

function MovingTile:init(startX, startY, endX, endY)
    local trueX, trueY = startX + DIMENSION / 2, startY + DIMENSION

    MovingTile.super.init(self, trueX, trueY, endX, endY)

    self:setImage(playdate.graphics.image.new("assets/images/spritesheets/movingTile"))

    self:setCollideRect(0, 0, DIMENSION, DIMENSION)
    self:setZIndex(500)
    self:setCenter(0.5, 1)

    self.canMove = true
    self.isWall = true
end

function MovingTile:onCrankCompleted()
    self:setCanMove(false)
end