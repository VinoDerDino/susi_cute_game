import "npcs/npc"

class('Sandy').extends(NPC)

function Sandy:init(config)
    if not config then return nil end
    Sandy.super.init(self)

    self.images = playdate.graphics.imagetable.new("assets/images/spritesheets/sandy")
    self:setImage(self.images:getImage(1))
    self:setZIndex(900)
    self:setCenter(0.5, 1)

    self.isPlayerNear = false

    self.frameCounter = 0
    self.currentAnimFrame = 2

    self:loadConfig(config)

    self.patrolling = true
    self.direction = "left"
    self.waiting = false

    self.waitCounter = 0
    self.walkingCounter = 0

    self.startX = self.x
    self.leftPatrolPos = self.startX - 40
    self.rightPatrolPos = self.startX + 40

    self.speed = 1
end

function Sandy:wait()
    self.waitCounter += 1
    if self.waitCounter >= 60 then
        self.waiting = false
        self.waitCounter = 0
        self.direction = (self.direction == "left") and "right" or "left"
    end

    if self.frameCounter % 20 == 0 then
        self.currentAnimFrame = (self.currentAnimFrame == 4) and 5 or 4
    end
    self.frameCounter += 1

    local flip = (self.direction == "left")
        and playdate.graphics.kImageFlippedX
        or playdate.graphics.kImageUnflipped
    self:setImage(self.images:getImage(self.currentAnimFrame), flip)
end

function Sandy:moveRight()
    self.position.x += self.speed
    if self.position.x >= self.rightPatrolPos then
        self.position.x = self.rightPatrolPos
        self.waiting = true
    end
    self:place(self.position.x, self.position.y)

    if not self.waiting then
        if self.frameCounter % 10 == 0 then
            self.currentAnimFrame = (self.currentAnimFrame == 6) and 7 or 6
        end
        self.frameCounter += 1

        local flip = playdate.graphics.kImageUnflipped
        self:setImage(self.images:getImage(self.currentAnimFrame), flip)
    end
end

function Sandy:moveLeft()
    self.position.x -= self.speed
    if self.position.x <= self.leftPatrolPos then
        self.position.x = self.leftPatrolPos
        self.waiting = true
    end
    self:place(self.position.x, self.position.y)

    if not self.waiting then
        if self.frameCounter % 10 == 0 then
            self.currentAnimFrame = (self.currentAnimFrame == 6) and 7 or 6
        end
        self.frameCounter += 1

        local flip = playdate.graphics.kImageFlippedX
        self:setImage(self.images:getImage(self.currentAnimFrame), flip)
    end
end

function Sandy:patrol()
    if self.waiting then
        self:wait()
    elseif self.direction == "left" then
        self:moveLeft()
    else
        self:moveRight()
    end
end

function Sandy:newPatrol()
    self.startX = self.x
    self.leftPatrolPos = self.startX - 80
    self.rightPatrolPos = self.startX + 80
end

function Sandy:sits()
    if self.isPlayerNear then
        if self.frameCounter % 15 == 0 then
            self.currentAnimFrame = (self.currentAnimFrame == 2) and 3 or 2
        end
        self.frameCounter += 1
    else
        self.currentAnimFrame = 1
        self.frameCounter = 0
    end

    local flip = (self.direction == "left")
        and playdate.graphics.kImageFlippedX
        or playdate.graphics.kImageUnflipped
    self:setImage(self.images:getImage(self.currentAnimFrame), flip)
end

function Sandy:update()
    if self.action == "patrol" and not self.isPlayerNear then
        if self.oldAction ~= self.action then
            self:newPatrol()
            self.oldAction = self.action
        end
        self:patrol()
    else
        self:sits()
    end
end

function Sandy:catchEvent(eventName, data)
    if eventName == "firstDoorOpened" then
        print("Sandy received firstDoorOpened event, going to next step")
        self:goToNextStep()
    end

    if eventName == "sandyGoToStep" then
        print("Sandy going to step: " .. tostring(data))
        self:goToStep(data)
    end

    if eventName == "sandyStartNextTalk" then
        self:goToStep(data)
        self:interact(true)
    end
end
