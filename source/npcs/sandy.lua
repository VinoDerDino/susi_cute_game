import "npcs/npc"

class('Sandy').extends(NPC)

local Point <const> = playdate.geometry.point

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
    Sandy.super.init(self, "sandy_portrait")
    
    
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
    self.randomPatrolTime = 0
    self.nextChangeTime = math.random(150, 200)

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
    local isAtEnd = false
    self.position.x += self.speed
    if self.position.x >= self.rightPatrolPos then
        self.position.x = self.rightPatrolPos
        self.waiting = true
        isAtEnd = true
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

    return isAtEnd
end

function Sandy:moveLeft()
    local isAtEnd = false
    self.position.x -= self.speed
    if self.position.x <= self.leftPatrolPos then
        self.position.x = self.leftPatrolPos
        self.waiting = true
        isAtEnd = true
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

    return isAtEnd
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

function Sandy:setPatrolAction()
    local action = math.random(1, 2)
    if action == 1 or self.waiting == true then
        self.direction = (math.random() < 0.5) and "left" or "right"
        self.nextChangeTime = math.random(150, 200)
    else
        self.waiting = true
        self.nextChangeTime = math.random(200, 300)
    end
    self.randomPatrolTime = 0
end

function Sandy:randomPatrol()
    self.randomPatrolTime += 1
    if self.randomPatrolTime >= self.nextChangeTime then
        self:setPatrolAction()
    end

    if self.waiting then
        self:wait()
    elseif self.direction == "left" then
        if self:moveLeft() then
            self:setPatrolAction()
        end
    else
        if self:moveRight() then
            self:setPatrolAction()
        end
    end
end

function Sandy:newPatrol()
    self.startX = self.x
    self.leftPatrolPos = self.startX - 80
    self.rightPatrolPos = self.startX + 80
end

function Sandy:newMenuPatrol()
    self.startX = self.x
    self.leftPatrolPos = self.startX - 190
    self.rightPatrolPos = self.startX + 190
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

function Sandy:initComeFromRight()
    local roomX = math.floor(self.position.x / 400) + 1
    self.endPosition = self.position
    self.position = Point.new(roomX * 400 + 25, self.endPosition.y)
    self.initComeFromRight = false
end

function Sandy:comeFromRight()
    self.position.x -= self.speed
    if self.position.x <= self.endPosition.x then
        self.position.x = self.endPosition.x
        self:place(self.position.x, self.position.y)
        return true
    end

    self:place(self.position.x, self.position.y)
    if self.frameCounter % 10 == 0 then
        self.currentAnimFrame = (self.currentAnimFrame == SANDY_FRAMES.walk_1) and SANDY_FRAMES.walk_2 or SANDY_FRAMES.walk_1
    end
    self.frameCounter += 1

    self:setImage(self.images:getImage(self.currentAnimFrame), playdate.graphics.kImageFlippedX)

    return false
end

function Sandy:update()
    if self.action == "comeFromRight" then
        if self.oldAction ~= self.action then
            self:initComeFromRight()
            self.oldAction = self.action
        end
        if self:comeFromRight() then self.action = nil end
    elseif self.action == "hide" then
        self:hide()
    elseif self.action == "patrol" and not self.isPlayerNear then
        if self.oldAction ~= self.action then
            self:newPatrol()
            self.oldAction = self.action
        end
        self:patrol()
    elseif self.action == "patrolMenu" then
        if self.oldAction ~= self.action then
            self:newMenuPatrol()
            self.oldAction = self.action
        end
        self:randomPatrol()
    else
        self:sits()
    end
end

function Sandy:catchEvent(eventName, data)
    if eventName == "firstDoorOpened" or eventName == "rescueSandy" or eventName == "doorOpened" then
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
