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
    self.downSpeed = 0.5
    self.upSpeed = 0.3

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
    if self.isPlayerOnTop and self.progress < 1 then
        self.progress = math.min(self.progress + self.downSpeed / 100, 1)
    elseif not self.isPlayerOnTop and self.progress > 0 then
        self.progress = math.max(self.progress - self.upSpeed / 100, 0)
    end

    local newY = self.startY + (self.endY - self.startY) * self.progress
    self:moveTo(self.x, newY)

    self:updateImage()
end

function FloatingPlatform:updateImage()
    local imageIndex = math.floor(self.progress * 4) + 1
    imageIndex = math.min(imageIndex, 5)
    self:setImage(self.images:getImage(imageIndex))
end