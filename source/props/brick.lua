class("Brick").extends(playdate.graphics.sprite)

local DIMENSION <const> = 20

function Brick:init(x, y)
    local trueX, trueY = x + DIMENSION / 2, y + DIMENSION

    self:setImage(playdate.graphics.image.new("assets/images/spritesheets/brick"))

    self:setCollideRect(0, 0, DIMENSION, DIMENSION)
    self:setCenter(0.5, 1)
    self:setZIndex(500)
    self:moveTo(trueX, trueY)

    self.isWall = true

    EventSystem:addListener(self)

    print("Brick placed at:", x, y)
end

function Brick:catchEvent(eventName, data)
    if eventName == "rescueSandy" then
        self:remove()
        print("Brick removed after rescuing Sandy")
    end
end