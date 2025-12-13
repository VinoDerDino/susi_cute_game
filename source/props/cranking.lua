class("Cranking").extends(playdate.graphics.sprite)

local TRIGGER_DISTANCE <const> = 50
local MAX_CRANK_VALUE <const> = 100
local CRANK_DEPLEATION_RATE <const> = 4
local CRANK_SENSITIVITY <const> = 15
local MOMENTUM_DECAY_PER_SECOND <const> = 0.2 * 30

local gfx <const> = playdate.graphics
local Point <const> = playdate.geometry.point

local progressBarTable <const> = gfx.imagetable.new("assets/images/props/progressbar")

function Cranking:init(x, y)
    Cranking.super.init(self)

    self.position = Point.new(x, y)
    self.isPlayerNear = false

    self.lastCrankValue = 0
    self.crankValue = 0
    self.dtCounter = 0
    self.crankMomentum = 0

    self.progressBar = gfx.sprite.new()
    self.progressBar:setImage(progressBarTable:getImage(1))
    self.progressBar:setZIndex(900)
    self.progressBar:setCenter(0.5, 1)
    self.progressBar:moveTo(x, y - 30)
    self.progressBar:setVisible(false)
    self.progressBar:add()

    self.lastProgressFrame = 1

    self.roomX = math.floor(x / 400) + 1
    self.roomY = math.floor(y / 240) + 1

    self.fullCranked = false
    self.isPlayerInSameRoom = false
    self.crankValueChanged = false
end

function Cranking:updatePlayerDistance(playerPosition)
    local dist = self.position:distanceToPoint(playerPosition)
    self.isPlayerNear = dist < TRIGGER_DISTANCE

    -- local playerRoomX = math.floor(playerPosition.x / 400) + 1
    -- local playerRoomY = math.floor(playerPosition.y / 240) + 1

    -- self.isPlayerInSameRoom = (playerRoomX == self.roomX) and (playerRoomY == self.roomY)
end

function Cranking:updateCrank()
    local isCranking = false

    if self.isPlayerNear then
        if playdate.isCrankDocked() then
            GameState.game.showCrank = true
        else
            self.progressBar:setVisible(true)
            local ticks = playdate.getCrankTicks(CRANK_SENSITIVITY)

            if ticks ~= 0 then
                isCranking = true
                self.lastCrankValue = self.crankValue
                self.crankValue = math.min(self.crankValue + math.abs(ticks), MAX_CRANK_VALUE)
                self.crankMomentum = math.abs(ticks)
            end

            self.crankMomentum = math.max(0, self.crankMomentum - 0.333)
        end
     end

    if not isCranking then
        self.dtCounter += 1
        if self.dtCounter >= CRANK_DEPLEATION_RATE then
            self.dtCounter = 0
            if self.crankValue > 0 then
                self.crankValue -= 1
            end
        end
    else
        self.dtCounter = 0
    end

    if self.crankValue >= MAX_CRANK_VALUE then
        self.fullCranked = true
        if self.connectedProp and self.connectedProp.onCrankCompleted then
            self.connectedProp:onCrankCompleted()
        end
    end

    self.crankValueChanged = (self.lastCrankValue ~= self.crankValue)
end

function Cranking:updateProgressBarImage()
    if self.crankValue <= 0 then
        self.progressBar:setVisible(false)
        return
    end

    self.progressBar:setVisible(true)

    local frameCount = 36
    local index = math.floor((self.crankValue / MAX_CRANK_VALUE) * (frameCount - 1)) + 1

    if index < 1 then index = 1 end
    if index > frameCount then index = frameCount end

    if self.lastProgressFrame ~= index then
        self.progressBar:setImage(progressBarTable:getImage(index))
        self.lastProgressFrame = index
    end
end