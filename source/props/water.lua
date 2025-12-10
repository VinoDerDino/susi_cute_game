class("Water").extends(playdate.graphics.sprite)

function Water:init(x, y)
    Water.super.init(self)

    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:setZIndex(100)

    self.images = playdate.graphics.imagetable.new("assets/images/props/water")
    self.currentFrame = 1
    self.frameCounter = 0
    self:setImage(self.images:getImage(self.currentFrame))
end

function Water:update()
    self.frameCounter += 1
    if self.frameCounter >= 50 then
        self.frameCounter = 0
        self.currentFrame = self.currentFrame == 1 and 2 or 1
        self:setImage(self.images:getImage(self.currentFrame))
    end
end