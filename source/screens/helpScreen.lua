class("HelpScreen").extends(playdate.graphics.sprite)

local INTRO_OFFSET <const> = 240

local gfx <const> = playdate.graphics

function HelpScreen:init()
    HelpScreen.super.init(self)

    self._y = -INTRO_OFFSET

    self.textImages = {}
    self.intro = false
    self.outro = false

    self.selectedTextIndex = 1
    self:setUpText()
end

function HelpScreen:setUpText()
    local text = {
[[
Wie spielt man das Spiel?

Du benutzt einfach die Pfeiltasten, um dich nach links und rechts zu bewegen. Zum Springen nutzt du die A-Taste.
Die B-Taste wird nur von Hebeln benutzt, aber die kommen erst in den letzteren Leveln vor.
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

Wenn du mal Hilfe brauchst oder Fragen hast, kannst du mich jederzeit fragen :)

Dein Winnie <3
]],
    }

    for i, t in ipairs(text) do
        local img = gfx.image.new(400, 240)
        gfx.pushContext(img)

            gfx.setColor(gfx.kColorBlack)
            gfx.drawTextInRect(t, 20, 10, 360, 200)

            local leftTextAddon = (i > 1) and "<-" or ""
            gfx.drawTextInRect(leftTextAddon,
                20, 215, 360, 20,
                nil, nil, kTextAlignment.left
            )

            gfx.drawTextInRect(tostring(i) .. "/" .. #text,
                20, 215, 360, 20,
                nil, nil, kTextAlignment.center
            )

            local rightTextAddon = (i < #text) and "->" or ""
            gfx.drawTextInRect(rightTextAddon,
                20, 215, 360, 20,
                nil, nil, kTextAlignment.right
            )

        gfx.popContext()

        self.textImages[i] = img
    end
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
        if self.selectedTextIndex > #self.textImages then
            self.selectedTextIndex = #self.textImages
        end
        SoundManager:playSound(SoundManager.kMenuMove)
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        SoundManager:playSound(SoundManager.kButtonB)
        GameState:setState(GameState.states.MENU)
    end
end

function HelpScreen:draw()
    self.textImages[self.selectedTextIndex]:draw(0, self._y)
end