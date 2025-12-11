import 'CoreLibs/animation'

class("NPC").extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local Point <const> = playdate.geometry.point

local sasser_slab_normal <const> = gfx.font.new("assets/fonts/PixelifySans/PixelifySans-Regular")
local sasser_slab_family <const> = gfx.font.newFamily({
    [gfx.font.kVariantNormal] = "assets/fonts/PixelifySans/PixelifySans-Regular",
    [gfx.font.kVariantBold] = "assets/fonts/PixelifySans/PixelifySans-Bold",
})

local TRIGGER_DISTANCE <const> = 50
local DIALOGUE_WIDTH <const> = 400
local DIALOGUE_HEIGHT <const> = 50

function NPC:init(portrait_name)
    NPC.super.init(self)

    self.portrait = gfx.animation.loop.new(150, gfx.imagetable.new("assets/images/npcs/" .. portrait_name), true)

    self.position = Point.new(0, 0)
    self.isPlayerNear = false

    self.oldAction = nil
    self.action = nil

    self.sequence = {}
    self.currentStepId = nil

    self.dialogueBox = nil

    self.tooltipImages = gfx.imagetable.new("assets/images/ui/cross_indicator")
    self.tooltip = gfx.sprite.new(self.tooltipImages:getImage(2))
    self.tooltip:setZIndex(1100)
    self.tooltip:setCenter(0.5, 1)
    self.tooltip:setVisible(false)
    self.tooltip:add()

    self.dialogueBoxSprite = nil

    EventSystem:addListener(self)
end

function NPC:destroy()
    EventSystem:removeListener(self)
    if self.tooltip then
        gfx.sprite.removeSprite(self.tooltip)
        self.tooltip = nil
    end

    if self.dialogueBoxSprite then
        gfx.sprite.removeSprite(self.dialogueBoxSprite)
        self.dialogueBoxSprite = nil
    end
end

function NPC:place(x, y)
    self.position.x = x
    self.position.y = y
    self:moveTo(self.position.x, self.position.y)
    self.tooltip:moveTo(self.position.x, self.position.y - 30)
end

function NPC:updatePlayerDistance(playerPosition)
    local dist = self.position:distanceToPoint(playerPosition)

    self.isPlayerNear = self:isVisible() and (dist < TRIGGER_DISTANCE)

    self.tooltip:setVisible(self.isPlayerNear)
end

function NPC:interact(skipPlayerNearCheck)
    skipPlayerNearCheck = skipPlayerNearCheck or false
    if not skipPlayerNearCheck then
        if not self.isPlayerNear then return end
    end

    local step = self.sequence[self.currentStepId]
    if not step then return end

    if self.dialogueBox then
        playdate.inputHandlers.push(self.dialogueBox:getInputHandlers())
        self.dialogueBoxSprite:add()
    end
end

local function getProperty(obj, propertyName, defaultValue)
    if obj.properties then
        for _, prop in ipairs(obj.properties) do
            if prop.name == propertyName then
                return prop.value
            end
        end
    end
    return defaultValue
end

local function getFirstStep(config)
    for _, step in ipairs(config) do
        if getProperty(step, "isFirstStep", false) then
            return step
        end
    end
end

function NPC:loadConfig(config)
    local stepMap = {}
    local firstStep = getFirstStep(config)
    if not firstStep then
        print("NPC config has no firstStep!")
        return
    end

    for _, step in ipairs(config) do
        stepMap[step.id] = step
    end

    self.sequence = {}

    for id, step in pairs(stepMap) do
        self.sequence[id] = {
            position = Point.new(step.x, step.y),
            dialogue = getProperty(step, "dialogue", nil),
            onDialogueEnd = {},
            waitFor = getProperty(step, "waitFor", nil),
            action = getProperty(step, "action", nil),
            nextStepId = getProperty(step, "nextStep", nil)
        }

        local nextId = self.sequence[id].nextStepId
        if nextId == 0 or nextId == false then
            self.sequence[id].nextStepId = nil
        elseif nextId and not stepMap[nextId] then
            print("WARNING: NPC step "..id.." points to missing nextStepId "..tostring(nextId))
            self.sequence[id].nextStepId = nil
        end
    end

    for id, entry in pairs(self.sequence) do
        local events = {}

        if entry.nextStepId then
            table.insert(events, "goToNextStep")
        end

        local customEnd = getProperty(stepMap[id], "onDialogueEnd", nil)
        if customEnd then
            table.insert(events, customEnd)
        end

        entry.onDialogueEnd = events
    end

    self.currentStepId = firstStep.id
    self:applyCurrentStep()
end

function NPC:removeDialogueSprite()
    if self.dialogueBoxSprite then
        gfx.sprite.removeSprite(self.dialogueBoxSprite)
        self.dialogueBoxSprite = nil
    end
end

function NPC:applyCurrentStep()
    local step = self.sequence[self.currentStepId]
    if not step then
        print("NPC applyCurrentStep: stepId " .. tostring(self.currentStepId) .. " does not exist.")
        return
    end

    self:place(step.position.x, step.position.y)

    if step.dialogue then
        self.dialogueBox = pdPortraitDialogueBox("", self.portrait, step.dialogue, DIALOGUE_WIDTH, DIALOGUE_HEIGHT, sasser_slab_normal)
        self.dialogueBox:setPadding(4)

        local npc = self

        function self.dialogueBox:drawText(x, y, text)
            playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
            gfx.drawText(text, x, y, sasser_slab_family)
        end

        function self.dialogueBox:drawBackground(x, y)
            playdate.graphics.setColor(playdate.graphics.kColorBlack)
            playdate.graphics.fillRect(x, y, self.width, self.height)
            self:drawPortrait(x + self.portrait_x_position - self.portrait_width, y)
        end

        function self.dialogueBox:drawPrompt(x, y)
            pdDialogueBox.arrowPrompt(x + self.width - 12, y + self.height - 10, gfx.kColorWhite)
        end

        function self.dialogueBox:nextPage()
            pdPortraitDialogueBox.super.nextPage(self)
            self.portrait.shouldLoop = true
        end

        function self.dialogueBox:onPageComplete()
            self.portrait.shouldLoop = false
            self.portrait.frame = 1
            self.dirty = true
        end

        function self.dialogueBox:finishLine()
            pdPortraitDialogueBox.super.finishLine(self)
            self.portrait.shouldLoop = false
        end

        function self.dialogueBox:onClose()
            playdate.inputHandlers.pop()

            npc.isPlayerNear = false
            npc.dialogueBoxSprite:remove()

            if step.onDialogueEnd then
                for _, cmd in ipairs(step.onDialogueEnd) do
                    if cmd == "goToNextStep" and not step.waitFor then
                        npc:goToNextStep()
                    elseif cmd == "goToSameStep" then
                        npc:applyCurrentStep()
                    elseif cmd == "enableCranking" then
                        GameState:unlock("cranking")
                    elseif cmd == "enableTwines" then
                        GameState:unlock("twineGrowth")
                    elseif cmd == "endLevel" then
                        GameState:setState(GameState.states.MENU)
                    else
                        EventSystem:emitEvent(cmd)
                    end
                end
            else
                npc:goToNextStep()
            end
        end

        self.dialogueBox.npc = self
        self:removeDialogueSprite()
        self.dialogueBoxSprite = self.dialogueBox:asSprite()
        self.dialogueBoxSprite.image = gfx.image.new(DIALOGUE_WIDTH, DIALOGUE_HEIGHT)
        self.dialogueBoxSprite:setImage(self.dialogueBoxSprite.image)
        self.dialogueBoxSprite:setZIndex(7000)
        self.dialogueBoxSprite:setCenter(0, 0)
        self.dialogueBoxSprite:moveTo(0, 240 - DIALOGUE_HEIGHT)
    else
        self.dialogueBox = nil
        self:removeDialogueSprite()
    end

    if step.action then
        self.action = step.action
    else
        self.action = nil
        self.oldAction = nil
    end
end

function NPC:goToNextStep()
    local nextStepId = self.sequence[self.currentStepId].nextStepId
    if not nextStepId then return end

    self.currentStepId = nextStepId
    self:applyCurrentStep()
    self.tooltip:setVisible(false)
end

function NPC:goToStep(stepId)
    if not self.sequence[stepId] then
        print("WARNING: NPC:goToStep() - stepId " .. tostring(stepId) .. " does not exist in sequence.")
        return
    end

    self.currentStepId = stepId
    self:applyCurrentStep()
    self.tooltip:setVisible(false)
end