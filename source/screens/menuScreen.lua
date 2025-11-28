import 'util/button'

class("MenuScreen").extends(playdate.graphics.sprite)

function MenuScreen:init()
    MenuScreen.super.init(self)

    self.buttons = {
        Button(200, 140, 200, 40, "Level Auswahl", function()
            GameState:setState(GameState.states.LEVEL_MENU)
        end),
        Button(200, 200, 200, 40, "Deine Socken", function()
            GameState:setState(GameState.states.SOCKS)
        end),
    }

    self.selectedButtonIndex = 1
end

function MenuScreen:show()
    for _, button in ipairs(self.buttons) do
        button:add()
    end
    self:add()
end

function MenuScreen:hide()
    for _, button in ipairs(self.buttons) do
        button:remove()
    end
    self:remove()
end

function MenuScreen:update()
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        self.selectedButtonIndex = self.selectedButtonIndex - 1
        if self.selectedButtonIndex < 1 then
            self.selectedButtonIndex = #self.buttons
        end
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        self.selectedButtonIndex = self.selectedButtonIndex + 1
        if self.selectedButtonIndex > #self.buttons then
            self.selectedButtonIndex = 1
        end
    end
    for i, button in ipairs(self.buttons) do
        button:setSelected(i == self.selectedButtonIndex)
    end
end

function MenuScreen:draw()

end