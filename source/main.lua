import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/frameTimer'
import 'CoreLibs/nineslice'
import 'CoreLibs/ui'

import 'dialogue/pdDialogue'

import 'util/soundManager'
import 'eventSystem'
import 'game_state'

local gfx <const> = playdate.graphics

local function setup()
    playdate.display.setRefreshRate(30)
    playdate.display.setInverted(true)

    GameState:load()
    GameState:init()

    local menu = playdate.getSystemMenu()
    local menuItem3, error3 = menu:addMenuItem("Menu", function()
        GameState:setState(GameState.states.MENU)
    end)
end

setup()


function playdate.update()
    GameState.game.showCrank = false
    GameState:draw()
    if GameState.game.showCrank then
        playdate.ui.crankIndicator:draw()
    end
    gfx.setColor(gfx.kColorWhite)
    playdate.drawFPS(0,0)
    gfx.setColor(gfx.kColorBlack)
end

function playdate.gameWillTerminate()
    GameState:save()
end

function playdate.gameWillSleep()
    GameState:save()
end

function playdate.gameWillPause()
    GameState:constructMenuImage()
end

function playdate.gameWillResume()
    playdate.setMenuImage(nil)
end