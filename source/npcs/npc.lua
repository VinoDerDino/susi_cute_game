class("NPC").extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics
local Point <const> = playdate.geometry.point

local sasser_slab_family <const> = gfx.font.newFamily({
    [gfx.font.kVariantNormal] = "assets/fonts/PixelifySans/PixelifySans-Regular",
    [gfx.font.kVariantBold] = "assets/fonts/PixelifySans/PixelifySans-Bold",
})

local TRIGGER_DISTANCE <const> = 50
local DIALOGUE_WIDTH <const> = 400
local DIALOGUE_HEIGHT <const> = 50

function NPC:init()
    NPC.super.init(self)

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

    EventSystem:addListener(self)
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
        if not self.isPlayerNear then
            print("Player not near")
            return
        end
    end

    local step = self.sequence[self.currentStepId]
    if not step then return end

    if self.dialogueBox then
        playdate.inputHandlers.push(self.dialogueBox:getInputHandlers())
        self.dialogueBox:enable()
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

function NPC:loadConfigOld(config)
    local stepMap = {}
    local firstStep = nil

    for _, step in ipairs(config) do
        stepMap[step.id] = step
    end

    firstStep = getFirstStep(config)
    if not firstStep then
        return
    end

    self.sequence = {}
    local currentStep = firstStep

    while currentStep do
        local nextStepId = getProperty(currentStep, "nextStep", false)
        local nextStep = nil
        if nextStepId and nextStepId ~= 0 then
            nextStep = stepMap[nextStepId]
        else
            nextStepId = nil
        end

        local onDialogueEnd = {}
        if nextStep then
            table.insert(onDialogueEnd, "goToNextStep")
        end

        table.insert(onDialogueEnd, getProperty(currentStep, "onDialogueEnd", nil))

        self.sequence[currentStep.id] = {
            position = Point.new(currentStep.x, currentStep.y),
            dialogue = getProperty(currentStep, "dialogue", nil),
            onDialogueEnd = onDialogueEnd,
            waitFor = getProperty(currentStep, "waitFor", nil),
            action = getProperty(currentStep, "action", nil),
            nextStepId = nextStepId
        }

        print("Loaded NPC step: " .. tostring(currentStep.id))

        currentStep = nextStep
    end

    self.currentStepId = firstStep.id
    self:applyCurrentStep()
end

function NPC:loadConfig(config)
    local stepMap = {}
    local firstStep = getFirstStep(config)
    if not firstStep then
        print("NPC config has no firstStep!")
        return
    end

    -- Schritt 1: Baue Lookup-Tabelle (alle Steps)
    for _, step in ipairs(config) do
        stepMap[step.id] = step
    end

    -- Schritt 2: Lade ALLE steps in self.sequence (nicht nur Kette!)
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

        -- nextStepId Validierung
        local nextId = self.sequence[id].nextStepId
        if nextId == 0 or nextId == false then
            self.sequence[id].nextStepId = nil
        elseif nextId and not stepMap[nextId] then
            print("WARNING: NPC step "..id.." points to missing nextStepId "..tostring(nextId))
            self.sequence[id].nextStepId = nil
        end
    end

    -- Schritt 3: Füge automatische "goToNextStep" Events ein
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

    -- Schritt 4: Setze den Startstep
    self.currentStepId = firstStep.id
    self:applyCurrentStep()
end

function NPC:applyCurrentStep()
    local step = self.sequence[self.currentStepId]
    if not step then return end

    self:place(step.position.x, step.position.y)

    if step.dialogue then
        self.dialogueBox = pdDialogueBox(step.dialogue, DIALOGUE_WIDTH, DIALOGUE_HEIGHT, sasser_slab_family)
        self.dialogueBox:setPadding(4)

        function self.dialogueBox:drawText(x, y, text)
            playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
            gfx.drawText(text, x, y, sasser_slab_family)
        end

        function self.dialogueBox:drawBackground(x, y)
            playdate.graphics.setColor(playdate.graphics.kColorBlack)
            playdate.graphics.fillRect(x, y, self.width, self.height)
        end

        function self.dialogueBox:drawPrompt(x, y)
            pdDialogueBox.arrowPrompt(x + self.width - 12, y + self.height - 10, gfx.kColorWhite)
        end

        function self.dialogueBox:onClose()
            playdate.inputHandlers.pop()

            if step.onDialogueEnd then
                for _, cmd in ipairs(step.onDialogueEnd) do
                    if cmd == "goToNextStep" and not step.waitFor then
                        self.npc:goToNextStep()
                    elseif cmd == "goToSameStep" then
                        self.npc:applyCurrentStep()
                    elseif cmd == "enableCranking" then
                        GameState:unlock("cranking")
                    end
                end
            else
                self.npc:goToNextStep()
            end
        end

        self.dialogueBox.npc = self
    else
        self.dialogueBox = nil
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
    if not nextStepId then
        return
    end

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