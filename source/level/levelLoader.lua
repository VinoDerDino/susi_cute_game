import 'props/crank'
import 'props/platform'
import 'props/door'
import 'props/triggerBox'
import 'props/movingTile'
import 'props/twine'
import 'props/spike'
import 'props/brick'
import 'props/floatingPlatform'
import 'props/sock'
import 'props/spring'
import 'props/water'
import 'props/lever'

function getJSONTableFromTiledFile(path)

	local levelData = nil
	local f = playdate.file.open(path)
	if f then
		local s = playdate.file.getSize(path)
		levelData = f:read(s)
		f:close()

		if not levelData then
			print('ERROR LOADING DATA for ' .. path)
			return nil
		end
	end
	local jsonTable = json.decode(levelData)
	if not jsonTable then
		print('ERROR PARSING JSON DATA for ' .. levelPath)
		return nil
	end

	return jsonTable
end

local function getTilesetsFromJSON(jsonTable)
	local tilesets = {}
	for i=1, #jsonTable.tilesets do
		local tileset = jsonTable.tilesets[i]
		local newTileset = {}

		newTileset.firstgid = tileset.firstgid
		newTileset.lastgid = tileset.firstgid + tileset.tilecount - 1
		newTileset.name = tileset.name
		newTileset.tileHeight = tileset.tileheight
		newTileset.tileWidth = tileset.tilewidth
		local tilesetImageName = string.sub(tileset.image, 1, string.find(tileset.image, '-table-') - 1)
		newTileset.imageTable = playdate.graphics.imagetable.new("assets/images/spritesheets/" .. tilesetImageName)
		tilesets[i] = newTileset
	end

	return tilesets
end

local function tilesetWithName(tilesets, name)
    for _, ts in ipairs(tilesets) do
        if ts.name == name then
            return ts
        end
    end
    return nil
end

local function tilesetNameForProperties(properties)
	for key, property in ipairs(properties) do
		if property.name == 'tilesetName' then
			return property.value
		end
	end
	return nil
end

function importTilemapsFromTiledJSON(jsonTable)
    local tilesets = getTilesetsFromJSON(jsonTable)

    local layers = {}

    for i = 1, #jsonTable.layers do
        local level = {}

		local layer = jsonTable.layers[i]

		if layer.type ~= "tilelayer" then goto continue end

		level.name = layer.name
		level.x = layer.x
		level.y = layer.y
		level.tileHeight = layer.height
		level.tileWidth = layer.width

        local tileset = nil
		local tilesetName = tilesetNameForProperties(layer.properties)
		if tilesetName ~= nil then
			tileset = tilesetWithName(tilesets, tilesetName)
		end

        if tileset ~= nil then
            level.pixelHeight = level.tileHeight * tileset.tileHeight
			level.pixelWidth = level.tileWidth * tileset.tileWidth

            local tilemap = playdate.graphics.tilemap.new()
			tilemap:setImageTable(tileset.imageTable)
			tilemap:setSize(level.tileWidth, level.tileHeight)

            local indexModifier = tileset.firstgid-1
			local tileData = layer.data

            local x = 1
			local y = 1

			local width = level.tileWidth
            local height = level.tileHeight
            for row = 1, height do
                for col = 1, width do
                    local idx = (row - 1) * width + col
                    local tileIndex = tileData[idx]
                    if tileIndex and tileIndex > 0 then
                        tileIndex = tileIndex - indexModifier
                        tilemap:setTileAtPosition(col, row, tileIndex)
                    end
                end
            end

			level.tilemap = tilemap
			layers[layer.name] = level
        end

		::continue::
    end

    return layers
end

local function getProperty(objData, propertyName)
    if not objData.properties then return nil end

    for _, prop in ipairs(objData.properties) do
        if prop.name == propertyName then
            return prop.value
        end
    end
    return nil
end

local function getObjectById(objectsById, id, objectType)
    local obj = objectsById[id]
    if not obj then
        print(string.format("WARNING: %s missing object with id: %s", objectType, tostring(id)))
    end
    return obj
end

local objectCreators = {
    Door = function(objData, objectsById, objectTable, cache)
        local emitEvent = getProperty(objData, "emitEvent") or nil
        print("Created doot with emitEvent: " .. tostring(emitEvent))
        local door = Door(objData.x , objData.y, objData.height, emitEvent)
        return door
    end,

    Platform = function(objData, objectsById, objectTable, cache)
        local endPointId = getProperty(objData, "endPoint")
        local endPoint = getObjectById(objectsById, endPointId, "Platform")

        if not endPoint then return nil end

        local platform = Platform(objData.x, objData.y, endPoint.x, endPoint.y)
        table.insert(objectTable, platform)
        return platform
    end,

    FloatingPlatform = function(objData, objectsById, objectTable, cache)
        local endPointId = getProperty(objData, "endPoint")
        local endPoint = getObjectById(objectsById, endPointId, "Platform")
        if not endPoint then return nil end

        local floatingPlatform = FloatingPlatform(objData.x, objData.y, endPoint.y)
        table.insert(objectTable, floatingPlatform)
        return floatingPlatform
    end,

    Crank = function(objData, objectsById, objectTable, cache)
        local targetId = getProperty(objData, "otherProp")
        local targetData = getObjectById(objectsById, targetId, "Crank")

        if not targetData then return nil end

        local target = createObjects(targetData, objectsById, objectTable, cache)
        if not target then return nil end

        local crank = Crank(objData.x, objData.y, target)
        table.insert(objectTable, crank)
        table.insert(objectTable, target)
        return crank
    end,

    MovingTile = function(objData, objectsById, objectTable, cache)
        local endPointId = getProperty(objData, "endPoint")
        local endPoint = getObjectById(objectsById, endPointId, "MovingTile")

        if not endPoint then return nil end

        local movingTile = MovingTile(objData.x, objData.y, endPoint.x, endPoint.y)
        table.insert(objectTable, movingTile)
        return movingTile
    end,

    Spike = function(objData, objectsById, objectTable, cache)
        local endPointId = getProperty(objData, "resetPoint")
        local endPoint = getObjectById(objectsById, endPointId, "Spike")
        local rotation = getProperty(objData, "rotation") or nil

        if not endPoint then return nil end

        local spike = Spike(objData.x, objData.y, endPoint.x, endPoint.y, rotation)
        table.insert(objectTable, spike)
        return spike
    end,

    Twine = function(objData, objectsById, objectTable, cache)
        local endPointId = getProperty(objData, "endPoint")
        local endPoint = getObjectById(objectsById, endPointId, "Twine")

        if not endPoint then return nil end

        local twine = Twine(objData.x, objData.y, endPoint.y)
        table.insert(objectTable, twine)
        return twine
    end,

    Brick = function(objData, objectsById, objectTable, cache)
        local disappearsOn = getProperty(objData, "disappearsOn") or nil
        local brick = Brick(objData.x, objData.y, disappearsOn)
        table.insert(objectTable, brick)
        return brick
    end,

    SockProp = function(objData, objectsById, objectTable, cache)
        local sockId = getProperty(objData, "id")
        if not sockId then
            print("WARNING: SockProp missing sockId property for object id: " .. tostring(objData.id))
            return nil
        end

        local sockProp = SockProp(sockId, objData.x, objData.y)
        table.insert(objectTable, sockProp)
        return sockProp
    end,

    Spring = function(objData, objectsById, objectTable, cache)
        local strength = getProperty(objData, "strength") or 400
        local spring = Spring(objData.x, objData.y, strength)
        table.insert(objectTable, spring)
        return spring
    end,

    Water = function(objData, objectsById, objectTable, cache)
        local water = Water(objData.x, objData.y, objData.width, objData.height)
        table.insert(objectTable, water)
        return water
    end,

    Lever = function(objData, objectsById, objectTable, cache)
        local emitEvent = getProperty(objData, "emitEvent") or nil
        local lever = Lever(objData.x, objData.y, emitEvent)
        table.insert(objectTable, lever)
        return lever
    end,
}

function createObjects(objData, objectsById, objectTable, cache)
    if not objData or not objData.type then return nil end

    if cache[objData.id] then
        return cache[objData.id]
    end

    local creator = objectCreators[objData.type]
    if creator then
        local obj = creator(objData, objectsById, objectTable, cache)
        if obj then
            cache[objData.id] = obj
        end
        return obj
    end

    return nil
end

function importObjectsFromTiledJSON(jsonTable)
    local objectsById = {}
    for _, layer in ipairs(jsonTable.layers) do
        if layer.type == "objectgroup" and layer.name == "props" then
            for _, objData in ipairs(layer.objects) do
                objectsById[objData.id] = objData
            end
        end
    end

    local objects = {}
    local cache = {}

    for id, objData in pairs(objectsById) do
        createObjects(objData, objectsById, objects, cache)
    end

    return objects
end

function getSandyConfig(jsonTable)
	for _, layer in ipairs(jsonTable.layers) do
		if layer.type == "objectgroup" and layer.name == "sandy" then
			return layer.objects
		end
	end

	return nil
end

function importTriggersFromTiledJSON(jsonTable)
    for _, layer in ipairs(jsonTable.layers) do
        if layer.type == "objectgroup" and layer.name == "triggerPoints" then
            local triggers = {}
            for _, objData in ipairs(layer.objects) do
                local toEmit = getProperty(objData, "toEmit") or nil
                local data = getProperty(objData, "data") or nil
                local oneTime = getProperty(objData, "oneTime") or false
                if toEmit then
                    local triggerBox = TriggerBox(objData.x, objData.y, objData.width, objData.height, toEmit, data, oneTime)
                    table.insert(triggers, triggerBox)
                end
            end
            return triggers
        end
    end

    return nil
end

function importSpikesFromTiledJSON(jsonTable)
    local objectsById = {}
    for _, layer in ipairs(jsonTable.layers) do
        if layer.type == "objectgroup" and layer.name == "spikes" then
            for _, objData in ipairs(layer.objects) do
                objectsById[objData.id] = objData
            end
        end
    end

    local spikes = {}
    local cache = {}

    for id, objData in pairs(objectsById) do
        createObjects(objData, objectsById, spikes, cache)
    end

    return spikes
end

function getMapPropertiesFromTiledJSON(jsonTable)
    local jsonProperties = jsonTable.properties
    if not jsonProperties then return nil end
    local properties = {}

    for _, prop in ipairs(jsonProperties) do
        properties[prop.name] = prop.value
    end

    return properties
end