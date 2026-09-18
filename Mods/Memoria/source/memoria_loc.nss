// Shared localization table loader for Memoria mods.
// Each mod authors one UTF-8 JSON resource per language named
// "<prefix>_loc_<language>.resjson". The build emits it in the matching
// game-local encoding as "<prefix>_loc_<language>.txt" (RESTYPE_TXT),
// mapping short, self-documenting keys to that language's text.
// Tables are parsed once per session and cached in transient NUI user data, since
// module locals persist in save games and would retain obsolete localization files.
// Note: the parameter is named sLang, not sLanguage, because nwscript.nss already
// declares a global string variable called sLanguage.

#include "nw_inc_nui"

const string MEMORIA_LOC_CACHE_OWNER_LOCAL = "MEMORIA_LOC_CACHE_OWNER";
const string MEMORIA_LOC_CACHE_WINDOW = "memoria_loc_cache";

string MEMORIA_LOC_GetResRef(string sPrefix, string sLang)
{
    return sPrefix + "_loc_" + sLang;
}

json MEMORIA_LOC_LoadTable(string sPrefix, string sLang)
{
    string sResRef = MEMORIA_LOC_GetResRef(sPrefix, sLang);
    if (ResManGetAliasFor(sResRef, RESTYPE_TXT) == "") sResRef = MEMORIA_LOC_GetResRef(sPrefix, "en");
    if (ResManGetAliasFor(sResRef, RESTYPE_TXT) == "") return JsonObject();
    json jTable = JsonParse(ResManGetFileContents(sResRef, RESTYPE_TXT));
    if (JsonGetType(jTable) != JSON_TYPE_OBJECT) return JsonObject();
    return jTable;
}

/// @brief Returns a mod's localization table for one language, loading and caching it on the module once per session.
/// @param sPrefix Mod resource prefix, e.g. "mecm". Must match the "<prefix>_loc_<language>.txt" resources shipped by that mod.
/// @param sLang Language code (en, ru, fr, de, it, es). Falls back to "en" when the requested language table is missing.
/// @return A JSON object mapping keys to localized text; empty JSON object when no table could be loaded.
json MEMORIA_LOC_GetTable(string sPrefix, string sLang)
{
    object oModule = GetModule();
    string sCacheKey = sPrefix + "_" + sLang;
    DeleteLocalJson(oModule, "MEMORIA_LOC_" + sCacheKey);
    object oCacheOwner = GetLocalObject(oModule, MEMORIA_LOC_CACHE_OWNER_LOCAL);
    int nToken = GetIsObjectValid(oCacheOwner) ? NuiFindWindow(oCacheOwner, MEMORIA_LOC_CACHE_WINDOW) : 0;
    json jTables = nToken > 0 ? NuiGetUserData(oCacheOwner, nToken) : JsonNull();
    json jTable = JsonObjectGet(jTables, sCacheKey);
    if (JsonGetType(jTable) == JSON_TYPE_OBJECT) return jTable;

    jTable = MEMORIA_LOC_LoadTable(sPrefix, sLang);
    if (nToken <= 0)
    {
        oCacheOwner = GetFirstPC();
        if (!GetIsObjectValid(oCacheOwner)) return jTable;
        json jWindow = NuiWindow(NuiVisible(NuiSpacer(), JsonBool(FALSE)), JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
        nToken = NuiCreate(oCacheOwner, jWindow, MEMORIA_LOC_CACHE_WINDOW, "memoria_noop");
        jTables = JsonObject();
        if (nToken > 0) SetLocalObject(oModule, MEMORIA_LOC_CACHE_OWNER_LOCAL, oCacheOwner);
    }
    if (nToken > 0)
    {
        if (JsonGetType(jTables) != JSON_TYPE_OBJECT) jTables = JsonObject();
        NuiSetUserData(oCacheOwner, nToken, JsonObjectSet(jTables, sCacheKey, jTable));
    }
    return jTable;
}

/// @brief Looks up one localized string in a mod's table.
/// @param sPrefix Mod resource prefix, e.g. "mecm".
/// @param sLang Language code of the player the text is shown to.
/// @param sKey Self-documenting key as defined in the mod's "<prefix>_loc_<language>.txt" resources.
/// @return The localized text, or an empty string when the key is not present in the table.
string MEMORIA_LOC_GetText(string sPrefix, string sLang, string sKey)
{
    return JsonGetString(JsonObjectGet(MEMORIA_LOC_GetTable(sPrefix, sLang), sKey));
}
