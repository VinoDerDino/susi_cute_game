class("Spring").extends(playdate.graphics.sprite)

local HALF_DIMENSION <const> = 10

function Spring:init(x, y, strength)
    Spring.super.init(self)

    self.images = playdate.graphics.imagetable.new("assets/images/props/spring")
    self:setImage(self.images:getImage(1))
    self:setCenter(0.5, 1)
    self:setCollideRect(0, 0, 20, 20)
    self:setZIndex(500)
    self:moveTo(x, y)

    self.strength = strength
    self.isPlayerOnTop = false
    self.wasPlayerOnTop = false
    self.timer = 0
    self.refractoryTime = 5
end

function Spring:updatePlayerDistance(playerPosition)
    local springLeft = self.x - HALF_DIMENSION
    local springRight = self.x + HALF_DIMENSION

    local playerLeft = playerPosition.x - HALF_DIMENSION
    local playerRight = playerPosition.x + HALF_DIMENSION

    local horizontalOverlap = playerRight > springLeft and playerLeft < springRight
    local verticalDistance = self.y - playerPosition.y - 20

    local isOnTop = verticalDistance >= 0 and verticalDistance < 2
    self.isPlayerOnTop = horizontalOverlap and isOnTop
end

function Spring:update()
    if self.isPlayerOnTop and not self.wasPlayerOnTop then
        self.timer = 0
        self.wasPlayerOnTop = true
    elseif self.wasPlayerOnTop then
        self.timer += 1
        if self.timer >= self.refractoryTime then
            self.wasPlayerOnTop = false
        end
    end

    if self.wasPlayerOnTop then
        self:setImage(self.images:getImage(2))
    else
        self:setImage(self.images:getImage(1))
    end
end