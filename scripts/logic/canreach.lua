-- CanReach graph engine, ported from the Crystal pack (itself trimmed from the ALTTP AP pack).
--
-- Model: the world is a graph of region Nodes, one per apworld region. Edges carry a rule
-- function. A WARP edge additionally carries its apworld entrance name (the token) and an ER
-- kind saying under which door-shuffle settings it is shuffled. A shuffled warp is detoured
-- through the player's manual link for its token; an unlinked shuffled warp leads nowhere.
-- With door shuffle off (the default) every warp is traversed vanilla.
--
-- Locations bind to the graph from their JSON with "^$CanReach|<apworld region>". The leading ^
-- is required: CanReach returns an AccessibilityLevel, and a bare $rule is coerced to a bool,
-- which would silently promote SequenceBreak/Inspect to fully reachable.

Node = {}
Node.__index = Node

---@type table<string, table>  name -> node, the table CanReach() looks names up in
NAMED_NODES = {}
---@type string[]
NAMED_NODES_KEYS = {}

-- door_shuffle: 0 off, 1 simple, 2 interiors, 3 full, 4 insanity, 5 decoupled
-- Randomize Rock Tunnel isn't in slot_data, its ladders just count as shuffled from Full up.
ER_SETTINGS = { door_shuffle = 0, warp_tiles = false }

-- warp token -> token of the door you came out of, owned by er_state.lua
ER_LINKS = {}

-- warp token -> name of the region the warp sits in (its "mouth"); filled by connect_warp.
WARP_SOURCE = {}

local stale = true
local accessibilityCache = {}
local accessibilityCacheComplete = false

--- Checks whether a named node is reachable from the entry point and returns its level.
--- Lazily rebuilds the whole flood-fill cache when the world state changed.
---@param name string
---@return integer
function CanReach(name)
    if stale then
        stale = false
        accessibilityCache = {}
        Entry_point:discover(ACCESS_NORMAL)
        -- Rules that read reach() (the apworld's event items) can turn true after their source
        -- region was discovered, and discover() only walks on from nodes whose level improved.
        -- Re-relax every reached node until nothing changes; restarting from Entry_point alone
        -- would never revisit those edges.
        repeat
            accessibilityCacheComplete = true
            for _, name in ipairs(NAMED_NODES_KEYS) do
                local node = NAMED_NODES[name]
                local level = accessibilityCache[node]
                if level and level > ACCESS_NONE then
                    node:discover(level)
                end
            end
        until accessibilityCacheComplete
    end
    local node = NAMED_NODES[name]
    if node == nil then
        print("CanReach: unknown region " .. tostring(name))
        return ACCESS_NONE
    end
    return node:accessibility()
end

--- Accessibility of a region from INSIDE a rule (the apworld's event items and CanReachRegion).
--- Reads the flood-fill cache directly rather than calling CanReach(), which would re-enter the
--- rebuild; discover's fixpoint loop converges these.
---@param region string
---@return integer
function reach(region)
    local node = NAMED_NODES[region]
    if node == nil then
        print("reach: unknown region " .. tostring(region))
        return ACCESS_NONE
    end
    return node:accessibility()
end

--- Forces the accessibility cache to be considered stale so the next CanReach rebuilds it.
--- Watched on every tracker state change (bottom of this file).
function InvalidateCanReach()
    stale = true
end

--- Creates a region node and self-registers it in NAMED_NODES.
---@param name string
---@return table
function Node.new(name)
    local self = setmetatable({}, Node)
    self.name = name
    -- list of { target, rule, is_warp, er_kind, token, shuffled_rule }
    self.exits = {}
    NAMED_NODES[name] = self
    table.insert(NAMED_NODES_KEYS, name)
    return self
end

--- default rule: always traversable
---@return integer
local function always()
    return ACCESS_NORMAL
end

--- One directed WALKING edge self -> exit. Walking edges are never shuffled.
---@param exit table
---@param token string|nil  apworld entrance name; nil for structural edges that never route
---@param rule? function
function Node:connect_one_way(exit, token, rule)
    self.exits[#self.exits + 1] = { exit, rule or always, false, nil, token }
end

--- One directed WARP edge self -> exit (exit = warp_data's vanilla to.map).
--- Vanilla warps have no rule, like the apworld's unshuffled connect(). Once shuffled, the
--- apworld's PokemonRBWarp.access_rule applies: leaving an elevator needs the Lift Key when all
--- elevators are locked, and always for the Rocket Hideout elevator.
---@param exit table
---@param token string  apworld entrance name
---@param er_kind table  one of the ER_* kinds in connections.lua
function Node:connect_warp(exit, token, er_kind)
    local shuffled_rule = always
    if string.find(self.name, "Elevator", 1, true) then
        if string.find(self.name, "Rocket Hideout", 1, true) then
            shuffled_rule = function() return has("liftkey") end
        else
            shuffled_rule = elevator_unlocked
        end
    end
    WARP_SOURCE[token] = self.name
    self.exits[#self.exits + 1] = { exit, always, true, er_kind, token, shuffled_rule }
end

--- Whether a warp of this ER kind is shuffled under the current settings. Mirrors
--- door_shuffle() in regions.py (the order of the checks matters):
---   * warp tiles follow their own setting only
---   * fixed pairs (Player's House stairs, Elite Four, Safari Zone in Simple/Interiors, Fuchsia
---     <-> Safari Zone Gate in Simple) are always paired vanilla, so they are not shuffled here
---   * Simple has two quirks (Game Corner stairs on, Celadon <-> Game Corner off)
---   * otherwise exterior doors shuffle from Simple up, interior ones from Full up
---@param er table
---@return boolean
function WarpShuffled(er)
    if er.warp_tile then
        return ER_SETTINGS.warp_tiles
    end
    local mode = ER_SETTINGS.door_shuffle
    if mode == 0 then
        return false
    end
    if er.fixed and er.fixed[mode] then
        return false
    end
    if mode == 1 and er.simple ~= nil then
        return er.simple
    end
    if er.interior then
        return mode >= 3
    end
    return true
end

--- Where a shuffled warp leads: going through it, the player came out at the linked door, i.e.
--- in that door's own region (the apworld's PokemonRBWarp.connect -> entrance.parent_region).
---@param token string
---@return table  Empty_node while unlinked
function WarpDetourTarget(token)
    local linked = ER_LINKS[token]
    local region = linked and WARP_SOURCE[linked]
    return region and NAMED_NODES[region] or Empty_node
end

--- Cached accessibility for this node (ACCESS_NONE if not discovered this rebuild).
---@return integer
function Node:accessibility()
    return accessibilityCache[self] or ACCESS_NONE
end

--- Flood-fill relaxation from this node. Bellman-Ford-style fixed point driven by CanReach.
---@param accessibility integer
function Node:discover(accessibility)
    if accessibility > self:accessibility() then
        accessibilityCache[self] = accessibility
        accessibilityCacheComplete = false
    end

    if accessibility <= ACCESS_NONE then
        return
    end

    for _, exit in pairs(self.exits) do
        local target = exit[1]
        local rule = exit[2]

        if exit[3] and WarpShuffled(exit[4]) then
            -- shuffled warp: detour through the manual link (or dead-end)
            target = WarpDetourTarget(exit[5])
            rule = exit[6]
        end

        local oldAccess = target:accessibility()
        if oldAccess < accessibility then
            local access = rule()
            local parent_access = self:accessibility()
            if access == nil then
                print("Warning: " .. self.name .. " -> " .. target.name .. " rule returned nil")
                access = ACCESS_NONE
            end
            if access > parent_access then
                access = parent_access
            end
            if access > oldAccess then
                target:discover(access)
            end
        end
    end
end

-- Root of the graph and the dead-end sink for unlinked warps.
-- connections.lua hooks up the starting regions and fly spots.
Entry_point = Node.new("Entry_point")
Empty_node = Node.new("Empty_node")

ScriptHost:AddWatchForCode("InvalidateCanReach", "*", InvalidateCanReach)
