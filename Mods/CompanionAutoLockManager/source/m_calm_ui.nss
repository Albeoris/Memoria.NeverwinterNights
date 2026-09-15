#include "m_calm_lib"
#include "memoria_string"
#include "nw_inc_nui"

const string M_CALM_NUI_WINDOW_ID = "m_calm_settings";
const string M_CALM_NUI_LOCK_ENABLED = "lock_enabled";
const string M_CALM_NUI_SEARCH_RADIUS = "search_radius";
const string M_CALM_NUI_LOCK_INTERVAL = "lock_interval";
const string M_CALM_NUI_REQUIRE_LOS = "require_los";
const string M_CALM_NUI_ATTACK_SAFETY = "attack_safety";
const string M_CALM_NUI_HIGHLIGHT = "highlight";
const string M_CALM_NUI_MESSAGES = "messages";
const string M_CALM_NUI_DEBUG = "debug";
const string M_CALM_NUI_STATUS = "status";

json M_CALM_NuiLabel(string sText)
{
    return NuiLabel(JsonString(sText), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
}

json M_CALM_NuiValueRow(string sLabel, string sBind)
{
    json jRow = JsonArray();
    jRow = JsonArrayInsert(jRow, NuiWidth(M_CALM_NuiLabel(sLabel), 330.0f));
    jRow = JsonArrayInsert(jRow, NuiWidth(NuiTextEdit(JsonString(""), NuiBind(sBind), 12, FALSE), 120.0f));
    return NuiHeight(NuiRow(jRow), 30.0f);
}

json M_CALM_NuiCheckRow(string sLabel, string sBind)
{
    return NuiHeight(NuiCheck(JsonString(sLabel), NuiBind(sBind)), 28.0f);
}

json M_CALM_BuildSettingsWindow(object oPC)
{
    json jColumn = JsonArray();
    jColumn = JsonArrayInsert(jColumn, NuiHeight(M_CALM_NuiLabel(M_CALM_GetText(M_CALM_TEXT_AUTO_LOCK, oPC)), 30.0f));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiCheckRow(M_CALM_GetText(M_CALM_TEXT_ENABLED, oPC), M_CALM_NUI_LOCK_ENABLED));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiValueRow(M_CALM_GetText(M_CALM_TEXT_SEARCH_RADIUS, oPC), M_CALM_NUI_SEARCH_RADIUS));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiValueRow(M_CALM_GetText(M_CALM_TEXT_LOCK_INTERVAL, oPC), M_CALM_NUI_LOCK_INTERVAL));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiCheckRow(M_CALM_GetText(M_CALM_TEXT_REQUIRE_LOS, oPC) + " (LOS)", M_CALM_NUI_REQUIRE_LOS));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiCheckRow(M_CALM_GetText(M_CALM_TEXT_ATTACK_SAFETY, oPC), M_CALM_NUI_ATTACK_SAFETY));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiCheckRow(M_CALM_GetText(M_CALM_TEXT_HIGHLIGHT, oPC), M_CALM_NUI_HIGHLIGHT));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiCheckRow(M_CALM_GetText(M_CALM_TEXT_OVERHEAD_MESSAGES, oPC), M_CALM_NUI_MESSAGES));
    jColumn = JsonArrayInsert(jColumn, M_CALM_NuiCheckRow(M_CALM_GetText(M_CALM_TEXT_DEBUG, oPC), M_CALM_NUI_DEBUG));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiStyleForegroundColor(M_CALM_NuiLabel(""), NuiColor(255, 90, 90)), 8.0f));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind(M_CALM_NUI_STATUS), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(255, 90, 90)), 28.0f));
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(M_CALM_GetText(M_CALM_TEXT_SAVE, oPC))), "save"), 150.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(M_CALM_GetText(M_CALM_TEXT_CANCEL, oPC))), "cancel"), 150.0f));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jButtons), 35.0f));
    return NuiWindow(NuiCol(jColumn), JsonString(M_CALM_GetText(M_CALM_TEXT_SETTINGS_TITLE, oPC)), NuiRect(-1.0f, -1.0f, 510.0f, 430.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void M_CALM_OpenSettings(object oPC)
{
    M_CALM_InitializeSettings(oPC);
    int iOldToken = NuiFindWindow(oPC, M_CALM_NUI_WINDOW_ID);
    if (iOldToken > 0)
        NuiDestroy(oPC, iOldToken);
    int iToken = NuiCreate(oPC, M_CALM_BuildSettingsWindow(oPC), M_CALM_NUI_WINDOW_ID, "m_calm_nuievt");
    if (iToken <= 0)
        return;
    NuiSetBind(oPC, iToken, M_CALM_NUI_LOCK_ENABLED, JsonBool(GetLocalInt(oPC, M_CALM_LOCAL_ENABLED)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_SEARCH_RADIUS, JsonString(FloatToString(M_CALM_GetSearchRadius(oPC), 0, 1)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_LOCK_INTERVAL, JsonString(FloatToString(M_CALM_GetLockInterval(oPC), 0, 1)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_REQUIRE_LOS, JsonBool(GetLocalInt(oPC, M_CALM_LOCAL_REQUIRE_LOS)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_ATTACK_SAFETY, JsonBool(GetLocalInt(oPC, M_CALM_LOCAL_ATTACK_SAFETY)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_HIGHLIGHT, JsonBool(GetLocalInt(oPC, M_CALM_LOCAL_HIGHLIGHT)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_MESSAGES, JsonBool(GetLocalInt(oPC, M_CALM_LOCAL_OVERHEAD_MESSAGES)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_DEBUG, JsonBool(GetLocalInt(oPC, M_CALM_LOCAL_DEBUG)));
    NuiSetBind(oPC, iToken, M_CALM_NUI_STATUS, JsonString(""));
}

float M_CALM_ReadNuiFloat(object oPC, int iToken, string sBind)
{
    return StringToFloat(MEMORIA_NormalizeDecimal(JsonGetString(NuiGetBind(oPC, iToken, sBind))));
}

int M_CALM_SaveSettings(object oPC, int iToken)
{
    string sRadius = MEMORIA_NormalizeDecimal(JsonGetString(NuiGetBind(oPC, iToken, M_CALM_NUI_SEARCH_RADIUS)));
    string sLockInterval = MEMORIA_NormalizeDecimal(JsonGetString(NuiGetBind(oPC, iToken, M_CALM_NUI_LOCK_INTERVAL)));
    float fRadius = StringToFloat(sRadius);
    float fLockInterval = StringToFloat(sLockInterval);
    if (sRadius == "" || sLockInterval == "" || fRadius < 1.0f || fRadius > 100.0f || fLockInterval < 0.1f || fLockInterval > 6.0f)
    {
        NuiSetBind(oPC, iToken, M_CALM_NUI_STATUS, JsonString(M_CALM_GetText(M_CALM_TEXT_INVALID_SETTINGS, oPC)));
        return FALSE;
    }
    SetLocalInt(oPC, M_CALM_LOCAL_ENABLED, JsonGetInt(NuiGetBind(oPC, iToken, M_CALM_NUI_LOCK_ENABLED)));
    SetLocalFloat(oPC, M_CALM_LOCAL_SEARCH_RADIUS, fRadius);
    SetLocalFloat(oPC, M_CALM_LOCAL_LOCK_INTERVAL, fLockInterval);
    SetLocalInt(oPC, M_CALM_LOCAL_REQUIRE_LOS, JsonGetInt(NuiGetBind(oPC, iToken, M_CALM_NUI_REQUIRE_LOS)));
    SetLocalInt(oPC, M_CALM_LOCAL_ATTACK_SAFETY, JsonGetInt(NuiGetBind(oPC, iToken, M_CALM_NUI_ATTACK_SAFETY)));
    SetLocalInt(oPC, M_CALM_LOCAL_HIGHLIGHT, JsonGetInt(NuiGetBind(oPC, iToken, M_CALM_NUI_HIGHLIGHT)));
    SetLocalInt(oPC, M_CALM_LOCAL_OVERHEAD_MESSAGES, JsonGetInt(NuiGetBind(oPC, iToken, M_CALM_NUI_MESSAGES)));
    SetLocalInt(oPC, M_CALM_LOCAL_DEBUG, JsonGetInt(NuiGetBind(oPC, iToken, M_CALM_NUI_DEBUG)));
    if (GetLocalInt(oPC, M_CALM_LOCAL_DEBUG))
        SetLocalInt(oPC, M_CALM_LOCAL_REPORT_PENDING, TRUE);
    if (!GetLocalInt(oPC, M_CALM_LOCAL_ENABLED))
    {
        M_CALM_CancelAllTasks(oPC);
        M_CALM_ClearCachedHighlights(oPC);
    }
    if (!GetLocalInt(oPC, M_CALM_LOCAL_HIGHLIGHT))
        M_CALM_ClearCachedHighlights(oPC);
    ExecuteScript("m_calm_registry", oPC);
    ExecuteScript("m_calm_lock", oPC);
    object oItem = GetItemPossessedBy(oPC, M_CALM_ITEM_TAG);
    if (GetIsObjectValid(oItem))
        M_CALM_LocalizeItem(oItem, oPC);
    NuiDestroy(oPC, iToken);
    SendMessageToPC(oPC, M_CALM_GetText(M_CALM_TEXT_SETTINGS_SAVED, oPC));
    return TRUE;
}
