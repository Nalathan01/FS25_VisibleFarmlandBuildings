VisibleFarmlandBuildings = {}

VisibleFarmlandBuildings.DEBUG = false

local function revealHotspots(placeable)
    local spec = placeable.spec_hotspots
    if spec == nil or spec.mapHotspots == nil then
        return
    end

    for _, hotspot in ipairs(spec.mapHotspots) do
        if hotspot ~= nil and hotspot.setVisible ~= nil then
            hotspot:setVisible(true)
        end
    end

    if VisibleFarmlandBuildings.DEBUG then
        print(string.format("[VisibleFarmlandBuildings] Kartensymbole erzwungen sichtbar (%d Stück).", #spec.mapHotspots))
    end
end

if PlaceableHotspots == nil then
    print("[VisibleFarmlandBuildings] WARNUNG: PlaceableHotspots nicht gefunden - Mod kann nicht greifen. Bitte Log an den Autor schicken.")
else
    local originalOnPostFinalizePlacement = PlaceableHotspots.onPostFinalizePlacement
    PlaceableHotspots.onPostFinalizePlacement = function(self, ...)
        originalOnPostFinalizePlacement(self, ...)
        revealHotspots(self)
    end

    local originalOnOwnerChanged = PlaceableHotspots.onOwnerChanged
    PlaceableHotspots.onOwnerChanged = function(self, ...)
        originalOnOwnerChanged(self, ...)
        revealHotspots(self)
    end

    if VisibleFarmlandBuildings.DEBUG then
        print("[VisibleFarmlandBuildings] PlaceableHotspots erfolgreich überschrieben (Mod aktiv).")
    end
end
