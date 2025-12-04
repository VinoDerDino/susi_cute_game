import 'util/button'

class("MenuScreen").extends(playdate.graphics.sprite)

local INTRO_OFFSET <const> = 240

function MenuScreen:init()
    MenuScreen.super.init(self)

    self.buttons = {
        Button(200, 120 - INTRO_OFFSET, 200, 40, "*Level Auswahl*", 1, function()
            GameState:setState(GameState.states.LEVEL_MENU)
        end),
        Button(200, 170 - INTRO_OFFSET, 200, 40, "*Deine Socken*", 2, function()
            GameState:setState(GameState.states.SOCKS)
        end),
        Button(200, 220 - INTRO_OFFSET, 200, 40, "*Hilfe*", 2, function()
            GameState:setState(GameState.states.HELP)
        end),
    }

    self.selectedButtonIndex = 1

    self:setImage(playdate.graphics.image.new("assets/images/ui/banner_menu"))
    self:moveTo(0, -INTRO_OFFSET)
    self:setCenter(0, 0)

    self.playerTable = nil
    self.sandy = Sandy({
        {
        id = 1,
        properties = {
            {
                name = "action",
                value = "patrolMenu"
            },
            {
                name = "isFirstStep",
                value = true
            },
        },
        x = 200,
        y = 86 - INTRO_OFFSET}
    })

    self.intro = false
    self.outro = false
end

function MenuScreen:show()
    for _, button in ipairs(self.buttons) do
        button:add()
        button:reset()
    end
    self.sandy:add()
    self.sandy:applyCurrentStep()
    self:add()
end

function MenuScreen:hide()
    for _, button in ipairs(self.buttons) do
        button:remove()
    end
    self.sandy:remove()
    self:remove()
end

function MenuScreen:introAnimation()
    self.y += GameState.consts.intro_speed
    if self.y >= 0 then
        self.y = 0
        self.intro = false
    end
    for _, button in ipairs(self.buttons) do
        button:moveTo(button.x, button.y + GameState.consts.intro_speed)
    end
    self.sandy.position.y += GameState.consts.intro_speed
    self.sandy:place(self.sandy.position.x, self.sandy.position.y)
    self:moveTo(0, self.y)
end

function MenuScreen:outroAnimation()
    self.y -= GameState.consts.intro_speed
    if self.y <= -240 then
        self.y = -240
        self.outro = false
        self:hide()
        GameState.currentOutro = false
    end
    for _, button in ipairs(self.buttons) do
        button:moveTo(button.x, button.y - GameState.consts.intro_speed)
    end
    self.sandy.position.y -= GameState.consts.intro_speed
    self.sandy:place(self.sandy.position.x, self.sandy.position.y)
    self:moveTo(0, self.y)
end

function MenuScreen:startIntro()
    self:show()
    self.intro = true
    self.outro = false
    self.y = -240
    GameState.currentOutro = true
end

function MenuScreen:startOutro()
    self.outro = true
    self.intro = false
    self.y = 0
end

function MenuScreen:update()
    if self.intro then
        self:introAnimation()
        return
    elseif self.outro then
        self:outroAnimation()
        return
    end
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        self.selectedButtonIndex = self.selectedButtonIndex - 1
        if self.selectedButtonIndex < 1 then
            self.selectedButtonIndex = #self.buttons
        end
        SoundManager:playSound(SoundManager.kMenuMove)
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        self.selectedButtonIndex = self.selectedButtonIndex + 1
        if self.selectedButtonIndex > #self.buttons then
            self.selectedButtonIndex = 1
        end
        SoundManager:playSound(SoundManager.kMenuMove)
    end
    for i, button in ipairs(self.buttons) do
        button:setSelected(i == self.selectedButtonIndex)
    end
end

function MenuScreen:draw()

end