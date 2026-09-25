// Shared feat helpers for Memoria mods.

/// @brief Returns the localized display name of a feat.
/// @param iFeat FEAT_* value to inspect.
/// @return The localized feat name, or an empty string when the feat row or name is unavailable.
string MEMORIA_GetFeatName(int iFeat)
{
    if (iFeat < 0) return "";
    string sNameStrRef = Get2DAString("feat", "FEAT", iFeat);
    if (sNameStrRef == "" || sNameStrRef == "****") return "";
    return GetStringByStrRef(StringToInt(sNameStrRef));
}

// Parry is skill-driven, while Defensive Stance is a COMBAT_MODE_* value rather than an ACTION_MODE_* state.
/// @brief Maps a persistent combat-mode feat to the corresponding NWN action mode.
/// @param iFeat FEAT_* value to inspect.
/// @return The matching ACTION_MODE_* value, or -1 when the feat is not represented by a persistent action mode.
int MEMORIA_GetFeatActionMode(int iFeat)
{
    switch (iFeat)
    {
        case FEAT_POWER_ATTACK:
            return ACTION_MODE_POWER_ATTACK;
        case FEAT_IMPROVED_POWER_ATTACK:
            return ACTION_MODE_IMPROVED_POWER_ATTACK;
        case FEAT_FLURRY_OF_BLOWS:
            return ACTION_MODE_FLURRY_OF_BLOWS;
        case FEAT_RAPID_SHOT:
            return ACTION_MODE_RAPID_SHOT;
        case FEAT_EXPERTISE:
            return ACTION_MODE_EXPERTISE;
        case FEAT_IMPROVED_EXPERTISE:
            return ACTION_MODE_IMPROVED_EXPERTISE;
        case FEAT_DIRTY_FIGHTING:
            return ACTION_MODE_DIRTY_FIGHTING;
    }
    return -1;
}

/// @brief Determines whether feat.2da marks a feat as self-targeting.
/// @param iFeat FEAT_* value to inspect.
/// @return TRUE when the feat is valid and its TARGETSELF value is 1; otherwise FALSE.
int MEMORIA_IsFeatTargetSelf(int iFeat)
{
    return iFeat >= 0 && Get2DAString("feat", "TARGETSELF", iFeat) == "1";
}
