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

-- breadth-first, so the fewest hops wins; returns the labels of the hops taken, or nil
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
                steps[#steps + 1] = { node = target, label = exit[3] and ENTRANCE_REGISTRY[exit[5]].pretty or "" }
            end
        end
        if FLY_MAPS[node.name:match("^[^-]*")] then
            for _, hop in ipairs(flights) do
                steps[#steps + 1] = hop
            end
        end
        for _, step in ipairs(steps) do
            if prev[step.node] == nil then
                prev[step.node] = { node = node, label = step.label }
                queue[#queue + 1] = step.node
            end
        end
    end
    if prev[finish] == nil then
        return nil
    end
    local labels = {}
    local node = finish
    while prev[node] do
        if prev[node].label ~= "" then
            table.insert(labels, 1, prev[node].label)
        end
        node = prev[node].node
    end
    return labels
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

function GetRoute(start, finish)
    if start == nil or finish == nil then
        return
    end
    CanReach("Entry_point")
    for i = 0, ROUTE_TILE_COUNT - 1 do
        writeRouteTile(i, "")
    end
    local labels = findPath(start, finish)
    if labels == nil then
        writeRouteTile(0, "No Route Found")
    elseif start == finish then
        writeRouteTile(0, "Already There")
    elseif #labels == 0 then
        writeRouteTile(0, "Just walk there")
    else
        for i, label in ipairs(labels) do
            if i == ROUTE_TILE_COUNT and #labels > ROUTE_TILE_COUNT then
                writeRouteTile(i - 1, "... " .. (#labels - i + 1) .. " more")
                break
            end
            writeRouteTile(i - 1, label)
        end
    end
    Tracker:UiHint("ActivateTab", "Routing")
end
