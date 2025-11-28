import 'level/level'
import 'util/sock'

import 'screens/menuScreen'
import 'screens/sockScreen'
import 'screens/levelPickerScreen'

local gfx <const> = playdate.graphics

local GameState = {}
GameState.filename = "susi_game_state"

GameState.data = {
    unlocked = {
        cranking = false,
        twineGrowth = false,
    },
    settings = {
        speedrunTimer = false,
    },
    level = {
        level1 = true,
        level2 = false,
    },
    socks = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
        [6] = false,
        [7] = false,
        [8] = false,
        [9] = false,
        [10] = false,
        [11] = false,
        [12] = false,
        [13] = false,
        [14] = false,
        [15] = false,
        [16] = false,
        [17] = false,
        [18] = false,
        [19] = false,
        [20] = false,
        [21] = false,
        [22] = false,
        [23] = false,
        [24] = false,
        [25] = false,
    },
}

GameState.game = {
    currentLevel = nil,
    sockScreen = nil,
    menuScreen = nil,
    levelMenuScreen = nil,
}

GameState.states = {
    MENU = 1,
    SOCKS = 2,
    LEVEL_MENU = 3,
    LEVEL = 4,
}

GameState.socks = {}

GameState.currentState = nil

function GameState:load()
    local ok, t = pcall(playdate.datastore.read, self.filename)
    if ok and type(t) == "table" then
        self.data = t
    end
end

function GameState:save()
    pcall(playdate.datastore.write, self.data, self.filename)
end

function GameState:setMultiUnlocks(unlockTable)
    for key, value in pairs(unlockTable) do
        self.data.unlocked[key] = value
    end
    -- self:save()
end

function GameState:unlock(key)
    self.data.unlocked[key] = true
    -- self:save()
end

function GameState:lock(key)
    self.data.unlocked[key] = nil
    -- self:save()
end

function GameState:isUnlocked(key)
    return self.data.unlocked[key] == true
end

function GameState:setSetting(key, value)
    self.data.settings[key] = value
    -- self:save()
end

function GameState:getSetting(key, default)
    if self.data.settings[key] ~= nil then return self.data.settings[key] end
    return default
end

function GameState:setCurrentLevel(levelId)
    local levelPaths = {
        "assets/maps/level_1.json",
        "assets/maps/level_2.json",
    }

    if levelPaths[levelId] then
        self.game.currentLevel = Level(levelPaths[levelId])
    else
        self.game.currentLevel = nil
    end
end

function GameState:setState(state)
    if self.currentState == state then return end

    if self.currentState == self.states.LEVEL then
        if self.game.currentLevel then
            self.game.currentLevel:close()
            self.game.currentLevel = nil
        end
    elseif self.currentState == self.states.MENU then
        if self.game.menuScreen then
            self.game.menuScreen:hide()
        end
    elseif self.currentState == self.states.LEVEL_MENU then
        if self.game.levelMenuScreen then
            self.game.levelMenuScreen:hide()
        end
    elseif self.currentState == self.states.SOCKS then
        if self.game.sockScreen then
            self.game.sockScreen:hide()
        end
    end

    self.currentState = state

    if self.currentState == self.states.MENU then
        if self.game.menuScreen then
            self.game.menuScreen:show()
        end
    elseif self.currentState == self.states.LEVEL_MENU then
        if self.game.levelMenuScreen then
            self.game.levelMenuScreen:show()
        end
    elseif self.currentState == self.states.SOCKS then
        if self.game.sockScreen then
            self.game.sockScreen:show()
        end
    end
end

function GameState:isInState(state)
    return self.currentState == state
end

function GameState:draw()
    local state = self.currentState

    if state == nil then return end

    gfx.clear(gfx.kColorBlack)
    local screenImage = gfx.image.new(400, 240)

    gfx.pushContext(screenImage)
        if state == self.states.LEVEL and self.game.currentLevel then
            local offsetX = -((self.game.currentLevel.activeRoomX - 1) * 400)
            local offsetY = -((self.game.currentLevel.activeRoomY - 1) * 240)
            gfx.setDrawOffset(offsetX, offsetY)

            gfx.sprite.update()
            pdDialogue.update()
            playdate.frameTimer.updateTimers()
        elseif state == self.states.MENU and self.game.menuScreen then
            gfx.sprite.update()
            self.game.menuScreen:draw()
        elseif state == self.states.SOCKS and self.game.sockScreen then
            gfx.sprite.update()
            self.game.sockScreen:draw()
        elseif state == self.states.LEVEL_MENU and self.game.levelMenuScreen then
            gfx.sprite.update()
            self.game.levelMenuScreen:draw()
        else
            gfx.popContext()
            return
        end
    gfx.popContext()

    screenImage:invertedImage():draw(0,0)
end

function GameState:debugDraw()
    local state = self.currentState

    if state == nil then return end

    if state == self.states.LEVEL and self.game.currentLevel then
        self.game.currentLevel:debugDraw()
    end
end

function GameState:init()
    self.game.menuScreen = MenuScreen()
    self.game.sockScreen = SockScreen()
    self.game.levelMenuScreen = LevelPickerScreen()
    self.socks = {}
    for i = 1, 25 do
        self.socks[i] = Sock(i)
        self.socks[i].owned = self.data.socks[i]
    end
    self:setState(self.states.MENU)
end

function GameState:catchEvent(eventName, eventData)
    if eventName == "enableSecondLevel" then
        self.data.level.level2 = true
        self:setState(self.states.LEVEL_MENU)
    elseif eventName == "enableThirdLevel" then
        self.data.level.level3 = true
        self:setState(self.states.LEVEL_MENU)
    elseif eventName == "endLevel" then
        self:setState(self.states.LEVEL_MENU)
    end
end

_G.GameState = GameState