function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end

    local ignore_keys = {
        type_chart = true,
    }

    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            local key_str = tostring(k)
            if not ignore_keys[key_str] then
                if type(k) ~= 'number' then
                    k = '"' .. k .. '"'
                end
                s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
            end
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function has(item, amount)
	local count = Tracker:ProviderCountForCode(item)
	local amount = tonumber(amount)
	if not amount then
        if count > 0 then
            return AccessibilityLevel.Normal
        end
	elseif count >= amount then
        return AccessibilityLevel.Normal
	end
    return AccessibilityLevel.None
end

function has_new(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

function has_location(loc)
    if loc.AvailableChestCount == 0 then
        return AccessibilityLevel.Normal
    else 
        return AccessibilityLevel.None
    end
end


function progCount(code)
	return Tracker:FindObjectForCode(code).CurrentStage
end

--returns whether we can access all given arguments
function access(...)
    local access = AccessibilityLevel.Normal
    local args = {...}
    for i,v in ipairs(args) do
        --break early if we hit min accessibility
        if v == AccessibilityLevel.None then
            return AccessibilityLevel.None
        end

        if access > v then
            access = v
        end
    end

    return access
end

--returns the maximum accessibility of the given arguments
function max(...)
    local maximum = AccessibilityLevel.None
    local args = {...}

    for i,v in ipairs(args) do
        if v == AccessibilityLevel.Normal then
            return AccessibilityLevel.Normal
        end

        if maximum < v then
            maximum = v
        end
    end
    return maximum
end

function scoutable()
    return AccessibilityLevel.Inspect
end

function get_ap_locations()
    -- We get all locations from AP.
    -- They only share checked & missing ones,
    -- so we combine them ourselves.
    local missing = Archipelago.MissingLocations
    local locations = Archipelago.CheckedLocations
    local existing_locations = {}
    
    --loop through all checked and unchecked locations and combine them
    for _, v in pairs(missing) do
        existing_locations[v] = true
    end
    for _, v in pairs(locations) do
        existing_locations[v] = true
    end
    
    return existing_locations
end

function trainersanity_init(locations)
    -- trainersanity checks have ids in the range 172000215-172000531
    local start_index = 172000215
    local end_index = 172000531
    local total = 0
    
    for i = start_index, end_index do
        if locations[i] then
            Tracker:FindObjectForCode("trainer_" .. i).Active = true
            total = total + 1
        else
            Tracker:FindObjectForCode("trainer_" .. i).Active = false
        end
    end
    
    if total == 0 then
        TRAINERS:setType("none")
    elseif total == 317 then
        TRAINERS:setType("full")
    else
        TRAINERS:setType("partial")
        TRAINERS:setStage(total)
    end
end

function dexsanity_init(locations)
	local count = 0
	for i = 1, 151 do
    
        --check to see if the dexsanity location exists in the list of all checks
		local dexID = i + 172000548
		local check_exists = locations[dexID]
        local obj = Tracker:FindObjectForCode("dexsanity_".. i)
        
		if check_exists then
			count = count + 1
            obj.Active = true
        else
            obj.Active = false
		end
	end
    
	local dexsanity = Tracker:FindObjectForCode('opt_dexsanity')
    
	if dexsanity then
		if count == 0 then
			dexsanity.CurrentStage = 0
		elseif count == 151 then
			dexsanity.CurrentStage = 2
		else
			dexsanity.CurrentStage = 1
		end
	end
end

function toggle_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code.."_hosted"
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  else
    if ENABLE_DEBUG_LOG then
      print(string.format("toggle_item: could not find object for code %s", code))
    end
  end
end

function toggle_hosted_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code:gsub("_hosted", "")
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  else
    if ENABLE_DEBUG_LOG then
      print(string.format("toggle_hosted_item: could not find object for code %s", code))
    end
  end
end

function onMap(value)
    if value == nil or value["data"] == nil then
        return
    end
    RouteMapEntered(value["data"]["currentMap"])
    local stage = Tracker:FindObjectForCode("automap").CurrentStage
    local mapping = ({MAP_MAPPING_ALL, MAP_MAPPING_MOST, MAP_MAPPING_MINIMUM})[stage + 1]
    if mapping then
        local map_number = value["data"]["currentMap"]

        -- Access correct mapping and activate tabs
        local tabs = mapping[map_number]
        
        if tabs then
            for i, tab in ipairs(tabs) do
                Tracker:UiHint("ActivateTab", tab)
            end
        end
    end
end

-- AddLayouts rebuilds the whole view, so only load on change
LOADED_LAYOUTS = {
    quick_settings = "layouts/settings_quick.json",
    tabbed_maps = "layouts/tabs_single.json",
    tabs_meta = "layouts/tabs_meta.json",
    tabs_submaps = "layouts/tabs_submaps.json",
}
local function load_layout(key, path)
    if LOADED_LAYOUTS[key] ~= path then
        LOADED_LAYOUTS[key] = path
        Tracker:AddLayouts(path)
    end
end

function er_any()
    return Tracker:FindObjectForCode("er_doors").CurrentStage > 0 or Tracker:ProviderCountForCode("er_warp_tiles_on") > 0
end

function toggle_quick_settings()
    load_layout("quick_settings", er_any() and "layouts/settings_quick_er.json" or "layouts/settings_quick.json")
end

function toggle_itemgrid()
    local stones = Tracker:FindObjectForCode("opt_stonesanity").CurrentStage == 1
    
    if Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 1 and stones then
        Tracker:AddLayouts("layouts/itemgrids_extra.json")
        Tracker:AddLayouts("layouts/items_extra_full.json")
        toggle_maingrid()
    elseif stones then
        Tracker:AddLayouts("layouts/itemgrids_extra.json")
        Tracker:AddLayouts("layouts/items_extra_stones.json")
        toggle_maingrid()
    elseif Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 1 then
        Tracker:AddLayouts("layouts/itemgrids_extra.json")
        Tracker:AddLayouts("layouts/items_extra_cardkey.json")
        toggle_maingrid()
    elseif not (Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 1) and not stones then
        Tracker:AddLayouts("layouts/itemgrids.json")
        toggle_maingrid()
    else
        print("Something went terribly wrong in toggle_itemgrid()")
    end
end

function toggle_maingrid()
    local extra_key = Tracker:FindObjectForCode("opt_extra_key_items").CurrentStage == 1
    local tea = Tracker:FindObjectForCode("opt_tea").CurrentStage == 1
    
    if Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 1 then
        if extra_key and tea then
            Tracker:AddLayouts("layouts/items_main_3_full.json")
        elseif extra_key then
            Tracker:AddLayouts("layouts/items_main_3_extrakey.json")
        elseif tea then
            Tracker:AddLayouts("layouts/items_main_3_tea.json")
        elseif not tea and not extra_key then
            Tracker:AddLayouts("layouts/items_main_3_minimal.json")
        else
            print("Something went terribly wrong in toggle_maingrid()")
        end
    elseif Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 2 then
        if extra_key and tea then
            Tracker:AddLayouts("layouts/items_main_2_full.json")
        elseif extra_key then
            Tracker:AddLayouts("layouts/items_main_2_extrakey.json")
        elseif tea then
            Tracker:AddLayouts("layouts/items_main_2_tea.json")
        elseif not tea and not extra_key then
            Tracker:AddLayouts("layouts/items_main_2_minimal.json")
        else
            print("Something went terribly wrong in toggle_maingrid()")
        end
    elseif Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 0 then
        if extra_key and tea then
            Tracker:AddLayouts("layouts/items_main_1_full.json")
        elseif extra_key then
            Tracker:AddLayouts("layouts/items_main_1_extrakey.json")
        elseif tea then
            Tracker:AddLayouts("layouts/items_main_1_tea.json")
        elseif not tea and not extra_key then
            Tracker:AddLayouts("layouts/items_main_1_minimal.json")
        else
            print("Something went terribly wrong in toggle_maingrid()")
        end
    else
        print("Oh nyo. This is even more terrible.")
    end
end

function toggle_grayscale()
    local bw = Tracker:FindObjectForCode("colormap").CurrentStage == 1

    if not bw then
        Tracker:AddMaps("maps/maps.json")
    elseif bw then
        Tracker:AddMaps("maps/maps_bw.json")
    else
        print("Oh Oh.")
    end
    toggle_encounter_map()
end

-- the overworld shows the encounter map image while encounters are shown
function toggle_encounter_map()
    local bw = Tracker:FindObjectForCode("colormap").CurrentStage == 1
    local shown = Tracker:ProviderCountForCode("show_encounters") > 0
    Tracker:AddMaps("maps/overworld" .. (bw and "_bw" or "") .. (shown and "_encounters" or "") .. ".json")
end

function toggle_boulders()
    local boulders = Tracker:FindObjectForCode("opt_extra_boulders").CurrentStage == 1
    local bw = Tracker:FindObjectForCode("colormap").CurrentStage == 1

    if not bw and not boulders then
        Tracker:AddMaps("maps/maps_boulder_vanilla.json")
    elseif bw and not boulders then
        Tracker:AddMaps("maps/maps_bw_boulder_vanilla.json")
    elseif not bw and boulders then
        Tracker:AddMaps("maps/maps_boulder.json")
    elseif bw and boulders then
        Tracker:AddMaps("maps/maps_bw_boulder.json")
    else
        print("Oh Oh.")
    end
end

function toggle_extra_key_items()
    local extra_key = Tracker:FindObjectForCode("opt_extra_key_items").CurrentStage == 1
    local bw = Tracker:FindObjectForCode("colormap").CurrentStage == 1

    if not bw and not extra_key then
        Tracker:AddMaps("maps/maps_extrakey_vanilla.json")
    elseif bw and not extra_key then
        Tracker:AddMaps("maps/maps_bw_extrakey_vanilla.json")
    elseif not bw and extra_key then
        Tracker:AddMaps("maps/maps_extrakey.json")
    elseif bw and extra_key then
        Tracker:AddMaps("maps/maps_bw_extrakey.json")
    else
        print("Oh Oh.")
    end
end

-- the Routing tab is only there while some entrance is shuffled
function toggle_splitmap()
    local stage = Tracker:FindObjectForCode("splitmap").CurrentStage
    local routing = er_any() and "_routing" or ""
    if stage == 0 then
        load_layout("tabbed_maps", "layouts/tabs_single" .. routing .. ".json")
        return
    end
    local submap_side = Tracker:ProviderCountForCode("routing_tab_submap") > 0
    load_layout("tabs_meta", "layouts/tabs_meta" .. (submap_side and "" or routing) .. ".json")
    load_layout("tabs_submaps", "layouts/tabs_submaps" .. (submap_side and routing or "") .. ".json")
    load_layout("tabbed_maps", "layouts/tabs_" .. (stage == 1 and "split" or "reverse") .. ".json")
end