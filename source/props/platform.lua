import 'props/moving'

class("Platform").extends(Moving)

local Point <const> = playdate.geometry.point
local gfx <const> = playdate.graphics

function Platform:init(startX, startY, endX, endY)
    Platform.super.init(self, startX, startY, endX, endY)

    self.images = gfx.imagetable.new("assets/images/props/platform")
    self:setImage(self.images:getImage(1))
    self:setZIndex(500)
    self:setCenter(0.5, 1)
    self:setCollideRect(0, 0, 20, 10)

    self.frameCounter = 0
    self.currentFrame = 1

    self.delta = Point.new(0, 0)
    self.lastPosition = Point.new(startX, startY)

    self.isPlatform = true
end

function Platform:update()
    if self.lastPosition.x ~= self.currentPosition.x or self.lastPosition.y ~= self.currentPosition.y then
        self.frameCounter += 1
        if self.frameCounter % 5 then
            self.currentFrame += 1
            if self.currentFrame > self.images:getLength() then
                self.currentFrame = 1
            end
            self:setImage(self.images:getImage(self.currentFrame))
        end
    end
    self.delta = Point.new(
        self.currentPosition.x - self.lastPosition.x,
        self.currentPosition.y - self.lastPosition.y
    )

    self.lastPosition = Point.new(self.currentPosition.x, self.currentPosition.y)
end

function Platform:debugDraw()
    local roomX = math.floor(self.x / 400)
    local roomY = math.floor(self.y / 240)

    local r = self:getCollideRect()
    local sx, sy = self:getPosition()
    local cx, cy = self:getCenter()
    local w, h = self:getSize()

    local x = (sx - (w * cx) + r.x) - 400 * roomX
    local y = (sy - (h * cy) + r.y) - 240 * roomY

    playdate.graphics.drawRect(x, y, r.width, r.height)
end