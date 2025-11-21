class('Player').extends(playdate.graphics.sprite)

local JUMP_VELOCITY <const> = -290
local WALK_VELOCITY <const> = 150
local MAX_FALL_VELOCITY <const> = 600
local MAX_JUMP_VELOCITY <const> = -420
local STRAVING_ACCELERATION <const> = 2000
local STRAVING_VELOCITY <const> = WALK_VELOCITY / 1.2
local dt <const> = 1 / 50
local GRAVITY_CONSTANT <const> = 1600

local Point <const> = playdate.geometry.point
local vector2D <const> = playdate.geometry.vector2D

function Player:init()
    Player.super.init(self)

    self.images = playdate.graphics.imagetable.new("assets/images/spritesheets/susi")
    self:setImage(self.images:getImage(2))
    self:setZIndex(1000)
    self:setCenter(0.5, 1)
    self:setCollideRect(2, 0, 20, 20)
    -- self:setImageDrawMode(gfx.kDrawModeInverted)

    self.jumpTimer = playdate.frameTimer.new(10, 50, 30, playdate.easingFunctions.outQuad)
    self.jumpTimer.discardOnCompletion = false
    self.jumpTimer:pause()
    self.jumpTimer.active = false

    self.wallJumpsMax = 1
    self.wallJumps = 1
    self.canWallJump = false

    self.inputsEnabled = true

    self.respawnPoint = Point.new(50, 50)

    self.isClimbing = false
    self.isMoving = false
    self.movementEnabled = true

    self.imageDt = 0
    self.imageIndex = 1

    self.interacting = false
    self.interactDepleation = 0

    self.onPlatform = nil

    self.isDead = false

    self:reset()
end

function Player:reset()
    self.position = Point.new(50, 50)
    self.velocity = vector2D.new(0, 0)
    self:moveTo(self.position.x, self.position.y)

    self.onGround = false
    self.facing = "left"
end

function Player:respawn(x, y)
    self.position = Point.new(x and x or self.respawnPoint.x, y and y or self.respawnPoint.y)
    self.velocity = vector2D.new(0, 0)
    self:moveTo(self.position.x, self.position.y)

    self.onGround = false
    self.facing = "left"

    SoundManager:playSound(SoundManager.kDeath)
end

function Player:setRespawnPoint(x, y)
    self.respawnPoint = Point.new(x, y)
end

function Player:collisionResponse(other)
    if other:isa(Prop) or other:isa(TriggerBox) or other:isa(Twine) then
        return 'overlap'
    end

    return 'slide'
end

function Player:setOnGround(flag)
    self.onGround = flag
end

function Player:walkLeft()
    self.velocity.x = -WALK_VELOCITY
    self.facing = "left"
end

function Player:walkRight()
    self.velocity.x = WALK_VELOCITY
    self.facing = "right"
end

function Player:performJump()
    self.velocity.y = JUMP_VELOCITY
    if self.onPlatform then
        self.position.y = self.onPlatform.y - self.onPlatform.height - 2
    end
    self:setOnGround(false)

    self.jumpTimer:reset()
    self.jumpTimer:start()

    if self.isClimbing then
        self.isClimbing = false
    end
end

function Player:jump()
    if self.onGround or self.isClimbing then
        self:performJump()
    elseif self.wallJumps > 0 and self.canWallJump then
        self:performJump()
        self.wallJumps -= 1
        self.velocity.x = self.facing == "left" and WALK_VELOCITY * 1.5 or -WALK_VELOCITY * 1.5
    end
end

function Player:continueJump()
    if self.jumpTimer.frame == self.jumpTimer.duration then
        return
    end
    self.velocity.y -= self.jumpTimer.value
end

function Player:resetWallJumps()
    self.wallJumps = self.wallJumpsMax
    self.canWallJump = false
end

function Player:pound()
    self.isPounding = true
    self.velocity.y = MAX_FALL_VELOCITY / 2
end

function Player:setClimbing(flag)
    self.isClimbing = flag
end

function Player:updateImage()
    local oldImageIndex = self.imageIndex
    self.imageDt = self.imageDt + 1
    local frame = math.floor(self.imageDt / 20) % 2
    if self.interacting then
        self.imageIndex = 5 + frame
        self:setImage(self.images:getImage(self.imageIndex))
    elseif self.isClimbing then
        if self.isMoving then
            self.imageIndex = 7 + frame
            self:setImage(self.images:getImage(self.imageIndex))
            if oldImageIndex ~= self.imageIndex then
                SoundManager:playSound(SoundManager.kClimb)
            end
        else
            self.imageIndex = 7
            self:setImage(self.images:getImage(self.imageIndex))
        end
    elseif self.onGround then
        if self.velocity.x ~= 0 then
            if self.facing == "left" then
                self.imageIndex = 3 + frame
                self:setImage(self.images:getImage(self.imageIndex), "flipX")
            else
                self.imageIndex = 3 + frame
                self:setImage(self.images:getImage(self.imageIndex))
            end
            if oldImageIndex ~= self.imageIndex then
                SoundManager:playSound(SoundManager.kStepSusi)
            end
        else
            if self.facing == "left" then
                self:setImage(self.images:getImage(2), "flipX")
            else
                self:setImage(self.images:getImage(2))
            end
        end
    else
        if self.facing == "left" then
            self:setImage(self.images:getImage(1), "flipX")
        else
            self:setImage(self.images:getImage(1))
        end
    end
end

function Player:climb()
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self:walkLeft()
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then
        self:walkRight()
    else
        self.velocity.x = 0
    end

    if not self.jumpTimer.active then
        if playdate.buttonIsPressed(playdate.kButtonUp) then
            self.velocity.y = -WALK_VELOCITY / 2
        elseif playdate.buttonIsPressed(playdate.kButtonDown) then
            self.velocity.y = WALK_VELOCITY / 2
        else
            self.velocity.y = 0
        end
    end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        self:jump()
    elseif playdate.buttonIsPressed(playdate.kButtonA) and not self.isClimbing then
        self:continueJump()
    end

    local velocityStep = self.velocity * dt
    self.position = self.position + velocityStep
end

function Player:setMovementEnabled(flag)
    self.movementEnabled = flag
end

function Player:setInteracting(flag)
    self.interacting = flag
    if self.interacting then
        self.interactDepleation = 50
    end
end

function Player:setOnPlatform(platform)
    self.onPlatform = platform
end

function Player:normalMovement()

    if playdate.buttonIsPressed(playdate.kButtonLeft) and self.movementEnabled then
        if self.onGround then
            self:walkLeft()
        else
            self.velocity.x = math.max(self.velocity.x - STRAVING_ACCELERATION * dt, -STRAVING_VELOCITY)
        end
    elseif playdate.buttonIsPressed(playdate.kButtonRight) and self.movementEnabled then
        if self.onGround then
            self:walkRight()
        else
            self.velocity.x = math.min(self.velocity.x + STRAVING_ACCELERATION * dt, STRAVING_VELOCITY)
        end
    elseif not self.onGround then
        self.velocity.x = self.velocity.x * 0.9
        if math.abs(self.velocity.x) < 1 then
            self.velocity.x = 0
        end
    else
        self.velocity.x = 0
    end

    if playdate.buttonJustPressed(playdate.kButtonA) and self.movementEnabled  then
        self:jump()
        SoundManager:playSound(SoundManager.kJump)
    elseif playdate.buttonIsPressed(playdate.kButtonA) and self.movementEnabled then
        self:continueJump()
    end

    if playdate.buttonJustPressed(playdate.kButtonB) and self.movementEnabled  then
        self:pound()
    end

    if self.isPounding then
        self.velocity.x = 0
        if self.onGround then
            self.isPounding = false
        end
    end

    self.velocity.y = self.velocity.y + GRAVITY_CONSTANT * dt

    local velocityStep = self.velocity * dt
    self.position = self.position + velocityStep

    if self.velocity.y > MAX_FALL_VELOCITY then
        self.velocity.y = MAX_FALL_VELOCITY
    elseif self.velocity.y < MAX_JUMP_VELOCITY then
        self.velocity.y = MAX_JUMP_VELOCITY
    end
end

function Player:update()
    self.isMoving = false
    if self.isClimbing then
        print("climbing")
        self:climb()
    else
        self:normalMovement()
    end

    if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
        self.isMoving = true
    end

    self:updateImage()
    self.interactDepleation = self.interactDepleation - 1
    if self.interactDepleation <= 0 then
        self:setInteracting(false)
    end
end