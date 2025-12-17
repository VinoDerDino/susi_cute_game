import "props/cranking"

class("Twine").extends(Cranking)

local SEGMENT_HEIGHT <const> = 20

local gfx <const> = playdate.graphics

local twineImageTable <const> = gfx.imagetable.new("assets/images/props/twine")

function Twine:init(x, y, endY)
    Twine.super.init(self, x, y)

    self:setImage(twineImageTable:getImage(1))
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

    self.lastCrankZone = "idle"

    self.isTwine = true
end

function Twine:destroy()
    Twine.super.destroy(self)
    gfx.sprite.removeSprites(self.segments)
end

function Twine:updateCollideRect()
    local totalHeight = self.startHeight - self.currentHeight + 20
    self:setCollideRect(0, 0, 20, totalHeight)
end

function Twine:spawnStemSegment(yPosition)
    self.timer += 1
    local index = (self.timer % 2 == 0) and 5 or 6
    local segment = gfx.sprite.new()

    segment:setImage(twineImageTable:getImage(index))
    segment:setCenter(0.5, 1)
    segment:moveTo(self.x, yPosition)
    segment:setZIndex(499)
    segment:add()

    table.insert(self.segments, segment)

    SoundManager:playSound(SoundManager.kGrow)
end

function Twine:getCrankZone()
    if self.crankValue > 75 then
        return "high"
    elseif self.crankValue > 50 then
        return "mid"
    elseif self.crankValue > 25 then
        return "low"
    else
        return "idle"
    end
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
            self.idleTimer += 1
            if self.idleTimer >= 8 then
                self.idleTimer = 0
                self.idleImageIndex += 1
                if self.idleImageIndex > 3 then
                    self.idleImageIndex = 1
                end
                self:setImage(twineImageTable:getImage(self.idleImageIndex))
            end

            local zone = self:getCrankZone()

            if zone ~= self.lastCrankZone then
                if zone == "low" then
                    SoundManager:playSound(SoundManager.kPlantLow)
                elseif zone == "mid" then
                    SoundManager:playSound(SoundManager.kPlantMid)
                elseif zone == "high" then
                    SoundManager:playSound(SoundManager.kPlantHigh)
                end

                self.lastCrankZone = zone
            end
        end
    elseif not self.fullGrown then
        self.progressBar:setVisible(false)
    end
end

function Twine:grow()
    if self.fullGrown then return end

    if self.currentHeight <= self.targetHeight then
        self:setImage(twineImageTable:getImage(7))
        self.fullGrown = true
        self:updateCollideRect()
        return
    end

    if self.phase == 0 then
        self.phase = 1
        self:setImage(twineImageTable:getImage(4))
        return
    end

    if self.phase == 1 or self.phase == 2 then
        self.phase = 2
        self.currentHeight -= SEGMENT_HEIGHT
        self:moveTo(self.x, self.currentHeight)
        self:spawnStemSegment(self.currentHeight + SEGMENT_HEIGHT)
        self:updateCollideRect()

        if self.currentHeight <= self.targetHeight then
            self:setImage(twineImageTable:getImage(7))
            self.fullGrown = true
        else
            self:setImage(twineImageTable:getImage(4))
        end
    end
end