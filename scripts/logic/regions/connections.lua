-- Region connections for Pokemon Red/Blue, ported from the apworld (worlds/pokemon_rb/regions.py).
-- Originally generated: walking edges from every connect(...) in create_regions(), warp edges
-- from warp_data. Keep in sync with regions.py by hand from here on.
--
-- Every transition carries its apworld entrance name as its token, verbatim: walking edges use
-- connect()'s name ("<source> to <target>" unless the apworld overrides it, e.g. "... (Fly)"),
-- warps use warp_data's name ("<region> to <to.map>" unless overridden, e.g. "Celadon City to
-- Celadon Department Store 1F W"). Pretty names are looked up by token (not here).
--
--   WALKING  connect_one_way(node, token [, rule])    never shuffled, may carry a logic rule.
--            connect() in the apworld is two-way unless one_way=True; both directions are
--            spelled out below, each with its own token and the shared rule.
--   WARP     connect_warp(node, token, ER_KIND)       vanilla target = warp_data's to.map; the
--            ER_KIND says under which door-shuffle settings it is shuffled (see canreach.lua
--            WarpShuffled). Vanilla warps have no rule, exactly like the apworld's unshuffled
--            connect(); the elevator Lift Key rule only applies once a warp is shuffled.
--
-- Rules return an AccessibilityLevel (the pack's has()/cut()/surf()/... all do). Mix them with
-- ALL/ANY, never and/or: AccessibilityLevel.None == 0 is truthy in Lua. reach(region) reads
-- another region's cached level for the apworld's event items (Game Corner, Buy Poke Doll,
-- Victory Road Boulder, ...), which in the apworld are locked events inside that region.
--
-- Loaded after region_definitions.lua.

local R = NAMED_NODES

-- ER kinds (see door_shuffle() in regions.py). Shared tables; WarpShuffled() reads them.
local ER_EXTERIOR = {} -- exterior <-> interior: shuffled from Simple up
local ER_INTERIOR = { interior = true } -- interior <-> interior: shuffled from Full up
local ER_WARP_TILE = { warp_tile = true } -- Silph Co / Saffron Gym warp tiles: own setting
local ER_SIMPLE_ON = { interior = true, simple = true } -- Game Corner stairs <-> Rocket Hideout B1F: interior, but Simple shuffles it
local ER_SIMPLE_OFF = { simple = false } -- Celadon City <-> Game Corner: exterior, but Simple keeps it
local ER_FIXED_FULL = { interior = true, fixed = { [3] = true, [4] = true, [5] = true } } -- Player's House stairs / Elite Four chain: always paired vanilla
local ER_FIXED_SIMPLE = { fixed = { [1] = true } } -- Fuchsia <-> Safari Zone Gate: vanilla in Simple
local ER_FIXED_SAFARI = { fixed = { [1] = true, [2] = true } } -- Safari Zone's own doors: vanilla in Simple/Interiors, randomly forced (but shown) from Full up

-- Walking-edge rules (apworld lambda -> pack logic).
local function card_key_2() return cardkey(2) end
local function card_key_3() return cardkey(3) end
local function card_key_4() return cardkey(4) end
local function card_key_5() return cardkey(5) end
local function card_key_6() return cardkey(6) end
local function card_key_7() return cardkey(7) end
local function card_key_8() return cardkey(8) end
local function card_key_9() return cardkey(9) end
local function card_key_10() return cardkey(10) end
local function card_key_11() return cardkey(11) end
local function cerulean_cave() return ALL(ceruleancave, surf) end
local function fuji_saved() return has("EVENT_RESCUED_MR_FUJI") end
local function giovanni_beaten() return has("EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI") end
local function good_rod() return has("goodrod") end
local function hideout_key() return ANY(has("hideoutkey"), has("opt_extra_key_items_off")) end
local function lift_key() return has("liftkey") end
local function mansion_key() return ANY(has("mansionkey"), has("opt_extra_key_items_off")) end
local function old_man_or_cut() return ANY(old_man, cut) end
local function old_rod() return has("oldrod") end
local function plant_key() return ANY(has("plantkey"), has("opt_extra_key_items_off")) end
local function poke_flute() return has("pokeflute") end
local function safari_pass() return ANY(has("safaripass"), has("opt_extra_key_items_off")) end
-- Kept from the pack: with the Mt Moon fossils in reach, the second check is a sequence break.
local function second_fossil_check() return ANY(fossil_checks(), ACCESS_SEQUENCEBREAK) end
local function secret_key() return has("secretkey") end
local function silph_liberated() return has("EVENT_BEAT_SILPH_CO_GIOVANNI") end
local function ss_ticket() return has("ssticket") end
local function strength_seafoam_boulders() return ALL(strength, seafoam_exit_boulders) end
local function strength_victory_road_boulder() return ALL(strength, reach("Victory Road 3F-S")) end
local function super_rod() return has("superrod") end
local function surf_or_cut() return ANY(surf, cut) end
local function surf_strength_seafoam_boulders() return ALL(surf, strength, seafoam_exit_boulders) end
local function tower_ghost() return ANY(has("silphscope"), ALL(has("opt_pokedoll_skip_on"), reach("Celadon Department Store 4F"))) end

-- The game starts in Pallet Town. Structural edge: no token, never routed.
-- The apworld's Menu origin and its Pokedex / Evolution / Fossil Level side regions are left
-- out: no tracker location binds to them.
Entry_point:connect_one_way(R["Pallet Town"])

-- Fly: the apworld only adds a Menu -> town edge for this seed's free fly and Town Map fly
-- destinations; the pack tracks those as fly_<town> / map_fly_<town> codes read by flyto().
for _, fly in ipairs({
    { "pallet", "Pallet Town" },
    { "viridian", "Viridian City" },
    { "pewter", "Pewter City" },
    { "cerulean", "Cerulean City" },
    { "lavender", "Lavender Town" },
    { "vermilion", "Vermilion City" },
    { "celadon", "Celadon City" },
    { "fuchsia", "Fuchsia City" },
    { "cinnabar", "Cinnabar Island" },
    { "indigo", "Indigo Plateau" },
    { "saffron", "Saffron City" },
}) do
    local code, region = fly[1], fly[2]
    Entry_point:connect_one_way(R[region], "Fly to " .. region, function() return flyto(code) end)
end

-- === Celadon City ===
R["Celadon City"]:connect_one_way(R["Route 10/Celadon Fishing"], "Celadon City to Route 10/Celadon Fishing", super_rod)
R["Celadon City"]:connect_one_way(R["Route 7"], "Celadon City to Route 7")
R["Celadon City"]:connect_one_way(R["Celadon City-G"], "Celadon City to Celadon City-G", cut)
R["Celadon City"]:connect_one_way(R["Route 16-E"], "Celadon City to Route 16-E")
R["Celadon City"]:connect_warp(R["Celadon Department Store 1F"], "Celadon City to Celadon Department Store 1F W", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Department Store 1F"], "Celadon City to Celadon Department Store 1F E", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Mansion 1F"], "Celadon City to Celadon Mansion 1F", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Mansion 1F-Back"], "Celadon City to Celadon Mansion 1F-Back", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Pokemon Center"], "Celadon City to Celadon Pokemon Center", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Game Corner"], "Celadon City to Celadon Game Corner", ER_SIMPLE_OFF)
R["Celadon City"]:connect_warp(R["Celadon Prize Corner"], "Celadon City to Celadon Prize Corner", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Diner"], "Celadon City to Celadon Diner", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Chief House"], "Celadon City to Celadon Chief House", ER_EXTERIOR)
R["Celadon City"]:connect_warp(R["Celadon Hotel"], "Celadon City to Celadon Hotel", ER_EXTERIOR)

-- === Celadon City-G ===
R["Celadon City-G"]:connect_one_way(R["Celadon City"], "Celadon City-G to Celadon City", cut)
R["Celadon City-G"]:connect_one_way(R["Celadon City"], "Celadon City-G to Celadon City (Fly)", fly)
R["Celadon City-G"]:connect_warp(R["Celadon Gym"], "Celadon City-G to Celadon Gym", ER_EXTERIOR)

-- === Pallet Town ===
R["Pallet Town"]:connect_one_way(R["Route 1"], "Pallet Town to Route 1")
R["Pallet Town"]:connect_one_way(R["Pallet/Viridian Fishing"], "Pallet Town to Pallet/Viridian Fishing", super_rod)
R["Pallet Town"]:connect_one_way(R["Old Rod Fishing"], "Pallet Town to Old Rod Fishing", old_rod)
R["Pallet Town"]:connect_one_way(R["Good Rod Fishing"], "Pallet Town to Good Rod Fishing", good_rod)
R["Pallet Town"]:connect_one_way(R["Route 21"], "Pallet Town to Route 21", surf)
R["Pallet Town"]:connect_warp(R["Player's House 1F"], "Pallet Town to Player's House 1F", ER_EXTERIOR)
R["Pallet Town"]:connect_warp(R["Rival's House"], "Pallet Town to Rival's House", ER_EXTERIOR)
R["Pallet Town"]:connect_warp(R["Oak's Lab"], "Pallet Town to Oak's Lab", ER_EXTERIOR)

-- === Viridian City ===
R["Viridian City"]:connect_one_way(R["Route 1"], "Viridian City to Route 1")
R["Viridian City"]:connect_one_way(R["Route 22"], "Viridian City to Route 22")
R["Viridian City"]:connect_one_way(R["Pallet/Viridian Fishing"], "Viridian City to Pallet/Viridian Fishing", super_rod)
R["Viridian City"]:connect_one_way(R["Viridian City-N"], "Viridian City to Viridian City-N", old_man_or_cut)
R["Viridian City"]:connect_warp(R["Viridian Pokemon Center"], "Viridian City to Viridian Pokemon Center", ER_EXTERIOR)
R["Viridian City"]:connect_warp(R["Viridian Pokemart"], "Viridian City to Viridian Pokemart", ER_EXTERIOR)
R["Viridian City"]:connect_warp(R["Viridian School House"], "Viridian City to Viridian School House", ER_EXTERIOR)
R["Viridian City"]:connect_warp(R["Viridian Nickname House"], "Viridian City to Viridian Nickname House", ER_EXTERIOR)

-- === Viridian City-N ===
R["Viridian City-N"]:connect_one_way(R["Viridian City-G"], "Viridian City-N to Viridian City-G", viridiangym)
R["Viridian City-N"]:connect_one_way(R["Route 2-SW"], "Viridian City-N to Route 2-SW")
R["Viridian City-N"]:connect_one_way(R["Viridian City"], "Viridian City-N to Viridian City", old_man_or_cut)

-- === Viridian City-G ===
R["Viridian City-G"]:connect_one_way(R["Viridian City-N"], "Viridian City-G to Viridian City-N", viridiangym)
R["Viridian City-G"]:connect_warp(R["Viridian Gym"], "Viridian City-G to Viridian Gym", ER_EXTERIOR)

-- === Pewter City-E ===
R["Pewter City-E"]:connect_one_way(R["Pewter City"], "Pewter City-E to Pewter City")
R["Pewter City-E"]:connect_one_way(R["Route 3"], "Pewter City-E to Route 3", rt3)

-- === Pewter City-M ===
R["Pewter City-M"]:connect_one_way(R["Pewter City"], "Pewter City-M to Pewter City")
R["Pewter City-M"]:connect_warp(R["Pewter Museum 1F-E"], "Pewter City-M to Pewter Museum 1F-E", ER_EXTERIOR)

-- === Pewter City ===
R["Pewter City"]:connect_one_way(R["Route 2-NW"], "Pewter City to Route 2-NW")
R["Pewter City"]:connect_one_way(R["Pewter City-E"], "Pewter City to Pewter City-E")
R["Pewter City"]:connect_one_way(R["Pewter City-M"], "Pewter City to Pewter City-M", cut)
R["Pewter City"]:connect_warp(R["Pewter Museum 1F"], "Pewter City to Pewter Museum 1F", ER_EXTERIOR)
R["Pewter City"]:connect_warp(R["Pewter Gym"], "Pewter City to Pewter Gym", ER_EXTERIOR)
R["Pewter City"]:connect_warp(R["Pewter Nidoran House"], "Pewter City to Pewter Nidoran House", ER_EXTERIOR)
R["Pewter City"]:connect_warp(R["Pewter Pokemart"], "Pewter City to Pewter Pokemart", ER_EXTERIOR)
R["Pewter City"]:connect_warp(R["Pewter Speech House"], "Pewter City to Pewter Speech House", ER_EXTERIOR)
R["Pewter City"]:connect_warp(R["Pewter Pokemon Center"], "Pewter City to Pewter Pokemon Center", ER_EXTERIOR)

-- === Cerulean City-T ===
R["Cerulean City-T"]:connect_one_way(R["Cerulean City"], "Cerulean City-T to Cerulean City", officer)
R["Cerulean City-T"]:connect_one_way(R["Cerulean City"], "Cerulean City-T to Cerulean City (Fly)", fly)
R["Cerulean City-T"]:connect_warp(R["Cerulean Trashed House"], "Cerulean City-T to Cerulean Trashed House", ER_EXTERIOR)

-- === Cerulean City ===
R["Cerulean City"]:connect_one_way(R["Route 4-E"], "Cerulean City to Route 4-E")
R["Cerulean City"]:connect_one_way(R["Route 24"], "Cerulean City to Route 24")
R["Cerulean City"]:connect_one_way(R["Cerulean City-T"], "Cerulean City to Cerulean City-T", officer)
R["Cerulean City"]:connect_one_way(R["Cerulean City-Outskirts"], "Cerulean City to Cerulean City-Outskirts", cut)
R["Cerulean City"]:connect_one_way(R["Route 24/25/Cerulean/Cerulean Gym Fishing"], "Cerulean City to Route 24/25/Cerulean/Cerulean Gym Fishing", super_rod)
R["Cerulean City"]:connect_warp(R["Cerulean Trade House"], "Cerulean City to Cerulean Trade House", ER_EXTERIOR)
R["Cerulean City"]:connect_warp(R["Cerulean Pokemon Center"], "Cerulean City to Cerulean Pokemon Center", ER_EXTERIOR)
R["Cerulean City"]:connect_warp(R["Cerulean Gym"], "Cerulean City to Cerulean Gym", ER_EXTERIOR)
R["Cerulean City"]:connect_warp(R["Cerulean Bicycle Shop"], "Cerulean City to Cerulean Bicycle Shop", ER_EXTERIOR)
R["Cerulean City"]:connect_warp(R["Cerulean Pokemart"], "Cerulean City to Cerulean Pokemart", ER_EXTERIOR)
R["Cerulean City"]:connect_warp(R["Cerulean Badge House"], "Cerulean City to Cerulean Badge House", ER_EXTERIOR)

-- === Cerulean City-Badge House Backyard ===
R["Cerulean City-Badge House Backyard"]:connect_one_way(R["Cerulean City"], "Cerulean City-Badge House Backyard to Cerulean City", fly)
R["Cerulean City-Badge House Backyard"]:connect_warp(R["Cerulean Badge House"], "Cerulean City-Badge House Backyard to Cerulean Badge House", ER_EXTERIOR)

-- === Cerulean City-Water ===
R["Cerulean City-Water"]:connect_one_way(R["Route 24"], "Cerulean City-Water to Route 24", surf)
R["Cerulean City-Water"]:connect_one_way(R["Route 4-Lass"], "Cerulean City-Water to Route 4-Lass", surf)
R["Cerulean City-Water"]:connect_one_way(R["Cerulean City-Cave"], "Cerulean City-Water to Cerulean City-Cave", cerulean_cave)

-- === Cerulean City-Cave ===
R["Cerulean City-Cave"]:connect_one_way(R["Cerulean City-Water"], "Cerulean City-Cave to Cerulean City-Water", cerulean_cave)
R["Cerulean City-Cave"]:connect_one_way(R["Cerulean City"], "Cerulean City-Cave to Cerulean City", fly)
R["Cerulean City-Cave"]:connect_warp(R["Cerulean Cave 1F-SE"], "Cerulean City-Cave to Cerulean Cave 1F-SE", ER_EXTERIOR)

-- === Cerulean City-Outskirts ===
R["Cerulean City-Outskirts"]:connect_one_way(R["Cerulean City"], "Cerulean City-Outskirts to Cerulean City")
R["Cerulean City-Outskirts"]:connect_one_way(R["Route 9"], "Cerulean City-Outskirts to Route 9", cut)
R["Cerulean City-Outskirts"]:connect_one_way(R["Route 5"], "Cerulean City-Outskirts to Route 5")
R["Cerulean City-Outskirts"]:connect_warp(R["Cerulean Trashed House"], "Cerulean City-Outskirts to Cerulean Trashed House", ER_EXTERIOR)

-- === Vermilion City ===
R["Vermilion City"]:connect_one_way(R["Route 6/11/Vermilion/Dock Fishing"], "Vermilion City to Route 6/11/Vermilion/Dock Fishing", super_rod)
R["Vermilion City"]:connect_one_way(R["Route 6"], "Vermilion City to Route 6")
R["Vermilion City"]:connect_one_way(R["Vermilion City-G"], "Vermilion City to Vermilion City-G", surf_or_cut)
R["Vermilion City"]:connect_one_way(R["Vermilion City-Dock"], "Vermilion City to Vermilion City-Dock", ss_ticket)
R["Vermilion City"]:connect_one_way(R["Route 11"], "Vermilion City to Route 11")
R["Vermilion City"]:connect_warp(R["Vermilion Pokemon Center"], "Vermilion City to Vermilion Pokemon Center", ER_EXTERIOR)
R["Vermilion City"]:connect_warp(R["Vermilion Pokemon Fan Club"], "Vermilion City to Vermilion Pokemon Fan Club", ER_EXTERIOR)
R["Vermilion City"]:connect_warp(R["Vermilion Pokemart"], "Vermilion City to Vermilion Pokemart", ER_EXTERIOR)
R["Vermilion City"]:connect_warp(R["Vermilion Pidgey House"], "Vermilion City to Vermilion Pidgey House", ER_EXTERIOR)
R["Vermilion City"]:connect_warp(R["Vermilion Trade House"], "Vermilion City to Vermilion Trade House", ER_EXTERIOR)
R["Vermilion City"]:connect_warp(R["Vermilion Old Rod House"], "Vermilion City to Vermilion Old Rod House", ER_EXTERIOR)

-- === Vermilion City-G ===
R["Vermilion City-G"]:connect_one_way(R["Vermilion City"], "Vermilion City-G to Vermilion City", surf_or_cut)
R["Vermilion City-G"]:connect_one_way(R["Vermilion City"], "Vermilion City-G to Vermilion City (Fly)", fly)
R["Vermilion City-G"]:connect_warp(R["Vermilion Gym"], "Vermilion City-G to Vermilion Gym", ER_EXTERIOR)

-- === Vermilion City-Dock ===
R["Vermilion City-Dock"]:connect_one_way(R["Vermilion City"], "Vermilion City-Dock to Vermilion City", ss_ticket)
R["Vermilion City-Dock"]:connect_one_way(R["Vermilion City"], "Vermilion City-Dock to Vermilion City (Fly)", fly)
R["Vermilion City-Dock"]:connect_warp(R["Vermilion Dock"], "Vermilion City-Dock to Vermilion Dock", ER_EXTERIOR)

-- === Fuchsia City ===
R["Fuchsia City"]:connect_one_way(R["Fuchsia Fishing"], "Fuchsia City to Fuchsia Fishing", super_rod)
R["Fuchsia City"]:connect_one_way(R["Route 15-W"], "Fuchsia City to Route 15-W")
R["Fuchsia City"]:connect_one_way(R["Route 18-E"], "Fuchsia City to Route 18-E")
R["Fuchsia City"]:connect_one_way(R["Route 19-N"], "Fuchsia City to Route 19-N")
R["Fuchsia City"]:connect_warp(R["Fuchsia Pokemart"], "Fuchsia City to Fuchsia Pokemart", ER_EXTERIOR)
R["Fuchsia City"]:connect_warp(R["Fuchsia Bill's Grandpa's House"], "Fuchsia City to Fuchsia Bill's Grandpa's House", ER_EXTERIOR)
R["Fuchsia City"]:connect_warp(R["Fuchsia Pokemon Center"], "Fuchsia City to Fuchsia Pokemon Center", ER_EXTERIOR)
R["Fuchsia City"]:connect_warp(R["Fuchsia Warden's House"], "Fuchsia City to Fuchsia Warden's House", ER_EXTERIOR)
R["Fuchsia City"]:connect_warp(R["Safari Zone Gate-S"], "Fuchsia City to Safari Zone Gate-S", ER_FIXED_SIMPLE)
R["Fuchsia City"]:connect_warp(R["Fuchsia Gym"], "Fuchsia City to Fuchsia Gym", ER_EXTERIOR)
R["Fuchsia City"]:connect_warp(R["Fuchsia Meeting Room"], "Fuchsia City to Fuchsia Meeting Room", ER_EXTERIOR)
R["Fuchsia City"]:connect_warp(R["Fuchsia Good Rod House"], "Fuchsia City to Fuchsia Good Rod House", ER_EXTERIOR)

-- === Fuchsia City-Good Rod House Backyard ===
R["Fuchsia City-Good Rod House Backyard"]:connect_one_way(R["Fuchsia City"], "Fuchsia City-Good Rod House Backyard to Fuchsia City", fly)
R["Fuchsia City-Good Rod House Backyard"]:connect_warp(R["Fuchsia Good Rod House"], "Fuchsia City-Good Rod House Backyard to Fuchsia Good Rod House", ER_EXTERIOR)

-- === Rival's House ===
R["Rival's House"]:connect_warp(R["Pallet Town"], "Rival's House to Pallet Town", ER_EXTERIOR)

-- === Vermilion Trade House ===
R["Vermilion Trade House"]:connect_warp(R["Vermilion City"], "Vermilion Trade House to Vermilion City", ER_EXTERIOR)

-- === Indigo Plateau Lobby ===
R["Indigo Plateau Lobby"]:connect_one_way(R["Indigo Plateau Lobby-N"], "Indigo Plateau Lobby to Indigo Plateau Lobby-N", elite4)
R["Indigo Plateau Lobby"]:connect_warp(R["Indigo Plateau"], "Indigo Plateau Lobby to Indigo Plateau", ER_EXTERIOR)

-- === Indigo Plateau Lobby-N ===
R["Indigo Plateau Lobby-N"]:connect_one_way(R["Indigo Plateau Lobby"], "Indigo Plateau Lobby-N to Indigo Plateau Lobby", elite4)
R["Indigo Plateau Lobby-N"]:connect_warp(R["Indigo Plateau Lorelei's Room"], "Indigo Plateau Lobby-N to Indigo Plateau Lorelei's Room", ER_FIXED_FULL)

-- === Silph Co 4F ===
R["Silph Co 4F"]:connect_one_way(R["Silph Co 4F-N"], "Silph Co 4F to Silph Co 4F-N", card_key_4)
R["Silph Co 4F"]:connect_one_way(R["Silph Co 4F-W"], "Silph Co 4F to Silph Co 4F-W", card_key_4)
R["Silph Co 4F"]:connect_warp(R["Silph Co 3F"], "Silph Co 4F to Silph Co 3F", ER_INTERIOR)
R["Silph Co 4F"]:connect_warp(R["Silph Co 5F"], "Silph Co 4F to Silph Co 5F", ER_INTERIOR)
R["Silph Co 4F"]:connect_warp(R["Silph Co Elevator-4F"], "Silph Co 4F to Silph Co Elevator-4F", ER_INTERIOR)
R["Silph Co 4F"]:connect_warp(R["Silph Co 10F-SE"], "Silph Co 4F to Silph Co 10F-SE", ER_WARP_TILE)
R["Silph Co 4F"]:connect_warp(R["Silph Co 10F"], "Silph Co 4F to Silph Co 10F", ER_WARP_TILE)

-- === Silph Co 4F-N ===
R["Silph Co 4F-N"]:connect_one_way(R["Silph Co 4F"], "Silph Co 4F-N to Silph Co 4F", card_key_4)
R["Silph Co 4F-N"]:connect_warp(R["Silph Co 6F"], "Silph Co 4F-N to Silph Co 6F", ER_WARP_TILE)
R["Silph Co 4F-N"]:connect_warp(R["Silph Co 10F-SE"], "Silph Co 4F-N to Silph Co 10F-SE", ER_WARP_TILE)

-- === Silph Co 4F-W ===
R["Silph Co 4F-W"]:connect_one_way(R["Silph Co 4F"], "Silph Co 4F-W to Silph Co 4F", card_key_4)

-- === Silph Co 5F-NW ===
R["Silph Co 5F-NW"]:connect_one_way(R["Silph Co 5F"], "Silph Co 5F-NW to Silph Co 5F", card_key_5)

-- === Silph Co 6F-SW ===
R["Silph Co 6F-SW"]:connect_one_way(R["Silph Co 6F"], "Silph Co 6F-SW to Silph Co 6F", card_key_6)

-- === Silph Co 5F ===
R["Silph Co 5F"]:connect_one_way(R["Silph Co 5F-NW"], "Silph Co 5F to Silph Co 5F-NW", card_key_5)
R["Silph Co 5F"]:connect_one_way(R["Silph Co 5F-SW"], "Silph Co 5F to Silph Co 5F-SW", card_key_5)
R["Silph Co 5F"]:connect_warp(R["Silph Co 6F"], "Silph Co 5F to Silph Co 6F", ER_INTERIOR)
R["Silph Co 5F"]:connect_warp(R["Silph Co 4F"], "Silph Co 5F to Silph Co 4F", ER_INTERIOR)
R["Silph Co 5F"]:connect_warp(R["Silph Co Elevator-5F"], "Silph Co 5F to Silph Co Elevator-5F", ER_INTERIOR)
R["Silph Co 5F"]:connect_warp(R["Silph Co 7F-SE"], "Silph Co 5F to Silph Co 7F-SE", ER_WARP_TILE)
R["Silph Co 5F"]:connect_warp(R["Silph Co 9F"], "Silph Co 5F to Silph Co 9F", ER_WARP_TILE)
R["Silph Co 5F"]:connect_warp(R["Silph Co 3F"], "Silph Co 5F to Silph Co 3F", ER_WARP_TILE)

-- === Silph Co 5F-SW ===
R["Silph Co 5F-SW"]:connect_one_way(R["Silph Co 5F"], "Silph Co 5F-SW to Silph Co 5F", card_key_5)
R["Silph Co 5F-SW"]:connect_warp(R["Silph Co 3F"], "Silph Co 5F-SW to Silph Co 3F", ER_WARP_TILE)

-- === Silph Co 6F ===
R["Silph Co 6F"]:connect_one_way(R["Silph Co 6F-SW"], "Silph Co 6F to Silph Co 6F-SW", card_key_6)
R["Silph Co 6F"]:connect_warp(R["Silph Co 7F"], "Silph Co 6F to Silph Co 7F", ER_INTERIOR)
R["Silph Co 6F"]:connect_warp(R["Silph Co 5F"], "Silph Co 6F to Silph Co 5F", ER_INTERIOR)
R["Silph Co 6F"]:connect_warp(R["Silph Co Elevator-7F"], "Silph Co 6F to Silph Co Elevator-7F", ER_INTERIOR)
R["Silph Co 6F"]:connect_warp(R["Silph Co 4F-N"], "Silph Co 6F to Silph Co 4F-N", ER_WARP_TILE)
R["Silph Co 6F"]:connect_warp(R["Silph Co 2F-SW"], "Silph Co 6F to Silph Co 2F-SW", ER_WARP_TILE)

-- === Cinnabar Island-M ===
R["Cinnabar Island-M"]:connect_one_way(R["Cinnabar Island"], "Cinnabar Island-M to Cinnabar Island", mansion_key)
R["Cinnabar Island-M"]:connect_one_way(R["Cinnabar Island"], "Cinnabar Island-M to Cinnabar Island (Fly)", fly)
R["Cinnabar Island-M"]:connect_warp(R["Pokemon Mansion 1F"], "Cinnabar Island-M to Pokemon Mansion 1F", ER_EXTERIOR)

-- === Cinnabar Island-G ===
R["Cinnabar Island-G"]:connect_one_way(R["Cinnabar Island"], "Cinnabar Island-G to Cinnabar Island", secret_key)
R["Cinnabar Island-G"]:connect_one_way(R["Cinnabar Island"], "Cinnabar Island-G to Cinnabar Island (Fly)", fly)
R["Cinnabar Island-G"]:connect_warp(R["Cinnabar Gym"], "Cinnabar Island-G to Cinnabar Gym", ER_EXTERIOR)

-- === Cinnabar Island ===
R["Cinnabar Island"]:connect_one_way(R["Sea Routes/Cinnabar/Seafoam Fishing"], "Cinnabar Island to Sea Routes/Cinnabar/Seafoam Fishing", super_rod)
R["Cinnabar Island"]:connect_one_way(R["Route 20-W"], "Cinnabar Island to Route 20-W", surf)
R["Cinnabar Island"]:connect_one_way(R["Cinnabar Island-G"], "Cinnabar Island to Cinnabar Island-G", secret_key)
R["Cinnabar Island"]:connect_one_way(R["Cinnabar Island-M"], "Cinnabar Island to Cinnabar Island-M", mansion_key)
R["Cinnabar Island"]:connect_one_way(R["Route 21"], "Cinnabar Island to Route 21", surf)
R["Cinnabar Island"]:connect_warp(R["Cinnabar Lab"], "Cinnabar Island to Cinnabar Lab", ER_EXTERIOR)
R["Cinnabar Island"]:connect_warp(R["Cinnabar Pokemon Center"], "Cinnabar Island to Cinnabar Pokemon Center", ER_EXTERIOR)
R["Cinnabar Island"]:connect_warp(R["Cinnabar Pokemart"], "Cinnabar Island to Cinnabar Pokemart", ER_EXTERIOR)

-- === Route 1 ===
R["Route 1"]:connect_one_way(R["Pallet Town"], "Route 1 to Pallet Town")
R["Route 1"]:connect_one_way(R["Viridian City"], "Route 1 to Viridian City")

-- === Oak's Lab ===
R["Oak's Lab"]:connect_warp(R["Pallet Town"], "Oak's Lab to Pallet Town", ER_EXTERIOR)

-- === Viridian Pokemart ===
R["Viridian Pokemart"]:connect_warp(R["Viridian City"], "Viridian Pokemart to Viridian City", ER_EXTERIOR)

-- === Viridian School House ===
R["Viridian School House"]:connect_warp(R["Viridian City"], "Viridian School House to Viridian City", ER_EXTERIOR)

-- === Viridian Nickname House ===
R["Viridian Nickname House"]:connect_warp(R["Viridian City"], "Viridian Nickname House to Viridian City", ER_EXTERIOR)

-- === Pewter Nidoran House ===
R["Pewter Nidoran House"]:connect_warp(R["Pewter City"], "Pewter Nidoran House to Pewter City", ER_EXTERIOR)

-- === Pewter Speech House ===
R["Pewter Speech House"]:connect_warp(R["Pewter City"], "Pewter Speech House to Pewter City", ER_EXTERIOR)

-- === Cerulean Trashed House ===
R["Cerulean Trashed House"]:connect_warp(R["Cerulean City-T"], "Cerulean Trashed House to Cerulean City-T", ER_EXTERIOR)
R["Cerulean Trashed House"]:connect_warp(R["Cerulean City-Outskirts"], "Cerulean Trashed House to Cerulean City-Outskirts", ER_EXTERIOR)

-- === Cerulean Trade House ===
R["Cerulean Trade House"]:connect_warp(R["Cerulean City"], "Cerulean Trade House to Cerulean City", ER_EXTERIOR)

-- === Cerulean Bicycle Shop ===
R["Cerulean Bicycle Shop"]:connect_warp(R["Cerulean City"], "Cerulean Bicycle Shop to Cerulean City", ER_EXTERIOR)

-- === Lavender Mr. Fuji's House ===
R["Lavender Mr. Fuji's House"]:connect_warp(R["Lavender Town"], "Lavender Mr. Fuji's House to Lavender Town", ER_EXTERIOR)

-- === Lavender Cubone House ===
R["Lavender Cubone House"]:connect_warp(R["Lavender Town"], "Lavender Cubone House to Lavender Town", ER_EXTERIOR)

-- === Lavender Name Rater's House ===
R["Lavender Name Rater's House"]:connect_warp(R["Lavender Town"], "Lavender Name Rater's House to Lavender Town", ER_EXTERIOR)

-- === Vermilion Pidgey House ===
R["Vermilion Pidgey House"]:connect_warp(R["Vermilion City"], "Vermilion Pidgey House to Vermilion City", ER_EXTERIOR)

-- === Vermilion Dock ===
R["Vermilion Dock"]:connect_one_way(R["Route 6/11/Vermilion/Dock Fishing"], "Vermilion Dock to Route 6/11/Vermilion/Dock Fishing", super_rod)
R["Vermilion Dock"]:connect_warp(R["Vermilion City-Dock"], "Vermilion Dock to Vermilion City-Dock", ER_EXTERIOR)
R["Vermilion Dock"]:connect_warp(R["S.S. Anne 1F"], "Vermilion Dock to S.S. Anne 1F", ER_INTERIOR)

-- === Celadon Mansion Roof House ===
R["Celadon Mansion Roof House"]:connect_warp(R["Celadon Mansion Roof-Back"], "Celadon Mansion Roof House to Celadon Mansion Roof-Back", ER_INTERIOR)

-- === Fuchsia Pokemart ===
R["Fuchsia Pokemart"]:connect_warp(R["Fuchsia City"], "Fuchsia Pokemart to Fuchsia City", ER_EXTERIOR)

-- === Saffron Pidgey House ===
R["Saffron Pidgey House"]:connect_warp(R["Saffron City-Pidgey"], "Saffron Pidgey House to Saffron City-Pidgey", ER_EXTERIOR)

-- === Saffron Mr. Psychic's House ===
R["Saffron Mr. Psychic's House"]:connect_warp(R["Saffron City"], "Saffron Mr. Psychic's House to Saffron City", ER_EXTERIOR)

-- === Diglett's Cave Route 2 ===
R["Diglett's Cave Route 2"]:connect_warp(R["Route 2-NE"], "Diglett's Cave Route 2 to Route 2-NE", ER_EXTERIOR)
R["Diglett's Cave Route 2"]:connect_warp(R["Diglett's Cave"], "Diglett's Cave Route 2 to Diglett's Cave", ER_INTERIOR)

-- === Route 2 Trade House ===
R["Route 2 Trade House"]:connect_warp(R["Route 2-NE"], "Route 2 Trade House to Route 2-NE", ER_EXTERIOR)

-- === Route 5 Gate-S ===
R["Route 5 Gate-S"]:connect_one_way(R["Route 5 Gate-N"], "Route 5 Gate-S to Route 5 Gate-N", pass_guards)
R["Route 5 Gate-S"]:connect_warp(R["Route 5-S"], "Route 5 Gate-S to Route 5-S", ER_EXTERIOR)

-- === Route 5 Gate-N ===
R["Route 5 Gate-N"]:connect_one_way(R["Route 5 Gate-S"], "Route 5 Gate-N to Route 5 Gate-S", pass_guards)
R["Route 5 Gate-N"]:connect_warp(R["Route 5"], "Route 5 Gate-N to Route 5", ER_EXTERIOR)

-- === Route 6 Gate-S ===
R["Route 6 Gate-S"]:connect_one_way(R["Route 6 Gate-N"], "Route 6 Gate-S to Route 6 Gate-N", pass_guards)
R["Route 6 Gate-S"]:connect_warp(R["Route 6"], "Route 6 Gate-S to Route 6", ER_EXTERIOR)

-- === Route 6 Gate-N ===
R["Route 6 Gate-N"]:connect_one_way(R["Route 6 Gate-S"], "Route 6 Gate-N to Route 6 Gate-S", pass_guards)
R["Route 6 Gate-N"]:connect_warp(R["Route 6-N"], "Route 6 Gate-N to Route 6-N", ER_EXTERIOR)

-- === Route 7 Gate-W ===
R["Route 7 Gate-W"]:connect_one_way(R["Route 7 Gate-E"], "Route 7 Gate-W to Route 7 Gate-E", pass_guards)
R["Route 7 Gate-W"]:connect_warp(R["Route 7"], "Route 7 Gate-W to Route 7", ER_EXTERIOR)

-- === Route 7 Gate-E ===
R["Route 7 Gate-E"]:connect_one_way(R["Route 7 Gate-W"], "Route 7 Gate-E to Route 7 Gate-W", pass_guards)
R["Route 7 Gate-E"]:connect_warp(R["Route 7-E"], "Route 7 Gate-E to Route 7-E", ER_EXTERIOR)

-- === Route 8 Gate-W ===
R["Route 8 Gate-W"]:connect_one_way(R["Route 8 Gate-E"], "Route 8 Gate-W to Route 8 Gate-E", pass_guards)
R["Route 8 Gate-W"]:connect_warp(R["Route 8-W"], "Route 8 Gate-W to Route 8-W", ER_EXTERIOR)

-- === Route 8 Gate-E ===
R["Route 8 Gate-E"]:connect_one_way(R["Route 8 Gate-W"], "Route 8 Gate-E to Route 8 Gate-W", pass_guards)
R["Route 8 Gate-E"]:connect_warp(R["Route 8"], "Route 8 Gate-E to Route 8", ER_EXTERIOR)

-- === Underground Path Route 8 ===
R["Underground Path Route 8"]:connect_warp(R["Route 8"], "Underground Path Route 8 to Route 8", ER_EXTERIOR)
R["Underground Path Route 8"]:connect_warp(R["Underground Path West East"], "Underground Path Route 8 to Underground Path West East", ER_INTERIOR)

-- === Power Plant ===
R["Power Plant"]:connect_warp(R["Route 10-P"], "Power Plant to Route 10-P", ER_EXTERIOR)
R["Power Plant"]:connect_warp(R["Route 10-P"], "Power Plant to Route 10-P Back Door", ER_EXTERIOR)

-- === Diglett's Cave Route 11 ===
R["Diglett's Cave Route 11"]:connect_warp(R["Route 11"], "Diglett's Cave Route 11 to Route 11", ER_EXTERIOR)
R["Diglett's Cave Route 11"]:connect_warp(R["Diglett's Cave"], "Diglett's Cave Route 11 to Diglett's Cave", ER_INTERIOR)

-- === Route 16 Fly House ===
R["Route 16 Fly House"]:connect_warp(R["Route 16-NW"], "Route 16 Fly House to Route 16-NW", ER_EXTERIOR)

-- === Route 22 Gate-S ===
R["Route 22 Gate-S"]:connect_one_way(R["Route 22 Gate-N"], "Route 22 Gate-S to Route 22 Gate-N", rt23)
R["Route 22 Gate-S"]:connect_warp(R["Route 22"], "Route 22 Gate-S to Route 22", ER_EXTERIOR)

-- === Route 22 Gate-N ===
R["Route 22 Gate-N"]:connect_one_way(R["Route 22 Gate-S"], "Route 22 Gate-N to Route 22 Gate-S", rt23)
R["Route 22 Gate-N"]:connect_warp(R["Route 23-S"], "Route 22 Gate-N to Route 23-S", ER_EXTERIOR)

-- === Bill's House ===
R["Bill's House"]:connect_warp(R["Route 25"], "Bill's House to Route 25", ER_EXTERIOR)

-- === Lavender Town ===
R["Lavender Town"]:connect_one_way(R["Route 12-L"], "Lavender Town to Route 12-L")
R["Lavender Town"]:connect_one_way(R["Route 10-S"], "Lavender Town to Route 10-S")
R["Lavender Town"]:connect_one_way(R["Route 8"], "Lavender Town to Route 8")
R["Lavender Town"]:connect_warp(R["Lavender Pokemon Center"], "Lavender Town to Lavender Pokemon Center", ER_EXTERIOR)
R["Lavender Town"]:connect_warp(R["Pokemon Tower 1F"], "Lavender Town to Pokemon Tower 1F", ER_EXTERIOR)
R["Lavender Town"]:connect_warp(R["Lavender Mr. Fuji's House"], "Lavender Town to Lavender Mr. Fuji's House", ER_EXTERIOR)
R["Lavender Town"]:connect_warp(R["Lavender Pokemart"], "Lavender Town to Lavender Pokemart", ER_EXTERIOR)
R["Lavender Town"]:connect_warp(R["Lavender Cubone House"], "Lavender Town to Lavender Cubone House", ER_EXTERIOR)
R["Lavender Town"]:connect_warp(R["Lavender Name Rater's House"], "Lavender Town to Lavender Name Rater's House", ER_EXTERIOR)

-- === Viridian Pokemon Center ===
R["Viridian Pokemon Center"]:connect_warp(R["Viridian City"], "Viridian Pokemon Center to Viridian City", ER_EXTERIOR)

-- === Pokemon Mansion 1F ===
R["Pokemon Mansion 1F"]:connect_one_way(R["Pokemon Mansion 1F-Wild"], "Pokemon Mansion 1F to Pokemon Mansion 1F-Wild")
R["Pokemon Mansion 1F"]:connect_warp(R["Pokemon Mansion 2F"], "Pokemon Mansion 1F to Pokemon Mansion 2F", ER_INTERIOR)
R["Pokemon Mansion 1F"]:connect_warp(R["Cinnabar Island-M"], "Pokemon Mansion 1F to Cinnabar Island-M", ER_EXTERIOR)

-- === Pokemon Mansion 1F-SE ===
R["Pokemon Mansion 1F-SE"]:connect_one_way(R["Pokemon Mansion 1F-Wild"], "Pokemon Mansion 1F-SE to Pokemon Mansion 1F-Wild")
R["Pokemon Mansion 1F-SE"]:connect_warp(R["Pokemon Mansion B1F"], "Pokemon Mansion 1F-SE to Pokemon Mansion B1F", ER_INTERIOR)
R["Pokemon Mansion 1F-SE"]:connect_warp(R["Cinnabar Island-M"], "Pokemon Mansion 1F-SE to Cinnabar Island-M", ER_EXTERIOR)

-- === Pokemon Mansion 2F ===
R["Pokemon Mansion 2F"]:connect_warp(R["Pokemon Mansion 1F"], "Pokemon Mansion 2F to Pokemon Mansion 1F", ER_INTERIOR)
R["Pokemon Mansion 2F"]:connect_warp(R["Pokemon Mansion 3F-SW"], "Pokemon Mansion 2F to Pokemon Mansion 3F-SW", ER_INTERIOR)
R["Pokemon Mansion 2F"]:connect_warp(R["Pokemon Mansion 3F"], "Pokemon Mansion 2F to Pokemon Mansion 3F", ER_INTERIOR)

-- === Pokemon Mansion 2F-E ===
R["Pokemon Mansion 2F-E"]:connect_one_way(R["Pokemon Mansion 2F-Wild"], "Pokemon Mansion 2F-E to Pokemon Mansion 2F-Wild")
R["Pokemon Mansion 2F-E"]:connect_warp(R["Pokemon Mansion 3F-SE"], "Pokemon Mansion 2F-E to Pokemon Mansion 3F-SE", ER_INTERIOR)

-- === Pokemon Mansion 3F ===
R["Pokemon Mansion 3F"]:connect_one_way(R["Pokemon Mansion 3F-Wild"], "Pokemon Mansion 3F to Pokemon Mansion 3F-Wild")
R["Pokemon Mansion 3F"]:connect_one_way(R["Pokemon Mansion 3F-SE"], "Pokemon Mansion 3F to Pokemon Mansion 3F-SE")
R["Pokemon Mansion 3F"]:connect_warp(R["Pokemon Mansion 2F"], "Pokemon Mansion 3F to Pokemon Mansion 2F", ER_INTERIOR)

-- === Pokemon Mansion 3F-SE ===
R["Pokemon Mansion 3F-SE"]:connect_one_way(R["Pokemon Mansion 3F-Wild"], "Pokemon Mansion 3F-SE to Pokemon Mansion 3F-Wild")
R["Pokemon Mansion 3F-SE"]:connect_one_way(R["Pokemon Mansion 2F"], "Pokemon Mansion 3F-SE to Pokemon Mansion 2F")
R["Pokemon Mansion 3F-SE"]:connect_one_way(R["Pokemon Mansion 1F-SE"], "Pokemon Mansion 3F-SE to Pokemon Mansion 1F-SE")
R["Pokemon Mansion 3F-SE"]:connect_warp(R["Pokemon Mansion 2F-E"], "Pokemon Mansion 3F-SE to Pokemon Mansion 2F-E", ER_INTERIOR)

-- === Pokemon Mansion 3F-SW ===
R["Pokemon Mansion 3F-SW"]:connect_one_way(R["Pokemon Mansion 3F-Wild"], "Pokemon Mansion 3F-SW to Pokemon Mansion 3F-Wild")
R["Pokemon Mansion 3F-SW"]:connect_warp(R["Pokemon Mansion 2F"], "Pokemon Mansion 3F-SW to Pokemon Mansion 2F", ER_INTERIOR)

-- === Pokemon Mansion B1F ===
R["Pokemon Mansion B1F"]:connect_warp(R["Pokemon Mansion 1F-SE"], "Pokemon Mansion B1F to Pokemon Mansion 1F-SE", ER_INTERIOR)

-- === Rock Tunnel 1F-NE 1 ===
R["Rock Tunnel 1F-NE 1"]:connect_one_way(R["Rock Tunnel 1F-NE"], "Rock Tunnel 1F-NE 1 to Rock Tunnel 1F-NE", rock_tunnel)
R["Rock Tunnel 1F-NE 1"]:connect_warp(R["Route 10-N"], "Rock Tunnel 1F-NE 1 to Route 10-N", ER_EXTERIOR)

-- === Rock Tunnel 1F-NE 2 ===
R["Rock Tunnel 1F-NE 2"]:connect_one_way(R["Rock Tunnel 1F-NE"], "Rock Tunnel 1F-NE 2 to Rock Tunnel 1F-NE", rock_tunnel)
R["Rock Tunnel 1F-NE 2"]:connect_warp(R["Rock Tunnel B1F-E 1"], "Rock Tunnel 1F-NE 2 to Rock Tunnel B1F-E 1", ER_INTERIOR)

-- === Rock Tunnel 1F-NW 1 ===
R["Rock Tunnel 1F-NW 1"]:connect_one_way(R["Rock Tunnel 1F-NW"], "Rock Tunnel 1F-NW 1 to Rock Tunnel 1F-NW", rock_tunnel)
R["Rock Tunnel 1F-NW 1"]:connect_warp(R["Rock Tunnel B1F-E 2"], "Rock Tunnel 1F-NW 1 to Rock Tunnel B1F-E 2", ER_INTERIOR)

-- === Rock Tunnel 1F-NW 2 ===
R["Rock Tunnel 1F-NW 2"]:connect_one_way(R["Rock Tunnel 1F-NW"], "Rock Tunnel 1F-NW 2 to Rock Tunnel 1F-NW", rock_tunnel)
R["Rock Tunnel 1F-NW 2"]:connect_warp(R["Rock Tunnel B1F-W 1"], "Rock Tunnel 1F-NW 2 to Rock Tunnel B1F-W 1", ER_INTERIOR)

-- === Rock Tunnel 1F-S 1 ===
R["Rock Tunnel 1F-S 1"]:connect_one_way(R["Rock Tunnel 1F-S"], "Rock Tunnel 1F-S 1 to Rock Tunnel 1F-S", rock_tunnel)
R["Rock Tunnel 1F-S 1"]:connect_warp(R["Route 10-S"], "Rock Tunnel 1F-S 1 to Route 10-S", ER_EXTERIOR)

-- === Rock Tunnel 1F-S 2 ===
R["Rock Tunnel 1F-S 2"]:connect_one_way(R["Rock Tunnel 1F-S"], "Rock Tunnel 1F-S 2 to Rock Tunnel 1F-S", rock_tunnel)
R["Rock Tunnel 1F-S 2"]:connect_warp(R["Rock Tunnel B1F-W 2"], "Rock Tunnel 1F-S 2 to Rock Tunnel B1F-W 2", ER_INTERIOR)

-- === Rock Tunnel 1F-NE ===
R["Rock Tunnel 1F-NE"]:connect_one_way(R["Rock Tunnel 1F-NE 1"], "Rock Tunnel 1F-NE to Rock Tunnel 1F-NE 1", rock_tunnel)
R["Rock Tunnel 1F-NE"]:connect_one_way(R["Rock Tunnel 1F-NE 2"], "Rock Tunnel 1F-NE to Rock Tunnel 1F-NE 2", rock_tunnel)
R["Rock Tunnel 1F-NE"]:connect_one_way(R["Rock Tunnel 1F-Wild"], "Rock Tunnel 1F-NE to Rock Tunnel 1F-Wild", rock_tunnel)

-- === Rock Tunnel 1F-NW ===
R["Rock Tunnel 1F-NW"]:connect_one_way(R["Rock Tunnel 1F-NW 1"], "Rock Tunnel 1F-NW to Rock Tunnel 1F-NW 1", rock_tunnel)
R["Rock Tunnel 1F-NW"]:connect_one_way(R["Rock Tunnel 1F-NW 2"], "Rock Tunnel 1F-NW to Rock Tunnel 1F-NW 2", rock_tunnel)
R["Rock Tunnel 1F-NW"]:connect_one_way(R["Rock Tunnel 1F-Wild"], "Rock Tunnel 1F-NW to Rock Tunnel 1F-Wild", rock_tunnel)

-- === Rock Tunnel 1F-S ===
R["Rock Tunnel 1F-S"]:connect_one_way(R["Rock Tunnel 1F-S 1"], "Rock Tunnel 1F-S to Rock Tunnel 1F-S 1", rock_tunnel)
R["Rock Tunnel 1F-S"]:connect_one_way(R["Rock Tunnel 1F-S 2"], "Rock Tunnel 1F-S to Rock Tunnel 1F-S 2", rock_tunnel)
R["Rock Tunnel 1F-S"]:connect_one_way(R["Rock Tunnel 1F-Wild"], "Rock Tunnel 1F-S to Rock Tunnel 1F-Wild", rock_tunnel)

-- === Rock Tunnel B1F-E ===
R["Rock Tunnel B1F-E"]:connect_one_way(R["Rock Tunnel B1F-E 1"], "Rock Tunnel B1F-E to Rock Tunnel B1F-E 1", rock_tunnel)
R["Rock Tunnel B1F-E"]:connect_one_way(R["Rock Tunnel B1F-E 2"], "Rock Tunnel B1F-E to Rock Tunnel B1F-E 2", rock_tunnel)
R["Rock Tunnel B1F-E"]:connect_one_way(R["Rock Tunnel B1F-Wild"], "Rock Tunnel B1F-E to Rock Tunnel B1F-Wild", rock_tunnel)

-- === Rock Tunnel B1F-W ===
R["Rock Tunnel B1F-W"]:connect_one_way(R["Rock Tunnel B1F-W 1"], "Rock Tunnel B1F-W to Rock Tunnel B1F-W 1", rock_tunnel)
R["Rock Tunnel B1F-W"]:connect_one_way(R["Rock Tunnel B1F-W 2"], "Rock Tunnel B1F-W to Rock Tunnel B1F-W 2", rock_tunnel)
R["Rock Tunnel B1F-W"]:connect_one_way(R["Rock Tunnel B1F-Wild"], "Rock Tunnel B1F-W to Rock Tunnel B1F-Wild", rock_tunnel)

-- === Seafoam Islands 1F ===
R["Seafoam Islands 1F"]:connect_one_way(R["Seafoam Islands 1F-Wild"], "Seafoam Islands 1F to Seafoam Islands 1F-Wild")
R["Seafoam Islands 1F"]:connect_one_way(R["Seafoam Islands B1F"], "Seafoam Islands 1F to Seafoam Islands B1F (Drop)")
R["Seafoam Islands 1F"]:connect_one_way(R["Seafoam Islands B1F-NE"], "Seafoam Islands 1F to Seafoam Islands B1F-NE (Drop)")
R["Seafoam Islands 1F"]:connect_warp(R["Route 20-IE"], "Seafoam Islands 1F to Route 20-IE", ER_EXTERIOR)
R["Seafoam Islands 1F"]:connect_warp(R["Seafoam Islands B1F"], "Seafoam Islands 1F to Seafoam Islands B1F", ER_INTERIOR)
R["Seafoam Islands 1F"]:connect_warp(R["Seafoam Islands B1F-NE"], "Seafoam Islands 1F to Seafoam Islands B1F-NE", ER_INTERIOR)

-- === Seafoam Islands 1F-SE ===
R["Seafoam Islands 1F-SE"]:connect_one_way(R["Seafoam Islands 1F-Wild"], "Seafoam Islands 1F-SE to Seafoam Islands 1F-Wild")
R["Seafoam Islands 1F-SE"]:connect_warp(R["Route 20-IW"], "Seafoam Islands 1F-SE to Route 20-IW", ER_EXTERIOR)
R["Seafoam Islands 1F-SE"]:connect_warp(R["Seafoam Islands B1F-SE"], "Seafoam Islands 1F-SE to Seafoam Islands B1F-SE", ER_INTERIOR)

-- === S.S. Anne 3F ===
R["S.S. Anne 3F"]:connect_warp(R["S.S. Anne Bow"], "S.S. Anne 3F to S.S. Anne Bow", ER_INTERIOR)
R["S.S. Anne 3F"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 3F to S.S. Anne 2F", ER_INTERIOR)

-- === Victory Road 3F ===
R["Victory Road 3F"]:connect_one_way(R["Victory Road 3F-S"], "Victory Road 3F to Victory Road 3F-S", strength)
R["Victory Road 3F"]:connect_one_way(R["Victory Road 3F-Wild"], "Victory Road 3F to Victory Road 3F-Wild")
R["Victory Road 3F"]:connect_warp(R["Victory Road 2F-C"], "Victory Road 3F to Victory Road 2F-C", ER_INTERIOR)
R["Victory Road 3F"]:connect_warp(R["Victory Road 2F-NW"], "Victory Road 3F to Victory Road 2F-NW", ER_INTERIOR)

-- === Victory Road 3F-SE ===
R["Victory Road 3F-SE"]:connect_one_way(R["Victory Road 3F-S"], "Victory Road 3F-SE to Victory Road 3F-S", strength)
R["Victory Road 3F-SE"]:connect_one_way(R["Victory Road 3F-Wild"], "Victory Road 3F-SE to Victory Road 3F-Wild")
R["Victory Road 3F-SE"]:connect_warp(R["Victory Road 2F-E"], "Victory Road 3F-SE to Victory Road 2F-E", ER_INTERIOR)
R["Victory Road 3F-SE"]:connect_warp(R["Victory Road 2F-SE"], "Victory Road 3F-SE to Victory Road 2F-SE", ER_INTERIOR)

-- === Victory Road 3F-S ===
R["Victory Road 3F-S"]:connect_one_way(R["Victory Road 3F"], "Victory Road 3F-S to Victory Road 3F", strength)
R["Victory Road 3F-S"]:connect_one_way(R["Victory Road 3F-Wild"], "Victory Road 3F-S to Victory Road 3F-Wild")
R["Victory Road 3F-S"]:connect_one_way(R["Victory Road 2F-C"], "Victory Road 3F-S to Victory Road 2F-C")

-- === Rocket Hideout B1F ===
R["Rocket Hideout B1F"]:connect_warp(R["Rocket Hideout B2F"], "Rocket Hideout B1F to Rocket Hideout B2F", ER_INTERIOR)
R["Rocket Hideout B1F"]:connect_warp(R["Celadon Game Corner-Hidden Stairs"], "Rocket Hideout B1F to Celadon Game Corner-Hidden Stairs", ER_SIMPLE_ON)

-- === Rocket Hideout B1F-SE ===
R["Rocket Hideout B1F-SE"]:connect_one_way(R["Rocket Hideout B1F"], "Rocket Hideout B1F-SE to Rocket Hideout B1F")
R["Rocket Hideout B1F-SE"]:connect_warp(R["Rocket Hideout Elevator-B1F"], "Rocket Hideout B1F-SE to Rocket Hideout Elevator-B1F", ER_INTERIOR)

-- === Rocket Hideout B1F-S ===
R["Rocket Hideout B1F-S"]:connect_warp(R["Rocket Hideout B2F"], "Rocket Hideout B1F-S to Rocket Hideout B2F", ER_INTERIOR)

-- === Rocket Hideout B2F ===
R["Rocket Hideout B2F"]:connect_warp(R["Rocket Hideout B1F"], "Rocket Hideout B2F to Rocket Hideout B1F", ER_INTERIOR)
R["Rocket Hideout B2F"]:connect_warp(R["Rocket Hideout B3F"], "Rocket Hideout B2F to Rocket Hideout B3F", ER_INTERIOR)
R["Rocket Hideout B2F"]:connect_warp(R["Rocket Hideout Elevator-B2F"], "Rocket Hideout B2F to Rocket Hideout Elevator-B2F", ER_INTERIOR)
R["Rocket Hideout B2F"]:connect_warp(R["Rocket Hideout B1F-S"], "Rocket Hideout B2F to Rocket Hideout B1F-S", ER_INTERIOR)

-- === Rocket Hideout B3F ===
R["Rocket Hideout B3F"]:connect_warp(R["Rocket Hideout B2F"], "Rocket Hideout B3F to Rocket Hideout B2F", ER_INTERIOR)
R["Rocket Hideout B3F"]:connect_warp(R["Rocket Hideout B4F-NW"], "Rocket Hideout B3F to Rocket Hideout B4F-NW", ER_INTERIOR)

-- === Rocket Hideout B4F ===
R["Rocket Hideout B4F"]:connect_warp(R["Rocket Hideout Elevator-B4F"], "Rocket Hideout B4F to Rocket Hideout Elevator-B4F", ER_INTERIOR)

-- === Rocket Hideout B4F-NW ===
R["Rocket Hideout B4F-NW"]:connect_warp(R["Rocket Hideout B3F"], "Rocket Hideout B4F-NW to Rocket Hideout B3F", ER_INTERIOR)

-- === Rocket Hideout Elevator ===
R["Rocket Hideout Elevator"]:connect_one_way(R["Rocket Hideout Elevator-B1F"], "Rocket Hideout Elevator to Rocket Hideout Elevator-B1F", lift_key)
R["Rocket Hideout Elevator"]:connect_one_way(R["Rocket Hideout Elevator-B2F"], "Rocket Hideout Elevator to Rocket Hideout Elevator-B2F", lift_key)
R["Rocket Hideout Elevator"]:connect_one_way(R["Rocket Hideout Elevator-B4F"], "Rocket Hideout Elevator to Rocket Hideout Elevator-B4F", lift_key)

-- === Silph Co Elevator ===
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-1F"], "Silph Co Elevator to Silph Co Elevator-1F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-2F"], "Silph Co Elevator to Silph Co Elevator-2F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-3F"], "Silph Co Elevator to Silph Co Elevator-3F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-4F"], "Silph Co Elevator to Silph Co Elevator-4F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-5F"], "Silph Co Elevator to Silph Co Elevator-5F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-6F"], "Silph Co Elevator to Silph Co Elevator-6F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-7F"], "Silph Co Elevator to Silph Co Elevator-7F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-8F"], "Silph Co Elevator to Silph Co Elevator-8F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-9F"], "Silph Co Elevator to Silph Co Elevator-9F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-10F"], "Silph Co Elevator to Silph Co Elevator-10F", elevator_unlocked)
R["Silph Co Elevator"]:connect_one_way(R["Silph Co Elevator-11F"], "Silph Co Elevator to Silph Co Elevator-11F", elevator_unlocked)

-- === Celadon Department Store Elevator ===
R["Celadon Department Store Elevator"]:connect_one_way(R["Celadon Department Store Elevator-1F"], "Celadon Department Store Elevator to Celadon Department Store Elevator-1F", elevator_unlocked)
R["Celadon Department Store Elevator"]:connect_one_way(R["Celadon Department Store Elevator-2F"], "Celadon Department Store Elevator to Celadon Department Store Elevator-2F", elevator_unlocked)
R["Celadon Department Store Elevator"]:connect_one_way(R["Celadon Department Store Elevator-3F"], "Celadon Department Store Elevator to Celadon Department Store Elevator-3F", elevator_unlocked)
R["Celadon Department Store Elevator"]:connect_one_way(R["Celadon Department Store Elevator-4F"], "Celadon Department Store Elevator to Celadon Department Store Elevator-4F", elevator_unlocked)
R["Celadon Department Store Elevator"]:connect_one_way(R["Celadon Department Store Elevator-5F"], "Celadon Department Store Elevator to Celadon Department Store Elevator-5F", elevator_unlocked)

-- === Rocket Hideout Elevator-B1F ===
R["Rocket Hideout Elevator-B1F"]:connect_one_way(R["Rocket Hideout Elevator"], "Rocket Hideout Elevator-B1F to Rocket Hideout Elevator", lift_key)
R["Rocket Hideout Elevator-B1F"]:connect_warp(R["Rocket Hideout B1F-SE"], "Rocket Hideout Elevator-B1F to Rocket Hideout B1F-SE", ER_INTERIOR)

-- === Rocket Hideout Elevator-B2F ===
R["Rocket Hideout Elevator-B2F"]:connect_one_way(R["Rocket Hideout Elevator"], "Rocket Hideout Elevator-B2F to Rocket Hideout Elevator", lift_key)
R["Rocket Hideout Elevator-B2F"]:connect_warp(R["Rocket Hideout B2F"], "Rocket Hideout Elevator-B2F to Rocket Hideout B2F", ER_INTERIOR)

-- === Rocket Hideout Elevator-B4F ===
R["Rocket Hideout Elevator-B4F"]:connect_one_way(R["Rocket Hideout Elevator"], "Rocket Hideout Elevator-B4F to Rocket Hideout Elevator", lift_key)
R["Rocket Hideout Elevator-B4F"]:connect_warp(R["Rocket Hideout B4F"], "Rocket Hideout Elevator-B4F to Rocket Hideout B4F", ER_INTERIOR)

-- === Silph Co Elevator-1F ===
R["Silph Co Elevator-1F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-1F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-1F"]:connect_warp(R["Silph Co 1F"], "Silph Co Elevator-1F to Silph Co 1F", ER_INTERIOR)

-- === Silph Co Elevator-2F ===
R["Silph Co Elevator-2F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-2F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-2F"]:connect_warp(R["Silph Co 2F"], "Silph Co Elevator-2F to Silph Co 2F", ER_INTERIOR)

-- === Silph Co Elevator-3F ===
R["Silph Co Elevator-3F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-3F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-3F"]:connect_warp(R["Silph Co 3F"], "Silph Co Elevator-3F to Silph Co 3F", ER_INTERIOR)

-- === Silph Co Elevator-4F ===
R["Silph Co Elevator-4F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-4F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-4F"]:connect_warp(R["Silph Co 4F"], "Silph Co Elevator-4F to Silph Co 4F", ER_INTERIOR)

-- === Silph Co Elevator-5F ===
R["Silph Co Elevator-5F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-5F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-5F"]:connect_warp(R["Silph Co 5F"], "Silph Co Elevator-5F to Silph Co 5F", ER_INTERIOR)

-- === Silph Co Elevator-6F ===
R["Silph Co Elevator-6F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-6F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-6F"]:connect_warp(R["Silph Co 6F"], "Silph Co Elevator-6F to Silph Co 6F", ER_INTERIOR)

-- === Silph Co Elevator-7F ===
R["Silph Co Elevator-7F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-7F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-7F"]:connect_warp(R["Silph Co 7F"], "Silph Co Elevator-7F to Silph Co 7F", ER_INTERIOR)

-- === Silph Co Elevator-8F ===
R["Silph Co Elevator-8F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-8F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-8F"]:connect_warp(R["Silph Co 8F"], "Silph Co Elevator-8F to Silph Co 8F", ER_INTERIOR)

-- === Silph Co Elevator-9F ===
R["Silph Co Elevator-9F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-9F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-9F"]:connect_warp(R["Silph Co 9F"], "Silph Co Elevator-9F to Silph Co 9F", ER_INTERIOR)

-- === Silph Co Elevator-10F ===
R["Silph Co Elevator-10F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-10F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-10F"]:connect_warp(R["Silph Co 10F"], "Silph Co Elevator-10F to Silph Co 10F", ER_INTERIOR)

-- === Silph Co Elevator-11F ===
R["Silph Co Elevator-11F"]:connect_one_way(R["Silph Co Elevator"], "Silph Co Elevator-11F to Silph Co Elevator", elevator_unlocked)
R["Silph Co Elevator-11F"]:connect_warp(R["Silph Co 11F"], "Silph Co Elevator-11F to Silph Co 11F", ER_INTERIOR)

-- === Safari Zone East ===
R["Safari Zone East"]:connect_one_way(R["Safari Zone Fishing"], "Safari Zone East to Safari Zone Fishing", super_rod)
R["Safari Zone East"]:connect_warp(R["Safari Zone North"], "Safari Zone East to Safari Zone North", ER_FIXED_SAFARI)
R["Safari Zone East"]:connect_warp(R["Safari Zone Center-S"], "Safari Zone East to Safari Zone Center-S", ER_FIXED_SAFARI)
R["Safari Zone East"]:connect_warp(R["Safari Zone East Rest House"], "Safari Zone East to Safari Zone East Rest House", ER_EXTERIOR)

-- === Safari Zone North ===
R["Safari Zone North"]:connect_one_way(R["Safari Zone Fishing"], "Safari Zone North to Safari Zone Fishing", super_rod)
R["Safari Zone North"]:connect_warp(R["Safari Zone West-NW"], "Safari Zone North to Safari Zone West-NW", ER_FIXED_SAFARI)
R["Safari Zone North"]:connect_warp(R["Safari Zone West"], "Safari Zone North to Safari Zone West", ER_FIXED_SAFARI)
R["Safari Zone North"]:connect_warp(R["Safari Zone Center-NE"], "Safari Zone North to Safari Zone Center-NE", ER_FIXED_SAFARI)
R["Safari Zone North"]:connect_warp(R["Safari Zone East"], "Safari Zone North to Safari Zone East", ER_FIXED_SAFARI)
R["Safari Zone North"]:connect_warp(R["Safari Zone North Rest House"], "Safari Zone North to Safari Zone North Rest House", ER_EXTERIOR)

-- === Safari Zone Center-C ===
R["Safari Zone Center-C"]:connect_one_way(R["Safari Zone Center-NW"], "Safari Zone Center-C to Safari Zone Center-NW", surf)
R["Safari Zone Center-C"]:connect_one_way(R["Safari Zone Center-NE"], "Safari Zone Center-C to Safari Zone Center-NE", surf)
R["Safari Zone Center-C"]:connect_one_way(R["Safari Zone Center-S"], "Safari Zone Center-C to Safari Zone Center-S", surf)

-- === Safari Zone Center-NW ===
R["Safari Zone Center-NW"]:connect_one_way(R["Safari Zone Fishing"], "Safari Zone Center-NW to Safari Zone Fishing", super_rod)
R["Safari Zone Center-NW"]:connect_one_way(R["Safari Zone Center-C"], "Safari Zone Center-NW to Safari Zone Center-C", surf)
R["Safari Zone Center-NW"]:connect_one_way(R["Safari Zone Center-Wild"], "Safari Zone Center-NW to Safari Zone Center-Wild")
R["Safari Zone Center-NW"]:connect_warp(R["Safari Zone West"], "Safari Zone Center-NW to Safari Zone West", ER_FIXED_SAFARI)

-- === Safari Zone Center-NE ===
R["Safari Zone Center-NE"]:connect_one_way(R["Safari Zone Fishing"], "Safari Zone Center-NE to Safari Zone Fishing", super_rod)
R["Safari Zone Center-NE"]:connect_one_way(R["Safari Zone Center-C"], "Safari Zone Center-NE to Safari Zone Center-C", surf)
R["Safari Zone Center-NE"]:connect_one_way(R["Safari Zone Center-Wild"], "Safari Zone Center-NE to Safari Zone Center-Wild")
R["Safari Zone Center-NE"]:connect_warp(R["Safari Zone North"], "Safari Zone Center-NE to Safari Zone North", ER_FIXED_SAFARI)

-- === Safari Zone Center-S ===
R["Safari Zone Center-S"]:connect_one_way(R["Safari Zone Fishing"], "Safari Zone Center-S to Safari Zone Fishing", super_rod)
R["Safari Zone Center-S"]:connect_one_way(R["Safari Zone Center-C"], "Safari Zone Center-S to Safari Zone Center-C", surf)
R["Safari Zone Center-S"]:connect_one_way(R["Safari Zone Center-Wild"], "Safari Zone Center-S to Safari Zone Center-Wild")
R["Safari Zone Center-S"]:connect_warp(R["Safari Zone Gate-N"], "Safari Zone Center-S to Safari Zone Gate-N", ER_FIXED_SAFARI)
R["Safari Zone Center-S"]:connect_warp(R["Safari Zone East"], "Safari Zone Center-S to Safari Zone East", ER_FIXED_SAFARI)
R["Safari Zone Center-S"]:connect_warp(R["Safari Zone Center Rest House"], "Safari Zone Center-S to Safari Zone Center Rest House", ER_EXTERIOR)

-- === Safari Zone Center Rest House ===
R["Safari Zone Center Rest House"]:connect_warp(R["Safari Zone Center-S"], "Safari Zone Center Rest House to Safari Zone Center-S", ER_EXTERIOR)

-- === Safari Zone West Rest House ===
R["Safari Zone West Rest House"]:connect_warp(R["Safari Zone West"], "Safari Zone West Rest House to Safari Zone West", ER_EXTERIOR)

-- === Safari Zone East Rest House ===
R["Safari Zone East Rest House"]:connect_warp(R["Safari Zone East"], "Safari Zone East Rest House to Safari Zone East", ER_EXTERIOR)

-- === Safari Zone North Rest House ===
R["Safari Zone North Rest House"]:connect_warp(R["Safari Zone North"], "Safari Zone North Rest House to Safari Zone North", ER_EXTERIOR)

-- === Cerulean Cave 2F-E ===
R["Cerulean Cave 2F-E"]:connect_one_way(R["Cerulean Cave 2F-Wild"], "Cerulean Cave 2F-E to Cerulean Cave 2F-Wild")
R["Cerulean Cave 2F-E"]:connect_warp(R["Cerulean Cave 1F-NE"], "Cerulean Cave 2F-E to Cerulean Cave 1F-NE", ER_INTERIOR)
R["Cerulean Cave 2F-E"]:connect_warp(R["Cerulean Cave 1F-SE"], "Cerulean Cave 2F-E to Cerulean Cave 1F-SE", ER_INTERIOR)

-- === Cerulean Cave 2F-W ===
R["Cerulean Cave 2F-W"]:connect_one_way(R["Cerulean Cave 2F-Wild"], "Cerulean Cave 2F-W to Cerulean Cave 2F-Wild")
R["Cerulean Cave 2F-W"]:connect_warp(R["Cerulean Cave 1F-NW"], "Cerulean Cave 2F-W to Cerulean Cave 1F-NW", ER_INTERIOR)
R["Cerulean Cave 2F-W"]:connect_warp(R["Cerulean Cave 1F-SW"], "Cerulean Cave 2F-W to Cerulean Cave 1F-SW", ER_INTERIOR)

-- === Cerulean Cave 2F-N ===
R["Cerulean Cave 2F-N"]:connect_one_way(R["Cerulean Cave 2F-Wild"], "Cerulean Cave 2F-N to Cerulean Cave 2F-Wild")
R["Cerulean Cave 2F-N"]:connect_warp(R["Cerulean Cave 1F-SW"], "Cerulean Cave 2F-N to Cerulean Cave 1F-SW", ER_INTERIOR)
R["Cerulean Cave 2F-N"]:connect_warp(R["Cerulean Cave 1F-N"], "Cerulean Cave 2F-N to Cerulean Cave 1F-N", ER_INTERIOR)

-- === Cerulean Cave B1F ===
R["Cerulean Cave B1F"]:connect_one_way(R["Cerulean Cave B1F-E"], "Cerulean Cave B1F to Cerulean Cave B1F-E", surf)
R["Cerulean Cave B1F"]:connect_one_way(R["Route 23/Cerulean Cave Fishing"], "Cerulean Cave B1F to Route 23/Cerulean Cave Fishing", super_rod)
R["Cerulean Cave B1F"]:connect_warp(R["Cerulean Cave 1F-NW"], "Cerulean Cave B1F to Cerulean Cave 1F-NW", ER_INTERIOR)

-- === Rock Tunnel B1F-E 1 ===
R["Rock Tunnel B1F-E 1"]:connect_one_way(R["Rock Tunnel B1F-E"], "Rock Tunnel B1F-E 1 to Rock Tunnel B1F-E", rock_tunnel)
R["Rock Tunnel B1F-E 1"]:connect_warp(R["Rock Tunnel 1F-NE 2"], "Rock Tunnel B1F-E 1 to Rock Tunnel 1F-NE 2", ER_INTERIOR)

-- === Rock Tunnel B1F-E 2 ===
R["Rock Tunnel B1F-E 2"]:connect_one_way(R["Rock Tunnel B1F-E"], "Rock Tunnel B1F-E 2 to Rock Tunnel B1F-E", rock_tunnel)
R["Rock Tunnel B1F-E 2"]:connect_warp(R["Rock Tunnel 1F-NW 1"], "Rock Tunnel B1F-E 2 to Rock Tunnel 1F-NW 1", ER_INTERIOR)

-- === Rock Tunnel B1F-W 1 ===
R["Rock Tunnel B1F-W 1"]:connect_one_way(R["Rock Tunnel B1F-W"], "Rock Tunnel B1F-W 1 to Rock Tunnel B1F-W", rock_tunnel)
R["Rock Tunnel B1F-W 1"]:connect_warp(R["Rock Tunnel 1F-NW 2"], "Rock Tunnel B1F-W 1 to Rock Tunnel 1F-NW 2", ER_INTERIOR)

-- === Rock Tunnel B1F-W 2 ===
R["Rock Tunnel B1F-W 2"]:connect_one_way(R["Rock Tunnel B1F-W"], "Rock Tunnel B1F-W 2 to Rock Tunnel B1F-W", rock_tunnel)
R["Rock Tunnel B1F-W 2"]:connect_warp(R["Rock Tunnel 1F-S 2"], "Rock Tunnel B1F-W 2 to Rock Tunnel 1F-S 2", ER_INTERIOR)

-- === Seafoam Islands B1F ===
R["Seafoam Islands B1F"]:connect_one_way(R["Seafoam Islands B1F-Wild"], "Seafoam Islands B1F to Seafoam Islands B1F-Wild")
R["Seafoam Islands B1F"]:connect_one_way(R["Seafoam Islands B2F-NW"], "Seafoam Islands 1F to Seafoam Islands B2F-NW (Drop)")
R["Seafoam Islands B1F"]:connect_warp(R["Seafoam Islands B2F-NW"], "Seafoam Islands B1F to Seafoam Islands B2F-NW", ER_INTERIOR)
R["Seafoam Islands B1F"]:connect_warp(R["Seafoam Islands 1F"], "Seafoam Islands B1F to Seafoam Islands 1F", ER_INTERIOR)
R["Seafoam Islands B1F"]:connect_warp(R["Seafoam Islands B2F-SW"], "Seafoam Islands B1F to Seafoam Islands B2F-SW N", ER_INTERIOR)
R["Seafoam Islands B1F"]:connect_warp(R["Seafoam Islands B2F-SW"], "Seafoam Islands B1F to Seafoam Islands B2F-SW S", ER_INTERIOR)

-- === Seafoam Islands B1F-SE ===
R["Seafoam Islands B1F-SE"]:connect_one_way(R["Seafoam Islands B1F-Wild"], "Seafoam Islands B1F-SE to Seafoam Islands B1F-Wild")
R["Seafoam Islands B1F-SE"]:connect_warp(R["Seafoam Islands 1F-SE"], "Seafoam Islands B1F-SE to Seafoam Islands 1F-SE", ER_INTERIOR)
R["Seafoam Islands B1F-SE"]:connect_warp(R["Seafoam Islands B2F-SE"], "Seafoam Islands B1F-SE to Seafoam Islands B2F-SE", ER_INTERIOR)

-- === Seafoam Islands B1F-NE ===
R["Seafoam Islands B1F-NE"]:connect_one_way(R["Seafoam Islands B1F-Wild"], "Seafoam Islands B1F-NE to Seafoam Islands B1F-Wild")
R["Seafoam Islands B1F-NE"]:connect_one_way(R["Seafoam Islands B2F-NE"], "Seafoam Islands B1F-NE to Seafoam Islands B2F-NE")
R["Seafoam Islands B1F-NE"]:connect_warp(R["Seafoam Islands 1F"], "Seafoam Islands B1F-NE to Seafoam Islands 1F", ER_INTERIOR)

-- === Seafoam Islands B2F-SE ===
R["Seafoam Islands B2F-SE"]:connect_one_way(R["Seafoam Islands B2F-Wild"], "Seafoam Islands B2F-SE to Seafoam Islands B2F-Wild")
R["Seafoam Islands B2F-SE"]:connect_warp(R["Seafoam Islands B1F-SE"], "Seafoam Islands B2F-SE to Seafoam Islands B1F-SE", ER_INTERIOR)
R["Seafoam Islands B2F-SE"]:connect_warp(R["Seafoam Islands B3F-SE"], "Seafoam Islands B2F-SE to Seafoam Islands B3F-SE", ER_INTERIOR)

-- === Seafoam Islands B2F-NE ===
R["Seafoam Islands B2F-NE"]:connect_one_way(R["Seafoam Islands B2F-Wild"], "Seafoam Islands B2F-NE to Seafoam Islands B2F-Wild")
R["Seafoam Islands B2F-NE"]:connect_one_way(R["Seafoam Islands B3F"], "Seafoam Islands B2F-NE to Seafoam Islands B3F", strength_seafoam_boulders)
R["Seafoam Islands B2F-NE"]:connect_one_way(R["Seafoam Islands B3F-SE"], "Seafoam Islands B2F-NE to Seafoam Islands B3F-SE", strength_seafoam_boulders)
R["Seafoam Islands B2F-NE"]:connect_one_way(R["Seafoam Islands B4F-W"], "Seafoam Islands B2F-NE to Seafoam Islands B4F-W")
R["Seafoam Islands B2F-NE"]:connect_warp(R["Seafoam Islands B3F-NE"], "Seafoam Islands B2F-NE to Seafoam Islands B3F-NE", ER_INTERIOR)

-- === Seafoam Islands B2F-SW ===
R["Seafoam Islands B2F-SW"]:connect_one_way(R["Seafoam Islands B2F-Wild"], "Seafoam Islands B2F-SW to Seafoam Islands B2F-Wild")
R["Seafoam Islands B2F-SW"]:connect_warp(R["Seafoam Islands B1F"], "Seafoam Islands B2F-SW to Seafoam Islands 1F-SW S", ER_INTERIOR)
R["Seafoam Islands B2F-SW"]:connect_warp(R["Seafoam Islands B3F"], "Seafoam Islands B2F-SW to Seafoam Islands B3F", ER_INTERIOR)
R["Seafoam Islands B2F-SW"]:connect_warp(R["Seafoam Islands B1F"], "Seafoam Islands B2F-SW to Seafoam Islands 1F-SW N", ER_INTERIOR)

-- === Seafoam Islands B2F-NW ===
R["Seafoam Islands B2F-NW"]:connect_one_way(R["Seafoam Islands B2F-Wild"], "Seafoam Islands B2F-NW to Seafoam Islands B2F-Wild")
R["Seafoam Islands B2F-NW"]:connect_one_way(R["Seafoam Islands B3F"], "Seafoam Islands B2F-NW to Seafoam Islands B3F", strength_seafoam_boulders)
R["Seafoam Islands B2F-NW"]:connect_one_way(R["Seafoam Islands B3F-SE"], "Seafoam Islands B2F-NW to Seafoam Islands B3F-SE", strength_seafoam_boulders)
R["Seafoam Islands B2F-NW"]:connect_one_way(R["Seafoam Islands B4F-W"], "Seafoam Islands B2F-NW to Seafoam Islands B4F-W")
R["Seafoam Islands B2F-NW"]:connect_warp(R["Seafoam Islands B1F"], "Seafoam Islands B2F-NW to Seafoam Islands B1F", ER_INTERIOR)

-- === Seafoam Islands B3F ===
R["Seafoam Islands B3F"]:connect_one_way(R["Sea Routes/Cinnabar/Seafoam Fishing"], "Seafoam Islands B3F to Sea Routes/Cinnabar/Seafoam Fishing", super_rod)
R["Seafoam Islands B3F"]:connect_one_way(R["Seafoam Islands B3F-Wild"], "Seafoam Islands B3F to Seafoam Islands B3F-Wild")
R["Seafoam Islands B3F"]:connect_one_way(R["Seafoam Islands B3F-SE"], "Seafoam Islands B3F to Seafoam Islands B3F-SE", surf_strength_seafoam_boulders)
R["Seafoam Islands B3F"]:connect_one_way(R["Seafoam Islands B4F"], "Seafoam Islands B1F to Seafoam Islands B4F (Drop)")
R["Seafoam Islands B3F"]:connect_one_way(R["Seafoam Islands B4F-W"], "Seafoam Islands B3F to Seafoam Islands B4F-W", surf)
R["Seafoam Islands B3F"]:connect_warp(R["Seafoam Islands B2F-SW"], "Seafoam Islands B3F to Seafoam Islands B2F-SW", ER_INTERIOR)
R["Seafoam Islands B3F"]:connect_warp(R["Seafoam Islands B4F"], "Seafoam Islands B3F to Seafoam Islands B4F", ER_INTERIOR)

-- === Seafoam Islands B3F-SE ===
R["Seafoam Islands B3F-SE"]:connect_one_way(R["Seafoam Islands B3F-Wild"], "Seafoam Islands B3F-SE to Seafoam Islands B3F-Wild")
R["Seafoam Islands B3F-SE"]:connect_one_way(R["Seafoam Islands B3F"], "Seafoam Islands B3F-SE to Seafoam Islands B3F", surf_strength_seafoam_boulders)
R["Seafoam Islands B3F-SE"]:connect_warp(R["Seafoam Islands B2F-SE"], "Seafoam Islands B3F-SE to Seafoam Islands B2F-SE", ER_INTERIOR)

-- === Seafoam Islands B3F-NE ===
R["Seafoam Islands B3F-NE"]:connect_one_way(R["Seafoam Islands B3F-Wild"], "Seafoam Islands B3F-NE to Seafoam Islands B3F-Wild")
R["Seafoam Islands B3F-NE"]:connect_warp(R["Seafoam Islands B4F"], "Seafoam Islands B3F-NE to Seafoam Islands B4F", ER_INTERIOR)
R["Seafoam Islands B3F-NE"]:connect_warp(R["Seafoam Islands B2F-NE"], "Seafoam Islands B3F-NE to Seafoam Islands B2F-NE", ER_INTERIOR)

-- === Seafoam Islands B4F-W ===
R["Seafoam Islands B4F-W"]:connect_one_way(R["Seafoam Islands B4F"], "Seafoam Islands B4F-W to Seafoam Islands B4F")

-- === Seafoam Islands B4F ===
R["Seafoam Islands B4F"]:connect_one_way(R["Sea Routes/Cinnabar/Seafoam Fishing"], "Seafoam Islands B4F to Sea Routes/Cinnabar/Seafoam Fishing", super_rod)
R["Seafoam Islands B4F"]:connect_one_way(R["Seafoam Islands B4F-W"], "Seafoam Islands B4F to Seafoam Islands B4F-W", surf)
R["Seafoam Islands B4F"]:connect_warp(R["Seafoam Islands B3F"], "Seafoam Islands B4F to Seafoam Islands B3F", ER_INTERIOR)
R["Seafoam Islands B4F"]:connect_warp(R["Seafoam Islands B3F-NE"], "Seafoam Islands B4F to Seafoam Islands B3F-NE", ER_INTERIOR)

-- === Route 7 ===
R["Route 7"]:connect_one_way(R["Celadon City"], "Route 7 to Celadon City")
R["Route 7"]:connect_warp(R["Route 7 Gate-W"], "Route 7 to Route 7 Gate-W", ER_EXTERIOR)
R["Route 7"]:connect_warp(R["Underground Path Route 7"], "Route 7 to Underground Path Route 7", ER_EXTERIOR)

-- === Route 7-E ===
R["Route 7-E"]:connect_one_way(R["Saffron City"], "Route 7-E to Saffron City")
R["Route 7-E"]:connect_warp(R["Route 7 Gate-E"], "Route 7-E to Route 7 Gate-E", ER_EXTERIOR)

-- === Player's House 1F ===
R["Player's House 1F"]:connect_warp(R["Pallet Town"], "Player's House 1F to Pallet Town", ER_EXTERIOR)
R["Player's House 1F"]:connect_warp(R["Player's House 2F"], "Player's House 1F to Player's House 2F", ER_FIXED_FULL)

-- === Celadon Department Store 3F ===
R["Celadon Department Store 3F"]:connect_warp(R["Celadon Department Store 4F"], "Celadon Department Store 3F to Celadon Department Store 4F", ER_INTERIOR)
R["Celadon Department Store 3F"]:connect_warp(R["Celadon Department Store 2F"], "Celadon Department Store 3F to Celadon Department Store 2F", ER_INTERIOR)
R["Celadon Department Store 3F"]:connect_warp(R["Celadon Department Store Elevator-3F"], "Celadon Department Store 3F to Celadon Department Store Elevator-3F", ER_INTERIOR)

-- === Celadon Department Store 4F ===
R["Celadon Department Store 4F"]:connect_warp(R["Celadon Department Store 3F"], "Celadon Department Store 4F to Celadon Department Store 3F", ER_INTERIOR)
R["Celadon Department Store 4F"]:connect_warp(R["Celadon Department Store 5F"], "Celadon Department Store 4F to Celadon Department Store 5F", ER_INTERIOR)
R["Celadon Department Store 4F"]:connect_warp(R["Celadon Department Store Elevator-4F"], "Celadon Department Store 4F to Celadon Department Store Elevator-4F", ER_INTERIOR)

-- === Celadon Department Store Roof ===
R["Celadon Department Store Roof"]:connect_warp(R["Celadon Department Store 5F"], "Celadon Department Store Roof to Celadon Department Store 5F", ER_INTERIOR)

-- === Celadon Department Store Elevator-1F ===
R["Celadon Department Store Elevator-1F"]:connect_one_way(R["Celadon Department Store Elevator"], "Celadon Department Store Elevator-1F to Celadon Department Store Elevator", elevator_unlocked)
R["Celadon Department Store Elevator-1F"]:connect_warp(R["Celadon Department Store 1F"], "Celadon Department Store Elevator-1F to Celadon Department Store 1F", ER_INTERIOR)

-- === Celadon Department Store Elevator-2F ===
R["Celadon Department Store Elevator-2F"]:connect_one_way(R["Celadon Department Store Elevator"], "Celadon Department Store Elevator-2F to Celadon Department Store Elevator", elevator_unlocked)
R["Celadon Department Store Elevator-2F"]:connect_warp(R["Celadon Department Store 2F"], "Celadon Department Store Elevator-2F to Celadon Department Store 2F", ER_INTERIOR)

-- === Celadon Department Store Elevator-3F ===
R["Celadon Department Store Elevator-3F"]:connect_one_way(R["Celadon Department Store Elevator"], "Celadon Department Store Elevator-3F to Celadon Department Store Elevator", elevator_unlocked)
R["Celadon Department Store Elevator-3F"]:connect_warp(R["Celadon Department Store 3F"], "Celadon Department Store Elevator-3F to Celadon Department Store 3F", ER_INTERIOR)

-- === Celadon Department Store Elevator-4F ===
R["Celadon Department Store Elevator-4F"]:connect_one_way(R["Celadon Department Store Elevator"], "Celadon Department Store Elevator-4F to Celadon Department Store Elevator", elevator_unlocked)
R["Celadon Department Store Elevator-4F"]:connect_warp(R["Celadon Department Store 4F"], "Celadon Department Store Elevator-4F to Celadon Department Store 4F", ER_INTERIOR)

-- === Celadon Department Store Elevator-5F ===
R["Celadon Department Store Elevator-5F"]:connect_one_way(R["Celadon Department Store Elevator"], "Celadon Department Store Elevator-5F to Celadon Department Store Elevator", elevator_unlocked)
R["Celadon Department Store Elevator-5F"]:connect_warp(R["Celadon Department Store 5F"], "Celadon Department Store Elevator-5F to Celadon Department Store 5F", ER_INTERIOR)

-- === Celadon Mansion 1F ===
R["Celadon Mansion 1F"]:connect_warp(R["Celadon City"], "Celadon Mansion 1F to Celadon City", ER_EXTERIOR)
R["Celadon Mansion 1F"]:connect_warp(R["Celadon Mansion 2F"], "Celadon Mansion 1F to Celadon Mansion 2F", ER_INTERIOR)

-- === Celadon Mansion 1F-Back ===
R["Celadon Mansion 1F-Back"]:connect_warp(R["Celadon Mansion 2F-Back"], "Celadon Mansion 1F-Back to Celadon Mansion 2F-Back", ER_INTERIOR)
R["Celadon Mansion 1F-Back"]:connect_warp(R["Celadon City"], "Celadon Mansion 1F-Back to Celadon City", ER_EXTERIOR)

-- === Celadon Mansion 2F ===
R["Celadon Mansion 2F"]:connect_warp(R["Celadon Mansion 3F"], "Celadon Mansion 2F to Celadon Mansion 3F", ER_INTERIOR)
R["Celadon Mansion 2F"]:connect_warp(R["Celadon Mansion 1F"], "Celadon Mansion 2F to Celadon Mansion 1F", ER_INTERIOR)

-- === Celadon Mansion 2F-Back ===
R["Celadon Mansion 2F-Back"]:connect_warp(R["Celadon Mansion 1F-Back"], "Celadon Mansion 2F-Back to Celadon Mansion 1F-Back", ER_INTERIOR)
R["Celadon Mansion 2F-Back"]:connect_warp(R["Celadon Mansion 3F-Back"], "Celadon Mansion 2F-Back to Celadon Mansion 3F-Back", ER_INTERIOR)

-- === Celadon Mansion 3F ===
R["Celadon Mansion 3F"]:connect_warp(R["Celadon Mansion 2F"], "Celadon Mansion 3F to Celadon Mansion 2F", ER_INTERIOR)
R["Celadon Mansion 3F"]:connect_warp(R["Celadon Mansion Roof"], "Celadon Mansion 3F to Celadon Mansion Roof", ER_INTERIOR)

-- === Celadon Mansion 3F-Back ===
R["Celadon Mansion 3F-Back"]:connect_warp(R["Celadon Mansion Roof-Back"], "Celadon Mansion 3F-Back to Celadon Mansion Roof-Back", ER_INTERIOR)
R["Celadon Mansion 3F-Back"]:connect_warp(R["Celadon Mansion 2F-Back"], "Celadon Mansion 3F-Back to Celadon Mansion 2F-Back", ER_INTERIOR)

-- === Celadon Mansion Roof ===
R["Celadon Mansion Roof"]:connect_warp(R["Celadon Mansion 3F"], "Celadon Mansion Roof to Celadon Mansion 3F", ER_INTERIOR)

-- === Celadon Mansion Roof-Back ===
R["Celadon Mansion Roof-Back"]:connect_warp(R["Celadon Mansion 3F-Back"], "Celadon Mansion Roof-Back to Celadon Mansion 3F-Back", ER_INTERIOR)
R["Celadon Mansion Roof-Back"]:connect_warp(R["Celadon Mansion Roof House"], "Celadon Mansion Roof-Back to Celadon Mansion Roof House", ER_INTERIOR)

-- === Celadon Pokemon Center ===
R["Celadon Pokemon Center"]:connect_warp(R["Celadon City"], "Celadon Pokemon Center to Celadon City", ER_EXTERIOR)

-- === Celadon Gym ===
R["Celadon Gym"]:connect_one_way(R["Celadon Gym-C"], "Celadon Gym to Celadon Gym-C", cut)
R["Celadon Gym"]:connect_warp(R["Celadon City-G"], "Celadon Gym to Celadon City-G", ER_EXTERIOR)

-- === Celadon Game Corner ===
R["Celadon Game Corner"]:connect_one_way(R["Celadon Game Corner-Hidden Stairs"], "Celadon Game Corner to Celadon Game Corner-Hidden Stairs", hideout_key)
R["Celadon Game Corner"]:connect_warp(R["Celadon City"], "Celadon Game Corner to Celadon City", ER_SIMPLE_OFF)

-- === Celadon Game Corner-Hidden Stairs ===
R["Celadon Game Corner-Hidden Stairs"]:connect_one_way(R["Celadon Game Corner"], "Celadon Game Corner-Hidden Stairs to Celadon Game Corner")
R["Celadon Game Corner-Hidden Stairs"]:connect_warp(R["Rocket Hideout B1F"], "Celadon Game Corner-Hidden Stairs to Rocket Hideout B1F", ER_SIMPLE_ON)

-- === Celadon Department Store 5F ===
R["Celadon Department Store 5F"]:connect_warp(R["Celadon Department Store Roof"], "Celadon Department Store 5F to Celadon Department Store Roof", ER_INTERIOR)
R["Celadon Department Store 5F"]:connect_warp(R["Celadon Department Store 4F"], "Celadon Department Store 5F to Celadon Department Store 4F", ER_INTERIOR)
R["Celadon Department Store 5F"]:connect_warp(R["Celadon Department Store Elevator-5F"], "Celadon Department Store 5F to Celadon Department Store Elevator-5F", ER_INTERIOR)

-- === Celadon Prize Corner ===
R["Celadon Prize Corner"]:connect_warp(R["Celadon City"], "Celadon Prize Corner to Celadon City", ER_EXTERIOR)

-- === Celadon Diner ===
R["Celadon Diner"]:connect_warp(R["Celadon City"], "Celadon Diner to Celadon City", ER_EXTERIOR)

-- === Celadon Chief House ===
R["Celadon Chief House"]:connect_warp(R["Celadon City"], "Celadon Chief House to Celadon City", ER_EXTERIOR)

-- === Celadon Hotel ===
R["Celadon Hotel"]:connect_warp(R["Celadon City"], "Celadon Hotel to Celadon City", ER_EXTERIOR)

-- === Route 4 Pokemon Center ===
R["Route 4 Pokemon Center"]:connect_warp(R["Route 4-W"], "Route 4 Pokemon Center to Route 4-W", ER_EXTERIOR)

-- === Rock Tunnel Pokemon Center ===
R["Rock Tunnel Pokemon Center"]:connect_warp(R["Route 10-N"], "Rock Tunnel Pokemon Center to Route 10-N", ER_EXTERIOR)

-- === Route 11 Gate 1F ===
R["Route 11 Gate 1F"]:connect_warp(R["Route 11-C"], "Route 11 Gate 1F to Route 11-C", ER_EXTERIOR)
R["Route 11 Gate 1F"]:connect_warp(R["Route 11-E"], "Route 11 Gate 1F to Route 11-E", ER_EXTERIOR)
R["Route 11 Gate 1F"]:connect_warp(R["Route 11 Gate 2F"], "Route 11 Gate 1F to Route 11 Gate 2F", ER_INTERIOR)

-- === Route 11 Gate 2F ===
R["Route 11 Gate 2F"]:connect_warp(R["Route 11 Gate 1F"], "Route 11 Gate 2F to Route 11 Gate 1F", ER_INTERIOR)

-- === Route 12 Gate 1F ===
R["Route 12 Gate 1F"]:connect_warp(R["Route 12-L"], "Route 12 Gate 1F to Route 12-L", ER_EXTERIOR)
R["Route 12 Gate 1F"]:connect_warp(R["Route 12-N"], "Route 12 Gate 1F to Route 12-N", ER_EXTERIOR)
R["Route 12 Gate 1F"]:connect_warp(R["Route 12 Gate 2F"], "Route 12 Gate 1F to Route 12 Gate 2F", ER_INTERIOR)

-- === Route 12 Gate 2F ===
R["Route 12 Gate 2F"]:connect_warp(R["Route 12 Gate 1F"], "Route 12 Gate 2F to Route 12 Gate 1F", ER_INTERIOR)

-- === Route 15 Gate 1F ===
R["Route 15 Gate 1F"]:connect_warp(R["Route 15-W"], "Route 15 Gate 1F to Route 15-W", ER_EXTERIOR)
R["Route 15 Gate 1F"]:connect_warp(R["Route 15"], "Route 15 Gate 1F to Route 15", ER_EXTERIOR)
R["Route 15 Gate 1F"]:connect_warp(R["Route 15 Gate 2F"], "Route 15 Gate 1F to Route 15 Gate 2F", ER_INTERIOR)

-- === Route 15 Gate 2F ===
R["Route 15 Gate 2F"]:connect_warp(R["Route 15 Gate 1F"], "Route 15 Gate 2F to Route 15 Gate 1F", ER_INTERIOR)

-- === Route 16 Gate 1F-W ===
R["Route 16 Gate 1F-W"]:connect_one_way(R["Route 16 Gate 1F-E"], "Route 16 Gate 1F-W to Route 16 Gate 1F-E", cyclingroad)
R["Route 16 Gate 1F-W"]:connect_warp(R["Route 16-SW"], "Route 16 Gate 1F-W to Route 16-SW", ER_EXTERIOR)

-- === Route 16 Gate 1F-E ===
R["Route 16 Gate 1F-E"]:connect_one_way(R["Route 16 Gate 1F-W"], "Route 16 Gate 1F-E to Route 16 Gate 1F-W", cyclingroad)
R["Route 16 Gate 1F-E"]:connect_warp(R["Route 16-C"], "Route 16 Gate 1F-E to Route 16-C", ER_EXTERIOR)
R["Route 16 Gate 1F-E"]:connect_warp(R["Route 16 Gate 2F"], "Route 16 Gate 1F-E to Route 16 Gate 2F", ER_INTERIOR)

-- === Route 16 Gate 1F-N ===
R["Route 16 Gate 1F-N"]:connect_warp(R["Route 16-NW"], "Route 16 Gate 1F-N to Route 16-NW", ER_EXTERIOR)
R["Route 16 Gate 1F-N"]:connect_warp(R["Route 16-NE"], "Route 16 Gate 1F-N to Route 16-NE", ER_EXTERIOR)

-- === Route 16 Gate 2F ===
R["Route 16 Gate 2F"]:connect_warp(R["Route 16 Gate 1F-E"], "Route 16 Gate 2F to Route 16 Gate 1F-E", ER_INTERIOR)

-- === Route 18 Gate 1F-W ===
R["Route 18 Gate 1F-W"]:connect_one_way(R["Route 18 Gate 1F-E"], "Route 18 Gate 1F-W to Route 18 Gate 1F-E", cyclingroad)
R["Route 18 Gate 1F-W"]:connect_warp(R["Route 18-W"], "Route 18 Gate 1F-W to Route 18-W", ER_EXTERIOR)

-- === Route 18 Gate 1F-E ===
R["Route 18 Gate 1F-E"]:connect_one_way(R["Route 18 Gate 1F-W"], "Route 18 Gate 1F-E to Route 18 Gate 1F-W", cyclingroad)
R["Route 18 Gate 1F-E"]:connect_warp(R["Route 18-E"], "Route 18 Gate 1F-E to Route 18-E", ER_EXTERIOR)
R["Route 18 Gate 1F-E"]:connect_warp(R["Route 18 Gate 2F"], "Route 18 Gate 1F-E to Route 18 Gate 2F", ER_INTERIOR)

-- === Route 18 Gate 2F ===
R["Route 18 Gate 2F"]:connect_warp(R["Route 18 Gate 1F-E"], "Route 18 Gate 2F to Route 18 Gate 1F-E", ER_INTERIOR)

-- === Mt Moon 1F ===
R["Mt Moon 1F"]:connect_warp(R["Route 4-W"], "Mt Moon 1F to Route 4-W", ER_EXTERIOR)
R["Mt Moon 1F"]:connect_warp(R["Mt Moon B1F-W"], "Mt Moon 1F to Mt Moon B1F-W", ER_INTERIOR)
R["Mt Moon 1F"]:connect_warp(R["Mt Moon B1F-C"], "Mt Moon 1F to Mt Moon B1F-C", ER_INTERIOR)
R["Mt Moon 1F"]:connect_warp(R["Mt Moon B1F-SE"], "Mt Moon 1F to Mt Moon B1F-SE", ER_INTERIOR)

-- === Mt Moon B2F ===
R["Mt Moon B2F"]:connect_one_way(R["Mt Moon B2F-Wild"], "Mt Moon B2F to Mt Moon B2F-Wild")
R["Mt Moon B2F"]:connect_warp(R["Mt Moon B1F-W"], "Mt Moon B2F to Mt Moon B1F-W", ER_INTERIOR)
R["Mt Moon B2F"]:connect_warp(R["Mt Moon B1F-NE"], "Mt Moon B2F to Mt Moon B1F-NE", ER_INTERIOR)
-- The second fossil check. The apworld hangs it off Menu; the tracker shows it with the Mt Moon
-- fossils, and fossil_checks() reads every region it needs through reach() anyway.
R["Mt Moon B2F"]:connect_one_way(R["Fossil"], "Mt Moon B2F to Fossil", second_fossil_check)

-- === Mt Moon B2F-NE ===
R["Mt Moon B2F-NE"]:connect_one_way(R["Mt Moon B2F-Wild"], "Mt Moon B2F-NE to Mt Moon B2F-Wild")
R["Mt Moon B2F-NE"]:connect_warp(R["Mt Moon B1F-C"], "Mt Moon B2F-NE to Mt Moon B1F-C", ER_INTERIOR)

-- === Mt Moon B2F-C ===
R["Mt Moon B2F-C"]:connect_one_way(R["Mt Moon B2F-Wild"], "Mt Moon B2F-C to Mt Moon B2F-Wild")
R["Mt Moon B2F-C"]:connect_warp(R["Mt Moon B1F-SE"], "Mt Moon B2F-C to Mt Moon B1F-SE", ER_INTERIOR)

-- === Safari Zone West ===
R["Safari Zone West"]:connect_one_way(R["Safari Zone Fishing"], "Safari Zone West to Safari Zone Fishing", super_rod)
R["Safari Zone West"]:connect_one_way(R["Safari Zone West-NW"], "Safari Zone West to Safari Zone West-NW", surf)
R["Safari Zone West"]:connect_one_way(R["Safari Zone West-Wild"], "Safari Zone West to Safari Zone West-Wild")
R["Safari Zone West"]:connect_warp(R["Safari Zone North"], "Safari Zone West to Safari Zone North", ER_FIXED_SAFARI)
R["Safari Zone West"]:connect_warp(R["Safari Zone Center-NW"], "Safari Zone West to Safari Zone Center-NW", ER_FIXED_SAFARI)
R["Safari Zone West"]:connect_warp(R["Safari Zone West Rest House"], "Safari Zone West to Safari Zone West Rest House", ER_EXTERIOR)

-- === Safari Zone West-NW ===
R["Safari Zone West-NW"]:connect_one_way(R["Safari Zone Fishing"], "Safari Zone West-NW to Safari Zone Fishing", super_rod)
R["Safari Zone West-NW"]:connect_one_way(R["Safari Zone West"], "Safari Zone West-NW to Safari Zone West", surf)
R["Safari Zone West-NW"]:connect_one_way(R["Safari Zone West-Wild"], "Safari Zone West-NW to Safari Zone West-Wild")
R["Safari Zone West-NW"]:connect_warp(R["Safari Zone North"], "Safari Zone West-NW to Safari Zone North", ER_FIXED_SAFARI)
R["Safari Zone West-NW"]:connect_warp(R["Safari Zone Secret House"], "Safari Zone West-NW to Safari Zone Secret House", ER_EXTERIOR)

-- === Safari Zone Secret House ===
R["Safari Zone Secret House"]:connect_warp(R["Safari Zone West-NW"], "Safari Zone Secret House to Safari Zone West-NW", ER_EXTERIOR)

-- === Route 22 ===
R["Route 22"]:connect_one_way(R["Viridian City"], "Route 22 to Viridian City")
R["Route 22"]:connect_one_way(R["Route 22-F"], "Route 22 to Route 22-F", giovanni_beaten)
R["Route 22"]:connect_one_way(R["Route 22 Fishing"], "Route 22 to Route 22 Fishing", super_rod)
R["Route 22"]:connect_warp(R["Route 22 Gate-S"], "Route 22 to Route 22 Gate-S", ER_EXTERIOR)

-- === Route 20-IW ===
R["Route 20-IW"]:connect_one_way(R["Sea Routes/Cinnabar/Seafoam Fishing"], "Route 20-IW to Sea Routes/Cinnabar/Seafoam Fishing", super_rod)
R["Route 20-IW"]:connect_one_way(R["Route 20-E"], "Route 20-IW to Route 20-E", surf)
R["Route 20-IW"]:connect_warp(R["Seafoam Islands 1F-SE"], "Route 20-IW to Seafoam Islands 1F-SE", ER_EXTERIOR)

-- === Route 20-IE ===
R["Route 20-IE"]:connect_one_way(R["Sea Routes/Cinnabar/Seafoam Fishing"], "Route 20-IE to Sea Routes/Cinnabar/Seafoam Fishing", super_rod)
R["Route 20-IE"]:connect_one_way(R["Route 20-W"], "Route 20-IE to Route 20-W", surf)
R["Route 20-IE"]:connect_warp(R["Seafoam Islands 1F"], "Route 20-IE to Seafoam Islands 1F", ER_EXTERIOR)

-- === Route 20-E ===
R["Route 20-E"]:connect_one_way(R["Route 20-IW"], "Route 20-E to Route 20-IW", surf)
R["Route 20-E"]:connect_one_way(R["Route 19-S"], "Route 20-E to Route 19-S")
R["Route 20-E"]:connect_one_way(R["Route 19/20-Water"], "Route 20-E to Route 19/20-Water")

-- === Route 20-W ===
R["Route 20-W"]:connect_one_way(R["Cinnabar Island"], "Route 20-W to Cinnabar Island", surf)
R["Route 20-W"]:connect_one_way(R["Route 20-IE"], "Route 20-W to Route 20-IE", surf)
R["Route 20-W"]:connect_one_way(R["Route 19/20-Water"], "Route 20-W to Route 19/20-Water")

-- === Route 23-S ===
R["Route 23-S"]:connect_one_way(R["Route 23-Grass"], "Route 23-S to Route 23-Grass", surf)
R["Route 23-S"]:connect_one_way(R["Route 23/Cerulean Cave Fishing"], "Route 23-S to Route 23/Cerulean Cave Fishing", super_rod)
R["Route 23-S"]:connect_warp(R["Route 22 Gate-N"], "Route 23-S to Route 22 Gate-N", ER_EXTERIOR)

-- === Route 23-C ===
R["Route 23-C"]:connect_one_way(R["Route 23-Grass"], "Route 23-C to Route 23-Grass", victoryroad)
R["Route 23-C"]:connect_warp(R["Victory Road 1F-S"], "Route 23-C to Victory Road 1F-S", ER_EXTERIOR)

-- === Route 23-N ===
R["Route 23-N"]:connect_one_way(R["Indigo Plateau"], "Route 23-N to Indigo Plateau")
R["Route 23-N"]:connect_warp(R["Victory Road 2F-E"], "Route 23-N to Victory Road 2F-E", ER_EXTERIOR)

-- === Route 23-Grass ===
R["Route 23-Grass"]:connect_one_way(R["Route 23-C"], "Route 23-Grass to Route 23-C", victoryroad)
R["Route 23-Grass"]:connect_one_way(R["Route 23-S"], "Route 23-Grass to Route 23-S", surf)
R["Route 23-Grass"]:connect_one_way(R["Route 23/Cerulean Cave Fishing"], "Route 23-Grass to Route 23/Cerulean Cave Fishing", super_rod)

-- === Route 24 ===
R["Route 24"]:connect_one_way(R["Cerulean City-Water"], "Route 24 to Cerulean City-Water", surf)
R["Route 24"]:connect_one_way(R["Cerulean City"], "Route 24 to Cerulean City")
R["Route 24"]:connect_one_way(R["Route 25"], "Route 24 to Route 25")
R["Route 24"]:connect_one_way(R["Route 24/25/Cerulean/Cerulean Gym Fishing"], "Route 24 to Route 24/25/Cerulean/Cerulean Gym Fishing", super_rod)

-- === Route 25 ===
R["Route 25"]:connect_one_way(R["Route 24"], "Route 25 to Route 24")
R["Route 25"]:connect_one_way(R["Route 24/25/Cerulean/Cerulean Gym Fishing"], "Route 25 to Route 24/25/Cerulean/Cerulean Gym Fishing", super_rod)
R["Route 25"]:connect_warp(R["Bill's House"], "Route 25 to Bill's House", ER_EXTERIOR)

-- === Indigo Plateau ===
R["Indigo Plateau"]:connect_one_way(R["Route 23-N"], "Indigo Plateau to Route 23-N")
R["Indigo Plateau"]:connect_warp(R["Indigo Plateau Lobby"], "Indigo Plateau to Indigo Plateau Lobby", ER_EXTERIOR)

-- === Saffron City ===
R["Saffron City"]:connect_one_way(R["Route 5-S"], "Saffron City to Route 5-S")
R["Saffron City"]:connect_one_way(R["Route 6-N"], "Saffron City to Route 6-N")
R["Saffron City"]:connect_one_way(R["Route 7-E"], "Saffron City to Route 7-E")
R["Saffron City"]:connect_one_way(R["Route 8-W"], "Saffron City to Route 8-W")
R["Saffron City"]:connect_one_way(R["Saffron City-Copycat"], "Saffron City to Saffron City-Copycat", silph_liberated)
R["Saffron City"]:connect_one_way(R["Saffron City-Pidgey"], "Saffron City to Saffron City-Pidgey", silph_liberated)
R["Saffron City"]:connect_one_way(R["Saffron City-G"], "Saffron City to Saffron City-G", silph_liberated)
R["Saffron City"]:connect_one_way(R["Saffron City-Silph"], "Saffron City to Saffron City-Silph", fuji_saved)
R["Saffron City"]:connect_warp(R["Saffron Fighting Dojo"], "Saffron City to Saffron Fighting Dojo", ER_EXTERIOR)
R["Saffron City"]:connect_warp(R["Saffron Pokemart"], "Saffron City to Saffron Pokemart", ER_EXTERIOR)
R["Saffron City"]:connect_warp(R["Saffron Pokemon Center"], "Saffron City to Saffron Pokemon Center", ER_EXTERIOR)
R["Saffron City"]:connect_warp(R["Saffron Mr. Psychic's House"], "Saffron City to Saffron Mr. Psychic's House", ER_EXTERIOR)

-- === Saffron City-Pidgey ===
R["Saffron City-Pidgey"]:connect_one_way(R["Saffron City"], "Saffron City-Pidgey to Saffron City", silph_liberated)
R["Saffron City-Pidgey"]:connect_one_way(R["Saffron City"], "Saffron City-Pidgey to Saffron City (Fly)", fly)
R["Saffron City-Pidgey"]:connect_warp(R["Saffron Pidgey House"], "Saffron City-Pidgey to Saffron Pidgey House", ER_EXTERIOR)

-- === Saffron City-Copycat ===
R["Saffron City-Copycat"]:connect_one_way(R["Saffron City"], "Saffron City-Copycat to Saffron City", silph_liberated)
R["Saffron City-Copycat"]:connect_one_way(R["Saffron City"], "Saffron City-Copycat to Saffron City (Fly)", fly)
R["Saffron City-Copycat"]:connect_warp(R["Saffron Copycat's House 1F"], "Saffron City-Copycat to Saffron Copycat's House 1F", ER_EXTERIOR)

-- === Saffron City-G ===
R["Saffron City-G"]:connect_one_way(R["Saffron City"], "Saffron City-G to Saffron City", silph_liberated)
R["Saffron City-G"]:connect_one_way(R["Saffron City"], "Saffron City-G to Saffron City (Fly)", fly)
R["Saffron City-G"]:connect_warp(R["Saffron Gym-S"], "Saffron City-G to Saffron Gym-S", ER_EXTERIOR)

-- === Saffron City-Silph ===
R["Saffron City-Silph"]:connect_one_way(R["Saffron City"], "Saffron City-Silph to Saffron City", fuji_saved)
R["Saffron City-Silph"]:connect_one_way(R["Saffron City"], "Saffron City-Silph to Saffron City (Fly)", fly)
R["Saffron City-Silph"]:connect_warp(R["Silph Co 1F"], "Saffron City-Silph to Silph Co 1F", ER_EXTERIOR)

-- === Victory Road 2F-E ===
R["Victory Road 2F-E"]:connect_one_way(R["Victory Road 2F-Wild"], "Victory Road 2F-E to Victory Road 2F-Wild")
R["Victory Road 2F-E"]:connect_warp(R["Route 23-N"], "Victory Road 2F-E to Route 23-N", ER_EXTERIOR)
R["Victory Road 2F-E"]:connect_warp(R["Victory Road 3F-SE"], "Victory Road 2F-E to Victory Road 3F-SE", ER_INTERIOR)

-- === Victory Road 2F-W ===
R["Victory Road 2F-W"]:connect_one_way(R["Victory Road 2F-Wild"], "Victory Road 2F-W to Victory Road 2F-Wild")
R["Victory Road 2F-W"]:connect_one_way(R["Victory Road 2F-C"], "Victory Road 2F-W to Victory Road 2F-C", strength)
R["Victory Road 2F-W"]:connect_warp(R["Victory Road 1F"], "Victory Road 2F-W to Victory Road 1F", ER_INTERIOR)

-- === Victory Road 2F-NW ===
R["Victory Road 2F-NW"]:connect_one_way(R["Victory Road 2F-Wild"], "Victory Road 2F-NW to Victory Road 2F-Wild")
R["Victory Road 2F-NW"]:connect_one_way(R["Victory Road 2F-W"], "Victory Road 2F-NW to Victory Road 2F-W", strength)
R["Victory Road 2F-NW"]:connect_warp(R["Victory Road 3F"], "Victory Road 2F-NW to Victory Road 3F", ER_INTERIOR)

-- === Victory Road 2F-C ===
R["Victory Road 2F-C"]:connect_one_way(R["Victory Road 2F-Wild"], "Victory Road 2F-C to Victory Road 2F-Wild")
R["Victory Road 2F-C"]:connect_one_way(R["Victory Road 2F-SE"], "Victory Road 2F-C to Victory Road 2F-SE", strength_victory_road_boulder)
R["Victory Road 2F-C"]:connect_warp(R["Victory Road 3F"], "Victory Road 2F-C to Victory Road 3F", ER_INTERIOR)

-- === Victory Road 2F-SE ===
R["Victory Road 2F-SE"]:connect_one_way(R["Victory Road 2F-Wild"], "Victory Road 2F-SE to Victory Road 2F-Wild")
R["Victory Road 2F-SE"]:connect_warp(R["Victory Road 3F-SE"], "Victory Road 2F-SE to Victory Road 3F-SE", ER_INTERIOR)

-- === Mt Moon B1F-W ===
R["Mt Moon B1F-W"]:connect_one_way(R["Mt Moon B1F-Wild"], "Mt Moon B1F-W to Mt Moon B1F-Wild")
R["Mt Moon B1F-W"]:connect_warp(R["Mt Moon 1F"], "Mt Moon B1F-W to Mt Moon 1F", ER_INTERIOR)
R["Mt Moon B1F-W"]:connect_warp(R["Mt Moon B2F"], "Mt Moon B1F-W to Mt Moon B2F", ER_INTERIOR)

-- === Mt Moon B1F-C ===
R["Mt Moon B1F-C"]:connect_one_way(R["Mt Moon B1F-Wild"], "Mt Moon B1F-C to Mt Moon B1F-Wild")
R["Mt Moon B1F-C"]:connect_warp(R["Mt Moon B2F-NE"], "Mt Moon B1F-C to Mt Moon B2F-NE", ER_INTERIOR)
R["Mt Moon B1F-C"]:connect_warp(R["Mt Moon 1F"], "Mt Moon B1F-C to Mt Moon 1F", ER_INTERIOR)

-- === Mt Moon B1F-NE ===
R["Mt Moon B1F-NE"]:connect_one_way(R["Mt Moon B1F-Wild"], "Mt Moon B1F-NE to Mt Moon B1F-Wild")
R["Mt Moon B1F-NE"]:connect_warp(R["Mt Moon B2F"], "Mt Moon B1F-NE to Mt Moon B2F", ER_INTERIOR)
R["Mt Moon B1F-NE"]:connect_warp(R["Route 4-C"], "Mt Moon B1F-NE to Route 4-C", ER_EXTERIOR)

-- === Mt Moon B1F-SE ===
R["Mt Moon B1F-SE"]:connect_one_way(R["Mt Moon B1F-Wild"], "Mt Moon B1F-SE to Mt Moon B1F-Wild")
R["Mt Moon B1F-SE"]:connect_warp(R["Mt Moon 1F"], "Mt Moon B1F-SE to Mt Moon 1F", ER_INTERIOR)
R["Mt Moon B1F-SE"]:connect_warp(R["Mt Moon B2F-C"], "Mt Moon B1F-SE to Mt Moon B2F-C", ER_INTERIOR)

-- === Silph Co 7F ===
R["Silph Co 7F"]:connect_one_way(R["Silph Co 7F-E"], "Silph Co 7F to Silph Co 7F-E", card_key_7)
R["Silph Co 7F"]:connect_warp(R["Silph Co 8F"], "Silph Co 7F to Silph Co 8F", ER_INTERIOR)
R["Silph Co 7F"]:connect_warp(R["Silph Co 6F"], "Silph Co 7F to Silph Co 6F", ER_INTERIOR)
R["Silph Co 7F"]:connect_warp(R["Silph Co Elevator-7F"], "Silph Co 7F to Silph Co Elevator-7F", ER_INTERIOR)

-- === Silph Co 7F-NW ===
R["Silph Co 7F-NW"]:connect_warp(R["Silph Co 3F-C"], "Silph Co 7F-NW to Silph Co 3F-C", ER_WARP_TILE)
R["Silph Co 7F-NW"]:connect_warp(R["Silph Co 11F-W"], "Silph Co 7F-NW to Silph Co 11F-W", ER_WARP_TILE)

-- === Silph Co 7F-SE ===
R["Silph Co 7F-SE"]:connect_one_way(R["Silph Co 7F-E"], "Silph Co 7F-SE to Silph Co 7F-E", card_key_7)
R["Silph Co 7F-SE"]:connect_warp(R["Silph Co 5F"], "Silph Co 7F-SE to Silph Co 5F", ER_WARP_TILE)

-- === Silph Co 7F-E ===
R["Silph Co 7F-E"]:connect_one_way(R["Silph Co 7F"], "Silph Co 7F-E to Silph Co 7F", card_key_7)
R["Silph Co 7F-E"]:connect_one_way(R["Silph Co 7F-SE"], "Silph Co 7F-E to Silph Co 7F-SE", card_key_7)

-- === Silph Co 11F-C ===
R["Silph Co 11F-C"]:connect_one_way(R["Silph Co 11F-W"], "Silph Co 11F-C to Silph Co 11F-W", card_key_11)

-- === Route 2-NW ===
R["Route 2-NW"]:connect_one_way(R["Route 2-Grass"], "Route 2-NW to Route 2-Grass")
R["Route 2-NW"]:connect_one_way(R["Route 2-NE"], "Route 2-NW to Route 2-NE", cut)
R["Route 2-NW"]:connect_one_way(R["Pewter City"], "Route 2-NW to Pewter City")
R["Route 2-NW"]:connect_warp(R["Viridian Forest North Gate"], "Route 2-NW to Viridian Forest North Gate", ER_EXTERIOR)

-- === Route 2-SW ===
R["Route 2-SW"]:connect_one_way(R["Route 2-Grass"], "Route 2-SW to Route 2-Grass")
R["Route 2-SW"]:connect_one_way(R["Route 2-SE"], "Route 2-SW to Route 2-SE", cut)
R["Route 2-SW"]:connect_one_way(R["Viridian City-N"], "Route 2-SW to Viridian City-N")
R["Route 2-SW"]:connect_warp(R["Viridian Forest South Gate"], "Route 2-SW to Viridian Forest South Gate", ER_EXTERIOR)

-- === Route 2-NE ===
R["Route 2-NE"]:connect_one_way(R["Route 2-NW"], "Route 2-NE to Route 2-NW", cut)
R["Route 2-NE"]:connect_one_way(R["Route 2-E"], "Route 2-NE to Route 2-E", cut)
R["Route 2-NE"]:connect_warp(R["Diglett's Cave Route 2"], "Route 2-NE to Diglett's Cave Route 2", ER_EXTERIOR)
R["Route 2-NE"]:connect_warp(R["Route 2 Trade House"], "Route 2-NE to Route 2 Trade House", ER_EXTERIOR)

-- === Route 2-E ===
R["Route 2-E"]:connect_one_way(R["Route 2-NE"], "Route 2-E to Route 2-NE", cut)
R["Route 2-E"]:connect_warp(R["Route 2 Gate"], "Route 2-E to Route 2 Gate", ER_EXTERIOR)

-- === Route 2-SE ===
R["Route 2-SE"]:connect_one_way(R["Route 2-SW"], "Route 2-SE to Route 2-SW", cut)
R["Route 2-SE"]:connect_warp(R["Route 2 Gate"], "Route 2-SE to Route 2 Gate", ER_EXTERIOR)

-- === Route 3 ===
R["Route 3"]:connect_one_way(R["Pewter City-E"], "Route 3 to Pewter City-E")
R["Route 3"]:connect_one_way(R["Route 4-W"], "Route 3 to Route 4-W")

-- === Route 4-W ===
R["Route 4-W"]:connect_one_way(R["Route 3"], "Route 4-W to Route 3")
R["Route 4-W"]:connect_warp(R["Route 4 Pokemon Center"], "Route 4-W to Route 4 Pokemon Center", ER_EXTERIOR)
R["Route 4-W"]:connect_warp(R["Mt Moon 1F"], "Route 4-W to Mt Moon 1F", ER_EXTERIOR)

-- === Route 4-C ===
R["Route 4-C"]:connect_one_way(R["Route 4-E"], "Route 4-C to Route 4-E")
R["Route 4-C"]:connect_warp(R["Mt Moon B1F-NE"], "Route 4-C to Mt Moon B1F-NE", ER_EXTERIOR)

-- === Route 4-Lass ===
R["Route 4-Lass"]:connect_one_way(R["Route 4-C"], "Route 4-Lass to Route 4-C")

-- === Route 4-E ===
R["Route 4-E"]:connect_one_way(R["Cerulean City"], "Route 4-E to Cerulean City")

-- === Route 5 ===
R["Route 5"]:connect_one_way(R["Cerulean City-Outskirts"], "Route 5 to Cerulean City-Outskirts")
R["Route 5"]:connect_warp(R["Route 5 Gate-N"], "Route 5 to Route 5 Gate-N", ER_EXTERIOR)
R["Route 5"]:connect_warp(R["Underground Path Route 5"], "Route 5 to Underground Path Route 5", ER_EXTERIOR)
R["Route 5"]:connect_warp(R["Daycare"], "Route 5 to Daycare", ER_EXTERIOR)

-- === Route 9 ===
R["Route 9"]:connect_one_way(R["Cerulean City-Outskirts"], "Route 9 to Cerulean City-Outskirts", cut)
R["Route 9"]:connect_one_way(R["Route 10-N"], "Route 9 to Route 10-N")

-- === Route 5-S ===
R["Route 5-S"]:connect_one_way(R["Saffron City"], "Route 5-S to Saffron City")
R["Route 5-S"]:connect_warp(R["Route 5 Gate-S"], "Route 5-S to Route 5 Gate-S", ER_EXTERIOR)

-- === Route 13 ===
R["Route 13"]:connect_one_way(R["Route 12/13/17/18 Fishing"], "Route 13 to Route 12/13/17/18 Fishing", super_rod)
R["Route 13"]:connect_one_way(R["Route 13-Grass"], "Route 13 to Route 13-Grass", cut)
R["Route 13"]:connect_one_way(R["Route 14"], "Route 13 to Route 14")
R["Route 13"]:connect_one_way(R["Route 13-E"], "Route 13 to Route 13-E", boardwalk_boulders)

-- === Route 13-E ===
R["Route 13-E"]:connect_one_way(R["Route 12/13/17/18 Fishing"], "Route 13-E to Route 12/13/17/18 Fishing", super_rod)
R["Route 13-E"]:connect_one_way(R["Route 13"], "Route 13-E to Route 13", boardwalk_boulders)
R["Route 13-E"]:connect_one_way(R["Route 12-S"], "Route 13-E to Route 12-S")

-- === Route 14 ===
R["Route 14"]:connect_one_way(R["Route 15"], "Route 14 to Route 15")
R["Route 14"]:connect_one_way(R["Route 15-N"], "Route 14 to Route 15-N", cut)
R["Route 14"]:connect_one_way(R["Route 14-Grass"], "Route 14 to Route 14-Grass", cut)
R["Route 14"]:connect_one_way(R["Route 13"], "Route 14 to Route 13")

-- === Route 17 ===
R["Route 17"]:connect_one_way(R["Route 12/13/17/18 Fishing"], "Route 17 to Route 12/13/17/18 Fishing", super_rod)
R["Route 17"]:connect_one_way(R["Route 16-SW"], "Route 17 to Route 16-SW")
R["Route 17"]:connect_one_way(R["Route 18-W"], "Route 17 to Route 18-W")

-- === Route 19-S ===
R["Route 19-S"]:connect_one_way(R["Route 19-N"], "Route 19-S to Route 19-N", surf)
R["Route 19-S"]:connect_one_way(R["Route 20-E"], "Route 19-S to Route 20-E")
R["Route 19-S"]:connect_one_way(R["Route 19/20-Water"], "Route 19-S to Route 19/20-Water")

-- === Route 19-N ===
R["Route 19-N"]:connect_one_way(R["Sea Routes/Cinnabar/Seafoam Fishing"], "Route 19-N to Sea Routes/Cinnabar/Seafoam Fishing", super_rod)
R["Route 19-N"]:connect_one_way(R["Fuchsia City"], "Route 19-N to Fuchsia City")
R["Route 19-N"]:connect_one_way(R["Route 19-S"], "Route 19-N to Route 19-S", surf)

-- === Route 21 ===
R["Route 21"]:connect_one_way(R["Sea Routes/Cinnabar/Seafoam Fishing"], "Route 21 to Sea Routes/Cinnabar/Seafoam Fishing", super_rod)
R["Route 21"]:connect_one_way(R["Cinnabar Island"], "Route 21 to Cinnabar Island", surf)
R["Route 21"]:connect_one_way(R["Pallet Town"], "Route 21 to Pallet Town", surf)

-- === Vermilion Old Rod House ===
R["Vermilion Old Rod House"]:connect_warp(R["Vermilion City"], "Vermilion Old Rod House to Vermilion City", ER_EXTERIOR)

-- === Celadon Department Store 2F ===
R["Celadon Department Store 2F"]:connect_warp(R["Celadon Department Store 1F"], "Celadon Department Store 2F to Celadon Department Store 1F", ER_INTERIOR)
R["Celadon Department Store 2F"]:connect_warp(R["Celadon Department Store 3F"], "Celadon Department Store 2F to Celadon Department Store 3F", ER_INTERIOR)
R["Celadon Department Store 2F"]:connect_warp(R["Celadon Department Store Elevator-2F"], "Celadon Department Store 2F to Celadon Department Store Elevator-2F", ER_INTERIOR)

-- === Fuchsia Good Rod House ===
R["Fuchsia Good Rod House"]:connect_warp(R["Fuchsia City-Good Rod House Backyard"], "Fuchsia Good Rod House to Fuchsia City-Good Rod House Backyard", ER_EXTERIOR)
R["Fuchsia Good Rod House"]:connect_warp(R["Fuchsia City"], "Fuchsia Good Rod House to Fuchsia City", ER_EXTERIOR)

-- === Daycare ===
R["Daycare"]:connect_warp(R["Route 5"], "Daycare to Route 5", ER_EXTERIOR)

-- === Route 12 Super Rod House ===
R["Route 12 Super Rod House"]:connect_warp(R["Route 12-S"], "Route 12 Super Rod House to Route 12-S", ER_EXTERIOR)

-- === Silph Co 8F ===
R["Silph Co 8F"]:connect_one_way(R["Silph Co 8F-W"], "Silph Co 8F to Silph Co 8F-W (Card Key)", card_key_8)
R["Silph Co 8F"]:connect_warp(R["Silph Co 9F"], "Silph Co 8F to Silph Co 9F", ER_INTERIOR)
R["Silph Co 8F"]:connect_warp(R["Silph Co 7F"], "Silph Co 8F to Silph Co 7F", ER_INTERIOR)
R["Silph Co 8F"]:connect_warp(R["Silph Co Elevator-8F"], "Silph Co 8F to Silph Co Elevator-8F", ER_INTERIOR)
R["Silph Co 8F"]:connect_warp(R["Silph Co 2F"], "Silph Co 8F to Silph Co 2F S", ER_WARP_TILE)
R["Silph Co 8F"]:connect_warp(R["Silph Co 2F"], "Silph Co 8F to Silph Co 2F N", ER_WARP_TILE)
R["Silph Co 8F"]:connect_warp(R["Silph Co 8F-W"], "Silph Co 8F to Silph Co 8F-W", ER_WARP_TILE)

-- === Silph Co 8F-W ===
R["Silph Co 8F-W"]:connect_one_way(R["Silph Co 8F"], "Silph Co 8F-W to Silph Co 8F (Card Key)", card_key_8)
R["Silph Co 8F-W"]:connect_warp(R["Silph Co 8F"], "Silph Co 8F-W to Silph Co 8F", ER_WARP_TILE)

-- === Route 6 ===
R["Route 6"]:connect_one_way(R["Route 6/11/Vermilion/Dock Fishing"], "Route 6 to Route 6/11/Vermilion/Dock Fishing", super_rod)
R["Route 6"]:connect_one_way(R["Vermilion City"], "Route 6 to Vermilion City")
R["Route 6"]:connect_warp(R["Route 6 Gate-S"], "Route 6 to Route 6 Gate-S", ER_EXTERIOR)
R["Route 6"]:connect_warp(R["Underground Path Route 6"], "Route 6 to Underground Path Route 6", ER_EXTERIOR)

-- === Route 6-N ===
R["Route 6-N"]:connect_one_way(R["Saffron City"], "Route 6-N to Saffron City")
R["Route 6-N"]:connect_warp(R["Route 6 Gate-N"], "Route 6-N to Route 6 Gate-N", ER_EXTERIOR)

-- === Route 8-W ===
R["Route 8-W"]:connect_one_way(R["Saffron City"], "Route 8-W to Saffron City")
R["Route 8-W"]:connect_warp(R["Route 8 Gate-W"], "Route 8-W to Route 8 Gate-W", ER_EXTERIOR)

-- === Route 8 ===
R["Route 8"]:connect_one_way(R["Lavender Town"], "Route 8 to Lavender Town")
R["Route 8"]:connect_one_way(R["Route 8-Grass"], "Route 8 to Route 8-Grass", cut)
R["Route 8"]:connect_warp(R["Route 8 Gate-E"], "Route 8 to Route 8 Gate-E", ER_EXTERIOR)
R["Route 8"]:connect_warp(R["Underground Path Route 8"], "Route 8 to Underground Path Route 8", ER_EXTERIOR)

-- === Route 10-N ===
R["Route 10-N"]:connect_one_way(R["Route 9"], "Route 10-N to Route 9")
R["Route 10-N"]:connect_one_way(R["Route 10-C"], "Route 10-N to Route 10-C", surf)
R["Route 10-N"]:connect_one_way(R["Route 10/Celadon Fishing"], "Route 10-N to Route 10/Celadon Fishing", super_rod)
R["Route 10-N"]:connect_warp(R["Rock Tunnel Pokemon Center"], "Route 10-N to Rock Tunnel Pokemon Center", ER_EXTERIOR)
R["Route 10-N"]:connect_warp(R["Rock Tunnel 1F-NE 1"], "Route 10-N to Rock Tunnel 1F-NE 1", ER_EXTERIOR)

-- === Route 10-S ===
R["Route 10-S"]:connect_one_way(R["Lavender Town"], "Route 10-S to Lavender Town")
R["Route 10-S"]:connect_warp(R["Rock Tunnel 1F-S 1"], "Route 10-S to Rock Tunnel 1F-S 1", ER_EXTERIOR)

-- === Route 10-P ===
R["Route 10-P"]:connect_one_way(R["Route 10-C"], "Route 10-P to Route 10-C", plant_key)
R["Route 10-P"]:connect_warp(R["Power Plant"], "Route 10-P to Power Plant", ER_EXTERIOR)

-- === Route 10-C ===
R["Route 10-C"]:connect_one_way(R["Route 10-N"], "Route 10-C to Route 10-N", surf)
R["Route 10-C"]:connect_one_way(R["Route 10-P"], "Route 10-C to Route 10-P", plant_key)
R["Route 10-C"]:connect_one_way(R["Route 10/Celadon Fishing"], "Route 10-C to Route 10/Celadon Fishing", super_rod)

-- === Route 11 ===
R["Route 11"]:connect_one_way(R["Route 6/11/Vermilion/Dock Fishing"], "Route 11 to Route 6/11/Vermilion/Dock Fishing", super_rod)
R["Route 11"]:connect_one_way(R["Vermilion City"], "Route 11 to Vermilion City")
R["Route 11"]:connect_one_way(R["Route 11-C"], "Route 11 to Route 11-C", rt11_boulders)
R["Route 11"]:connect_warp(R["Diglett's Cave Route 11"], "Route 11 to Diglett's Cave Route 11", ER_EXTERIOR)

-- === Route 11-E ===
R["Route 11-E"]:connect_one_way(R["Route 12-W"], "Route 11-E to Route 12-W")
R["Route 11-E"]:connect_warp(R["Route 11 Gate 1F"], "Route 11-E to Route 11 Gate 1F", ER_EXTERIOR)

-- === Route 11-C ===
R["Route 11-C"]:connect_one_way(R["Route 11"], "Route 11-C to Route 11", rt11_boulders)
R["Route 11-C"]:connect_warp(R["Route 11 Gate 1F"], "Route 11-C to Route 11 Gate 1F", ER_EXTERIOR)

-- === Route 12-L ===
R["Route 12-L"]:connect_one_way(R["Lavender Town"], "Route 12-L to Lavender Town")
R["Route 12-L"]:connect_warp(R["Route 12 Gate 1F"], "Route 12-L to Route 12 Gate 1F", ER_EXTERIOR)

-- === Route 12-N ===
R["Route 12-N"]:connect_one_way(R["Route 12/13/17/18 Fishing"], "Route 12-N to Route 12/13/17/18 Fishing", super_rod)
R["Route 12-N"]:connect_one_way(R["Route 12-S"], "Route 12-N to Route 12-S", surf)
R["Route 12-N"]:connect_one_way(R["Route 12-W"], "Route 12-N to Route 12-W", poke_flute)
R["Route 12-N"]:connect_warp(R["Route 12 Gate 1F"], "Route 12-N to Route 12 Gate 1F", ER_EXTERIOR)

-- === Route 12-S ===
R["Route 12-S"]:connect_one_way(R["Route 12/13/17/18 Fishing"], "Route 12-S to Route 12/13/17/18 Fishing", super_rod)
R["Route 12-S"]:connect_one_way(R["Route 12-N"], "Route 12-S to Route 12-N", surf)
R["Route 12-S"]:connect_one_way(R["Route 12-W"], "Route 12-S to Route 12-W", poke_flute)
R["Route 12-S"]:connect_one_way(R["Route 12-Grass"], "Route 12-S to Route 12-Grass", cut)
R["Route 12-S"]:connect_one_way(R["Route 13-E"], "Route 12-S to Route 13-E")
R["Route 12-S"]:connect_warp(R["Route 12 Super Rod House"], "Route 12-S to Route 12 Super Rod House", ER_EXTERIOR)

-- === Route 12-W ===
R["Route 12-W"]:connect_one_way(R["Route 11-E"], "Route 12-W to Route 11-E")
R["Route 12-W"]:connect_one_way(R["Route 12-N"], "Route 12-W to Route 12-N", poke_flute)
R["Route 12-W"]:connect_one_way(R["Route 12-S"], "Route 12-W to Route 12-S", poke_flute)

-- === Route 15-W ===
R["Route 15-W"]:connect_one_way(R["Fuchsia City"], "Route 15-W to Fuchsia City")
R["Route 15-W"]:connect_warp(R["Route 15 Gate 1F"], "Route 15-W to Route 15 Gate 1F", ER_EXTERIOR)

-- === Route 15 ===
R["Route 15"]:connect_one_way(R["Route 14"], "Route 15 to Route 14")
R["Route 15"]:connect_warp(R["Route 15 Gate 1F"], "Route 15 to Route 15 Gate 1F", ER_EXTERIOR)

-- === Route 16-E ===
R["Route 16-E"]:connect_one_way(R["Celadon City"], "Route 16-E to Celadon City")
R["Route 16-E"]:connect_one_way(R["Route 16-NE"], "Route 16-E to Route 16-NE", cut)
R["Route 16-E"]:connect_one_way(R["Route 16-C"], "Route 16-E to Route 16-C", poke_flute)

-- === Route 16-C ===
R["Route 16-C"]:connect_one_way(R["Route 16-E"], "Route 16-C to Route 16-E", poke_flute)
R["Route 16-C"]:connect_warp(R["Route 16 Gate 1F-E"], "Route 16-C to Route 16 Gate 1F-E", ER_EXTERIOR)

-- === Route 16-SW ===
R["Route 16-SW"]:connect_one_way(R["Route 17"], "Route 16-SW to Route 17")
R["Route 16-SW"]:connect_warp(R["Route 16 Gate 1F-W"], "Route 16-SW to Route 16 Gate 1F-W", ER_EXTERIOR)

-- === Route 16-NW ===
R["Route 16-NW"]:connect_warp(R["Route 16 Gate 1F-N"], "Route 16-NW to Route 16 Gate 1F-N", ER_EXTERIOR)
R["Route 16-NW"]:connect_warp(R["Route 16 Fly House"], "Route 16-NW to Route 16 Fly House", ER_EXTERIOR)

-- === Route 16-NE ===
R["Route 16-NE"]:connect_one_way(R["Route 16-E"], "Route 16-NE to Route 16-E", cut)
R["Route 16-NE"]:connect_warp(R["Route 16 Gate 1F-N"], "Route 16-NE to Route 16 Gate 1F-N", ER_EXTERIOR)

-- === Route 18-W ===
R["Route 18-W"]:connect_one_way(R["Route 12/13/17/18 Fishing"], "Route 18-W to Route 12/13/17/18 Fishing", super_rod)
R["Route 18-W"]:connect_one_way(R["Route 17"], "Route 18-W to Route 17")
R["Route 18-W"]:connect_warp(R["Route 18 Gate 1F-W"], "Route 18-W to Route 18 Gate 1F-W", ER_EXTERIOR)

-- === Route 18-E ===
R["Route 18-E"]:connect_one_way(R["Fuchsia City"], "Route 18-E to Fuchsia City")
R["Route 18-E"]:connect_warp(R["Route 18 Gate 1F-E"], "Route 18-E to Route 18 Gate 1F-E", ER_EXTERIOR)

-- === Vermilion Pokemon Fan Club ===
R["Vermilion Pokemon Fan Club"]:connect_warp(R["Vermilion City"], "Vermilion Pokemon Fan Club to Vermilion City", ER_EXTERIOR)

-- === Silph Co 2F-NW ===
R["Silph Co 2F-NW"]:connect_one_way(R["Silph Co 2F"], "Silph Co 2F-NW to Silph Co 2F", card_key_2)
R["Silph Co 2F-NW"]:connect_warp(R["Silph Co 3F"], "Silph Co 2F-NW to Silph Co 3F", ER_WARP_TILE)

-- === Silph Co 2F ===
R["Silph Co 2F"]:connect_one_way(R["Silph Co 2F-NW"], "Silph Co 2F to Silph Co 2F-NW", card_key_2)
R["Silph Co 2F"]:connect_one_way(R["Silph Co 2F-SW"], "Silph Co 2F to Silph Co 2F-SW", card_key_2)
R["Silph Co 2F"]:connect_warp(R["Silph Co 1F"], "Silph Co 2F to Silph Co 1F", ER_INTERIOR)
R["Silph Co 2F"]:connect_warp(R["Silph Co 3F"], "Silph Co 2F to Silph Co 3F", ER_INTERIOR)
R["Silph Co 2F"]:connect_warp(R["Silph Co Elevator-2F"], "Silph Co 2F to Silph Co Elevator-2F", ER_INTERIOR)
R["Silph Co 2F"]:connect_warp(R["Silph Co 8F"], "Silph Co 2F to Silph Co 8F N", ER_WARP_TILE)
R["Silph Co 2F"]:connect_warp(R["Silph Co 8F"], "Silph Co 2F to Silph Co 8F S", ER_WARP_TILE)

-- === Silph Co 2F-SW ===
R["Silph Co 2F-SW"]:connect_one_way(R["Silph Co 2F"], "Silph Co 2F-SW to Silph Co 2F", card_key_2)
R["Silph Co 2F-SW"]:connect_warp(R["Silph Co 6F"], "Silph Co 2F-SW to Silph Co 6F", ER_WARP_TILE)

-- === Silph Co 3F ===
R["Silph Co 3F"]:connect_one_way(R["Silph Co 3F-C"], "Silph Co 3F to Silph Co 3F-C", card_key_3)
R["Silph Co 3F"]:connect_warp(R["Silph Co 2F"], "Silph Co 3F to Silph Co 2F", ER_INTERIOR)
R["Silph Co 3F"]:connect_warp(R["Silph Co 4F"], "Silph Co 3F to Silph Co 4F", ER_INTERIOR)
R["Silph Co 3F"]:connect_warp(R["Silph Co Elevator-3F"], "Silph Co 3F to Silph Co Elevator-3F", ER_INTERIOR)
R["Silph Co 3F"]:connect_warp(R["Silph Co 3F"], "Silph Co 3F to Silph Co 3F N", ER_WARP_TILE)
R["Silph Co 3F"]:connect_warp(R["Silph Co 5F"], "Silph Co 3F to Silph Co 5F", ER_WARP_TILE)
R["Silph Co 3F"]:connect_warp(R["Silph Co 5F-SW"], "Silph Co 3F to Silph Co 5F-SW", ER_WARP_TILE)
R["Silph Co 3F"]:connect_warp(R["Silph Co 2F-NW"], "Silph Co 3F to Silph Co 2F-NW", ER_WARP_TILE)
R["Silph Co 3F"]:connect_warp(R["Silph Co 3F"], "Silph Co 3F to Silph Co 3F S", ER_WARP_TILE)

-- === Silph Co 3F-C ===
R["Silph Co 3F-C"]:connect_one_way(R["Silph Co 3F"], "Silph Co 3F-C to Silph Co 3F", card_key_3)
R["Silph Co 3F-C"]:connect_one_way(R["Silph Co 3F-W"], "Silph Co 3F-C to Silph Co 3F-W", card_key_3)
R["Silph Co 3F-C"]:connect_warp(R["Silph Co 7F-NW"], "Silph Co 3F-C to Silph Co 7F-NW", ER_WARP_TILE)

-- === Silph Co 3F-W ===
R["Silph Co 3F-W"]:connect_one_way(R["Silph Co 3F-C"], "Silph Co 3F-W to Silph Co 3F-C", card_key_3)
R["Silph Co 3F-W"]:connect_warp(R["Silph Co 9F-NW"], "Silph Co 3F-W to Silph Co 9F-NW", ER_WARP_TILE)

-- === Silph Co 10F ===
R["Silph Co 10F"]:connect_one_way(R["Silph Co 10F-SE"], "Silph Co 10F to Silph Co 10F-SE", card_key_10)
R["Silph Co 10F"]:connect_warp(R["Silph Co 9F"], "Silph Co 10F to Silph Co 9F", ER_INTERIOR)
R["Silph Co 10F"]:connect_warp(R["Silph Co 11F"], "Silph Co 10F to Silph Co 11F", ER_INTERIOR)
R["Silph Co 10F"]:connect_warp(R["Silph Co Elevator-10F"], "Silph Co 10F to Silph Co Elevator-10F", ER_INTERIOR)
R["Silph Co 10F"]:connect_warp(R["Silph Co 4F"], "Silph Co 10F to Silph Co 4F", ER_WARP_TILE)

-- === Silph Co 10F-SE ===
R["Silph Co 10F-SE"]:connect_one_way(R["Silph Co 10F"], "Silph Co 10F-SE to Silph Co 10F", card_key_10)
R["Silph Co 10F-SE"]:connect_warp(R["Silph Co 4F-N"], "Silph Co 10F-SE to Silph Co 4F-N", ER_WARP_TILE)
R["Silph Co 10F-SE"]:connect_warp(R["Silph Co 4F"], "Silph Co 10F-SE to Silph Co 4F", ER_WARP_TILE)

-- === Indigo Plateau Lance's Room ===
R["Indigo Plateau Lance's Room"]:connect_warp(R["Indigo Plateau Agatha's Room"], "Indigo Plateau Lance's Room to Indigo Plateau Agatha's Room", ER_FIXED_FULL)
R["Indigo Plateau Lance's Room"]:connect_warp(R["Indigo Plateau Champion's Room"], "Indigo Plateau Lance's Room to Indigo Plateau Champion's Room", ER_FIXED_FULL)

-- === Indigo Plateau Hall of Fame ===
R["Indigo Plateau Hall of Fame"]:connect_warp(R["Indigo Plateau Champion's Room"], "Indigo Plateau Hall of Fame to Indigo Plateau Champion's Room", ER_FIXED_FULL)

-- === Player's House 2F ===
R["Player's House 2F"]:connect_warp(R["Player's House 1F"], "Player's House 2F to Player's House 1F", ER_FIXED_FULL)

-- === Pewter Museum 1F ===
R["Pewter Museum 1F"]:connect_warp(R["Pewter City"], "Pewter Museum 1F to Pewter City", ER_EXTERIOR)
R["Pewter Museum 1F"]:connect_warp(R["Pewter Museum 2F"], "Pewter Museum 1F to Pewter Museum 2F", ER_INTERIOR)

-- === Pewter Museum 1F-E ===
R["Pewter Museum 1F-E"]:connect_warp(R["Pewter City-M"], "Pewter Museum 1F-E to Pewter City-M", ER_EXTERIOR)

-- === Pewter Museum 2F ===
R["Pewter Museum 2F"]:connect_warp(R["Pewter Museum 1F"], "Pewter Museum 2F to Pewter Museum 1F", ER_INTERIOR)

-- === Pewter Gym ===
R["Pewter Gym"]:connect_warp(R["Pewter City"], "Pewter Gym to Pewter City", ER_EXTERIOR)

-- === Pewter Pokemon Center ===
R["Pewter Pokemon Center"]:connect_warp(R["Pewter City"], "Pewter Pokemon Center to Pewter City", ER_EXTERIOR)

-- === Cerulean Pokemon Center ===
R["Cerulean Pokemon Center"]:connect_warp(R["Cerulean City"], "Cerulean Pokemon Center to Cerulean City", ER_EXTERIOR)

-- === Cerulean Gym ===
R["Cerulean Gym"]:connect_one_way(R["Route 24/25/Cerulean/Cerulean Gym Fishing"], "Cerulean Gym to Route 24/25/Cerulean/Cerulean Gym Fishing", super_rod)
R["Cerulean Gym"]:connect_warp(R["Cerulean City"], "Cerulean Gym to Cerulean City", ER_EXTERIOR)

-- === Cerulean Pokemart ===
R["Cerulean Pokemart"]:connect_warp(R["Cerulean City"], "Cerulean Pokemart to Cerulean City", ER_EXTERIOR)

-- === Lavender Pokemon Center ===
R["Lavender Pokemon Center"]:connect_warp(R["Lavender Town"], "Lavender Pokemon Center to Lavender Town", ER_EXTERIOR)

-- === Lavender Pokemart ===
R["Lavender Pokemart"]:connect_warp(R["Lavender Town"], "Lavender Pokemart to Lavender Town", ER_EXTERIOR)

-- === Vermilion Pokemon Center ===
R["Vermilion Pokemon Center"]:connect_warp(R["Vermilion City"], "Vermilion Pokemon Center to Vermilion City", ER_EXTERIOR)

-- === Vermilion Pokemart ===
R["Vermilion Pokemart"]:connect_warp(R["Vermilion City"], "Vermilion Pokemart to Vermilion City", ER_EXTERIOR)

-- === Vermilion Gym ===
R["Vermilion Gym"]:connect_warp(R["Vermilion City-G"], "Vermilion Gym to Vermilion City-G", ER_EXTERIOR)

-- === Saffron Copycat's House 2F ===
R["Saffron Copycat's House 2F"]:connect_warp(R["Saffron Copycat's House 1F"], "Saffron Copycat's House 2F to Saffron Copycat's House 1F", ER_INTERIOR)

-- === Saffron Fighting Dojo ===
R["Saffron Fighting Dojo"]:connect_warp(R["Saffron City"], "Saffron Fighting Dojo to Saffron City", ER_EXTERIOR)

-- === Saffron Gym-NW ===
R["Saffron Gym-NW"]:connect_warp(R["Saffron Gym-NE"], "Saffron Gym-NW to Saffron Gym-NE", ER_WARP_TILE)
R["Saffron Gym-NW"]:connect_warp(R["Saffron Gym-N"], "Saffron Gym-NW to Saffron Gym-N", ER_WARP_TILE)
R["Saffron Gym-NW"]:connect_warp(R["Saffron Gym-C"], "Saffron Gym-NW to Saffron Gym-C", ER_WARP_TILE)
R["Saffron Gym-NW"]:connect_warp(R["Saffron Gym-W"], "Saffron Gym-NW to Saffron Gym-W", ER_WARP_TILE)

-- === Saffron Gym-W ===
R["Saffron Gym-W"]:connect_warp(R["Saffron Gym-E"], "Saffron Gym-W to Saffron Gym-E", ER_WARP_TILE)
R["Saffron Gym-W"]:connect_warp(R["Saffron Gym-N"], "Saffron Gym-W to Saffron Gym-N", ER_WARP_TILE)
R["Saffron Gym-W"]:connect_warp(R["Saffron Gym-NW"], "Saffron Gym-W to Saffron Gym-NW", ER_WARP_TILE)
R["Saffron Gym-W"]:connect_warp(R["Saffron Gym-SW"], "Saffron Gym-W to Saffron Gym-SW", ER_WARP_TILE)

-- === Saffron Gym-SW ===
R["Saffron Gym-SW"]:connect_warp(R["Saffron Gym-NE"], "Saffron Gym-SW to Saffron Gym-NE", ER_WARP_TILE)
R["Saffron Gym-SW"]:connect_warp(R["Saffron Gym-SE"], "Saffron Gym-SW to Saffron Gym-SE", ER_WARP_TILE)
R["Saffron Gym-SW"]:connect_warp(R["Saffron Gym-N"], "Saffron Gym-SW to Saffron Gym-N", ER_WARP_TILE)
R["Saffron Gym-SW"]:connect_warp(R["Saffron Gym-W"], "Saffron Gym-SW to Saffron Gym-W", ER_WARP_TILE)

-- === Saffron Gym-N ===
R["Saffron Gym-N"]:connect_warp(R["Saffron Gym-E"], "Saffron Gym-N to Saffron Gym-E", ER_WARP_TILE)
R["Saffron Gym-N"]:connect_warp(R["Saffron Gym-NW"], "Saffron Gym-N to Saffron Gym-NW", ER_WARP_TILE)
R["Saffron Gym-N"]:connect_warp(R["Saffron Gym-W"], "Saffron Gym-N to Saffron Gym-W", ER_WARP_TILE)
R["Saffron Gym-N"]:connect_warp(R["Saffron Gym-SW"], "Saffron Gym-N to Saffron Gym-SW", ER_WARP_TILE)

-- === Saffron Gym-C ===
R["Saffron Gym-C"]:connect_warp(R["Saffron Gym-NW"], "Saffron Gym-C to Saffron Gym-NW", ER_WARP_TILE)

-- === Saffron Gym-S ===
R["Saffron Gym-S"]:connect_warp(R["Saffron Gym-SE"], "Saffron Gym-S to Saffron Gym-SE", ER_WARP_TILE)
R["Saffron Gym-S"]:connect_warp(R["Saffron City-G"], "Saffron Gym-S to Saffron City-G", ER_EXTERIOR)

-- === Saffron Gym-NE ===
R["Saffron Gym-NE"]:connect_warp(R["Saffron Gym-E"], "Saffron Gym-NE to Saffron Gym-E", ER_WARP_TILE)
R["Saffron Gym-NE"]:connect_warp(R["Saffron Gym-SE"], "Saffron Gym-NE to Saffron Gym-SE", ER_WARP_TILE)
R["Saffron Gym-NE"]:connect_warp(R["Saffron Gym-NW"], "Saffron Gym-NE to Saffron Gym-NW", ER_WARP_TILE)
R["Saffron Gym-NE"]:connect_warp(R["Saffron Gym-SW"], "Saffron Gym-NE to Saffron Gym-SW", ER_WARP_TILE)

-- === Saffron Gym-E ===
R["Saffron Gym-E"]:connect_warp(R["Saffron Gym-NE"], "Saffron Gym-E to Saffron Gym-NE", ER_WARP_TILE)
R["Saffron Gym-E"]:connect_warp(R["Saffron Gym-SE"], "Saffron Gym-E to Saffron Gym-SE", ER_WARP_TILE)
R["Saffron Gym-E"]:connect_warp(R["Saffron Gym-N"], "Saffron Gym-E to Saffron Gym-N", ER_WARP_TILE)
R["Saffron Gym-E"]:connect_warp(R["Saffron Gym-W"], "Saffron Gym-E to Saffron Gym-W", ER_WARP_TILE)

-- === Saffron Gym-SE ===
R["Saffron Gym-SE"]:connect_warp(R["Saffron Gym-NE"], "Saffron Gym-SE to Saffron Gym-NE", ER_WARP_TILE)
R["Saffron Gym-SE"]:connect_warp(R["Saffron Gym-E"], "Saffron Gym-SE to Saffron Gym-E", ER_WARP_TILE)
R["Saffron Gym-SE"]:connect_warp(R["Saffron Gym-SW"], "Saffron Gym-SE to Saffron Gym-SW", ER_WARP_TILE)
R["Saffron Gym-SE"]:connect_warp(R["Saffron Gym-S"], "Saffron Gym-SE to Saffron Gym-S", ER_WARP_TILE)

-- === Saffron Pokemart ===
R["Saffron Pokemart"]:connect_warp(R["Saffron City"], "Saffron Pokemart to Saffron City", ER_EXTERIOR)

-- === Silph Co 1F ===
R["Silph Co 1F"]:connect_warp(R["Saffron City-Silph"], "Silph Co 1F to Saffron City-Silph", ER_EXTERIOR)
R["Silph Co 1F"]:connect_warp(R["Silph Co 2F"], "Silph Co 1F to Silph Co 2F", ER_INTERIOR)
R["Silph Co 1F"]:connect_warp(R["Silph Co Elevator-1F"], "Silph Co 1F to Silph Co Elevator-1F", ER_INTERIOR)

-- === Saffron Pokemon Center ===
R["Saffron Pokemon Center"]:connect_warp(R["Saffron City"], "Saffron Pokemon Center to Saffron City", ER_EXTERIOR)

-- === Viridian Forest North Gate ===
R["Viridian Forest North Gate"]:connect_warp(R["Route 2-NW"], "Viridian Forest North Gate to Route 2-NW", ER_EXTERIOR)
R["Viridian Forest North Gate"]:connect_warp(R["Viridian Forest"], "Viridian Forest North Gate to Viridian Forest", ER_INTERIOR)

-- === Route 2 Gate ===
R["Route 2 Gate"]:connect_warp(R["Route 2-E"], "Route 2 Gate to Route 2-E", ER_EXTERIOR)
R["Route 2 Gate"]:connect_warp(R["Route 2-SE"], "Route 2 Gate to Route 2-SE", ER_EXTERIOR)

-- === Viridian Forest South Gate ===
R["Viridian Forest South Gate"]:connect_warp(R["Viridian Forest"], "Viridian Forest South Gate to Viridian Forest", ER_INTERIOR)
R["Viridian Forest South Gate"]:connect_warp(R["Route 2-SW"], "Viridian Forest South Gate to Route 2-SW", ER_EXTERIOR)

-- === Underground Path Route 5 ===
R["Underground Path Route 5"]:connect_warp(R["Route 5"], "Underground Path Route 5 to Route 5", ER_EXTERIOR)
R["Underground Path Route 5"]:connect_warp(R["Underground Path North South"], "Underground Path Route 5 to Underground Path North South", ER_INTERIOR)

-- === Underground Path Route 6 ===
R["Underground Path Route 6"]:connect_warp(R["Route 6"], "Underground Path Route 6 to Route 6", ER_EXTERIOR)
R["Underground Path Route 6"]:connect_warp(R["Underground Path North South"], "Underground Path Route 6 to Underground Path North South", ER_INTERIOR)

-- === Underground Path Route 7 ===
R["Underground Path Route 7"]:connect_warp(R["Route 7"], "Underground Path Route 7 to Route 7", ER_EXTERIOR)
R["Underground Path Route 7"]:connect_warp(R["Underground Path West East"], "Underground Path Route 7 to Underground Path West East", ER_INTERIOR)

-- === Silph Co 9F-SW ===
R["Silph Co 9F-SW"]:connect_one_way(R["Silph Co 9F"], "Silph Co 9F-SW to Silph Co 9F", card_key_9)
R["Silph Co 9F-SW"]:connect_one_way(R["Silph Co 9F-NW"], "Silph Co 9F-SW to Silph Co 9F-NW", card_key_9)

-- === Silph Co 9F ===
R["Silph Co 9F"]:connect_one_way(R["Silph Co 9F-SW"], "Silph Co 9F to Silph Co 9F-SW", card_key_9)
R["Silph Co 9F"]:connect_warp(R["Silph Co 10F"], "Silph Co 9F to Silph Co 10F", ER_INTERIOR)
R["Silph Co 9F"]:connect_warp(R["Silph Co 8F"], "Silph Co 9F to Silph Co 8F", ER_INTERIOR)
R["Silph Co 9F"]:connect_warp(R["Silph Co Elevator-9F"], "Silph Co 9F to Silph Co Elevator-9F", ER_INTERIOR)
R["Silph Co 9F"]:connect_warp(R["Silph Co 5F"], "Silph Co 9F to Silph Co 5F", ER_WARP_TILE)

-- === Silph Co 9F-NW ===
R["Silph Co 9F-NW"]:connect_one_way(R["Silph Co 9F-SW"], "Silph Co 9F-NW to Silph Co 9F-SW", card_key_9)
R["Silph Co 9F-NW"]:connect_warp(R["Silph Co 3F-W"], "Silph Co 9F-NW to Silph Co 3F-W", ER_WARP_TILE)

-- === Victory Road 1F-S ===
R["Victory Road 1F-S"]:connect_one_way(R["Victory Road 1F"], "Victory Road 1F-S to Victory Road 1F", strength)
R["Victory Road 1F-S"]:connect_one_way(R["Victory Road 1F-Wild"], "Victory Road 1F-S to Victory Road 1F-Wild")
R["Victory Road 1F-S"]:connect_warp(R["Route 23-C"], "Victory Road 1F-S to Route 23-C", ER_EXTERIOR)

-- === Victory Road 1F ===
R["Victory Road 1F"]:connect_one_way(R["Victory Road 1F-S"], "Victory Road 1F to Victory Road 1F-S", strength)
R["Victory Road 1F"]:connect_one_way(R["Victory Road 1F-Wild"], "Victory Road 1F to Victory Road 1F-Wild")
R["Victory Road 1F"]:connect_warp(R["Victory Road 2F-W"], "Victory Road 1F to Victory Road 2F-W", ER_INTERIOR)

-- === Pokemon Tower 1F ===
R["Pokemon Tower 1F"]:connect_warp(R["Lavender Town"], "Pokemon Tower 1F to Lavender Town", ER_EXTERIOR)
R["Pokemon Tower 1F"]:connect_warp(R["Pokemon Tower 2F"], "Pokemon Tower 1F to Pokemon Tower 2F", ER_INTERIOR)

-- === Pokemon Tower 2F ===
R["Pokemon Tower 2F"]:connect_warp(R["Pokemon Tower 3F"], "Pokemon Tower 2F to Pokemon Tower 3F", ER_INTERIOR)
R["Pokemon Tower 2F"]:connect_warp(R["Pokemon Tower 1F"], "Pokemon Tower 2F to Pokemon Tower 1F", ER_INTERIOR)

-- === Pokemon Tower 3F ===
R["Pokemon Tower 3F"]:connect_warp(R["Pokemon Tower 2F"], "Pokemon Tower 3F to Pokemon Tower 2F", ER_INTERIOR)
R["Pokemon Tower 3F"]:connect_warp(R["Pokemon Tower 4F"], "Pokemon Tower 3F to Pokemon Tower 4F", ER_INTERIOR)

-- === Pokemon Tower 4F ===
R["Pokemon Tower 4F"]:connect_warp(R["Pokemon Tower 5F"], "Pokemon Tower 4F to Pokemon Tower 5F", ER_INTERIOR)
R["Pokemon Tower 4F"]:connect_warp(R["Pokemon Tower 3F"], "Pokemon Tower 4F to Pokemon Tower 3F", ER_INTERIOR)

-- === Pokemon Tower 5F ===
R["Pokemon Tower 5F"]:connect_warp(R["Pokemon Tower 4F"], "Pokemon Tower 5F to Pokemon Tower 4F", ER_INTERIOR)
R["Pokemon Tower 5F"]:connect_warp(R["Pokemon Tower 6F"], "Pokemon Tower 5F to Pokemon Tower 6F", ER_INTERIOR)

-- === Pokemon Tower 6F ===
R["Pokemon Tower 6F"]:connect_one_way(R["Pokemon Tower 6F-S"], "Pokemon Tower 6F to Pokemon Tower 6F-S", tower_ghost)
R["Pokemon Tower 6F"]:connect_warp(R["Pokemon Tower 5F"], "Pokemon Tower 6F to Pokemon Tower 5F", ER_INTERIOR)

-- === Pokemon Tower 6F-S ===
R["Pokemon Tower 6F-S"]:connect_one_way(R["Pokemon Tower 6F"], "Pokemon Tower 6F-S to Pokemon Tower 6F", tower_ghost)
R["Pokemon Tower 6F-S"]:connect_warp(R["Pokemon Tower 7F"], "Pokemon Tower 6F-S to Pokemon Tower 7F", ER_INTERIOR)

-- === Pokemon Tower 7F ===
R["Pokemon Tower 7F"]:connect_warp(R["Pokemon Tower 6F-S"], "Pokemon Tower 7F to Pokemon Tower 6F-S", ER_INTERIOR)

-- === Celadon Department Store 1F ===
R["Celadon Department Store 1F"]:connect_warp(R["Celadon City"], "Celadon Department Store 1F to Celadon City W", ER_EXTERIOR)
R["Celadon Department Store 1F"]:connect_warp(R["Celadon City"], "Celadon Department Store 1F to Celadon City E", ER_EXTERIOR)
R["Celadon Department Store 1F"]:connect_warp(R["Celadon Department Store 2F"], "Celadon Department Store 1F to Celadon Department Store 2F", ER_INTERIOR)
R["Celadon Department Store 1F"]:connect_warp(R["Celadon Department Store Elevator-1F"], "Celadon Department Store 1F to Celadon Department Store Elevator-1F", ER_INTERIOR)

-- === Viridian Forest ===
R["Viridian Forest"]:connect_warp(R["Viridian Forest North Gate"], "Viridian Forest to Viridian Forest North Gate", ER_INTERIOR)
R["Viridian Forest"]:connect_warp(R["Viridian Forest South Gate"], "Viridian Forest to Viridian Forest South Gate", ER_INTERIOR)

-- === S.S. Anne 1F ===
R["S.S. Anne 1F"]:connect_warp(R["Vermilion Dock"], "S.S. Anne 1F to Vermilion Dock", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne 1F Rooms-East Gentleman Room"], "S.S. Anne 1F to S.S. Anne 1F Rooms-East Gentleman Room", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne 1F Rooms-West Gentleman Room"], "S.S. Anne 1F to S.S. Anne 1F Rooms-West Gentleman Room", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne 1F Rooms-Cherry Pie Room"], "S.S. Anne 1F to S.S. Anne 1F Rooms-Cherry Pie Room", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne 1F Rooms-Wigglytuff Room"], "S.S. Anne 1F to S.S. Anne 1F Rooms-Wigglytuff Room", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne 1F Rooms-Youngster and Lass Room"], "S.S. Anne 1F to S.S. Anne 1F Rooms-Youngster and Lass Room", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne 1F Rooms-Police Room"], "S.S. Anne 1F to S.S. Anne 1F Rooms-Police Room", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 1F to S.S. Anne 2F", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne B1F"], "S.S. Anne 1F to S.S. Anne B1F", ER_INTERIOR)
R["S.S. Anne 1F"]:connect_warp(R["S.S. Anne Kitchen"], "S.S. Anne 1F to S.S. Anne Kitchen", ER_INTERIOR)

-- === S.S. Anne 2F ===
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 2F Rooms-Snorlax Room"], "S.S. Anne 2F to S.S. Anne 2F Rooms-Snorlax Room", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 2F Rooms-Fisherman and Gentleman Room"], "S.S. Anne 2F to S.S. Anne 2F Rooms-Fisherman and Gentleman Room", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 2F Rooms-Surf and Cut Room"], "S.S. Anne 2F to S.S. Anne 2F Rooms-Surf and Cut Room", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 2F Rooms-Gentleman and Lass Room"], "S.S. Anne 2F to S.S. Anne 2F Rooms-Gentleman and Lass Room", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 2F Rooms-Safari Zone Room"], "S.S. Anne 2F to S.S. Anne 2F Rooms-Safari Zone Room", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 2F Rooms-Seasickness Room"], "S.S. Anne 2F to S.S. Anne 2F Rooms-Seasickness Room", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne 2F to S.S. Anne 1F", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne 3F"], "S.S. Anne 2F to S.S. Anne 3F", ER_INTERIOR)
R["S.S. Anne 2F"]:connect_warp(R["S.S. Anne Captain's Room"], "S.S. Anne 2F to S.S. Anne Captain's Room", ER_INTERIOR)

-- === S.S. Anne B1F ===
R["S.S. Anne B1F"]:connect_warp(R["S.S. Anne B1F Rooms-Machoke Room"], "S.S. Anne B1F to S.S. Anne B1F Rooms-Machoke Room", ER_INTERIOR)
R["S.S. Anne B1F"]:connect_warp(R["S.S. Anne B1F Rooms-Two Sailors Room"], "S.S. Anne B1F to S.S. Anne B1F Rooms-Two Sailors Room", ER_INTERIOR)
R["S.S. Anne B1F"]:connect_warp(R["S.S. Anne B1F Rooms-East Single Sailor Room"], "S.S. Anne B1F to S.S. Anne B1F Rooms-East Single Sailor Room", ER_INTERIOR)
R["S.S. Anne B1F"]:connect_warp(R["S.S. Anne B1F Rooms-West Single Sailor Room"], "S.S. Anne B1F to S.S. Anne B1F Rooms-West Single Sailor Room", ER_INTERIOR)
R["S.S. Anne B1F"]:connect_warp(R["S.S. Anne B1F Rooms-Fisherman Room"], "S.S. Anne B1F to S.S. Anne B1F Rooms-Fisherman Room", ER_INTERIOR)
R["S.S. Anne B1F"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne B1F to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne Bow ===
R["S.S. Anne Bow"]:connect_warp(R["S.S. Anne 3F"], "S.S. Anne Bow to S.S. Anne 3F", ER_INTERIOR)

-- === S.S. Anne Kitchen ===
R["S.S. Anne Kitchen"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne Kitchen to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne Captain's Room ===
R["S.S. Anne Captain's Room"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne Captain's Room to S.S. Anne 2F", ER_INTERIOR)

-- === S.S. Anne 1F Rooms-West Gentleman Room ===
R["S.S. Anne 1F Rooms-West Gentleman Room"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne 1F Rooms-West Gentleman Room to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne 1F Rooms-East Gentleman Room ===
R["S.S. Anne 1F Rooms-East Gentleman Room"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne 1F Rooms-East Gentleman Room to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne 1F Rooms-Police Room ===
R["S.S. Anne 1F Rooms-Police Room"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne 1F Rooms-Police Room to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne 1F Rooms-Youngster and Lass Room ===
R["S.S. Anne 1F Rooms-Youngster and Lass Room"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne 1F Rooms-Youngster and Lass Room to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne 1F Rooms-Wigglytuff Room ===
R["S.S. Anne 1F Rooms-Wigglytuff Room"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne 1F Rooms-Wigglytuff Room to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne 1F Rooms-Cherry Pie Room ===
R["S.S. Anne 1F Rooms-Cherry Pie Room"]:connect_warp(R["S.S. Anne 1F"], "S.S. Anne 1F Rooms-Cherry Pie Room to S.S. Anne 1F", ER_INTERIOR)

-- === S.S. Anne 2F Rooms-Snorlax Room ===
R["S.S. Anne 2F Rooms-Snorlax Room"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 2F Rooms-Snorlax Room to S.S. Anne 2F", ER_INTERIOR)

-- === S.S. Anne 2F Rooms-Fisherman and Gentleman Room ===
R["S.S. Anne 2F Rooms-Fisherman and Gentleman Room"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 2F Rooms-Fisherman and Gentleman Room to S.S. Anne 2F", ER_INTERIOR)

-- === S.S. Anne 2F Rooms-Surf and Cut Room ===
R["S.S. Anne 2F Rooms-Surf and Cut Room"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 2F Rooms-Surf and Cut Room to S.S. Anne 2F", ER_INTERIOR)

-- === S.S. Anne 2F Rooms-Gentleman and Lass Room ===
R["S.S. Anne 2F Rooms-Gentleman and Lass Room"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 2F Rooms-Gentleman and Lass Room to S.S. Anne 2F", ER_INTERIOR)

-- === S.S. Anne 2F Rooms-Safari Zone Room ===
R["S.S. Anne 2F Rooms-Safari Zone Room"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 2F Rooms-Safari Zone Room to S.S. Anne 2F", ER_INTERIOR)

-- === S.S. Anne 2F Rooms-Seasickness Room ===
R["S.S. Anne 2F Rooms-Seasickness Room"]:connect_warp(R["S.S. Anne 2F"], "S.S. Anne 2F Rooms-Seasickness Room to S.S. Anne 2F", ER_INTERIOR)

-- === S.S. Anne B1F Rooms-Fisherman Room ===
R["S.S. Anne B1F Rooms-Fisherman Room"]:connect_warp(R["S.S. Anne B1F"], "S.S. Anne B1F Rooms-Fisherman Room to S.S. Anne B1F", ER_INTERIOR)

-- === S.S. Anne B1F Rooms-West Single Sailor Room ===
R["S.S. Anne B1F Rooms-West Single Sailor Room"]:connect_warp(R["S.S. Anne B1F"], "S.S. Anne B1F Rooms-West Single Sailor Room to S.S. Anne B1F", ER_INTERIOR)

-- === S.S. Anne B1F Rooms-East Single Sailor Room ===
R["S.S. Anne B1F Rooms-East Single Sailor Room"]:connect_warp(R["S.S. Anne B1F"], "S.S. Anne B1F Rooms-East Single Sailor Room to S.S. Anne B1F", ER_INTERIOR)

-- === S.S. Anne B1F Rooms-Two Sailors Room ===
R["S.S. Anne B1F Rooms-Two Sailors Room"]:connect_warp(R["S.S. Anne B1F"], "S.S. Anne B1F Rooms-Two Sailors Room to S.S. Anne B1F", ER_INTERIOR)

-- === S.S. Anne B1F Rooms-Machoke Room ===
R["S.S. Anne B1F Rooms-Machoke Room"]:connect_warp(R["S.S. Anne B1F"], "S.S. Anne B1F Rooms-Machoke Room to S.S. Anne B1F", ER_INTERIOR)

-- === Underground Path North South ===
R["Underground Path North South"]:connect_warp(R["Underground Path Route 5"], "Underground Path North South to Underground Path Route 5", ER_INTERIOR)
R["Underground Path North South"]:connect_warp(R["Underground Path Route 6"], "Underground Path North South to Underground Path Route 6", ER_INTERIOR)

-- === Underground Path West East ===
R["Underground Path West East"]:connect_warp(R["Underground Path Route 7"], "Underground Path West East to Underground Path Route 7", ER_INTERIOR)
R["Underground Path West East"]:connect_warp(R["Underground Path Route 8"], "Underground Path West East to Underground Path Route 8", ER_INTERIOR)

-- === Diglett's Cave ===
R["Diglett's Cave"]:connect_warp(R["Diglett's Cave Route 2"], "Diglett's Cave to Diglett's Cave Route 2", ER_INTERIOR)
R["Diglett's Cave"]:connect_warp(R["Diglett's Cave Route 11"], "Diglett's Cave to Diglett's Cave Route 11", ER_INTERIOR)

-- === Silph Co 11F ===
R["Silph Co 11F"]:connect_warp(R["Silph Co 10F"], "Silph Co 11F to Silph Co 10F", ER_INTERIOR)
R["Silph Co 11F"]:connect_warp(R["Silph Co Elevator-11F"], "Silph Co 11F to Silph Co Elevator-11F", ER_INTERIOR)

-- === Silph Co 11F-W ===
R["Silph Co 11F-W"]:connect_one_way(R["Silph Co 11F-C"], "Silph Co 11F-W to Silph Co 11F-C", card_key_11)
R["Silph Co 11F-W"]:connect_warp(R["Silph Co 7F-NW"], "Silph Co 11F-W to Silph Co 7F-NW", ER_WARP_TILE)

-- === Viridian Gym ===
R["Viridian Gym"]:connect_warp(R["Viridian City-G"], "Viridian Gym to Viridian City-G", ER_EXTERIOR)

-- === Pewter Pokemart ===
R["Pewter Pokemart"]:connect_warp(R["Pewter City"], "Pewter Pokemart to Pewter City", ER_EXTERIOR)

-- === Cerulean Cave 1F-SE ===
R["Cerulean Cave 1F-SE"]:connect_one_way(R["Route 23/Cerulean Cave Fishing"], "Cerulean Cave 1F-SE to Route 23/Cerulean Cave Fishing", super_rod)
R["Cerulean Cave 1F-SE"]:connect_one_way(R["Cerulean Cave 1F-Wild"], "Cerulean Cave 1F-SE to Cerulean Cave 1F-Wild")
R["Cerulean Cave 1F-SE"]:connect_one_way(R["Cerulean Cave 1F-Water"], "Cerulean Cave 1F-SE to Cerulean Cave 1F-Water", surf)
R["Cerulean Cave 1F-SE"]:connect_warp(R["Cerulean City-Cave"], "Cerulean Cave 1F-SE to Cerulean City-Cave", ER_EXTERIOR)
R["Cerulean Cave 1F-SE"]:connect_warp(R["Cerulean Cave 2F-E"], "Cerulean Cave 1F-SE to Cerulean Cave 2F-E", ER_INTERIOR)

-- === Cerulean Cave 1F-NE ===
R["Cerulean Cave 1F-NE"]:connect_one_way(R["Route 23/Cerulean Cave Fishing"], "Cerulean Cave 1F-NE to Route 23/Cerulean Cave Fishing", super_rod)
R["Cerulean Cave 1F-NE"]:connect_one_way(R["Cerulean Cave 1F-Wild"], "Cerulean Cave 1F-NE to Cerulean Cave 1F-Wild")
R["Cerulean Cave 1F-NE"]:connect_one_way(R["Cerulean Cave 1F-Water"], "Cerulean Cave 1F-NE to Cerulean Cave 1F-Water", surf)
R["Cerulean Cave 1F-NE"]:connect_warp(R["Cerulean Cave 2F-E"], "Cerulean Cave 1F-NE to Cerulean Cave 2F-E", ER_INTERIOR)

-- === Cerulean Cave 1F-N ===
R["Cerulean Cave 1F-N"]:connect_one_way(R["Route 23/Cerulean Cave Fishing"], "Cerulean Cave 1F-N to Route 23/Cerulean Cave Fishing", super_rod)
R["Cerulean Cave 1F-N"]:connect_one_way(R["Cerulean Cave 1F-Wild"], "Cerulean Cave 1F-N to Cerulean Cave 1F-Wild")
R["Cerulean Cave 1F-N"]:connect_one_way(R["Cerulean Cave 1F-Water"], "Cerulean Cave 1F-N to Cerulean Cave 1F-Water", surf)
R["Cerulean Cave 1F-N"]:connect_warp(R["Cerulean Cave 2F-N"], "Cerulean Cave 1F-N to Cerulean Cave 2F-N", ER_INTERIOR)

-- === Cerulean Cave 1F-SW ===
R["Cerulean Cave 1F-SW"]:connect_one_way(R["Route 23/Cerulean Cave Fishing"], "Cerulean Cave 1F-SW to Route 23/Cerulean Cave Fishing", super_rod)
R["Cerulean Cave 1F-SW"]:connect_one_way(R["Cerulean Cave 1F-Wild"], "Cerulean Cave 1F-SW to Cerulean Cave 1F-Wild")
R["Cerulean Cave 1F-SW"]:connect_one_way(R["Cerulean Cave 1F-Water"], "Cerulean Cave 1F-SW to Cerulean Cave 1F-Water", surf)
R["Cerulean Cave 1F-SW"]:connect_warp(R["Cerulean Cave 2F-N"], "Cerulean Cave 1F-SW to Cerulean Cave 2F-N", ER_INTERIOR)
R["Cerulean Cave 1F-SW"]:connect_warp(R["Cerulean Cave 2F-W"], "Cerulean Cave 1F-SW to Cerulean Cave 2F-W", ER_INTERIOR)

-- === Cerulean Cave 1F-NW ===
R["Cerulean Cave 1F-NW"]:connect_one_way(R["Cerulean Cave 1F-Wild"], "Cerulean Cave 1F-NW to Cerulean Cave 1F-Wild")
R["Cerulean Cave 1F-NW"]:connect_warp(R["Cerulean Cave 2F-W"], "Cerulean Cave 1F-NW to Cerulean Cave 2F-W", ER_INTERIOR)
R["Cerulean Cave 1F-NW"]:connect_warp(R["Cerulean Cave B1F"], "Cerulean Cave 1F-NW to Cerulean Cave B1F", ER_INTERIOR)

-- === Cerulean Cave 1F-Water ===
R["Cerulean Cave 1F-Water"]:connect_one_way(R["Cerulean Cave 1F-SE"], "Cerulean Cave 1F-Water to Cerulean Cave 1F-SE", surf)
R["Cerulean Cave 1F-Water"]:connect_one_way(R["Cerulean Cave 1F-SW"], "Cerulean Cave 1F-Water to Cerulean Cave 1F-SW", surf)
R["Cerulean Cave 1F-Water"]:connect_one_way(R["Cerulean Cave 1F-N"], "Cerulean Cave 1F-Water to Cerulean Cave 1F-N", surf)
R["Cerulean Cave 1F-Water"]:connect_one_way(R["Cerulean Cave 1F-NE"], "Cerulean Cave 1F-Water to Cerulean Cave 1F-NE", surf)

-- === Cerulean Badge House ===
R["Cerulean Badge House"]:connect_warp(R["Cerulean City-Badge House Backyard"], "Cerulean Badge House to Cerulean City-Badge House Backyard", ER_EXTERIOR)
R["Cerulean Badge House"]:connect_warp(R["Cerulean City"], "Cerulean Badge House to Cerulean City", ER_EXTERIOR)

-- === Fuchsia Bill's Grandpa's House ===
R["Fuchsia Bill's Grandpa's House"]:connect_warp(R["Fuchsia City"], "Fuchsia Bill's Grandpa's House to Fuchsia City", ER_EXTERIOR)

-- === Fuchsia Pokemon Center ===
R["Fuchsia Pokemon Center"]:connect_warp(R["Fuchsia City"], "Fuchsia Pokemon Center to Fuchsia City", ER_EXTERIOR)

-- === Fuchsia Warden's House ===
R["Fuchsia Warden's House"]:connect_warp(R["Fuchsia City"], "Fuchsia Warden's House to Fuchsia City", ER_EXTERIOR)

-- === Safari Zone Gate-S ===
R["Safari Zone Gate-S"]:connect_one_way(R["Safari Zone Gate-N"], "Safari Zone Gate-S to Safari Zone Gate-N", safari_pass)
R["Safari Zone Gate-S"]:connect_warp(R["Fuchsia City"], "Safari Zone Gate-S to Fuchsia City", ER_FIXED_SIMPLE)

-- === Safari Zone Gate-N ===
R["Safari Zone Gate-N"]:connect_warp(R["Safari Zone Center-S"], "Safari Zone Gate-N to Safari Zone Center-S", ER_FIXED_SAFARI)

-- === Fuchsia Gym ===
R["Fuchsia Gym"]:connect_warp(R["Fuchsia City"], "Fuchsia Gym to Fuchsia City", ER_EXTERIOR)

-- === Fuchsia Meeting Room ===
R["Fuchsia Meeting Room"]:connect_warp(R["Fuchsia City"], "Fuchsia Meeting Room to Fuchsia City", ER_EXTERIOR)

-- === Cinnabar Gym ===
R["Cinnabar Gym"]:connect_warp(R["Cinnabar Island-G"], "Cinnabar Gym to Cinnabar Island-G", ER_EXTERIOR)

-- === Cinnabar Lab ===
R["Cinnabar Lab"]:connect_warp(R["Cinnabar Island"], "Cinnabar Lab to Cinnabar Island", ER_EXTERIOR)
R["Cinnabar Lab"]:connect_warp(R["Cinnabar Lab Trade Room"], "Cinnabar Lab to Cinnabar Lab Trade Room", ER_INTERIOR)
R["Cinnabar Lab"]:connect_warp(R["Cinnabar Lab R&D Room"], "Cinnabar Lab to Cinnabar Lab R&D Room", ER_INTERIOR)
R["Cinnabar Lab"]:connect_warp(R["Cinnabar Lab Fossil Room"], "Cinnabar Lab to Cinnabar Lab Fossil Room", ER_INTERIOR)

-- === Cinnabar Lab Trade Room ===
R["Cinnabar Lab Trade Room"]:connect_warp(R["Cinnabar Lab"], "Cinnabar Lab Trade Room to Cinnabar Lab", ER_INTERIOR)

-- === Cinnabar Lab R&D Room ===
R["Cinnabar Lab R&D Room"]:connect_warp(R["Cinnabar Lab"], "Cinnabar Lab R&D Room to Cinnabar Lab", ER_INTERIOR)

-- === Cinnabar Lab Fossil Room ===
R["Cinnabar Lab Fossil Room"]:connect_warp(R["Cinnabar Lab"], "Cinnabar Lab Fossil Room to Cinnabar Lab", ER_INTERIOR)

-- === Cinnabar Pokemon Center ===
R["Cinnabar Pokemon Center"]:connect_warp(R["Cinnabar Island"], "Cinnabar Pokemon Center to Cinnabar Island", ER_EXTERIOR)

-- === Cinnabar Pokemart ===
R["Cinnabar Pokemart"]:connect_warp(R["Cinnabar Island"], "Cinnabar Pokemart to Cinnabar Island", ER_EXTERIOR)

-- === Saffron Copycat's House 1F ===
R["Saffron Copycat's House 1F"]:connect_warp(R["Saffron City-Copycat"], "Saffron Copycat's House 1F to Saffron City-Copycat", ER_EXTERIOR)
R["Saffron Copycat's House 1F"]:connect_warp(R["Saffron Copycat's House 2F"], "Saffron Copycat's House 1F to Saffron Copycat's House 2F", ER_INTERIOR)

-- === Indigo Plateau Champion's Room ===
R["Indigo Plateau Champion's Room"]:connect_warp(R["Indigo Plateau Lance's Room"], "Indigo Plateau Champion's Room to Indigo Plateau Lance's Room", ER_FIXED_FULL)
R["Indigo Plateau Champion's Room"]:connect_warp(R["Indigo Plateau Hall of Fame"], "Indigo Plateau Champion's Room to Indigo Plateau Hall of Fame", ER_FIXED_FULL)

-- === Indigo Plateau Lorelei's Room ===
R["Indigo Plateau Lorelei's Room"]:connect_warp(R["Indigo Plateau Lobby-N"], "Indigo Plateau Lorelei's Room to Indigo Plateau Lobby-N", ER_FIXED_FULL)
R["Indigo Plateau Lorelei's Room"]:connect_warp(R["Indigo Plateau Bruno's Room"], "Indigo Plateau Lorelei's Room to Indigo Plateau Bruno's Room", ER_FIXED_FULL)

-- === Indigo Plateau Bruno's Room ===
R["Indigo Plateau Bruno's Room"]:connect_warp(R["Indigo Plateau Lorelei's Room"], "Indigo Plateau Bruno's Room to Indigo Plateau Lorelei's Room", ER_FIXED_FULL)
R["Indigo Plateau Bruno's Room"]:connect_warp(R["Indigo Plateau Agatha's Room"], "Indigo Plateau Bruno's Room to Indigo Plateau Agatha's Room", ER_FIXED_FULL)

-- === Indigo Plateau Agatha's Room ===
R["Indigo Plateau Agatha's Room"]:connect_warp(R["Indigo Plateau Bruno's Room"], "Indigo Plateau Agatha's Room to Indigo Plateau Bruno's Room", ER_FIXED_FULL)
R["Indigo Plateau Agatha's Room"]:connect_warp(R["Indigo Plateau Lance's Room"], "Indigo Plateau Agatha's Room to Indigo Plateau Lance's Room", ER_FIXED_FULL)
