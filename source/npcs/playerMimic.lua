class("PlayerMimic").extends(playdate.graphics.sprite)

local Point <const> = playdate.geometry.point

function PlayerMimic:init()
    PlayerMimic.super.init(self)

    self:setZIndex(500)
    self:setCenter(0.5, 1)

    self.images = playdate.graphics.image.new("assets/images/player/susi")
    self:setImage(self.images:getImage(1))
end

function PlayerMimic:update()

end