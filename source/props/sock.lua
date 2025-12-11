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
    self:setCenter(0, 0)

    self.inLevelPosition = Point.new(x, y)

    self.moveTimer = playdate.frameTimer.new(60, -3, 3)
    self.moveTimer.repeats = true
    self.moveTimer.reverses = true
    self.floatOffset = 0

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
    SoundManager:playSound(SoundManager.kCollect)
end

function SockProp:update()
    if self.animate then
        self:animateFound()
        return
    end
    self:drawMovingAt(self.inLevelPosition.x, self.inLevelPosition.y)
end