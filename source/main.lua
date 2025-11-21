import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/frameTimer'
import 'CoreLibs/nineslice'

import 'dialogue/pdDialogue'

import 'util/soundManager'
import 'game_state'
import 'eventSystem'
import 'screens/menuScreen'
import 'screens/sockScreen'

local gfx <const> = playdate.graphics

local function setup()
    playdate.display.setRefreshRate(50)

    -- GameState:load()
    GameState.game.menuScreen = MenuScreen()
    GameState.game.sockScreen = SockScreen()
    GameState:setState(GameState.states.MENU)

    local menu = playdate.getSystemMenu()
    local menuItem, error = menu:addCheckmarkMenuItem("Timer", true, function(value)
        GameState:setSetting("speedrunTimer", value)
    end)
end

setup()

function playdate.update()
    GameState:draw()
    gfx.setColor(gfx.kColorWhite)
    playdate.drawFPS(0,0)
    gfx.setColor(gfx.kColorBlack)
end

function playdate.gameWillTerminate()
    -- GameState:save()
end