// Shared localization dispatch helpers for Memoria mods.

const string MEMORIA_RUSSIAN_PROBE_SCRIPT = "memoria_is_ru";
const string MEMORIA_RUSSIAN_PROBE_LOCAL = "MEMORIA_LANGUAGE_IS_RUSSIAN";

/// @brief Detects and returns the player's current language.
/// @param oPlayer Player whose language is requested.
/// @param sLanguageLocal Legacy parameter retained for source compatibility; no language value is cached.
/// @return Current language code: ru, fr, de, it, es, or en.
string MEMORIA_GetLanguage(object oPlayer, string sLanguageLocal)
{
    DeleteLocalInt(oPlayer, MEMORIA_RUSSIAN_PROBE_LOCAL);
    DeleteLocalString(oPlayer, "MEMORIA_LANGUAGE");
    ExecuteScript(MEMORIA_RUSSIAN_PROBE_SCRIPT, oPlayer);
    string sResult = GetLocalString(oPlayer, "MEMORIA_LANGUAGE");
    DeleteLocalInt(oPlayer, MEMORIA_RUSSIAN_PROBE_LOCAL);
    DeleteLocalString(oPlayer, "MEMORIA_LANGUAGE");
    if (sResult == "") sResult = "en";
    return sResult;
}
