class("Spike").extends(playdate.graphics.sprite)

local Point <const> = playdate.geometry.point

local gfx <const> = playdate.graphics

function Spike:init(x, y, spawnX, spawnY, rotation)
    Spike.super.init(self)

    self.images = playdate.graphics.imagetable.new("assets/images/props/rhababer")
    self:setImage(self.images:getImage(1))

    self:setCenter(0.5, 1)
    self:moveTo(x, y)
    self:setZIndex(800)

    if rotation then
        self:setRotation(rotation)
        if rotation == 90 then
            self:setCollideRect(4, 2, 16, 16)
        elseif rotation == -90 then
            self:setCollideRect(0, 2, 16, 16)
        end
    else
        self:setCollideRect(2, 4, 16, 16)
    end

    self.spawnPoint = Point.new(spawnX, spawnY)

    self.dt = 0
    self.currentSprite = 1
end

function Spike:update()
    self.dt += 1
    if self.dt >= 10 then
        self.dt = 0
        self.currentSprite += 1
        if self.currentSprite > self.images:getLength() then
            self.currentSprite = 1
        end
        self:setImage(self.images:getImage(self.currentSprite))
    end
end