class("TriggerBox").extends(playdate.graphics.sprite)

function TriggerBox:init(x, y, w, h, toEmit, data, oneTime)
    TriggerBox.super.init(self)

    self:setCollideRect(0, 0, w, h)
    self:moveTo(x, y)

    self.toEmit = toEmit
    self.data = data
    self.hasTriggered = false
    self.oneTime = oneTime or false
end

function TriggerBox:handleTrigger()
    if self.oneTime and self.hasTriggered then
        return
    end
    EventSystem:emitEvent(self.toEmit, self.data)
    self.hasTriggered = true
end