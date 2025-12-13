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

    self._x = (self.levelIndex - self.currentViewIndex) * 400
    self._y = 240
    self.newX = self._x

    self:moveTo(self._x, self._y)

    self.enter = false
    self:setSize(400, 240)
    self:setCenter(0, 0)

    self:setZIndex(2000)
end

function LevelOverview:reset()
    self.currentViewIndex = 1
    self._x = (self.levelIndex - self.currentViewIndex) * 400
    self.newX = self._x
    self._y = 240

    self.enabled = GameState.data.level["level" .. self.levelIndex]
end

function LevelOverview:draw()
    gfx.setColor(gfx.kColorBlack)

    local txt = self.enabled and self.name or "???"
    gfx.getSystemFont(gfx.font.kVariantBold):drawText(
        txt, 100, 20, 200, 39, 0, gfx.kWrapClip, gfx.kAlignCenter)

    gfx.drawRect(79, 49, 242, 146)

    if self.enabled then
        self.thumbnail:draw(80, 50)
    else
        LEVEL_LOCKED_IMG:draw(80, 50)
    end

    for _, sockIndex in ipairs(self.sockIndexes) do
        local sock = GameState.socks[sockIndex]
        if sock then
            local localSockIndex = sockIndex - (self.levelIndex - 1) * 5
            sock:drawAt(105 + (localSockIndex - 1) * 43, 210)
        else
            print("Sock index " .. sockIndex .. " not found")
        end
    end
end

function LevelOverview:setNewPos(pos)
    self.currentViewIndex += pos
    self.newX = (self.levelIndex - self.currentViewIndex) * 400
 end

function LevelOverview:setNewPosY(yOffset)
    self._y = yOffset
end

function LevelOverview:update()
    local step = 16

    local lastX = self._x

    if self._x < self.newX then
        self._x = math.min(self._x + step, self.newX)
    else
        self._x = math.max(self._x - step, self.newX)
    end
    self:moveTo(self._x, self._y)

    return lastX ~= self._x
end