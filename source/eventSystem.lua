local EventSystem = {
    listeners = {}
}

function EventSystem:addListener(listener)
    table.insert(self.listeners, listener)
end

function EventSystem:removeListener(listener)
    for i, l in ipairs(self.listeners) do
        if l == listener then
            table.remove(self.listeners, i)
            break
        end
    end
end

function EventSystem:emitEvent(eventName, data)
    for _, listener in ipairs(self.listeners) do
        if listener.catchEvent then
            listener:catchEvent(eventName, data)
        end
    end
end

_G.EventSystem = EventSystem