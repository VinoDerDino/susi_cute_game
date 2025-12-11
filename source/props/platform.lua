import 'props/moving'

class("Platform").extends(Moving)

local Point <const> = playdate.geometry.point
local gfx <const> = playdate.graphics

local platformImageTable <const> = gfx.imagetable.new("assets/images/props/platform")
local platformImageTableLength <const> = platformImageTable:getLength()

function Platform:init(startX, startY, endX, endY)
    Platform.super.init(self, startX, startY, endX, endY)

    self:setImage(platformImageTable:getImage(1))
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
        if self.frameCounter % 5 == 0 then
            self.currentFrame += 1
            if self.currentFrame > platformImageTableLength then
                self.currentFrame = 1
            end
            self:setImage(platformImageTable:getImage(self.currentFrame))
        end
    end
    self.delta.x = self.currentPosition.x - self.lastPosition.x
    self.delta.y = self.currentPosition.y - self.lastPosition.y

    self.lastPosition.x = self.currentPosition.x
    self.lastPosition.y = self.currentPosition.y
end