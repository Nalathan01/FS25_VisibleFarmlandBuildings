VisibleFarmlandBuildings = {}
VisibleFarmlandBuildings.modDirectory = g_currentModDirectory
VisibleFarmlandBuildings.modName = g_currentModName

source(VisibleFarmlandBuildings.modDirectory .. "scripts/VisibleFarmlandBuildingsSettings.lua")

VisibleFarmlandBuildings.settings = VisibleFarmlandBuildingsSettings.new(VisibleFarmlandBuildings)
VisibleFarmlandBuildings.settings:install()

function VisibleFarmlandBuildings:loadMap()
    self.settings:install()
    self.settings:loadSettings()
    self.settings:initializeSettingsOption()
end

local function getHotspotType(hotspot)
    if hotspot.getPlaceableType ~= nil then
        return hotspot:getPlaceableType()
    end
    return hotspot.placeableType
end

local function isOwnedByLocalFarm(placeable)
    if placeable.getOwnerFarmId == nil or g_currentMission == nil or g_currentMission.getFarmId == nil then
        return false
    end
    local ownerFarmId = placeable:getOwnerFarmId()
    return ownerFarmId ~= nil and ownerFarmId == g_currentMission:getFarmId()
end

local function applyHotspotVisibility(placeable)
    local spec = placeable.spec_hotspots
    if spec == nil or spec.mapHotspots == nil then
        return
    end

    local hideFarmType = not VisibleFarmlandBuildings.settings:isEnabled()
    local farmType = PlaceableHotspot ~= nil and PlaceableHotspot.TYPE ~= nil and PlaceableHotspot.TYPE.FARM or nil
    local ownedByMe = hideFarmType and isOwnedByLocalFarm(placeable)

    for _, hotspot in ipairs(spec.mapHotspots) do
        if hotspot ~= nil and hotspot.setVisible ~= nil then
            local isFarmType = farmType ~= nil and getHotspotType(hotspot) == farmType
            if isFarmType and hideFarmType and not ownedByMe then
                hotspot:setVisible(false)
            else
                hotspot:setVisible(true)
            end
        end
    end
end

function VisibleFarmlandBuildings.refreshAllHotspots()
    if g_currentMission == nil or g_currentMission.placeableSystem == nil or g_currentMission.placeableSystem.placeables == nil then
        return
    end
    for _, placeable in ipairs(g_currentMission.placeableSystem.placeables) do
        applyHotspotVisibility(placeable)
    end
end

if PlaceableHotspots == nil then
    Logging.warning("[VisibleFarmlandBuildings] PlaceableHotspots nicht gefunden, Mod kann nicht greifen.")
else
    local originalOnPostFinalizePlacement = PlaceableHotspots.onPostFinalizePlacement
    PlaceableHotspots.onPostFinalizePlacement = function(self, ...)
        originalOnPostFinalizePlacement(self, ...)
        applyHotspotVisibility(self)
    end

    local originalOnOwnerChanged = PlaceableHotspots.onOwnerChanged
    PlaceableHotspots.onOwnerChanged = function(self, ...)
        originalOnOwnerChanged(self, ...)
        applyHotspotVisibility(self)
    end
end

addModEventListener(VisibleFarmlandBuildings)
