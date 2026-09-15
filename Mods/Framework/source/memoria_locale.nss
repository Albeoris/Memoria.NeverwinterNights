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

/// @brief Executes a language-specific text script and retrieves the localized text it writes to the player.
/// @param iKey Numeric text key passed to the localization script.
/// @param oPlayer Player used as the script target and result-local owner.
/// @param sLang Language suffix appended to the text script prefix.
/// @param sTextScriptPrefix Prefix of the language-specific text script resource.
/// @param sTextResultLocal Name of the local string containing the script result.
/// @param sTextKeyParam Name of the script parameter that receives iKey.
/// @return Localized text written by the executed script, or an empty string when no result is written.
string MEMORIA_GetText(int iKey, object oPlayer, string sLang, string sTextScriptPrefix, string sTextResultLocal, string sTextKeyParam)
{
    DeleteLocalString(oPlayer, sTextResultLocal);
    SetScriptParam(sTextKeyParam, IntToString(iKey));
    ExecuteScript(sTextScriptPrefix + sLang, oPlayer);
    return GetLocalString(oPlayer, sTextResultLocal);
}
