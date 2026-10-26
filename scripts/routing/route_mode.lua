-- Route mode: shortest path between two regions over the current graph. Every edge counts as a
-- hop, but only warps and Fly get printed.

ROUTE_TILE_COUNT = 30

local FLY_TOWNS = {
    "Pallet Town",
    "Viridian City",
    "Pewter City",
    "Cerulean City",
    "Lavender Town",
    "Vermilion City",
    "Celadon City",
    "Fuchsia City",
    "Cinnabar Island",
    "Indigo Plateau",
    "Saffron City",
}

-- the apworld's outdoor_map minus the Safari Zone, which isn't a Fly map
local FLY_MAPS = {}
for _, town in ipairs(FLY_TOWNS) do
    FLY_MAPS[town] = true
end
for i = 1, 25 do
    FLY_MAPS["Route " .. i] = true
end

local function usable(level)
    return (level or ACCESS_NONE) >= ACCESS_SEQUENCEBREAK
end

local function flyHops()
    local hops = {}
    if Tracker:ProviderCountForCode("er_no_fly_on") > 0 or not usable(fly()) then
        return hops
    end
    for _, town in ipairs(FLY_TOWNS) do
        local node = NAMED_NODES[town]
        if usable(node:accessibility()) then
            hops[#hops + 1] = { node = node, label = "Fly: " .. town }
        end
    end
    return hops
end

-- breadth-first, so the fewest hops wins; returns the printed hops, or nil
local function findPath(start, finish)
    local flights = flyHops()
    local prev = { [start] = false }
    local queue = { start }
    local head = 1
    while queue[head] and prev[finish] == nil do
        local node = queue[head]
        head = head + 1
        local steps = {}
        for _, exit in ipairs(node.exits) do
            local target, rule = exit[1], exit[2]
            if exit[3] and WarpShuffled(exit[4]) then
                target = WarpDetourTarget(exit[5])
                rule = exit[6]
            end
            if prev[target] == nil and usable(target:accessibility()) and usable(rule()) then
                if exit[3] then
                    steps[#steps + 1] = { node = target, label = ENTRANCE_REGISTRY[exit[5]].pretty, token = exit[5] }
                else
                    steps[#steps + 1] = { node = target, label = "" }
                end
            end
        end
        if FLY_MAPS[node.name:match("^[^-]*")] then
            for _, hop in ipairs(flights) do
                steps[#steps + 1] = hop
            end
        end
        for _, step in ipairs(steps) do
            if prev[step.node] == nil then
                prev[step.node] = { node = node, label = step.label, token = step.token }
                queue[#queue + 1] = step.node
            end
        end
    end
    if prev[finish] == nil then
        return nil
    end
    local hops = {}
    local node = finish
    while prev[node] do
        if prev[node].label ~= "" then
            table.insert(hops, 1, prev[node])
        end
        node = prev[node].node
    end
    return hops
end

local function writeRouteTile(index, text)
    local tile = Tracker:FindObjectForCode("solidblack" .. index)
    if not tile then
        return
    end
    tile.BadgeText = text
    tile:SetOverlayFontSize(16)
    tile.BadgeTextColor = "FFFFFFFF"
    tile:SetOverlayAlign("left")
end

local function clearRouteTiles()
    for i = 0, ROUTE_TILE_COUNT - 1 do
        writeRouteTile(i, "")
    end
end

local BLINK_ITEMS = {}

RouteAbortItem = CustomItem:extend()

function RouteAbortItem:init()
    self:createItem("", {"route_abort"})
    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/other/blank.png")
    self:show(false)
end

function RouteAbortItem:canProvideCode(code)
    return code == "route_abort"
end

function RouteAbortItem:show(active)
    local inst = self.ItemInstance
    inst.Name = active and "Abort Routing" or ""
    inst.BadgeText = active and "Abort Routing" or ""
    inst:SetOverlayFontSize(16)
    inst.BadgeTextColor = "#FFD700"
    inst:SetOverlayAlign("left")
end

function RouteAbortItem:onLeftClick()
    if #BLINK_ITEMS > 0 then
        StopRouting()
    end
end

ROUTE_ABORT_ITEM = RouteAbortItem()

-- the route's entrances alternate gold/red every second until aborted or ROUTE_BLINK_SECONDS pass
local ROUTE_BLINK_SECONDS = 300
local ROUTE_BLINK_HANDLER = "route blink handler"
local BLINK_ELAPSED = 0
local BLINK_TICK = 0
local BLINK_GOLD = true

local function setBlinkColor()
    local highlight = BLINK_GOLD and Highlight.Priority or Highlight.Avoid
    for _, item in ipairs(BLINK_ITEMS) do
        item.routeGlow = highlight
        item:refreshGlow()
    end
end

function StopRouting()
    ScriptHost:RemoveOnFrameHandler(ROUTE_BLINK_HANDLER)
    local items = BLINK_ITEMS
    BLINK_ITEMS = {}
    for _, item in ipairs(items) do
        item.routeGlow = nil
        item:refreshGlow()
    end
    clearRouteTiles()
    ROUTE_ABORT_ITEM:show(false)
end

local function routeBlinkFrame(elapsed)
    BLINK_ELAPSED = BLINK_ELAPSED + elapsed
    if BLINK_ELAPSED >= ROUTE_BLINK_SECONDS then
        StopRouting()
        return
    end
    BLINK_TICK = BLINK_TICK + elapsed
    if BLINK_TICK >= 1 then
        BLINK_TICK = BLINK_TICK - 1
        BLINK_GOLD = not BLINK_GOLD
        setBlinkColor()
    end
end

-- only entrances that have a square right now; vanilla warps have none
local function startRouteBlink(hops)
    for _, hop in ipairs(hops) do
        local item = hop.token and ENTRANCE_ITEMS[hop.token]
        if item and er_shown(hop.token) then
            BLINK_ITEMS[#BLINK_ITEMS + 1] = item
        end
    end
    if #BLINK_ITEMS == 0 then
        return
    end
    BLINK_ELAPSED = 0
    BLINK_TICK = 0
    BLINK_GOLD = true
    setBlinkColor()
    ROUTE_ABORT_ITEM:show(true)
    ScriptHost:AddOnFrameHandler(ROUTE_BLINK_HANDLER, routeBlinkFrame)
end

-- start_tab: tab chain of where the route starts, shown once the route is written
function GetRoute(start, finish, start_tab)
    if start == nil or finish == nil then
        return
    end
    StopRouting()
    CanReach("Entry_point")
    local hops = findPath(start, finish)
    if hops == nil then
        writeRouteTile(0, "No Route Found")
    elseif start == finish then
        writeRouteTile(0, "Already There")
    elseif #hops == 0 then
        writeRouteTile(0, "Just walk there")
    else
        for i, hop in ipairs(hops) do
            if i == ROUTE_TILE_COUNT and #hops > ROUTE_TILE_COUNT then
                writeRouteTile(i - 1, "... " .. (#hops - i + 1) .. " more")
                break
            end
            writeRouteTile(i - 1, hop.label)
        end
        startRouteBlink(hops)
    end
    Tracker:UiHint("ActivateTab", "Routing")
    for _, tab in ipairs(start_tab or {}) do
        Tracker:UiHint("ActivateTab", tab)
    end
end
