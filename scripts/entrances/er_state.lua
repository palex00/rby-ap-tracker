-- ER_LINKS[a] = b: going through a, you come out at door b.
-- Saved in a single LuaItem made at load, since PopTracker only restores into items that already exist.

ER_REVERSE = {}

local function coupled()
    return ER_SETTINGS.door_shuffle ~= 5
end

local function rebuildReverse()
    ER_REVERSE = {}
    for from, to in pairs(ER_LINKS) do
        ER_REVERSE[to] = from
    end
end

local function unlinkForward(token)
    local to = ER_LINKS[token]
    if to then
        ER_LINKS[token] = nil
        ER_REVERSE[to] = nil
    end
end

local function unlinkReverse(token)
    local from = ER_REVERSE[token]
    if from then
        ER_LINKS[from] = nil
        ER_REVERSE[token] = nil
    end
end

local function linksChanged()
    UpdateEntranceBadges()
    ER_STATE:touch()
end

function ErLink(a, b)
    if coupled() then
        unlinkForward(a)
        unlinkReverse(a)
        unlinkForward(b)
        unlinkReverse(b)
        ER_LINKS[b] = a
        ER_REVERSE[a] = b
    else
        unlinkForward(a)
        unlinkReverse(b)
    end
    ER_LINKS[a] = b
    ER_REVERSE[b] = a
    linksChanged()
end

function ErUnlink(token)
    unlinkForward(token)
    if coupled() then
        unlinkReverse(token)
    end
    linksChanged()
end

function ErClearAll()
    ER_LINKS = {}
    ER_REVERSE = {}
    linksChanged()
end

ErState = CustomItem:extend()

function ErState:init()
    self:createItem("Entrance Links", {"er_state", "er_linking_active"})
    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/options/er.png")
    self.stamp = nil
    self.pending = nil
end

function ErState:canProvideCode(code)
    return code == "er_state" or code == "er_linking_active"
end

function ErState:providesCode(code)
    if code == "er_linking_active" and self.pending then
        return 1
    end
    return 0
end

-- makes PopTracker re-evaluate logic and visibility
function ErState:touch()
    self:setProperty("rev", (self:getProperty("rev") or 0) + 1)
end

function ErState:setPending(item)
    local old = self.pending
    if old == item then
        return
    end
    self.pending = item
    if old then
        old:refreshGlow()
    end
    if item then
        item:refreshGlow()
    end
    self:touch()
end

-- links made before the first connect are kept; returns true for a different seed
function ErState:adoptSeed(stamp)
    local changed = self.stamp ~= nil and self.stamp ~= stamp
    if changed then
        self:setPending(nil)
        ErClearAll()
    end
    self.stamp = stamp
    return changed
end

function ErState:save()
    return { stamp = self.stamp, links = ER_LINKS }
end

function ErState:load(data)
    self:setPending(nil)
    self.stamp = data.stamp
    ER_LINKS = {}
    for from, to in pairs(data.links) do
        ER_LINKS[from] = to
    end
    rebuildReverse()
    linksChanged()
    -- section highlights get restored after the items, clear any left from a pending link
    ScriptHost:AddOnFrameHandler("er stale glow", function()
        ScriptHost:RemoveOnFrameHandler("er stale glow")
        for _, row in pairs(ENTRANCE_REGISTRY) do
            Tracker:FindObjectForCode(row.section).Highlight = Highlight.None
        end
    end)
    return true
end

function ErClickEntrance(item)
    local pending = ER_STATE.pending
    if pending == nil then
        StopRouting()
        ER_STATE:setPending(item)
    elseif pending == item then
        ER_STATE:setPending(nil)
    else
        ER_STATE:setPending(nil)
        ErLink(pending.token, item.token)
    end
end

ErAction = CustomItem:extend()

function ErAction:init(name, code, icon, action)
    self:createItem(name, {code})
    self.ItemInstance.Icon = ImageReference:FromPackRelativePath(icon)
    self.code = code
    self.action = action
end

function ErAction:canProvideCode(code)
    return code == self.code
end

function ErAction:onLeftClick()
    self.action()
end

local ER_CLEAR_SECONDS = 5
ErClearButton = CustomItem:extend()

function ErClearButton:init()
    self:createItem("Clear ER connections (click twice)", {"er_clear_all"})
    self.ItemInstance.Icon = ImageReference:FromPackRelativePath("images/options/er.png")
    self.ItemInstance.IconMods = "@disabled"
    self.ItemInstance.BadgeTextColor = "#ff4040"
    self.armedAt = nil
end

function ErClearButton:canProvideCode(code)
    return code == "er_clear_all"
end

function ErClearButton:disarm()
    self.armedAt = nil
    self.ItemInstance.IconMods = "@disabled"
    self.ItemInstance.BadgeText = ""
    ScriptHost:RemoveOnFrameHandler("er clear disarm")
end

function ErClearButton:onLeftClick()
    if self.armedAt then
        self:disarm()
        ER_STATE:setPending(nil)
        ErClearAll()
        return
    end
    self.armedAt = os.time()
    self.ItemInstance.IconMods = ""
    self.ItemInstance.BadgeText = "Sure?"
    ScriptHost:AddOnFrameHandler("er clear disarm", function()
        if os.time() - self.armedAt >= ER_CLEAR_SECONDS then
            self:disarm()
        end
    end)
end

function ErClearButton:onRightClick()
    self:disarm()
end

-- er_doors stage -> door_shuffle, Full also covers Insanity
local DOOR_SHUFFLE_BY_STAGE = { [0] = 0, 1, 2, 3, 5 }

function RefreshERSettings()
    ER_SETTINGS.door_shuffle = DOOR_SHUFFLE_BY_STAGE[Tracker:FindObjectForCode("er_doors").CurrentStage]
    ER_SETTINGS.warp_tiles = Tracker:ProviderCountForCode("er_warp_tiles_on") > 0
    CreateShuffledEntrances()
    UpdateEntranceBadges()
    InvalidateCanReach()
end

ER_STATE = ErState()
ER_ABORT_ITEM = ErAction("Abort ER Linking", "er_abort", "images/options/er.png", function()
    ER_STATE:setPending(nil)
end)
ER_CLEAR_LINK_ITEM = ErAction("Clear this mapping", "er_clear_link", "images/entrances/entrance_unexplored.png", function()
    local pending = ER_STATE.pending
    if pending then
        ER_STATE:setPending(nil)
        ErUnlink(pending.token)
    end
end)
ER_CLEAR_ALL_ITEM = ErClearButton()
