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

    print("Sock id:", id)

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

    self:setupPopupText()
end

function Sock:setupPopupText()
    local _text = "Du darfst Briefumschlag Nummer _" .. tostring(self.sock_id) .. "_ aufmachen!"
    self.dialogueBox = pdDialogueBox(_text, 200, 50, sasser_slab_family)
    self.dialogueBox:setPadding(4)

    function self.dialogueBox:drawText(x, y, text)
        playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        gfx.drawTextAligned(text, x + self.width / 2 - 4, y, kTextAlignment.center)
    end

    function self.dialogueBox:drawBackground(x, y)
        playdate.graphics.setColor(playdate.graphics.kColorBlack)
        playdate.graphics.fillRect(x, y, self.width, self.height)
        playdate.graphics.setColor(playdate.graphics.kColorWhite)
        playdate.graphics.drawRect(x, y, self.width, self.height)
        playdate.graphics.setColor(playdate.graphics.kColorBlack)
    end

    function self.dialogueBox:drawPrompt(x, y)
        pdDialogueBox.arrowPrompt(x + self.width - 12, y + self.height - 10, gfx.kColorWhite)
    end

    function self.dialogueBox:onOpen()
        playdate.inputHandlers.push(self:getInputHandlers())
        self:finishDialogue()
    end

    function self.dialogueBox:onClose()
        playdate.inputHandlers.pop()
    end
end

function Sock:setOwned()
    self:setImage(self.images:getImage(self.sock_id))
    self.owned = true
end

function Sock:showPopupText()
    if self.dialogueBox then
       self.dialogueBox:enable()
    end
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
end