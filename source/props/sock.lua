import 'util/sock'

class("SockProp").extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local Point <const> = playdate.geometry.point
local SOCK_ALREADY_FOUND <const> = 27

local font2 <const> = gfx.font.new("assets/fonts/Diamond 12")

function SockProp:init(id, x, y)
    SockProp.super.init(self)

    self.sock_id = id
    self.sock = GameState.socks[id]

    if self.sock.owned then
        self:setImage(self.sock.images:getImage(SOCK_ALREADY_FOUND))
    else
        self:setImage(self.sock.images:getImage(id))
    end
    self:setCollideRect(0, 0, 20, 20)

    self.inLevelPosition = Point.new(x, y)

    self.moveTimer = playdate.frameTimer.new(60, -3, 3)
    self.moveTimer.repeats = true
    self.moveTimer.reverses = true
    self.floatOffset = 0

    local nineSlice = gfx.nineSlice.new("assets/images/ui/nineslice-kenney-1", 4, 4, 8, 8)
    local roomX, roomY = self:getPositionInRoom()
    local textTimer = 0
    self.infoDialogueConfig = {
        width = 300,
        height = 40,
        x = (roomX + 1) * 400 - 350,
        y = (roomY + 1) * 240 - 65,
        padding = 4,
        font = font2,
        nineSlice = nineSlice,
        drawPrompt = function() end,
        timer = 0,
        onOpen = function() pdDialogue.DialogueBox:finishDialogue() end,
        drawText = function(box, _x, _y, text)
            textTimer += 1
            print("X:", _x, "Y:", _y, "Timer: ", textTimer)
            gfx.setFont(box.font or gfx.getSystemFont())
            gfx.drawTextAligned(
                text,
                _x + box.width / 2 - box.padding,
                _y,
                kTextAlignment.center
            )

            if textTimer >= 240 then
                pdDialogue.DialogueBox:disable()
            end
        end
    }
    self.infoShown = false

    self.animate = false
    self.animationTimer = 0
    self.animFrame = 2
end

function SockProp:getPositionInRoom()
    return math.floor(self.inLevelPosition.x / 400), math.floor(self.inLevelPosition.y / 240)
end

function SockProp:drawMovingAt(x, y)
    self.floatOffset = self.moveTimer.value
    self:moveTo(x, y + self.floatOffset)
end

function SockProp:animateFound()
    self.animationTimer += 1

    if (self.animationTimer % 20) == 0 then
        print("ANIMATION TIMER: ", self.animationTimer)
        self.animFrame = self.animFrame == 1 and 2 or 1
        self:setImage(self.animFrame == 1 and
            self.sock.images:getImage(SOCK_ALREADY_FOUND) or
            self.sock.images:getImage(self.sock_id))
    end

    if self.animationTimer >= 240 then
        self:remove()
        self.animate = false
    end
end

function SockProp:hit()
    if self.animate then return end
    self.sock:setOwned()
    self.animate = true
end

function SockProp:update()
    if self.animate then
        self:animateFound()
        if not self.infoShown then
            pdDialogue.say("Mach Briefumschlag Nr. " .. tostring(self.sock.sock_id) .. " auf! Schau im Menue nach!", self.infoDialogueConfig)
            self.infoShown = true
        end
        return
    end
    self:drawMovingAt(self.inLevelPosition.x, self.inLevelPosition.y)
end