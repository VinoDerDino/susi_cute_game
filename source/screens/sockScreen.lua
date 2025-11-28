import 'util/sock'

class("SockScreen").extends(playdate.graphics.sprite)


function SockScreen:init()
    SockScreen.super.init(self)

    self:setZIndex(1000)
end

function SockScreen:show()
    for _, sock in ipairs(GameState.socks) do
        sock:add()
        sock:reset()
    end
    self:add()
end

function SockScreen:hide()
    for _, sock in ipairs(GameState.socks) do
        sock:remove()
    end
    self:remove()
end

function SockScreen:getSock(index)
    if index < 1 or index > #GameState.socks then
        print("WARNING: Invalid sock index: " .. tostring(index))
        return nil
    end

    return GameState.socks[index]
end

function SockScreen:update()
    if playdate.buttonJustPressed(playdate.kButtonB) then
        GameState:setState(GameState.states.MENU)
    end
end

function SockScreen:draw()

end