// Shared localization dispatch helpers for Memoria mods.

const string MEMORIA_RUSSIAN_PROBE_SCRIPT = "memoria_is_ru";
const string MEMORIA_RUSSIAN_PROBE_LOCAL = "MEMORIA_LANGUAGE_IS_RUSSIAN";

/// @brief Resolves and caches a player's supported language.
/// @param oPlayer Player whose language is resolved and cached.
/// @param sLanguageLocal Name of the local string used for the cached language code.
/// @return Cached or detected language code: ru, fr, de, it, es, or en.
string MEMORIA_GetLanguage(object oPlayer, string sLanguageLocal)
{
    string sResult = GetLocalString(oPlayer, sLanguageLocal);
    if (sResult != "") return sResult;
    DeleteLocalInt(oPlayer, MEMORIA_RUSSIAN_PROBE_LOCAL);
    ExecuteScript(MEMORIA_RUSSIAN_PROBE_SCRIPT, oPlayer);
    if (GetLocalInt(oPlayer, MEMORIA_RUSSIAN_PROBE_LOCAL))
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
