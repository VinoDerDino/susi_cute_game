class("LevelPickerScreen").extends(playdate.graphics.sprite)

import 'util/levelOverview'

local LEVEL_COUNT <const> = 2

function LevelPickerScreen:init()
    LevelPickerScreen.super.init(self)

    self.levels = {
        level1 = LevelOverview({name = "1. Hilf Sandy!", levelIndex = 1, sockIndexes = {1, 2, 3, 4, 5}, enabled = GameState.data.level.level1}),
        level2 = LevelOverview({name = "2. Verstecke", levelIndex = 2, sockIndexes = {6, 7, 8, 9, 10}, enabled = GameState.data.level.level2}),
    }

    self.lastLevelIndex = 1
    self.currentLevelIndex = 1

    self.inEnterTransition = false
    self.inTransition = false

    self:setZIndex(0)
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
        end
    elseif playdate.buttonJustPressed(playdate.kButtonRight) then
        self.lastLevelIndex = self.currentLevelIndex
        self.currentLevelIndex = self.currentLevelIndex + 1
        if self.currentLevelIndex > LEVEL_COUNT then
            self.currentLevelIndex = LEVEL_COUNT
        end
        if self.lastLevelIndex ~= self.currentLevelIndex then
            self.inTransition = true
        end
    elseif playdate.buttonJustPressed(playdate.kButtonA) then
        GameState:setCurrentLevel(self.currentLevelIndex)
        GameState:setState(GameState.states.LEVEL)
    end
end

function LevelPickerScreen:setLevelTransitions()
    local direction = (self.currentLevelIndex > self.lastLevelIndex) and 1 or -1

    for _, level in pairs(self.levels) do
        level:setNewPos(direction)
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

function LevelPickerScreen:update()
    self:updateLevelSelection()
    self:transition()
    self:updateLevelOverviews()
end

function LevelPickerScreen:draw()
    for _, level in pairs(self.levels) do
        level:draw()
    end
end