// Shared NUI help behavior for Memoria-owned windows.

#include "nw_inc_nui"

const string MEMORIA_NUI_HELP_PROPERTY = "_memoria_help";
const string MEMORIA_NUI_HELP_BUILD_LOCAL = "MEMORIA_NUI_HELP_BUILD";
const string MEMORIA_NUI_HELP_ELEMENT_PREFIX = "memoria_help_";
const string MEMORIA_NUI_HELP_CACHE_WINDOW = "memoria_help_cache";
const string MEMORIA_NUI_HELP_WINDOW = "memoria_help";

/// @brief Marks an element as having contextual help opened with the right mouse button.
/// @param jElement NUI element or layout to annotate.
/// @param jHelp Static JsonString or NuiBind resolving to the help text.
/// @return The annotated element. Use MEMORIA_NUI_Create to create the containing window.
json MEMORIA_NUI_Help(json jElement, json jHelp)
{
    return JsonObjectSet(jElement, MEMORIA_NUI_HELP_PROPERTY, jHelp);
}

json MEMORIA_NUI_PrepareHelpValue(object oPlayer, json jValue)
{
    int nType = JsonGetType(jValue);
    if (nType == JSON_TYPE_ARRAY)
    {
        int nIndex;
        for (nIndex = 0; nIndex < JsonGetLength(jValue); nIndex++)
            jValue = JsonArraySet(jValue, nIndex, MEMORIA_NUI_PrepareHelpValue(oPlayer, JsonArrayGet(jValue, nIndex)));
        return jValue;
    }
    if (nType != JSON_TYPE_OBJECT)
        return jValue;

    json jHelp = JsonObjectGet(jValue, MEMORIA_NUI_HELP_PROPERTY);
    if (JsonGetType(jHelp) != JSON_TYPE_NULL)
    {
        json jRegistry = GetLocalJson(oPlayer, MEMORIA_NUI_HELP_BUILD_LOCAL);
        if (JsonGetType(jRegistry) != JSON_TYPE_OBJECT) jRegistry = JsonObject();
        string sElement = JsonGetString(JsonObjectGet(jValue, "id"));
        if (sElement == "")
        {
            int nCandidate = JsonGetLength(jRegistry);
            sElement = MEMORIA_NUI_HELP_ELEMENT_PREFIX + IntToString(nCandidate);
            while (JsonGetType(JsonObjectGet(jRegistry, sElement)) != JSON_TYPE_NULL)
            {
                nCandidate++;
                sElement = MEMORIA_NUI_HELP_ELEMENT_PREFIX + IntToString(nCandidate);
            }
            jValue = JsonObjectSet(jValue, "id", JsonString(sElement));
        }
        jRegistry = JsonObjectSet(jRegistry, sElement, jHelp);
        SetLocalJson(oPlayer, MEMORIA_NUI_HELP_BUILD_LOCAL, jRegistry);
        jValue = JsonObjectDel(jValue, MEMORIA_NUI_HELP_PROPERTY);
    }

    json jKeys = JsonObjectKeys(jValue);
    int nKey;
    for (nKey = 0; nKey < JsonGetLength(jKeys); nKey++)
    {
        string sKey = JsonGetString(JsonArrayGet(jKeys, nKey));
        jValue = JsonObjectSet(jValue, sKey, MEMORIA_NUI_PrepareHelpValue(oPlayer, JsonObjectGet(jValue, sKey)));
    }
    return jValue;
}

int MEMORIA_NUI_GetHelpCacheToken(object oPlayer)
{
    int nToken = NuiFindWindow(oPlayer, MEMORIA_NUI_HELP_CACHE_WINDOW);
    if (nToken > 0) return nToken;
    json jWindow = NuiWindow(NuiVisible(NuiSpacer(), JsonBool(FALSE)), JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
    nToken = NuiCreate(oPlayer, jWindow, MEMORIA_NUI_HELP_CACHE_WINDOW, "memoria_noop");
    if (nToken > 0) NuiSetUserData(oPlayer, nToken, JsonObject());
    return nToken;
}

void MEMORIA_NUI_SetHelpRegistry(object oPlayer, int nWindowToken, json jRegistry)
{
    int nCacheToken = MEMORIA_NUI_GetHelpCacheToken(oPlayer);
    if (nCacheToken <= 0) return;
    json jRegistries = NuiGetUserData(oPlayer, nCacheToken);
    if (JsonGetType(jRegistries) != JSON_TYPE_OBJECT) jRegistries = JsonObject();
    NuiSetUserData(oPlayer, nCacheToken, JsonObjectSet(jRegistries, IntToString(nWindowToken), jRegistry));
}

json MEMORIA_NUI_GetHelpRegistry(object oPlayer, int nWindowToken)
{
    int nCacheToken = NuiFindWindow(oPlayer, MEMORIA_NUI_HELP_CACHE_WINDOW);
    if (nCacheToken <= 0) return JsonNull();
    return JsonObjectGet(NuiGetUserData(oPlayer, nCacheToken), IntToString(nWindowToken));
}

void MEMORIA_NUI_DeleteHelpRegistry(object oPlayer, int nWindowToken)
{
    int nCacheToken = NuiFindWindow(oPlayer, MEMORIA_NUI_HELP_CACHE_WINDOW);
    if (nCacheToken <= 0) return;
    json jRegistries = NuiGetUserData(oPlayer, nCacheToken);
    if (JsonGetType(jRegistries) != JSON_TYPE_OBJECT) return;
    NuiSetUserData(oPlayer, nCacheToken, JsonObjectDel(jRegistries, IntToString(nWindowToken)));
}

/// @brief Creates a Memoria-owned window and registers every MEMORIA_NUI_Help element for shared right-click handling.
int MEMORIA_NUI_Create(object oPlayer, json jNui, string sWindowId = "", string sEventScript = "")
{
    DeleteLocalJson(oPlayer, MEMORIA_NUI_HELP_BUILD_LOCAL);
    jNui = MEMORIA_NUI_PrepareHelpValue(oPlayer, jNui);
    json jRegistry = GetLocalJson(oPlayer, MEMORIA_NUI_HELP_BUILD_LOCAL);
    DeleteLocalJson(oPlayer, MEMORIA_NUI_HELP_BUILD_LOCAL);
    int nToken = NuiCreate(oPlayer, jNui, sWindowId, sEventScript);
    if (nToken > 0 && JsonGetType(jRegistry) == JSON_TYPE_OBJECT)
        MEMORIA_NUI_SetHelpRegistry(oPlayer, nToken, jRegistry);
    return nToken;
}

json MEMORIA_NUI_BuildHelpWindow(string sText)
{
    json jRoot = JsonArray();
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiText(JsonString(sText), TRUE, NUI_SCROLLBARS_AUTO), 160.0f));
    return NuiWindow(NuiCol(jRoot), JsonString("?"), NuiRect(-3.0f, -3.0f, 420.0f, 224.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void MEMORIA_NUI_ShowHelp(object oPlayer, string sText)
{
    int nOldToken = NuiFindWindow(oPlayer, MEMORIA_NUI_HELP_WINDOW);
    if (nOldToken > 0) NuiDestroy(oPlayer, nOldToken);
    NuiCreate(oPlayer, MEMORIA_NUI_BuildHelpWindow(sText), MEMORIA_NUI_HELP_WINDOW, "memoria_noop");
}

string MEMORIA_NUI_ResolveHelp(object oPlayer, int nToken, json jHelp)
{
    if (JsonGetType(jHelp) == JSON_TYPE_STRING) return JsonGetString(jHelp);
    if (JsonGetType(jHelp) != JSON_TYPE_OBJECT) return "";
    string sBind = JsonGetString(JsonObjectGet(jHelp, "bind"));
    if (sBind == "") return "";
    json jValue = NuiGetBind(oPlayer, nToken, sBind);
    int nIndex = NuiGetEventArrayIndex();
    if (JsonGetType(jValue) == JSON_TYPE_ARRAY && nIndex >= 0 && nIndex < JsonGetLength(jValue))
        jValue = JsonArrayGet(jValue, nIndex);
    return JsonGetType(jValue) == JSON_TYPE_STRING ? JsonGetString(jValue) : "";
}

/// @brief Handles shared right-click help for the current NUI event.
/// @return TRUE when the current event was a right-click on a registered help element.
int MEMORIA_NUI_HandleHelpEvent()
{
    object oPlayer = NuiGetEventPlayer();
    int nToken = NuiGetEventWindow();
    if (NuiGetEventType() == "close")
    {
        MEMORIA_NUI_DeleteHelpRegistry(oPlayer, nToken);
        return FALSE;
    }
    if (NuiGetEventType() != "mousedown") return FALSE;
    json jPayload = NuiGetEventPayload();
    if (JsonGetInt(JsonObjectGet(jPayload, "mouse_btn")) != NUI_MOUSE_BUTTON_RIGHT) return FALSE;
    json jRegistry = MEMORIA_NUI_GetHelpRegistry(oPlayer, nToken);
    json jHelp = JsonObjectGet(jRegistry, NuiGetEventElement());
    if (JsonGetType(jHelp) == JSON_TYPE_NULL) return FALSE;
    string sText = MEMORIA_NUI_ResolveHelp(oPlayer, nToken, jHelp);
    if (sText != "") MEMORIA_NUI_ShowHelp(oPlayer, sText);
    return TRUE;
}
