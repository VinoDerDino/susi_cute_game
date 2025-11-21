import "props/cranking"

class("Twine").extends(Cranking)

local SEGMENT_HEIGHT <const> = 20

local gfx <const> = playdate.graphics

function Twine:init(x, y, endY)
    Twine.super.init(self, x, y)

    self.images = gfx.imagetable.new("assets/images/spritesheets/twine")
    self:setImage(self.images:getImage(1))
    self:setZIndex(500)
    self:setCenter(0.5, 1)
    self:setCollideRect(0, 0, 20, 20)
    self:moveTo(x, y)

    self.targetHeight = endY
    self.currentHeight = y
    self.startHeight = y
    self.phase = 0
    self.timer = 0
    self.fullGrown = false
    self.segments = {}
    self.growthFrameCounter = 0

    self.idleTimer = 0
    self.idleImageIndex = 1
end

function Twine:updateCollideRect()
    local totalHeight = self.startHeight - self.currentHeight + 20
    self:setCollideRect(0, 0, 20, totalHeight)
end

function Twine:spawnStemSegment(yPosition)
    self.timer += 1
    local index = (self.timer % 2 == 0) and 5 or 6
    local segment = gfx.sprite.new()

    segment:setImage(self.images:getImage(index))
    segment:setCenter(0.5, 1)
    segment:moveTo(self.x, yPosition)
    segment:setZIndex(499)
    segment:add()

    table.insert(self.segments, segment)

    SoundManager:playSound(SoundManager.kGrow)
end

function Twine:update()
    if not self.fullGrown and GameState.data.unlocked.twineGrowth then
        self:updateCrank(GameState.game.currentLevel.player)
        if self.fullCranked then
            self.growthFrameCounter += 1
            if self.growthFrameCounter >= 14 then
                self:grow()
                self.growthFrameCounter = 0
            end
            self.progressBar:setVisible(false)
        else
            self:updateProgressBarImage()
        end
    else
        self.progressBar:setVisible(false)
        self.idleTimer += 1
        if self.idleTimer >= 20 then
            self.idleTimer = 0
            self.idleImageIndex += 1
            if self.idleImageIndex > 3 then
                self.idleImageIndex = 1
            end
            self:setImage(self.images:getImage(self.idleImageIndex))
        end
    end
end

function Twine:grow()
    if self.fullGrown then return end

    if self.currentHeight <= self.targetHeight then
        self:setImage(self.images:getImage(7))
        self.fullGrown = true
        self:updateCollideRect()
        return
    end

    if self.phase == 0 then
        self.phase = 1
        self:setImage(self.images:getImage(4))
        return
    end

    if self.phase == 1 or self.phase == 2 then
        self.phase = 2
        self.currentHeight -= SEGMENT_HEIGHT
        self:moveTo(self.x, self.currentHeight)
        self:spawnStemSegment(self.currentHeight + SEGMENT_HEIGHT)
        self:updateCollideRect()

        if self.currentHeight <= self.targetHeight then
            self:setImage(self.images:getImage(7))
            self.fullGrown = true
        else
            self:setImage(self.images:getImage(4))
        end
    end
end