// Shared localization table loader for Memoria mods.
// Each mod authors one UTF-8 JSON resource per language named
// "<prefix>_loc_<language>.resjson". The build emits it in the matching
// game-local encoding as "<prefix>_loc_<language>.txt" (RESTYPE_TXT),
// mapping short, self-documenting keys to that language's text.
// Tables are parsed once per module load and cached on the module, since the same
// mod+language table is identical for every player.
// Note: the parameter is named sLang, not sLanguage, because nwscript.nss already
// declares a global string variable called sLanguage.

string MEMORIA_I18N_GetResRef(string sPrefix, string sLang)
{
    return sPrefix + "_loc_" + sLang;
}

json MEMORIA_I18N_LoadTable(string sPrefix, string sLang)
{
    string sResRef = MEMORIA_I18N_GetResRef(sPrefix, sLang);
    if (ResManGetAliasFor(sResRef, RESTYPE_TXT) == "") sResRef = MEMORIA_I18N_GetResRef(sPrefix, "en");
    if (ResManGetAliasFor(sResRef, RESTYPE_TXT) == "") return JsonObject();
    json jTable = JsonParse(ResManGetFileContents(sResRef, RESTYPE_TXT));
    if (JsonGetType(jTable) != JSON_TYPE_OBJECT) return JsonObject();
    return jTable;
}

/// @brief Returns a mod's localization table for one language, loading and caching it on the module once per session.
/// @param sPrefix Mod resource prefix, e.g. "mecalm". Must match the "<prefix>_loc_<language>.txt" resources shipped by that mod.
/// @param sLang Language code (en, ru, fr, de, it, es). Falls back to "en" when the requested language table is missing.
/// @return A JSON object mapping keys to localized text; empty JSON object when no table could be loaded.
json MEMORIA_I18N_GetTable(string sPrefix, string sLang)
{
    object oModule = GetModule();
    string sCacheLocal = "MEMORIA_I18N_" + sPrefix + "_" + sLang;
    json jTable = GetLocalJson(oModule, sCacheLocal);
    if (JsonGetType(jTable) == JSON_TYPE_OBJECT) return jTable;

    jTable = MEMORIA_I18N_LoadTable(sPrefix, sLang);
    SetLocalJson(oModule, sCacheLocal, jTable);
    return jTable;
}

/// @brief Looks up one localized string in a mod's table.
/// @param sPrefix Mod resource prefix, e.g. "mecalm".
/// @param sLang Language code of the player the text is shown to.
/// @param sKey Self-documenting key as defined in the mod's "<prefix>_loc_<language>.txt" resources.
/// @return The localized text, or an empty string when the key is not present in the table.
string MEMORIA_I18N_GetText(string sPrefix, string sLang, string sKey)
{
    return JsonGetString(JsonObjectGet(MEMORIA_I18N_GetTable(sPrefix, sLang), sKey));
}
