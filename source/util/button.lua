class("Button").extends(playdate.graphics.sprite)

function Button:init(x, y, width, height, label, callback)
    Button.super.init(self)

    self.innerWidth = width
    self.innerHeight = height

    self:setSize(width + 20, height + 20)
    self:setCenter(0.5, 0.5)
    self:moveTo(x, y)
    self:setZIndex(1000)

    self.label = label or ""
    self.font = playdate.graphics.getSystemFont()

    self.selected = false
    self.isPressed = false
    self.callback = callback
    self.cursorDt = 0
    self.animateCursor = false
    self.cursorBig = true
end

function Button:setSelected(flag)
    if self.selected == flag then
        return
    end

    self.selected = flag
    self.cursorBig = false
end

function Button:drawCursor()
    if self.isPressed then
        return
    end
    playdate.graphics.setLineWidth(4)
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    if not self.animateCursor or not self.cursorBig then
        playdate.graphics.drawRect(8, 8, self.width - 16, self.height - 16)
    else
        playdate.graphics.drawRect(6, 6, self.width - 12, self.height - 12)
    end
    playdate.graphics.setLineWidth(1)
end

function Button:draw()
    local oldDrawMode = playdate.graphics.getImageDrawMode()
    playdate.graphics.setColor(playdate.graphics.kColorBlack)
    playdate.graphics.fillRect(10, 10, self.innerWidth, self.innerHeight)

    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.drawRect(10, 10, self.innerWidth, self.innerHeight)

    local textWidth = self.font:getTextWidth(self.label)
    local textHeight = self.font:getHeight()
    local textX = 10 + (self.innerWidth - textWidth) / 2
    local textY = 10 + (self.innerHeight - textHeight) / 2
    playdate.graphics.drawText(self.label, textX, textY)

    self:drawCursor()
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