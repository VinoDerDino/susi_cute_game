class("Spring").extends(playdate.graphics.sprite)

local HALF_DIMENSION <const> = 10
local springImageTable <const> = playdate.graphics.imagetable.new("assets/images/props/spring")

function Spring:init(x, y, strength)
    Spring.super.init(self)

    self.currentImageIndex = 1 
    self:setImage(springImageTable:getImage(self.currentImageIndex))
    self:setCenter(0.5, 1)
    self:setCollideRect(0, 0, 20, 20)
    self:setZIndex(500)
    self:moveTo(x, y)

    self.strength = strength
    self.isPlayerOnTop = false
    self.wasPlayerOnTop = false
    self.timer = 0
    self.refractoryTime = 5

    self.isSpring = true

    self.springLeft = self.x - HALF_DIMENSION
    self.springRight = self.x + HALF_DIMENSION
end

function Spring:update()
    if self.isPlayerOnTop and not self.wasPlayerOnTop then
        self.timer = 0
        self.wasPlayerOnTop = true
    elseif self.wasPlayerOnTop then
        self.isPlayerOnTop = false
        self.timer += 1
        if self.timer >= self.refractoryTime then
            self.wasPlayerOnTop = false
        end
    end

    local newImageIndex = self.wasPlayerOnTop and 2 or 1
    if self.currentImageIndex ~= newImageIndex then
        self.currentImageIndex = newImageIndex
        self:setImage(springImageTable:getImage(self.currentImageIndex))
    end
end