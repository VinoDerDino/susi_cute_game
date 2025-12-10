import 'level/levelLoader'
import 'player'
import 'npcs/sandy'

class('Level').extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local PD_WIDTH <const> = playdate.display.getWidth()
local PD_HEIGHT <const> = playdate.display.getHeight()

function Level:init(levelPath)
    Level.super.init(self)
    self:setZIndex(0)

    local jsonTable = getJSONTableFromTiledFile(levelPath)
    self.layers = importTilemapsFromTiledJSON(jsonTable)
    if not self.layers then
        print("ERROR: Level data could not be loaded from " .. levelPath)
        return
    end

    local properties = getMapPropertiesFromTiledJSON(jsonTable)
    local unlocks = {
        twineGrowth = properties.twineGrowth or false,
        cranking = properties.cranking or false,
    }
    GameState:setMultiUnlocks(unlocks)

    self.objects = importObjectsFromTiledJSON(jsonTable)
    self.triggers = importTriggersFromTiledJSON(jsonTable)
    self.spikes = importSpikesFromTiledJSON(jsonTable)

    self.walls = self.layers["walls"]
    self.wallSprites = {}
    self.deco = self.layers["deco"] or {}

    self.WorldWidth = self.walls.pixelWidth
    self.WorldHeight = self.walls.pixelHeight

    self.activeRoomX = 1
    self.activeRoomY = 1

    if self.walls then
        self:setBounds(0, 0, self.walls.pixelWidth, self.walls.pixelHeight)
    end

    self.sandy = Sandy(getSandyConfig(jsonTable))
    self.player = Player(properties.playerSpawnX or 20, properties.playerSpawnY or 20)
end

function Level:open()
    self:setupWalls()
    self:setupObjects()
    self:setupSpikes()
    self:setupTriggers()
    self.player:add()
    if self.sandy then
        self.sandy:add()
    end
    self:add()
    self.runStartTime = playdate.getCurrentTimeMilliseconds()
end

function Level:close()
    if self.player then
        gfx.sprite.removeSprite(self.player)
        self.player = nil
    end

    if self.sandy then
        self.sandy:destroy()
        gfx.sprite.removeSprite(self.sandy)
        self.sandy = nil
    end

    if self.triggers then
        for i, trigger in ipairs(self.triggers) do
            if trigger and trigger.remove then
                gfx.sprite.removeSprite(trigger)
            end
        end
        self.triggers = nil
    end

    if self.objects then
        for i, obj in ipairs(self.objects) do
            if obj and obj.remove then
                if obj.destory then
                    obj:destroy()
                end
                gfx.sprite.removeSprite(obj)
            end
        end
        self.objects = nil
    end

    if self.walls and self.walls.tilemap then
        local wallSprites = self.walls.tilemap.wallSprites
        if wallSprites then
            for i = 1, #wallSprites do
                if wallSprites[i] and wallSprites[i].remove then
                    gfx.sprite.removeSprite(wallSprites[i])
                end
            end
        end
    end
    self.walls = nil

    if self.wallSprites then
        gfx.sprite.removeSprites(self.wallSprites)
        self.wallSprites = nil
    end

    if self.spikes then
        for i, spike in ipairs(self.spikes) do
            if spike and spike.remove then
                spike:remove()
            end
        end
        self.spikes = nil
    end

    self.deco = nil

    self:remove()
end

function Level:setupWalls()
    local tilemap = self.walls.tilemap
	self.wallSprites = gfx.sprite.addWallSprites(tilemap, {})
	for i = 1, #self.wallSprites do
		local w = self.wallSprites[i]
		w.isWall = true
	end
end

function Level:setupObjects()
    for i, obj in ipairs(self.objects) do
        obj:add()
    end
end

function Level:setupSpikes()
    for i, spike in ipairs(self.spikes) do
        spike:add()
    end
end

function Level:setupTriggers()
    if not self.triggers then return end

    for i, trigger in ipairs(self.triggers) do
        trigger:add()
    end
end

function Level:movePlayer()

    if self.player.position.x < 0 then
        self.player.position.x = 0
        self.player.velocity.x = 0
    elseif self.player.position.x > self.WorldWidth then
        self.player.position.x = self.WorldWidth
        self.player.velocity.x = 0
    end

    if self.player.position.y < 18 then
        self.player.position.y = 18
        self.player.velocity.y = 0
    elseif self.player.position.y > self.WorldHeight then
        self.player.position.y = self.WorldHeight
        self.player.velocity.y = -100
        SoundManager:playSound(SoundManager.kHeadbut)
    end

    local collisions, len
    self.player.position.x , self.player.position.y, collisions, len = self.player:moveWithCollisions(self.player.position)
    local playerWasOnGround = self.player.onGround

    self.player:setOnGround(false)
    self.player:setClimbing(false)
    self.player:setInteracting(false)
    self.player:setOnPlatform(nil)

    local playerCanRespawn = true

    for i = 1, len do
        local c = collisions[i]

        if c.other.isWall then
            if c.normal.y < 0 then
                self.player:setOnGround(true)
                self.player.velocity.y = 0
            elseif c.normal.y > 0 then
                self.player.velocity.y = 100
                if not self.player.isClimbing then
                    SoundManager:playSound(SoundManager.kHeadbut)
                end
            end
        elseif c.other.isPlatform then
            playerCanRespawn = false
            if c.normal.y < 0 then
                self.player:setOnGround(true)
                self.player:setOnPlatform(c.other)
                self.player.velocity.y = math.min(self.player.velocity.y, 0)
                self.player.position.x += c.other.delta.x
            elseif c.normal.y > 0 then
                if not self.player.isClimbing then
                    SoundManager:playSound(SoundManager.kHeadbut)
                end
                if self.player.velocity.y < 0 and self.player.y > c.other.y then
                    self.player.velocity.y = 100
                end
            end
        elseif c.other:isa(FloatingPlatform) then
            playerCanRespawn = false
            if c.normal.y < 0 then
                self.player:setOnGround(true)
                self.player.velocity.y = 0
            elseif c.normal.y > 0 then
                self.player.velocity.y = 100
                SoundManager:playSound(SoundManager.kHeadbut)
            end
        elseif c.other:isa(Spring) then
            playerCanRespawn = false
            if c.normal.y < 0 then
                self.player.velocity.y = -c.other.strength
                SoundManager:playSound(SoundManager.kSpring)
            elseif c.normal.y > 0 then
                self.player.velocity.y = 100
                SoundManager:playSound(SoundManager.kHeadbut)
            end
        elseif c.other:isa(Twine) then
            if c.other.fullGrown then
                self.player:setClimbing(true)
            end
        elseif c.other:isa(TriggerBox) then
            c.other:handleTrigger()
        elseif c.other:isa(Spike) then
            local respawnPoint = c.other.spawnPoint
            if respawnPoint then
                self.player:respawn(respawnPoint.x, respawnPoint.y)
            else
                self.player:respawn()
            end
        elseif c.other:isa(SockProp) then
            c.other:hit()
        end
    end

    if playerCanRespawn and self.player.onGround then
        self.player:setRespawnPoint(self.player.position.x, self.player.position.y)
    end

    if not playerWasOnGround and self.player.onGround then
        SoundManager:playSound(SoundManager.kLand)
    end
end

function Level:updateRoomPosition()
    local newRoomX = math.floor(self.player.position.x / PD_WIDTH) + 1
    local newRoomY = math.floor(self.player.position.y / PD_HEIGHT) + 1

    if newRoomX ~= self.activeRoomX or newRoomY ~= self.activeRoomY then
        self.activeRoomX = newRoomX
        self.activeRoomY = newRoomY

        gfx.sprite.addDirtyRect(0, 0, PD_WIDTH, PD_HEIGHT)
        gfx.setDrawOffset(-((self.activeRoomX - 1) * PD_WIDTH), -((self.activeRoomY - 1) * PD_HEIGHT))
    end
end

function Level:interact()
    if self.sandy and playdate.buttonJustPressed(playdate.kButtonDown) and self.player.onGround then
        self.sandy:interact()
    end
end

function Level:updateObjects()
    for _, obj in ipairs(self.objects) do
        if obj.updatePlayerDistance then
            obj:updatePlayerDistance(self.player.position)
        end
    end
end

function Level:setZIndexForObjects(zIndex)
    for _, obj in ipairs(self.objects) do
        obj:setZIndex(zIndex)
    end

    for _, spike in ipairs(self.spikes) do
        spike:setZIndex(zIndex)
    end
end

function Level:update()
    if self.sandy then
        if self.sandy.dialogueBox and self.sandy.dialogueBox.enabled then
            self.sandy:setZIndex(-1)
            self.player:setZIndex(-1)
            self.player:setMovementEnabled(false)
            self:setZIndexForObjects(-1)
            self.sandy.dialogueBox:update()
        else
            self:setZIndexForObjects(500)
            self.sandy:setZIndex(900)
            self.player:setZIndex(1000)
            self.player:setMovementEnabled(true)
        end
    end
    self:movePlayer()
    self:updateObjects()
    if self.sandy then
        self.sandy:updatePlayerDistance(self.player.position)
    end
    self:interact()
    self:updateRoomPosition()
end

function Level:draw(x, y, width, height)
    if self.walls and self.walls.tilemap then
        self.walls.tilemap:draw(0, 0)
    end

    if self.deco and self.deco.tilemap then
        self.deco.tilemap:draw(0, 0)
    end

    if self.sandy and self.sandy.dialogueBox and self.sandy.dialogueBox.enabled then
        self.sandy.dialogueBox:draw(0 + (self.activeRoomX - 1) * PD_WIDTH, 190 + (self.activeRoomY - 1) * PD_HEIGHT)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end

    self:drawTimer()
end

function Level:drawTimer()
    if not GameState.data.settings.speedrunTimer then return end
    local time = playdate.getCurrentTimeMilliseconds() - self.runStartTime
    local seconds = math.floor(time / 1000)
    local ms = math.floor((time % 1000) / 10)

    gfx.drawText(string.format("%02d:%02d.%02d",
        seconds // 60,
        seconds % 60,
        ms
    ), PD_WIDTH - 65 + (self.activeRoomX - 1) * PD_WIDTH, 2 + (self.activeRoomY - 1) * PD_HEIGHT)
end