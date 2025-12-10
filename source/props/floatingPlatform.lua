class("FloatingPlatform").extends(playdate.graphics.sprite)

local HALF_DIMENSION <const> = 10

function FloatingPlatform:init(x, y, endY)
    FloatingPlatform.super.init(self)

    self.images = playdate.graphics.imagetable.new("assets/images/props/floating_platform")
    self:setImage(self.images:getImage(1))
    self:setCenter(0.5, 1)
    self:setCollideRect(0, 0, 20, 20)
    self:setZIndex(500)

    self.isPlayerOnTop = false
    self.startY = y
    self.endY = endY
    self.progress = 0
    self.speedDown = 0.5
    self.speedUp = 0.3

    self:moveTo(x, y)
end

function FloatingPlatform:updatePlayerDistance(playerPosition)
    local platformLeft = self.x - HALF_DIMENSION
    local platformRight = self.x + HALF_DIMENSION

    local playerLeft = playerPosition.x - HALF_DIMENSION
    local playerRight = playerPosition.x + HALF_DIMENSION

    local horizontalOverlap = playerRight > platformLeft and playerLeft < platformRight
    local verticalDistance = self.y - playerPosition.y - 20

    local isOnTop = verticalDistance >= 0 and verticalDistance < 2
    self.isPlayerOnTop = horizontalOverlap and isOnTop
end

function FloatingPlatform:update()
    local newY = self.y

    if self.isPlayerOnTop then
        newY = math.min(self.y + self.speedDown, self.endY)
    else
        newY = math.max(self.y - self.speedUp, self.startY)
    end

    self:moveTo(self.x, newY)
    self:updateImage()
end

function FloatingPlatform:updateImage()
    local ratio = (self.y - self.startY) / (self.endY - self.startY)
    ratio = math.max(0, math.min(ratio, 1))

    local imageIndex = math.floor(ratio * 4) + 1
    imageIndex = math.min(imageIndex, 5)

    self:setImage(self.images:getImage(imageIndex))
end