class("Button").extends(playdate.graphics.sprite)

local Point <const> = playdate.geometry.point

function Button:init(x, y, width, height, label, nb, callback)
    Button.super.init(self)

    self.innerWidth = width
    self.innerHeight = height

    self.startPos = Point.new(x, y)
    self.position = self.startPos:copy()

    self:setSize(width + 100, height + 20)
    self:setCenter(0.5, 0.5)
    self:moveTo(self.position.x, self.position.y)
    self:setZIndex(1000)

    self.label = label or ""
    self.font = playdate.graphics.getSystemFont()

    self.selected = false
    self.isPressed = false
    self.callback = callback
    self.cursorDt = 0
    self.animateCursor = false
    self.cursorBig = true

    self.pawtable = playdate.graphics.imagetable.new("assets/images/ui/paw")
    self.background = playdate.graphics.image.new("assets/images/ui/button")
end

function Button:reset()
    self.position = self.startPos:copy()
    self:moveTo(self.position.x, self.position.y)
    self.isPressed = false
end

function Button:setSelected(flag)
    if self.selected == flag then
        return
    end

    self.selected = flag
    self.cursorBig = false
end

function Button:drawCursor()
    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    local img = self.pawtable:getImage(self.isPressed and 2 or 1)
    img:draw(0, 10)
end

function Button:draw()
    local oldDrawMode = playdate.graphics.getImageDrawMode()
    self.background:draw(50, 10)

    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
    playdate.graphics.setColor(playdate.graphics.kColorWhite)


    local textWidth = self.font:getTextWidth(self.label)
    local textHeight = self.font:getHeight()
    local textX = 50 + (self.innerWidth - textWidth) / 2
    local textY = 10 + (self.innerHeight - textHeight) / 2
    playdate.graphics.drawText(self.label, textX, textY)

    if self.selected then
        self:drawCursor()
    end
    playdate.graphics.setImageDrawMode(oldDrawMode)
end

function Button:update()
    self:markDirty()
    if not self.selected then
        self.isPressed = false
        return
    end
    if playdate.buttonIsPressed(playdate.kButtonA) then
        self.isPressed = true
    else
        if self.isPressed then
            if self.callback then
                self.callback()
            end
            self.isPressed = false
            self.animateCursor = false
            self.cursorDt = 0
            self.cursorBig = true
            SoundManager:playSound(SoundManager.kButtonA)
        else
            self.animateCursor = true
            self.cursorDt += 1
            if self.cursorDt > 30 then
                self.cursorBig = not self.cursorBig
                self.cursorDt = 0
            end
        end
    end
end