import 'props/moving'

class("MovingTile").extends(Moving)

local DIMENSION <const> = 20

local movingTileImage <const> = playdate.graphics.image.new("assets/images/props/movingTile")

function MovingTile:init(startX, startY, endX, endY)
    local trueX, trueY = startX + DIMENSION / 2, startY + DIMENSION

    MovingTile.super.init(self, trueX, trueY, endX, endY)

    self:setImage(movingTileImage)

    self:setCollideRect(0, 0, DIMENSION, DIMENSION)
    self:setZIndex(500)
    self:setCenter(0.5, 1)

    self.isWall = true
end

function MovingTile:onCrankCompleted()
    self:setCanMove(false)
end