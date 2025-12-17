import 'CoreLibs/timer'

class("Sock").extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local sasser_slab_family <const> = gfx.font.newFamily({
    [gfx.font.kVariantNormal] = "assets/fonts/PixelifySans/PixelifySans-Regular",
    [gfx.font.kVariantBold] = "assets/fonts/PixelifySans/PixelifySans-Bold",
})

local SOCK_NOT_FOUND <const> = 26

local INTRO_OFFSET <const> = 240

local positions = {
    {x = 50,  y = 23},
    {x = 120, y = 23},
    {x = 190, y = 23},
    {x = 260, y = 23},
    {x = 330, y = 23},

    {x = 50,  y = 67},
    {x = 120, y = 67},
    {x = 190, y = 67},
    {x = 260, y = 67},
    {x = 330, y = 67},

    {x = 50,  y = 110},
    {x = 120, y = 110},
    {x = 190, y = 110},
    {x = 260, y = 110},
    {x = 330, y = 110},

    {x = 50,  y = 153},
    {x = 120, y = 153},
    {x = 190, y = 153},
    {x = 260, y = 153},
    {x = 330, y = 153},

    {x = 50,  y = 197},
    {x = 120, y = 197},
    {x = 190, y = 197},
    {x = 260, y = 197},
    {x = 330, y = 197},
}

function Sock:init(id)
    Sock.super.init(self)

    self.sock_id = id
    self.images = gfx.imagetable.new("assets/images/socks/socks")
    self:setImage(self.images:getImage(SOCK_NOT_FOUND))

    local pos = positions[id]

    self:moveTo(pos.x, pos.y + INTRO_OFFSET)

    self:setCenter(0, 0)
    self:setCollideRect(0, 0, 20, 20)
    self:setZIndex(1000)

    self.owned = false

    self.dialogueBox = nil

    self.menuPos = {
        x = pos.x,
        y = pos.y + INTRO_OFFSET
    }
    self.floatOffset = 0

    self.isNew = false
    self.isNewIndicator = gfx.sprite.new(gfx.image.new("assets/images/socks/new_indicator"))
    self.isNewIndicator:moveTo(self.x, self.y - 5)
    self.isNewIndicator:setCenter(0, 0)
end

function Sock:setOwned()
    if self.owned then return end
    self:setImage(self.images:getImage(self.sock_id))
    self.owned = true
    self.isNew = true

    GameState.data.socks[self.sock_id] = true
end

function Sock:drawAt(x, y)
    self.images:getImage(self.owned and self.sock_id or SOCK_NOT_FOUND):draw(x, y)
end

function Sock:reset()
    self:moveTo(positions[self.sock_id].x, positions[self.sock_id].y + 240)
    if self.owned then
        self:setImage(self.images:getImage(self.sock_id))
    else
        self:setImage(self.images:getImage(SOCK_NOT_FOUND))
    end
end

function Sock:update()
    self.isNewIndicator:moveTo(self.x, self.y - 5)
    if self.isNew then
        self.isNewIndicator:add()
    else
        self.isNewIndicator:remove()
    end
end