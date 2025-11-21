import 'util/sock'

class("SockScreen").extends(playdate.graphics.sprite)

local function createSocks()
    local socks = {}
    for i = 1, 25 do
        local sock = Sock(i)
        table.insert(socks, sock)
    end
    return socks
end

function SockScreen:init()
    self.socks = createSocks()
end

function SockScreen:show()
    for _, sock in ipairs(self.socks) do
        sock:addSprite()
        sock:setOwned()
    end
    self:addSprite()
end

function SockScreen:hide()
    for _, sock in ipairs(self.socks) do
        sock:remove()
    end
    self:remove()
end

function SockScreen:setSockOwned(index)
    if index < 1 or index > #self.socks then
        print("WARNING: Invalid sock index: " .. tostring(index))
        return
    end

    local sock = self.socks[index]
    sock:setOwned()
end

function SockScreen:update()
    if playdate.buttonJustPressed(playdate.kButtonB) then
        GameState:setState(GameState.states.MENU)
    end
end

function SockScreen:draw()

end