import 'util/sock'

class("SockProp").extends(playdate.graphics.sprite)

local SOCK_ALREADY_FOUND <const> = 27

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

    self:moveTo(x, y)

    self.floatOffset = 0

    self.animate = false
    self.animationTimer = 0
    self.animFrame = 2

    self.isSockProp = true
end

function SockProp:getImage()
    if self.sock.owned then
        return self.sock.images:getImage(self.sock_id)
    else
        return self.sock.images:getImage(SOCK_ALREADY_FOUND)
    end
end

function SockProp:getOwnedImage()
    return self.sock.images:getImage(self.sock_id)
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
    end
end