import 'level/level'

local gfx <const> = playdate.graphics

local GameState = {}
GameState.filename = "susi_game_state"

GameState.data = {
    unlocked = {
        cranking = false,
        wallJumping = false,
        dashing = false,
        twineGrowth = true,
    },
    settings = {
        speedrunTimer = true,
    },
    stats = {
        totalPlaytime = 0,
        totalPlaytimes = {
            level1 = 0,
        },
        bestPlaytimes = {
            level1 = nil,
        }
    },
    level = {
        level1 = {
            unlocked = true,
            socks = {
                [1] = false,
                [2] = false,
                [3] = false,
                [4] = false,
                [5] = false,
            }
        },
        level2 = {
            unlocked = false,
            socks = {
                [6] = false,
                [7] = false,
                [8] = false,
                [9] = false,
                [10] = false,
            }
        },
    }
}

GameState.game = {
    currentLevel = nil,
    sockScreen = nil,
    menuScreen = nil,
}

GameState.states = {
    MENU = 1,
    SOCKS = 2,
    LEVEL_MENU = 3,
    LEVEL = 4,
}

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
        "assets/maps/level_1_with_objects.json",
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
    elseif self.currentState == self.states.SOCKS then
        if self.game.sockScreen then
            self.game.sockScreen:hide()
        end
    end

    self.currentState = state

    if self.currentState == self.states.LEVEL then
        print("Cranking enabled: ", GameState.data.unlocked.cranking)
        if not self.game.currentLevel then
            self:setCurrentLevel(1)
        end
    elseif self.currentState == self.states.MENU then
        if self.game.menuScreen then
            self.game.menuScreen:show()
        end
    elseif self.currentState == self.states.SOCKS then
        if self.game.sockScreen then
            self.game.sockScreen:show()
        end
    end
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
        else
            gfx.popContext()
            return
        end
    gfx.popContext()

    screenImage:invertedImage():draw(0,0)
end

_G.GameState = GameState