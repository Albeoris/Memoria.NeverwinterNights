// Shared localization dispatch helpers for Memoria mods.

/// @brief Resolves and caches a player's supported language, using a script probe to distinguish Russian installations.
/// @param oPlayer Player whose language is resolved and cached.
/// @param sLanguageLocal Name of the local string used for the cached language code.
/// @param sRussianProbeScript Script that sets the Russian detection result.
/// @param sRussianResultLocal Name of the local integer written by the Russian probe script.
/// @return Cached or detected language code: ru, fr, de, it, es, or en.
string MEMORIA_GetLanguage(object oPlayer, string sLanguageLocal, string sRussianProbeScript, string sRussianResultLocal)
{
    string sResult = GetLocalString(oPlayer, sLanguageLocal);
    if (sResult != "") return sResult;
    DeleteLocalInt(oPlayer, sRussianResultLocal);
    ExecuteScript(sRussianProbeScript, oPlayer);
    if (GetLocalInt(oPlayer, sRussianResultLocal))
        sResult = "ru";
    else if (GetPlayerLanguage(oPlayer) == PLAYER_LANGUAGE_FRENCH)
        sResult = "fr";
    else if (GetPlayerLanguage(oPlayer) == PLAYER_LANGUAGE_GERMAN)
        sResult = "de";
    else if (GetPlayerLanguage(oPlayer) == PLAYER_LANGUAGE_ITALIAN)
        sResult = "it";
    else if (GetPlayerLanguage(oPlayer) == PLAYER_LANGUAGE_SPANISH)
        sResult = "es";
    else
        sResult = "en";
    SetLocalString(oPlayer, sLanguageLocal, sResult);
    return sResult;
}
