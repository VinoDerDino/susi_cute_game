import 'util/sock'

class("SockScreen").extends(playdate.graphics.sprite)

local targetH = 100
local targetW = 250
local startW  = 20

local centerW = 400
local centerH = 240

local gfx <const> = playdate.graphics

function SockScreen:init()
    SockScreen.super.init(self)

    self:setImage(gfx.image.new("assets/images/ui/sock_cursor"))
    self.selectedSockIndex = 1
    self:setZIndex(1000)
    self:setCenter(0, 0)
    self:moveTo(48, 21)

    self._y = 240
    self.nineSlice = gfx.nineSlice.new("assets/images/ui/nineslice-kenney-1", 4, 4, 8, 8)
    self.isNineSliceVisible = false
    self.animW = startW
    self.growthSpeed = 10
    self.phase = 1
    self.animH = 0
    self.animFinished = false
end

function SockScreen:show()
    for _, sock in ipairs(GameState.socks) do
        sock:add()
        sock:reset()
    end
    self:add()
end

function SockScreen:hide()
    for _, sock in ipairs(GameState.socks) do
        sock:remove()
    end
    self:remove()
end

function SockScreen:moveSocks(delta)
    for _, sock in ipairs(GameState.socks) do
        sock.menuPos.y += delta
        sock:moveTo(sock.menuPos.x, sock.menuPos.y)
    end
end

function SockScreen:introAnimation()
    self._y -= GameState.consts.intro_speed
    if self._y <= 0 then
        self._y = 0
        self.intro = false
    end
    self:moveSocks(-GameState.consts.intro_speed)
end

function SockScreen:outroAnimation()
    self._y += GameState.consts.intro_speed
    if self._y >= 240 then
        self._y = 240
        self.outro = false
        self:hide()
    end
    self:moveSocks(GameState.consts.intro_speed)
end

function SockScreen:startIntro()
    self:show()
    self.intro = true
    self.outro = false
    self.y = 240
end

function SockScreen:startOutro()
    self.outro = true
    self.intro = false
    self.y = 0
end

function SockScreen:getSock(index)
    if index < 1 or index > #GameState.socks then
        print("WARNING: Invalid sock index: " .. tostring(index))
        return nil
    end

    return GameState.socks[index]
end

function SockScreen:resetInfoScreen()
    self.isNineSliceVisible = false
    self.animW = startW
    self.phase = 1
    self.animH = 0
    self.animFinished = false
end

function SockScreen:buttonInputs()
    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        self.selectedSockIndex = self.selectedSockIndex - 1
        if self.selectedSockIndex < 1 then
            self.selectedSockIndex = #GameState.socks
        end
        self:resetInfoScreen()
        SoundManager:playSound(SoundManager.kMenuMove)
    elseif playdate.buttonJustPressed(playdate.kButtonRight) then
        self.selectedSockIndex = self.selectedSockIndex + 1
        if self.selectedSockIndex > #GameState.socks then
            self.selectedSockIndex = 1
        end
        self:resetInfoScreen()
        SoundManager:playSound(SoundManager.kMenuMove)
    elseif playdate.buttonJustPressed(playdate.kButtonUp) then
        self.selectedSockIndex = self.selectedSockIndex - 5
        if self.selectedSockIndex < 1 then
            self.selectedSockIndex = self.selectedSockIndex + #GameState.socks
        end
        self:resetInfoScreen()
        SoundManager:playSound(SoundManager.kMenuMove)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        self.selectedSockIndex = self.selectedSockIndex + 5
        if self.selectedSockIndex > #GameState.socks then
            self.selectedSockIndex = self.selectedSockIndex - #GameState.socks
        end
        self:resetInfoScreen()
        SoundManager:playSound(SoundManager.kMenuMove)
    elseif playdate.buttonJustPressed(playdate.kButtonA) then
        SoundManager:playSound(SoundManager.kButtonA)
        self.isNineSliceVisible = true
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        SoundManager:playSound(SoundManager.kButtonB)
        if self.isNineSliceVisible then
            self:resetInfoScreen()
        else
            GameState:setState(GameState.states.MENU)
        end
    end
end

function SockScreen:update()
    if self.intro then
        self:introAnimation()
    elseif self.outro then
        self:outroAnimation()
    end
    if not self.outro and not self.intro then
        self:buttonInputs()
    end

    local selectedSock = self:getSock(self.selectedSockIndex)
    if not selectedSock then return end
    self:moveTo(selectedSock.menuPos.x - 2, selectedSock.menuPos.y - 2)
end

function SockScreen:drawScreen()
    if not self.isNineSliceVisible then return end
    if self.phase == 1 then
        self.animH = math.min(self.animH + self.growthSpeed, targetH)
        if self.animH >= targetH then
            self.phase = 2
        end
    end

    if self.phase == 2 then
        self.animW = math.min(self.animW + self.growthSpeed, targetW)
        if self.animW >= targetW then
            self.animFinished = true
        end
    end

    local x = (centerW - self.animW) / 2
    local y = (centerH - self.animH) / 2

    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(x, y, self.animW, self.animH)
    self.nineSlice:drawInRect(x, y, self.animW, self.animH)
    if not self.animFinished then return end
    gfx.setColor(gfx.kColorBlack)
    local sock = self:getSock(self.selectedSockIndex)
    if not sock then return end

    local text = "Du musst die Socke in einem Level finden! Wenn du Hilfe brauchst, frag Winnie :)"
    if sock.owned then
         text = "Du darfst dein Geschenk Nummer *" .. tostring(self.selectedSockIndex) ..
                "* aufmachen! Hab ganz viel Spass damit <3"
    end

    local inset = 20
    local textX = x + inset
    local textY = y + inset
    local textW = self.animW - inset * 2
    local textH = self.animH - inset * 2

    gfx.drawTextInRect(
        text,
        textX,
        textY,
        textW,
        textH,
        nil,
        "center"
    )
end