class("Cranking").extends(playdate.graphics.sprite)

local TRIGGER_DISTANCE <const> = 50
local MAX_CRANK_VALUE <const> = 100
local CRANK_DEPLEATION_RATE <const> = 4
local CRANK_SENSITIVITY <const> = 15

local gfx <const> = playdate.graphics
local Point <const> = playdate.geometry.point

function Cranking:init(x, y)
    Cranking.super.init(self)

    self.position = Point.new(x, y)
    self.isPlayerNear = false

    self.crankValue = 0
    self.dtCounter = 0
    self.crankMomentum = 0

    self.barWidth = 40
    self.barHeight = 6

    self.progressBar = gfx.sprite.new()
    self.progressBar:setZIndex(900)
    self:updateProgressBarImage()
    self.progressBar:setCenter(0.5, 1)
    self.progressBar:moveTo(x, y - 30)
    self.progressBar:setVisible(false)
    self.progressBar:add()

    self.roomX = math.floor(x / 400) + 1
    self.roomY = math.floor(y / 240) + 1

    self.fullCranked = false
    self.isPlayerInSameRoom = false
end

function Cranking:updatePlayerDistance(playerPosition)
    local dist = self.position:distanceToPoint(playerPosition)
    self.isPlayerNear = dist < TRIGGER_DISTANCE

    local playerRoomX = math.floor(playerPosition.x / 400) + 1
    local playerRoomY = math.floor(playerPosition.y / 240) + 1

    self.isPlayerInSameRoom = (playerRoomX == self.roomX) and (playerRoomY == self.roomY)
end

function Cranking:updateCrank(player)
    local isCranking = false

    if self.isPlayerNear then
        if playdate.isCrankDocked() then
            GameState.game.showCrank = true
        else
            self.progressBar:setVisible(true)
            local ticks = playdate.getCrankTicks(CRANK_SENSITIVITY)

            if ticks ~= 0 then
                isCranking = true
                local previousValue = self.crankValue
                self.crankValue = math.min(self.crankValue + math.abs(ticks), MAX_CRANK_VALUE)
                self.crankMomentum = math.abs(ticks)

                if previousValue < MAX_CRANK_VALUE and self.crankValue == MAX_CRANK_VALUE then
                    if self.connectedProp and self.connectedProp.onCrankCompleted then
                        self.connectedProp:onCrankCompleted()
                    end
                end
            end

            self.crankMomentum = math.max(0, self.crankMomentum - 0.2)
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
end

function Cranking:updateProgressBarImage()
    if self.crankValue <= 0 then
        self.progressBar:setVisible(false)
        return
    end

    local img = gfx.image.new(self.barWidth, self.barHeight)
    gfx.pushContext(img)

        gfx.setColor(gfx.kColorBlack)
        gfx.fillRoundRect(0, 0, self.barWidth, self.barHeight, 2)

        local fillWidth = (self.crankValue / MAX_CRANK_VALUE) * (self.barWidth - 2)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(1, 1, fillWidth, self.barHeight - 2, 2)

    gfx.popContext()
    self.progressBar:setImage(img)
end