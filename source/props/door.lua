import 'props/moving'

class("Door").extends(Moving)

local TILE_SIZE <const> = 20

local gfx <const> = playdate.graphics

function Door:init(x, y, height, emitEvent)
    local endY = y + height
    Door.super.init(self, x, y, x, endY)

    self.height = height
    self:setCenter(0.5, 0)
    self:setSize(TILE_SIZE, self.height)
    self:setCollideRect(0, 0, TILE_SIZE, self.height)

    if emitEvent == "" then emitEvent = nil end
    self.emitEvent = emitEvent
    self.alreadyEmitted = false

    self.nineSlice = gfx.nineSlice.new("assets/images/props/door.png", 2, 2, 16, 16)
    self.sliceRect = playdate.geometry.rect.new(0, 0, TILE_SIZE, self.height)
end

function Door:onCrankCompleted()
    if self.alreadyEmitted then return end
    self.alreadyEmitted = true
    if self.emitEvent then
        EventSystem:emitEvent(self.emitEvent)
    end
    self:remove()
end

function Door:draw(x, y, width, height)
    local currentY = self.y
    local progress = math.abs(currentY - self.startingPosition.y) / self.height

    local visibleHeight = self.height * (1 - progress)
    self.sliceRect.height = visibleHeight
    self.sliceRect.y = 0

    self.nineSlice:drawInRect(self.sliceRect)
end