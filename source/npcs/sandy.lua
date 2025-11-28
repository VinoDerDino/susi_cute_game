import "npcs/npc"

class('Sandy').extends(NPC)

local SANDY_FRAMES <const> = {
    sleep = 1,
    sit_1 = 2,
    sit_2 = 3,
    wait_1 = 4,
    wait_2 = 5,
    walk_1 = 6,
    walk_2 = 7,
    hide_1 = 8,
    hide_2 = 9,
    hide_3 = 10,
    hide_4 = 11,
    hide_show_head = 12,
}

function Sandy:init(config)
    if not config then return nil end
    Sandy.super.init(self)

    self.images = playdate.graphics.imagetable.new("assets/images/npcs/sandy")
    self:setImage(self.images:getImage(SANDY_FRAMES.sleep))
    self:setZIndex(900)
    self:setCenter(0.5, 1)

    self.isPlayerNear = false

    self.frameCounter = 0
    self.currentAnimFrame = SANDY_FRAMES.sit_1

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
        self.currentAnimFrame = (self.currentAnimFrame == SANDY_FRAMES.wait_1) and SANDY_FRAMES.wait_2 or SANDY_FRAMES.wait_1
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
            self.currentAnimFrame = (self.currentAnimFrame == SANDY_FRAMES.walk_1) and SANDY_FRAMES.walk_2 or SANDY_FRAMES.walk_1
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
            self.currentAnimFrame = (self.currentAnimFrame == SANDY_FRAMES.walk_1) and SANDY_FRAMES.walk_2 or SANDY_FRAMES.walk_1
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
            self.currentAnimFrame = (self.currentAnimFrame == SANDY_FRAMES.sit_1) and SANDY_FRAMES.sit_2 or SANDY_FRAMES.sit_1
        end
        self.frameCounter += 1
    else
        self.currentAnimFrame = SANDY_FRAMES.sleep
        self.frameCounter = 0
    end

    local flip = (self.direction == "left")
        and playdate.graphics.kImageFlippedX
        or playdate.graphics.kImageUnflipped
    self:setImage(self.images:getImage(self.currentAnimFrame), flip)
end

function Sandy:hide()
    self.frameCounter += 1
    if self.isPlayerNear then
        self.currentAnimFrame = SANDY_FRAMES.hide_show_head
        self.frameCounter = 0
    else
        if self.frameCounter % 15 == 0 then
            self.currentAnimFrame += 1
            if self.currentAnimFrame > SANDY_FRAMES.hide_4 then
                self.currentAnimFrame = SANDY_FRAMES.hide_1
            end
        end
    end

    self:setImage(self.images:getImage(self.currentAnimFrame))
end

function Sandy:update()
    if self.action == "patrol" and not self.isPlayerNear then
        if self.oldAction ~= self.action then
            self:newPatrol()
            self.oldAction = self.action
        end
        self:patrol()
    elseif self.action == "hide" then
        self:hide()
    else
        self:sits()
    end
end

function Sandy:catchEvent(eventName, data)
    if eventName == "firstDoorOpened" or eventName == "rescueSandy" then
        self:goToNextStep()
    end

    if eventName == "sandyGoToStep" then
        self:goToStep(data)
    end

    if eventName == "sandyStartNextTalk" then
        self:goToStep(data)
        self:interact(true)
    end
end
