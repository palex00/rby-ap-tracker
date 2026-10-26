-- Links are kept in er_state.lua, not on the items: an item only exists while its warp is shuffled.

ENTRANCE_CLOSED_ICON = "images/entrances/entrance_unexplored.png"
ENTRANCE_OPEN_ICON = "images/entrances/entrance_explored.png"

-- PopTracker right-aligns the lines of a multi-line overlay, so both lines get padded to the same
-- pixel width. Widths are DejaVuSans-Bold at size 10.
local BADGE_PAD_3 = " "
local BADGE_PAD_2 = "\226\128\137" -- thin space
local BADGE_PAD_1 = "\226\128\138" -- hair space
local BADGE_INDENT = string.rep(BADGE_PAD_3, 12) -- clear of the icon
local BADGE_CHAR_W = {}
do
    local function w(width, chars)
        for ch in chars:gmatch(".") do
            BADGE_CHAR_W[ch] = width
        end
    end
    w(3, " 'ijl")
    w(4, "-.IJf")
    w(5, "()rt")
    w(6, "Lcsxz")
    w(7, "0123456789CEFPSTYZabdeghknopquvy")
    w(8, "ABDGHKNRUVX")
    w(9, "&OQw")
    w(10, "Mm")
    w(11, "W")
end

local function badgeWidth(name)
    local total = 0
    for i = 1, #name do
        total = total + BADGE_CHAR_W[name:sub(i, i)]
    end
    return total
end

local function padBadgePair(a, b)
    local diff = badgeWidth(a) - badgeWidth(b)
    local n = diff < 0 and -diff or diff
    local pad = string.rep(BADGE_PAD_3, math.floor(n / 3))
    local rest = n % 3
    if rest == 2 then
        pad = pad .. BADGE_PAD_2
    elseif rest == 1 then
        pad = pad .. BADGE_PAD_1
    end
    if diff < 0 then
        return a .. pad, b
    end
    return a, b .. pad
end

EntranceItem = CustomItem:extend()

function EntranceItem:init(token, row)
    self:createItem(row.pretty, {token})
    self.token = token
    self.row = row
    self.node = WARP_SOURCE[token]
    self:updateBadge()
end

function EntranceItem:updateBadge()
    local inst = self.ItemInstance
    local forward = ER_LINKS[self.token]
    local reverse = ER_REVERSE[self.token]
    local fwd = forward and ENTRANCE_REGISTRY[forward]
    local rev = reverse and ENTRANCE_REGISTRY[reverse]
    local ARROW_FWD = "\226\134\146"
    local ARROW_REV = "\226\134\144"
    local ARROW_BOTH = "\226\134\148"
    local text = ""
    if fwd and rev then
        if forward == reverse then
            text = BADGE_INDENT .. ARROW_BOTH .. fwd.pretty
        else
            local f, r = padBadgePair(fwd.pretty, rev.pretty)
            text = BADGE_INDENT .. ARROW_FWD .. f .. "\n" .. BADGE_INDENT .. ARROW_REV .. r
        end
    elseif fwd then
        text = BADGE_INDENT .. ARROW_FWD .. fwd.pretty
    elseif rev then
        text = BADGE_INDENT .. ARROW_REV .. rev.pretty
    end
    inst.BadgeText = text
    inst.BadgeTextColor = "#abcdef"
    inst:SetOverlayBackground("") -- would cover the icon
    inst:SetOverlayFontSize(10)
    inst:SetOverlayAlign("left")
    if self:isLinked() then
        inst.Icon = ImageReference:FromPackRelativePath(ENTRANCE_OPEN_ICON)
    else
        inst.Icon = ImageReference:FromPackRelativePath(ENTRANCE_CLOSED_ICON)
    end
end

-- only the forward side counts, in decoupled the reverse says nothing about this door
function EntranceItem:isLinked()
    return ER_LINKS[self.token] ~= nil
end

local NAV_TARGET = nil

-- middle-click target, then pending link, then route blink
-- highlights only draw on sections that aren't done, so a glowing entrance reports as unlinked
function EntranceItem:refreshGlow()
    local highlight = self.routeGlow or Highlight.None
    if NAV_TARGET == self then
        highlight = Highlight.Avoid
    elseif ER_STATE.pending == self then
        highlight = Highlight.NoPriority
    end
    Tracker:FindObjectForCode(self.row.section).Highlight = highlight
    self:setProperty("glow", highlight ~= Highlight.None)
end

function EntranceItem:providesCode(code)
    if code == self.token and self:isLinked() and not self:getProperty("glow") then
        return 1
    end
    return 0
end

function EntranceItem:canProvideCode(code)
    return code == self.token
end

function EntranceItem:onLeftClick()
    ErClickEntrance(self)
end

-- same entrance twice routes from Pallet Town
ROUTE_START_ITEM = nil
local PALLET_TAB = {"Cities", "Pallet Town", "Town"}

function EntranceItem:onRightClick()
    if ROUTE_START_ITEM == nil then
        StopRouting()
        ROUTE_START_ITEM = self
        return
    end
    if ROUTE_START_ITEM == self then
        GetRoute(NAMED_NODES["Pallet Town"], NAMED_NODES[self.node], PALLET_TAB)
    else
        GetRoute(NAMED_NODES[ROUTE_START_ITEM.node], NAMED_NODES[self.node], ROUTE_START_ITEM.row.tab)
    end
    ROUTE_START_ITEM = nil
end

local NAV_TIME = 0
local NAV_SECONDS = 5

function RemoveEntranceHighlight()
    if os.time() - NAV_TIME < NAV_SECONDS then
        return
    end
    ScriptHost:RemoveOnFrameHandler("entrance highlight handler")
    local old = NAV_TARGET
    NAV_TARGET = nil
    if old then
        old:refreshGlow()
    end
end

function EntranceItem:onMiddleClick()
    local reverse = ER_REVERSE[self.token]
    if not reverse then
        return
    end
    for _, tab in ipairs(ENTRANCE_REGISTRY[reverse].tab) do
        Tracker:UiHint("ActivateTab", tab)
    end
    -- link left over from other settings
    local target = ENTRANCE_ITEMS[reverse]
    if not target then
        return
    end
    local old = NAV_TARGET
    NAV_TARGET = target
    if old and old ~= target then
        old:refreshGlow()
    end
    target:refreshGlow()
    NAV_TIME = os.time()
    ScriptHost:AddOnFrameHandler("entrance highlight handler", RemoveEntranceHighlight)
end

ENTRANCE_KIND = {}
function BuildEntranceKinds()
    for _, name in ipairs(NAMED_NODES_KEYS) do
        for _, exit in ipairs(NAMED_NODES[name].exits) do
            if exit[3] then
                ENTRANCE_KIND[exit[5]] = exit[4]
            end
        end
    end
end

function er_shown(token)
    return WarpShuffled(ENTRANCE_KIND[token])
end

-- PopTracker can't remove items, so this only adds
ENTRANCE_ITEMS = {}
function CreateShuffledEntrances()
    for token, row in pairs(ENTRANCE_REGISTRY) do
        if not ENTRANCE_ITEMS[token] and WarpShuffled(ENTRANCE_KIND[token]) then
            ENTRANCE_ITEMS[token] = EntranceItem(token, row)
        end
    end
end

function UpdateEntranceBadges()
    for _, item in pairs(ENTRANCE_ITEMS) do
        item:updateBadge()
    end
end
