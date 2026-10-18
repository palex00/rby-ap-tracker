TABLE_DUMP = TRUE

-- ITEM COUNT CHECKS

-- returns int of # of badges
function badges_count()
    return Tracker:ProviderCountForCode('badge')
end

-- returns int of # of key items
function key_items_count()
    return Tracker:ProviderCountForCode('keyitem')
end

-- returns int of # of pokemon caught
function pokedex_count()
    local hundreds = 0
    local tens = 0
    local ones = 0

    obj = Tracker:FindObjectForCode("dex_digit1")
    if obj then
        hundreds = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("dex_digit2")
    if obj then
        tens = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("dex_digit3")
    if obj then
        ones = obj.CurrentStage
    end
    return (100 * hundreds) + (10 * tens) + ones
end

-- HM CHECKS

--a table for lookups
badges = {"boulder", "cascade", "thunder", "rainbow", "soul", "marsh", "volcano", "earth"}

-- An HM is usable with its vanilla badge, with no badges needed at all (opt_hm_off), or with
-- the extra badge its item stage names: stage 0 none, 1-8 the badges above, 9 no requirement.
local function hm(code, badge)
    local obj = Tracker:FindObjectForCode(code)
    local extra = AccessibilityLevel.None
    if obj then
        local stage = obj.CurrentStage
        if stage > #badges then
            extra = AccessibilityLevel.Normal
        elseif stage > 0 then
            extra = has(badges[stage])
        end
    end
    return access(has(code), max(has(badge), has('opt_hm_off'), extra))
end

function cut()
    return hm('cut', 'cascade')
end

function fly()
    return hm('fly', 'thunder')
end

function surf()
    return hm('surf', 'soul')
end

function strength()
    return hm('strength', 'rainbow')
end

function flash()
    return hm('flash', 'boulder')
end

function flyto(location)
    local map = access(has("map_fly_"..location),has('townmap'))
    return access(fly(),max(map,has("fly_"..location)))
end

-- ITEM ACCESS CHECKS
function cardkey(floor)
    if has_new("cardkey") or has_new("cardkey"..floor.."f") or (Tracker:FindObjectForCode("cardkey_progressive").CurrentStage >= floor-1) then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function hidden()
    return max(has('opt_itemfinder_off'),has('itemfinder'))
end

function aide(route)
    local code = 'opt_aide_' .. route
    local required = Tracker:FindObjectForCode(code).AcquiredCount
    local caught = pokedex_count()
    return required <= caught and max(has('pokedex'),has('opt_dex_required_off'))

end

function rt25_item()
    local blind = AccessibilityLevel.SequenceBreak
    if has('opt_blind_trainers_on') == AccessibilityLevel.Normal then
        blind = AccessibilityLevel.None
    end
    return max(cut(), blind)
end

-- ROADBLOCK CHECKS
function old_man()
    if has_new("opt_old_man_on") or has_new("EVENT_OAK_GOT_PARCEL") then
        return AccessibilityLevel.Normal
    else
        return AccessibilityLevel.None
    end
end

function rt11_boulders()
    return max(has('opt_extra_boulders_off'), strength())
end

function boardwalk_boulders()
    return max(has('opt_extra_boulders_off'), strength(), surf())
end

function cyclingroad()
    return max(has('bicycle'), has('opt_bike_skips_on'))
end

function rock_tunnel()
    local in_logic = max(flash(), has('opt_dark_rock_tunnel_on'))
    local out_of_logic = AccessibilityLevel.SequenceBreak
    return max(in_logic, out_of_logic)
end

function officer()
    if has_new("opt_officer_off") or has_new("EVENT_GOT_SS_TICKET") then
        return AccessibilityLevel.Normal
    else
        return AccessibilityLevel.None
    end
end

-- REGION GRAPH CHECKS
-- These run inside the CanReach flood fill (connections.lua), so they read other regions
-- through reach(), never through a location's AccessibilityLevel.

-- Saffron's gate guards: Tea, or a drink from the Celadon Department Store roof vending machines.
function pass_guards()
    if has_new("opt_tea_on") then
        return has("tea")
    end
    return reach("Celadon Department Store Roof")
end

-- Leaving a Silph Co / Celadon Department Store elevator.
function elevator_unlocked()
    return max(has("opt_elevators_locked_off"), has("liftkey"))
end

-- The six Seafoam Exit Boulder events: every boulder room must be reachable.
function seafoam_exit_boulders()
    return ALL(
        reach("Seafoam Islands 1F"),
        reach("Seafoam Islands B1F"),
        reach("Seafoam Islands B1F-NE"),
        reach("Seafoam Islands B2F-NW"),
        reach("Seafoam Islands B2F-NE")
    )
end

-- The apworld's fossil_checks() for the second fossil check: the Mt Moon fossil, the Cinnabar
-- Lab and Cinnabar Island events, plus as many fossils as the second fossil check condition.
function fossil_checks()
    local fossils_req = Tracker:FindObjectForCode("opt_fossilcheck").AcquiredCount
    if Tracker:ProviderCountForCode("fossil") < fossils_req then
        return AccessibilityLevel.None
    end
    return ALL(reach("Mt Moon B2F"), reach("Cinnabar Lab"), reach("Cinnabar Island"))
end

-- LOCATION ACCESS CHECKS

function gyms()
    return
    Tracker:ProviderCountForCode("EVENT_BEAT_BROCK") +
    Tracker:ProviderCountForCode("EVENT_BEAT_MISTY") +
    Tracker:ProviderCountForCode("EVENT_BEAT_LT_SURGE") +
    Tracker:ProviderCountForCode("EVENT_BEAT_ERIKA") +
    Tracker:ProviderCountForCode("EVENT_BEAT_JANINE") +
    Tracker:ProviderCountForCode("EVENT_BEAT_SABRINA") +
    Tracker:ProviderCountForCode("EVENT_BEAT_BLAINE") +
    Tracker:ProviderCountForCode("EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI")
end

function rt3()
    local open = has_new('opt_rt3open')
    local brock = has_new("opt_rt3brock") and has_new("EVENT_BEAT_BROCK")
    local boulder = has_new('opt_rt3boulder') and has_new('boulder')
    local any_gym = has_new("opt_rt3gym") and (gyms() >= 1)
    local any_badge = has_new('opt_rt3badge') and has_new("badge")
    
    if open or brock or boulder or any_gym or any_badge then
        return AccessibilityLevel.Normal
    else
        return AccessibilityLevel.None
    end
end


function elite4()
    local badges_required = Tracker:FindObjectForCode("e4b_digit").CurrentStage

    local tens = Tracker:FindObjectForCode("e4k_digit1").CurrentStage
    local ones = Tracker:FindObjectForCode("e4k_digit2").CurrentStage
    local key_items_required = 10 * tens + ones

    local hundreds = Tracker:FindObjectForCode("e4p_digit1").CurrentStage
    tens = Tracker:FindObjectForCode("e4p_digit2").CurrentStage
    ones = Tracker:FindObjectForCode("e4p_digit3").CurrentStage
    local pokedex_required = 100 * hundreds + 10 * tens + ones

    local enough_badges = badges_count() >= badges_required
    local enough_items = key_items_count() >= key_items_required
    local enough_dex
    
    if pokedex_required > 0 then
        enough_dex = ((pokedex_count() >= pokedex_required) and Tracker:FindObjectForCode("pokedex").Active == true)
    else
        enough_dex = true
    end

    if enough_badges and enough_items and enough_dex then
        return AccessibilityLevel.Normal
    elseif enough_badges and enough_items then
        return AccessibilityLevel.SequenceBreak
    else
        return scoutable()
    end
    return AccessibilityLevel.None
end

function victoryroad()
    local count = Tracker:FindObjectForCode("vr_digit").CurrentStage
    if badges_count() >= count then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function rt23()
    local obj = Tracker:FindObjectForCode("rt22_digit")
    local req = obj.CurrentStage
    if badges_count() >= req then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function viridiangym()
    local obj = Tracker:FindObjectForCode("vg_digit")
    if obj then
        local count = obj.CurrentStage
        if (badges_count() >= count) then
            return AccessibilityLevel.Normal
        end
    end
    return AccessibilityLevel.None
end

function ceruleancave()
    local badge_req = Tracker:FindObjectForCode("ccaveB_digit").CurrentStage
    local tens = Tracker:FindObjectForCode("ccaveK_digit1").CurrentStage
    local ones = Tracker:FindObjectForCode("ccaveK_digit2").CurrentStage
    local key_item_req = 10 * tens + ones
    if key_items_count() >= key_item_req and badges_count() >= badge_req then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function scout()
    return AccessibilityLevel.Inspect
end