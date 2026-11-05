HOSTED_ITEMS =
{
    "EVENT_BEAT_BROCK",
    "EVENT_BEAT_MISTY",
    "EVENT_BEAT_LT_SURGE",
    "EVENT_BEAT_ERIKA",
    "EVENT_BEAT_KOGA",
    "EVENT_BEAT_SABRINA",
    "EVENT_BEAT_BLAINE",
    "EVENT_BEAT_VIRIDIAN_GYM_GIOVANNI",
    "EVENT_OAK_GOT_PARCEL",
    "EVENT_BEAT_ROUTE22_RIVAL_1ST_BATTLE",
    "EVENT_RESCUED_MR_FUJI",
    "EVENT_GOT_SS_TICKET",
    "EVENT_BEAT_SILPH_CO_GIOVANNI",
    "EVENT_BEAT_CHAMPION_RIVAL",
    "leafstone",
    "thunderstone",
    "waterstone",
    "firestone"
}

function initialize_watch_items()
    for _, code in pairs(HOSTED_ITEMS) do
        ScriptHost:AddWatchForCode(code.."_hostsync", code, toggle_item)
        ScriptHost:AddWatchForCode(code.."_hosted", code.."_hosted", toggle_hosted_item)
    end
end
