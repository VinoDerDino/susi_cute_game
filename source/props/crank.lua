import 'CoreLibs/crank'
import 'CoreLibs/ui'
import 'props/cranking'

class("Crank").extends(Cranking)

local gfx <const> = playdate.graphics

local font2 <const> = gfx.font.new("assets/fonts/Diamond 12")

function Crank:init(x, y, connectedProp)
    Crank.super.init(self, x, y)

    self.connectedProp = connectedProp

    self.images = gfx.imagetable.new("assets/images/props/crank")
    self:setImage(self.images:getImage(1))

    self.imageIndex = 1

    self:setZIndex(500)
    self:setCenter(0.5, 1)
    self:moveTo(x, y)

    local nineSlice = gfx.nineSlice.new("assets/images/ui/nineslice-kenney-1", 4, 4, 8, 8)
    self.infoDialogueConfig = {
        width = 120,
        height = 18,
        x = x - 55,
        padding = 4,
        font = font2,
        nineSlice = nineSlice,
        y = y - 45,
        drawPrompt = function() end,
        onOpen = function() pdDialogue.DialogueBox:finishDialogue() end,
        drawText = function(box, x, y, text)
            gfx.setFont(box.font or gfx.getSystemFont())
            gfx.drawTextAligned(
                text,
                x + box.width / 2 - box.padding,
                y,
                kTextAlignment.center
            )
        end
    }
    self.infoShown = false
end

function Crank:activate()
    self.connectedProp:activate()
end

function Crank:update()
    if not GameState:isUnlocked("cranking") then
        if self.isPlayerNear and not self.infoShown then
            self.infoShown = true
            pdDialogue.say("Rede mit Sandy", self.infoDialogueConfig)
        elseif not self.isPlayerNear then
            self.infoShown = false
        end
        return
    end

    self:updateCrank(GameState.game.currentLevel.player)
    self:updateProgressBarImage()

    local newIndex = math.floor(self.crankValue / 8) % self.images:getLength() + 1
    if self.imageIndex ~= newIndex then
        self.imageIndex = newIndex
        self:setImage(self.images:getImage(self.imageIndex))
        if self.isPlayerInSameRoom then
            SoundManager:playSound(SoundManager.kClick)
        end
    end

    if self.connectedProp and self.connectedProp.setCrankValue then
        self.connectedProp:setCrankValue(self.crankValue)
    end
end