class("SpikeHitbox").extends(playdate.graphics.sprite)


function SpikeHitbox:init(x, y, width, height, spawnX, spawnY)
    SpikeHitbox.super.init(self)

    self:setSize(width, height)
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:setCollideRect(0, 0, width, height)
    self:setVisible(false)

    self.spawnPoint = playdate.geometry.point.new(spawnX, spawnY)
end