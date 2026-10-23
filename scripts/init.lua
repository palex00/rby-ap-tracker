ENABLE_DEBUG_LOG = false
-- get current variant
local variant = Tracker.ActiveVariantUID

print("-- Pokemon Red/Blue Archipelago Tracker --")
print("Loaded variant: ", variant)
if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

-- Utility Script for helper functions etc.
ScriptHost:LoadScript("scripts/watch.lua")
ScriptHost:LoadScript("scripts/utils.lua")

-- Logic
ScriptHost:LoadScript("scripts/logic/logic.lua")
ScriptHost:LoadScript("scripts/custom_items.lua")

-- CanReach region graph (locations bind to it with "^$CanReach|<apworld region>").
-- Order matters, the graph is built imperatively: helpers -> engine -> nodes -> connections.
-- logic.lua must come first: connections.lua captures its rule functions (surf, cut, ...) at
-- load time. There is no separate dark-area pass and no check-leaf file, unlike Crystal:
--   * Rock Tunnel's darkness is already on the graph's edges. The apworld splits each Rock
--     Tunnel room into door landings ("Rock Tunnel 1F-S 1") and the dark interior ("Rock Tunnel
--     1F-S"), with rock_tunnel() on the edges between them, so a shuffled door into Rock Tunnel
--     still has to pass the Flash gate.
--   * Location-specific rules (hidden items, Coin Case, ...) are ANDed in the location JSON.
ScriptHost:LoadScript("scripts/logic/logic_helpers.lua")
ScriptHost:LoadScript("scripts/logic/canreach.lua")
ScriptHost:LoadScript("scripts/logic/regions/region_definitions.lua")
ScriptHost:LoadScript("scripts/logic/regions/connections.lua")

ScriptHost:LoadScript("scripts/entrances/entrance_registry.lua")
ScriptHost:LoadScript("scripts/entrances/entrance_item.lua")
ScriptHost:LoadScript("scripts/entrances/er_state.lua")
ScriptHost:LoadScript("scripts/routing/route_mode.lua")
BuildEntranceKinds()

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/options.json")
Tracker:AddItems("items/dexsanity.json")
Tracker:AddItems("items/trainersanity.json")
Tracker:AddItems("items/events.json")

-- Maps
Tracker:AddMaps("maps/maps.json")
Tracker:AddMaps("maps/maps_boulder_vanilla.json")
Tracker:AddMaps("maps/maps_extrakey_vanilla.json")
   
-- Locations
Tracker:AddLocations("locations/locations.json")
Tracker:AddLocations("locations/encountertab.json")
Tracker:AddLocations("locations/pokedex.json")
Tracker:AddLocations("locations/submaps_deep_single.json")
Tracker:AddLocations("locations/submaps_deep_group.json")
Tracker:AddLocations("locations/submaps_overview.json")
Tracker:AddLocations("locations/meta_entrance.json")
Tracker:AddLocations("locations/submaps_entrances.json")

-- Layout
Tracker:AddLayouts("layouts/items_main_1_full.json")
Tracker:AddLayouts("layouts/itemgrids.json")
Tracker:AddLayouts("layouts/eventgrid.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/settings.json")
Tracker:AddLayouts("layouts/settings_quick.json")
Tracker:AddLayouts("layouts/submaps.json")
Tracker:AddLayouts("layouts/tabs_single.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- AutoTracking for Poptracker
ScriptHost:LoadScript("scripts/autotracking.lua")

-- Adds Watches for Item Grid Toggles
ScriptHost:AddWatchForCode("opt_cardkey", "opt_cardkey", toggle_itemgrid)
ScriptHost:AddWatchForCode("opt_stonesanity", "opt_stonesanity", toggle_itemgrid)
ScriptHost:AddWatchForCode("opt_extra_key_items", "opt_extra_key_items", toggle_maingrid)
ScriptHost:AddWatchForCode("opt_tea", "opt_tea", toggle_maingrid)

-- Adds Watches for Option Toggles
ScriptHost:AddWatchForCode("colormap", "colormap", toggle_grayscale)
ScriptHost:AddWatchForCode("colormap2", "colormap", toggle_boulders)
ScriptHost:AddWatchForCode("splitmap", "splitmap", toggle_splitmap)
ScriptHost:AddWatchForCode("opt_extra_boulders", "opt_extra_boulders", toggle_boulders)
ScriptHost:AddWatchForCode("colormap3", "colormap", toggle_extra_key_items)
ScriptHost:AddWatchForCode("opt_extra_key_items2", "opt_extra_key_items", toggle_extra_key_items)

ScriptHost:AddWatchForCode("er_doors", "er_doors", RefreshERSettings)
ScriptHost:AddWatchForCode("er_doors_layout", "er_doors", toggle_quick_settings)
ScriptHost:AddWatchForCode("er_warp_tiles", "er_warp_tiles", RefreshERSettings)
RefreshERSettings()

initialize_watch_items()

-- This is debug code
--for i = 1, 151 do
--    local obj = Tracker:FindObjectForCode("dexsanity_" .. i)
--    if obj then
--        obj.Active = true
--    end
--end