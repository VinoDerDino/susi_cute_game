class("LevelPickerScreen").extends(playdate.graphics.sprite)

import 'util/levelOverview'

local LEVEL_COUNT <const> = 2

function LevelPickerScreen:init()
    LevelPickerScreen.super.init(self)

    self.levels = {
        level1 = LevelOverview({name = "Tag 1: Hilf Sandy!", levelIndex = 1, sockIndexes = {1, 2, 3, 4, 5}, enabled = GameState.data.level.level1}),
        level2 = LevelOverview({name = "Tag 2: Verstecke", levelIndex = 2, sockIndexes = {6, 7, 8, 9, 10}, enabled = GameState.data.level.level2}),
    }

    self.lastLevelIndex = 1
    self.currentLevelIndex = 1

    self.inEnterTransition = false
    self.inTransition = false

    self:setZIndex(0)
    self._y = 240
    self:moveTo(0, self._y)

    self.intro = false
    self.outro = false
end

function LevelPickerScreen:show()
    self.lastLevelIndex = 1
    self.currentLevelIndex = 1
    for _, level in pairs(self.levels) do
        level:reset()
        level:add()
    end

    self:add()
end

function LevelPickerScreen:hide()
    for _, level in pairs(self.levels) do
        level:remove()
    end

    self:remove()
end

function LevelPickerScreen:updateLevelSelection()
    if self.inTransition then return end

    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        self.lastLevelIndex = self.currentLevelIndex
        self.currentLevelIndex = self.currentLevelIndex - 1
        if self.currentLevelIndex < 1 then
            self.currentLevelIndex = 1
        end
        if self.lastLevelIndex ~= self.currentLevelIndex then
            self.inTransition = true
            SoundManager:playSound(SoundManager.kMenuMove)
        end
    elseif playdate.buttonJustPressed(playdate.kButtonRight) then
        self.lastLevelIndex = self.currentLevelIndex
        self.currentLevelIndex = self.currentLevelIndex + 1
        if self.currentLevelIndex > LEVEL_COUNT then
            self.currentLevelIndex = LEVEL_COUNT
        end
        if self.lastLevelIndex ~= self.currentLevelIndex then
            self.inTransition = true
            SoundManager:playSound(SoundManager.kMenuMove)
        end
    elseif playdate.buttonJustPressed(playdate.kButtonA) then
        SoundManager:playSound(SoundManager.kButtonA)
        local level = self.levels["level" .. tostring(self.currentLevelIndex)]
        if not level.enabled then
            return
        end
        GameState:setCurrentLevel(self.currentLevelIndex)
        GameState:setState(GameState.states.LEVEL)
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        SoundManager:playSound(SoundManager.kButtonB)
        GameState:setState(GameState.states.MENU)
    end
end

function LevelPickerScreen:setLevelTransitions()
    local direction = (self.currentLevelIndex > self.lastLevelIndex) and 1 or -1

    for _, level in pairs(self.levels) do
        level:setNewPos(direction, self._y)
    end
end

function LevelPickerScreen:transition()
    if self.inEnterTransition then return end
    if not self.inTransition then return end

    self:setLevelTransitions()

    self.inTransition = false
end

function LevelPickerScreen:updateLevelOverviews()
    for _, level in pairs(self.levels) do
        level:update()
    end
end

function LevelPickerScreen:introAnimation()
    self._y -= GameState.consts.intro_speed
    if self._y <= 0 then
        self._y = 0
        self.intro = false
    end
    for _, level in pairs(self.levels) do
        level:setNewPosY(self._y)
    end
    self:moveTo(0, self._y)
end

function LevelPickerScreen:outroAnimation()
    self._y += GameState.consts.intro_speed
    if self._y >= 240 then
        self._y = 240
        self.outro = false
        self:hide()
    end
    for _, level in pairs(self.levels) do
        level:setNewPosY(self._y)
    end
    self:moveTo(0, self._y)
end

function LevelPickerScreen:startIntro()
    self:show()
    self.intro = true
    self.outro = false
    self._y = 240
end

function LevelPickerScreen:startOutro()
    self.outro = true
    self.intro = false
    self._y = 0
end

function LevelPickerScreen:update()
    if self.intro then
        self:introAnimation()
    elseif self.outro then
        self:outroAnimation()
    end
    self:updateLevelSelection()
    self:transition()
    self:updateLevelOverviews()
end

function LevelPickerScreen:draw()
end