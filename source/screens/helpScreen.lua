class("HelpScreen").extends(playdate.graphics.sprite)

local INTRO_OFFSET <const> = 240

function HelpScreen:init()
    HelpScreen.super.init(self)

    self._y = -INTRO_OFFSET

    self.text = {
[[
Wie spielt man das Spiel?

Du benutzt einfach die Pfeiltasten, um dich nach links und rechts zu bewegen. Zum Springen nutzt du die A-Taste.

Im Spiel selber findest du an verschiedenen Stellen *Sandy*. Mit der Pfeiltaste nach unten kannst du mit ihr interargieren.
]],
[[
Zudem gibt es weitere Sachen im Spiel, die du nutzen kannst. Bei diesen Dingen nutzt du einfach die Kurbel.

Das wichtigste Element im Spiel sind die *Socken*. Diese kannst du in einem Level einsammeln.
Im Socken-Menue kannst du nachschauen, wie viele Socken du schon eingesammelt hast.
]],
[[
Jede eingesammelte Socke erlaubt es dir, im echten Leben ein kleines Geschenk von mir aufzumachen!

Hab ganz Viel Spass mit dem Spiel!

Wenn du mal Hilfe oder Fragen hast, kannst du mich jederzeit fragen :)

Dein Winnie <3
]],
    }
    self.intro = false
    self.outro = false

    self.selectedTextIndex = 1
end

function HelpScreen:show()
    self:add()
end

function HelpScreen:hide()
    self:remove()
end

function HelpScreen:introAnimation()
    self._y -= GameState.consts.intro_speed
    if self._y <= 0 then
        self._y = 0
        self.intro = false
    end
end

function HelpScreen:outroAnimation()
    self._y += GameState.consts.intro_speed
    if self._y >= 240 then
        self._y = 240
        self.outro = false
        self:hide()
    end
end

function HelpScreen:startIntro()
    self:show()
    self.intro = true
    self.outro = false
    self._y = 240
end

function HelpScreen:startOutro()
    self.outro = true
    self.intro = false
    self._y = 0
end

function HelpScreen:update()
    if self.intro then
        self:introAnimation()
    elseif self.outro then
        self:outroAnimation()
    end

    if self.intro or self.outro then return end

    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        self.selectedTextIndex -= 1
        if self.selectedTextIndex < 1 then
            self.selectedTextIndex = 1
        end
        SoundManager:playSound(SoundManager.kMenuMove)
    elseif playdate.buttonJustPressed(playdate.kButtonRight) then
        self.selectedTextIndex += 1
        if self.selectedTextIndex > #self.text then
            self.selectedTextIndex = #self.text
        end
        SoundManager:playSound(SoundManager.kMenuMove)
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        SoundManager:playSound(SoundManager.kButtonB)
        GameState:setState(GameState.states.MENU)
    end
end

function HelpScreen:draw()
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    playdate.graphics.drawTextInRect(self.text[self.selectedTextIndex], 20, self._y + 10, 360, 200)
    local leftTextAddon = self.selectedTextIndex > 1 and "<-" or ""
    local rightTextAddon = self.selectedTextIndex < #self.text and "->" or ""
    playdate.graphics.drawTextInRect(leftTextAddon, 20, self._y + 215, 360, 20, nil, nil, kTextAlignment.left)
    playdate.graphics.drawTextInRect(tostring(self.selectedTextIndex) .. "/" .. #self.text, 20, self._y + 215, 360, 20, nil, nil, kTextAlignment.center)
    playdate.graphics.drawTextInRect(rightTextAddon, 20, self._y + 215, 360, 20, nil, nil, kTextAlignment.right)
end