import 'CoreLibs/crank'
import 'CoreLibs/ui'
import 'props/cranking'

class("Crank").extends(Cranking)

local gfx <const> = playdate.graphics

local crankImages <const> = gfx.imagetable.new("assets/images/props/crank")
local crankImagesLength <const> = crankImages:getLength()

function Crank:init(x, y, connectedProp)
    Crank.super.init(self, x, y)

    self.connectedProp = connectedProp

    self:setImage(crankImages:getImage(1))

    self.imageIndex = 1

    self:setZIndex(500)
    self:setCenter(0.5, 1)
    self:moveTo(x, y)
end

function Crank:activate()
    self.connectedProp:activate()
end

function Crank:update()
    if not GameState:isUnlocked("cranking") then
        return
    end

    self:updateCrank()
    self:updateProgressBarImage()

    local newIndex = math.floor(self.crankValue / 8) % crankImagesLength + 1
    if self.imageIndex ~= newIndex then
        self.imageIndex = newIndex
        self:setImage(crankImages:getImage(self.imageIndex))
        SoundManager:playSound(SoundManager.kClick)
    end

    if self.crankValueChanged and self.connectedProp and self.connectedProp.setCrankValue then
        self.connectedProp:setCrankValue(self.crankValue)
    end
end