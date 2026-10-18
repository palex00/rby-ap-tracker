-- Accessibility helpers for the CanReach region graph.
-- Ported from the Crystal pack (itself trimmed from the ALTTP AP pack).
-- Used by the CanReach engine and the region graph (connections.lua).

ACCESS_NONE = AccessibilityLevel.None                   -- 0  unreachable
ACCESS_SEQUENCEBREAK = AccessibilityLevel.SequenceBreak -- 5  reachable out of logic
ACCESS_NORMAL = AccessibilityLevel.Normal               -- 6  reachable in logic

---AND: returns the MINIMUM accessibility over all arguments (short-circuits on NONE).
---Arguments are levels or functions returning one (called with no arguments).
---@param ... integer|function
---@return integer
function ALL(...)
    local min = ACCESS_NORMAL
    for _, v in ipairs({ ... }) do
        if type(v) == "function" then
            v = v()
        end
        if v < min then
            if v == ACCESS_NONE then
                return ACCESS_NONE
            end
            min = v
        end
    end
    return min
end

---OR: returns the MAXIMUM accessibility over all arguments (short-circuits on NORMAL).
---Arguments are levels or functions returning one (called with no arguments).
---@param ... integer|function
---@return integer
function ANY(...)
    local max = ACCESS_NONE
    for _, v in ipairs({ ... }) do
        if type(v) == "function" then
            v = v()
        end
        if v > max then
            if v == ACCESS_NORMAL then
                return ACCESS_NORMAL
            end
            max = v
        end
    end
    return max
end
