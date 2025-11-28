class("LevelOverview").extends(playdate.graphics.sprite)

local gfx <const> = playdate.graphics

local LEVEL_LOCKED_IMG <const> = gfx.image.new("assets/images/levelThumbnails/level_locked")

function LevelOverview:init(config)
    LevelOverview.super.init(self)

    self.name = config.name
    self.levelIndex = config.levelIndex
    self.currentViewIndex = 1
    self.sockIndexes = config.sockIndexes
    self.enabled = config.enabled

    self.thumbnail = gfx.image.new("assets/images/levelThumbnails/level_" .. self.levelIndex) or LEVEL_LOCKED_IMG

    self.x = (self.levelIndex - self.currentViewIndex) * 400
    self.y = 0
    self.newX = self.x

    self.enter = false

    self:setZIndex(2000)
end

function LevelOverview:reset()
    self.currentViewIndex = 1
    self.x = (self.levelIndex - self.currentViewIndex) * 400
    self.newX = self.x
    self.y = 0

    self.enabled = GameState.data.level["level" .. self.levelIndex]
end

function LevelOverview:draw()
    gfx.setColor(gfx.kColorBlack)
    gfx.getSystemFont(gfx.font.kVariantBold):drawText(
        self.name, self.x + 100, self.y + 20, 200, 39, 0, gfx.kWrapClip, gfx.kAlignCenter)

    gfx.drawRect(self.x + 79, self.y + 49, 242, 146)

    if self.enabled then
        self.thumbnail:draw(self.x + 80, self.y + 50)
    else
        LEVEL_LOCKED_IMG:draw(self.x + 80, self.y + 50)
    end

    for _, sockIndex in ipairs(self.sockIndexes) do
        local sock = GameState.socks[sockIndex]
        if sock then
            local localSockIndex = sockIndex - (self.levelIndex - 1) * 5
            sock:drawAt(self.x + 105 + (localSockIndex - 1) * 43, self.y + 210)
        else
            print("Sock index " .. sockIndex .. " not found")
        end
    end
end

function LevelOverview:setNewPos(pos)
    self.currentViewIndex += pos
    self.newX = (self.levelIndex - self.currentViewIndex) * 400
end

function LevelOverview:update()
    if self.x == self.newX then return end

    local step = 10

    if self.x < self.newX then
        self.x = math.min(self.x + step, self.newX)
    else
        self.x = math.max(self.x - step, self.newX)
    end
end