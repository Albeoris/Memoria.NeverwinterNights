#include "esi_lib"
#include "memoria_locale"
#include "memoria_i18n"
#include "nw_inc_nui"

const string MEMORIA_CONFIG_MANIFEST_PREFIX = "memoria_";
const string MEMORIA_CONFIG_ITEM_RESREF = "memoria_config";
const string MEMORIA_CONFIG_ITEM_TAG = "MEMORIA_CONFIGURATION_ITEM";
const string MEMORIA_CONFIG_ACTIVATE_HANDLER = "meconfig_evact";
const string MEMORIA_CONFIG_ESI_KEY = "meconfig.module.activate";
const string MEMORIA_CONFIG_WINDOW_ID = "memoria_config";
const string MEMORIA_CONFIG_I18N_PREFIX = "meconfig";
const string MEMORIA_CONFIG_LOCAL_ITEM_SCHEMA = "MEMORIA_CONFIG_ITEM_SCHEMA";
const string MEMORIA_CONFIG_LOCAL_SELECTED_ID = "MEMORIA_CONFIG_SELECTED_ID";
const string MEMORIA_CONFIG_LOCAL_DIAGNOSTIC_TARGET = "MEMORIA_CONFIG_DIAGNOSTIC_TARGET";
const string MEMORIA_CONFIG_LOCAL_LANGUAGE = "MEMORIA_CONFIG_LANGUAGE";
const string MEMORIA_CONFIG_LOCAL_ITEM_LANGUAGE = "MEMORIA_CONFIG_ITEM_LANGUAGE";
const string MEMORIA_CONFIG_LOCAL_ITEM_OBJECT = "MEMORIA_CONFIG_ITEM_OBJECT";
const string MEMORIA_CONFIG_CACHE_OWNER_LOCAL = "MEMORIA_CONFIG_CACHE_OWNER";
const string MEMORIA_CONFIG_CACHE_WINDOW = "meconfig_cache";
const int MEMORIA_CONFIG_ITEM_SCHEMA = 1;

const string MEMORIA_CONFIG_TEXT_ITEM_NAME = "item_name";
const string MEMORIA_CONFIG_TEXT_ITEM_DESCRIPTION = "item_description";
const string MEMORIA_CONFIG_TEXT_WINDOW_TITLE = "window_title";
const string MEMORIA_CONFIG_TEXT_NO_MODULES = "no_modules";
const string MEMORIA_CONFIG_TEXT_SAVE = "save";
const string MEMORIA_CONFIG_TEXT_CLOSE = "close";
const string MEMORIA_CONFIG_TEXT_RANGE_ERROR = "range_error";

void MEMORIA_CONFIG_ReportError(object oPC, string sManifest, string sError)
{
    string sLocal = "MEMORIA_CONFIG_ERR_" + sManifest;
    if (GetLocalString(oPC, sLocal) == sError) return;
    SetLocalString(oPC, sLocal, sError);
    SendMessageToPC(oPC, "Memoria Configuration Manager ignored " + sManifest + ".txt: " + sError);
}

int MEMORIA_CONFIG_HasId(json jModules, string sId)
{
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jModules); nIndex++)
    {
        if (JsonGetString(JsonObjectGet(JsonArrayGet(jModules, nIndex), "id")) == sId) return TRUE;
    }
    return FALSE;
}

string MEMORIA_CONFIG_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, MEMORIA_CONFIG_LOCAL_LANGUAGE);
}

string MEMORIA_CONFIG_GetText(object oPC, string sKey)
{
    return MEMORIA_I18N_GetText(MEMORIA_CONFIG_I18N_PREFIX, MEMORIA_CONFIG_GetLanguage(oPC), sKey);
}

int MEMORIA_CONFIG_CompareNames(string sLeft, string sRight)
{
    string sAlphabet = " 0123456789abcdefghijklmnopqrstuvwxyz";
    sLeft = GetStringLowerCase(sLeft);
    sRight = GetStringLowerCase(sRight);
    int nLength = GetStringLength(sLeft);
    if (GetStringLength(sRight) < nLength) nLength = GetStringLength(sRight);
    int nIndex;
    for (nIndex = 0; nIndex < nLength; nIndex++)
    {
        int nLeft = FindSubString(sAlphabet, GetSubString(sLeft, nIndex, 1));
        int nRight = FindSubString(sAlphabet, GetSubString(sRight, nIndex, 1));
        if (nLeft < 0) nLeft = 0;
        if (nRight < 0) nRight = 0;
        if (nLeft < nRight) return -1;
        if (nLeft > nRight) return 1;
    }
    if (GetStringLength(sLeft) < GetStringLength(sRight)) return -1;
    if (GetStringLength(sLeft) > GetStringLength(sRight)) return 1;
    return 0;
}

string MEMORIA_CONFIG_GetLocalizedValue(object oPC, json jModule, json jValue, string sFallbackField, string sKeyField)
{
    string sFallback = JsonGetString(JsonObjectGet(jValue, sFallbackField));
    string sKey = JsonGetString(JsonObjectGet(jValue, sKeyField));
    string sPrefix = JsonGetString(JsonObjectGet(JsonObjectGet(jModule, "localization"), "prefix"));
    if (sKey == "" || sPrefix == "") return sFallback;
    string sLocalized = MEMORIA_I18N_GetText(sPrefix, MEMORIA_CONFIG_GetLanguage(oPC), sKey);
    return sLocalized == "" ? sFallback : sLocalized;
}

json MEMORIA_CONFIG_LocalizeModules(object oPC, json jModules)
{
    json jLocalized = JsonArray();
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jModules); nIndex++)
    {
        json jModule = JsonArrayGet(jModules, nIndex);
        jModule = JsonObjectSet(jModule, "name", JsonString(MEMORIA_CONFIG_GetLocalizedValue(oPC, jModule, jModule, "name", "name_key")));
        json jOptions = JsonObjectGet(jModule, "options");
        int nOption;
        for (nOption = 0; nOption < JsonGetLength(jOptions); nOption++)
        {
            json jOption = JsonArrayGet(jOptions, nOption);
            jOption = JsonObjectSet(jOption, "label", JsonString(MEMORIA_CONFIG_GetLocalizedValue(oPC, jModule, jOption, "label", "label_key")));
            jOptions = JsonArraySet(jOptions, nOption, jOption);
        }
        jModule = JsonObjectSet(jModule, "options", jOptions);
        int nInsert = JsonGetLength(jLocalized);
        string sName = JsonGetString(JsonObjectGet(jModule, "name"));
        jLocalized = JsonArrayInsert(jLocalized, jModule);
        while (nInsert > 0 && MEMORIA_CONFIG_CompareNames(sName, JsonGetString(JsonObjectGet(JsonArrayGet(jLocalized, nInsert - 1), "name"))) < 0)
        {
            jLocalized = JsonArraySet(jLocalized, nInsert, JsonArrayGet(jLocalized, nInsert - 1));
            nInsert--;
        }
        jLocalized = JsonArraySet(jLocalized, nInsert, jModule);
    }
    return jLocalized;
}

json MEMORIA_CONFIG_LoadModules(object oPC)
{
    json jModules = JsonArray();
    int nNth = 1;
    string sResource = ResManFindPrefix(MEMORIA_CONFIG_MANIFEST_PREFIX, RESTYPE_TXT, nNth, FALSE);
    while (sResource != "")
    {
        json jManifest = JsonParse(ResManGetFileContents(sResource, RESTYPE_TXT));
        json jModule = JsonObjectGet(jManifest, "configuration");
        string sId = JsonGetString(JsonObjectGet(jManifest, "id"));
        int bValid = JsonGetError(jManifest) == "" && JsonGetType(jManifest) == JSON_TYPE_OBJECT && JsonGetInt(JsonObjectGet(jManifest, "schema")) == 1 && sId != "" && JsonGetType(jModule) == JSON_TYPE_OBJECT && JsonGetString(JsonObjectGet(jModule, "name")) != "";
        if (bValid)
        {
            jModule = JsonObjectSet(jModule, "id", JsonString(sId));
            if (MEMORIA_CONFIG_HasId(jModules, sId)) MEMORIA_CONFIG_ReportError(oPC, sResource, "duplicate module id " + sId);
            else
            {
                int nInsert = JsonGetLength(jModules);
                string sName = JsonGetString(JsonObjectGet(jModule, "name"));
                jModules = JsonArrayInsert(jModules, jModule);
                while (nInsert > 0 && MEMORIA_CONFIG_CompareNames(sName, JsonGetString(JsonObjectGet(JsonArrayGet(jModules, nInsert - 1), "name"))) < 0)
                {
                    jModules = JsonArraySet(jModules, nInsert, JsonArrayGet(jModules, nInsert - 1));
                    nInsert--;
                }
                jModules = JsonArraySet(jModules, nInsert, jModule);
            }
        }
        nNth++;
        sResource = ResManFindPrefix(MEMORIA_CONFIG_MANIFEST_PREFIX, RESTYPE_TXT, nNth, FALSE);
    }
    return jModules;
}

json MEMORIA_CONFIG_BuildCacheWindow()
{
    return NuiWindow(NuiVisible(NuiSpacer(), JsonBool(FALSE)), JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
}

json MEMORIA_CONFIG_GetModules(object oPC)
{
    object oModule = GetModule();
    object oCacheOwner = GetLocalObject(oModule, MEMORIA_CONFIG_CACHE_OWNER_LOCAL);
    int nToken = GetIsObjectValid(oCacheOwner) ? NuiFindWindow(oCacheOwner, MEMORIA_CONFIG_CACHE_WINDOW) : 0;
    json jModules = NuiGetUserData(oCacheOwner, nToken);
    if (nToken == 0 || JsonGetType(jModules) != JSON_TYPE_ARRAY)
    {
        jModules = MEMORIA_CONFIG_LoadModules(oPC);
        oCacheOwner = oPC;
        nToken = NuiFindWindow(oCacheOwner, MEMORIA_CONFIG_CACHE_WINDOW);
        if (nToken == 0) nToken = NuiCreate(oCacheOwner, MEMORIA_CONFIG_BuildCacheWindow(), MEMORIA_CONFIG_CACHE_WINDOW, "meconfig_noop");
        if (nToken > 0)
        {
            NuiSetUserData(oCacheOwner, nToken, jModules);
            SetLocalObject(oModule, MEMORIA_CONFIG_CACHE_OWNER_LOCAL, oCacheOwner);
        }
    }
    return MEMORIA_CONFIG_LocalizeModules(oPC, jModules);
}

json MEMORIA_CONFIG_GetSelectedModule(object oPC, json jModules)
{
    string sSelectedId = GetLocalString(oPC, MEMORIA_CONFIG_LOCAL_SELECTED_ID);
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jModules); nIndex++)
    {
        json jModule = JsonArrayGet(jModules, nIndex);
        if (JsonGetString(JsonObjectGet(jModule, "id")) == sSelectedId)
            return jModule;
    }
    if (JsonGetLength(jModules) == 0)
        return JsonObject();
    json jModule = JsonArrayGet(jModules, 0);
    SetLocalString(oPC, MEMORIA_CONFIG_LOCAL_SELECTED_ID, JsonGetString(JsonObjectGet(jModule, "id")));
    return jModule;
}

string MEMORIA_CONFIG_OptionBind(int nIndex)
{
    return "option_" + IntToString(nIndex);
}

object MEMORIA_CONFIG_GetOptionOwner(json jOption, object oPC)
{
    if (JsonGetString(JsonObjectGet(jOption, "scope")) == "module")
        return GetModule();
    return oPC;
}

json MEMORIA_CONFIG_BuildModuleList()
{
    json jTemplate = JsonArray();
    jTemplate = JsonArrayInsert(jTemplate, NuiListTemplateCell(NuiId(NuiButtonSelect(NuiBind("module_names"), NuiBind("module_selected")), "module_select"), 0.0f, TRUE));
    return NuiList(jTemplate, NuiBind("module_count"), 32.0f, TRUE, NUI_SCROLLBARS_Y);
}

json MEMORIA_CONFIG_BuildOptions(object oPC, json jModule)
{
    json jColumn = JsonArray();
    string sName = JsonGetString(JsonObjectGet(jModule, "name"));
    if (sName == "")
    {
        jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiLabel(JsonString(MEMORIA_CONFIG_GetText(oPC, MEMORIA_CONFIG_TEXT_NO_MODULES)), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 30.0f));
        return NuiCol(jColumn);
    }
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiStyleForegroundColor(NuiLabel(JsonString(sName), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(225, 190, 95)), 30.0f));
    json jOptions = JsonObjectGet(jModule, "options");
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jOptions); nIndex++)
    {
        json jOption = JsonArrayGet(jOptions, nIndex);
        string sType = JsonGetString(JsonObjectGet(jOption, "type"));
        string sLabel = JsonGetString(JsonObjectGet(jOption, "label"));
        string sBind = MEMORIA_CONFIG_OptionBind(nIndex);
        if (sType == "bool")
            jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiCheck(JsonString(sLabel), NuiBind(sBind)), 28.0f));
        else if (sType == "int" || sType == "float")
        {
            json jRow = JsonArray();
            jRow = JsonArrayInsert(jRow, NuiWidth(NuiLabel(JsonString(sLabel), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 340.0f));
            jRow = JsonArrayInsert(jRow, NuiWidth(NuiTextEdit(JsonString(""), NuiBind(sBind), 12, FALSE), 140.0f));
            jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jRow), 30.0f));
        }
        else if (sType == "action")
            jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiId(NuiButton(JsonString(sLabel)), "action_" + IntToString(nIndex)), 32.0f));
    }
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MEMORIA_CONFIG_GetText(oPC, MEMORIA_CONFIG_TEXT_SAVE))), "save"), 130.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MEMORIA_CONFIG_GetText(oPC, MEMORIA_CONFIG_TEXT_CLOSE))), "close"), 130.0f));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jButtons), 36.0f));
    return NuiCol(jColumn);
}

json MEMORIA_CONFIG_BuildWindow(object oPC, json jModule)
{
    json jRow = JsonArray();
    jRow = JsonArrayInsert(jRow, NuiWidth(NuiGroup(MEMORIA_CONFIG_BuildModuleList(), TRUE, NUI_SCROLLBARS_NONE), 250.0f));
    jRow = JsonArrayInsert(jRow, NuiWidth(NuiGroup(MEMORIA_CONFIG_BuildOptions(oPC, jModule), TRUE, NUI_SCROLLBARS_Y), 540.0f));
    return NuiWindow(NuiRow(jRow), JsonString(MEMORIA_CONFIG_GetText(oPC, MEMORIA_CONFIG_TEXT_WINDOW_TITLE)), NuiRect(-1.0f, -1.0f, 830.0f, 500.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void MEMORIA_CONFIG_SetOptionBinds(object oPC, int nToken, json jModule)
{
    json jOptions = JsonObjectGet(jModule, "options");
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jOptions); nIndex++)
    {
        json jOption = JsonArrayGet(jOptions, nIndex);
        string sType = JsonGetString(JsonObjectGet(jOption, "type"));
        object oOwner = MEMORIA_CONFIG_GetOptionOwner(jOption, oPC);
        string sLocal = JsonGetString(JsonObjectGet(jOption, "local"));
        string sBind = MEMORIA_CONFIG_OptionBind(nIndex);
        if (sType == "bool") NuiSetBind(oPC, nToken, sBind, JsonBool(GetLocalInt(oOwner, sLocal)));
        else if (sType == "int") NuiSetBind(oPC, nToken, sBind, JsonString(IntToString(GetLocalInt(oOwner, sLocal))));
        else if (sType == "float") NuiSetBind(oPC, nToken, sBind, JsonString(FloatToString(GetLocalFloat(oOwner, sLocal), 0, 1)));
    }
}

void MEMORIA_CONFIG_Open(object oPC)
{
    json jModules = MEMORIA_CONFIG_GetModules(oPC);
    json jModule = MEMORIA_CONFIG_GetSelectedModule(oPC, jModules);
    int nOldToken = NuiFindWindow(oPC, MEMORIA_CONFIG_WINDOW_ID);
    if (nOldToken > 0)
        NuiDestroy(oPC, nOldToken);
    int nToken = NuiCreate(oPC, MEMORIA_CONFIG_BuildWindow(oPC, jModule), MEMORIA_CONFIG_WINDOW_ID, "meconfig_nuievt");
    if (nToken <= 0)
        return;
    json jNames = JsonArray();
    json jSelected = JsonArray();
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jModules); nIndex++)
    {
        json jEntry = JsonArrayGet(jModules, nIndex);
        jNames = JsonArrayInsert(jNames, JsonString(JsonGetString(JsonObjectGet(jEntry, "name"))));
        jSelected = JsonArrayInsert(jSelected, JsonBool(JsonGetString(JsonObjectGet(jEntry, "id")) == JsonGetString(JsonObjectGet(jModule, "id"))));
    }
    NuiSetBind(oPC, nToken, "module_names", jNames);
    NuiSetBind(oPC, nToken, "module_selected", jSelected);
    NuiSetBind(oPC, nToken, "module_count", JsonInt(JsonGetLength(jModules)));
    MEMORIA_CONFIG_SetOptionBinds(oPC, nToken, jModule);
}

int MEMORIA_CONFIG_IsValidNumber(string sValue, string sType)
{
    string sPattern = sType == "int" ? "^[+-]?[0-9]+$" : "^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$";
    return JsonGetLength(RegExpMatch(sPattern, sValue)) > 0;
}

int MEMORIA_CONFIG_Save(object oPC, int nToken)
{
    json jModule = MEMORIA_CONFIG_GetSelectedModule(oPC, MEMORIA_CONFIG_GetModules(oPC));
    json jOptions = JsonObjectGet(jModule, "options");
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jOptions); nIndex++)
    {
        json jOption = JsonArrayGet(jOptions, nIndex);
        string sType = JsonGetString(JsonObjectGet(jOption, "type"));
        if (sType != "int" && sType != "float")
            continue;
        string sValue = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, nToken, MEMORIA_CONFIG_OptionBind(nIndex))), ".");
        float fValue = StringToFloat(sValue);
        float fMinimum = JsonGetFloat(JsonObjectGet(jOption, "minimum"));
        float fMaximum = JsonGetFloat(JsonObjectGet(jOption, "maximum"));
        if (!MEMORIA_CONFIG_IsValidNumber(sValue, sType) || fValue < fMinimum || fValue > fMaximum)
        {
            SendMessageToPC(oPC, JsonGetString(JsonObjectGet(jOption, "label")) + " " + MEMORIA_CONFIG_GetText(oPC, MEMORIA_CONFIG_TEXT_RANGE_ERROR) + " " + FloatToString(fMinimum, 0, 1) + " - " + FloatToString(fMaximum, 0, 1) + ".");
            return FALSE;
        }
    }
    for (nIndex = 0; nIndex < JsonGetLength(jOptions); nIndex++)
    {
        json jOption = JsonArrayGet(jOptions, nIndex);
        string sType = JsonGetString(JsonObjectGet(jOption, "type"));
        object oOwner = MEMORIA_CONFIG_GetOptionOwner(jOption, oPC);
        string sLocal = JsonGetString(JsonObjectGet(jOption, "local"));
        string sValue = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, nToken, MEMORIA_CONFIG_OptionBind(nIndex))), ".");
        if (sType == "bool") SetLocalInt(oOwner, sLocal, JsonGetInt(NuiGetBind(oPC, nToken, MEMORIA_CONFIG_OptionBind(nIndex))));
        else if (sType == "int") SetLocalInt(oOwner, sLocal, StringToInt(sValue));
        else if (sType == "float") SetLocalFloat(oOwner, sLocal, StringToFloat(sValue));
    }
    string sApply = JsonGetString(JsonObjectGet(jModule, "apply"));
    if (sApply != "")
        ExecuteScript(sApply, oPC);
    return TRUE;
}

void MEMORIA_CONFIG_RunAction(object oPC, int nActionIndex)
{
    json jModule = MEMORIA_CONFIG_GetSelectedModule(oPC, MEMORIA_CONFIG_GetModules(oPC));
    json jOptions = JsonObjectGet(jModule, "options");
    if (nActionIndex < 0 || nActionIndex >= JsonGetLength(jOptions))
        return;
    string sScript = JsonGetString(JsonObjectGet(JsonArrayGet(jOptions, nActionIndex), "script"));
    if (sScript != "")
        ExecuteScript(sScript, oPC);
}

void MEMORIA_CONFIG_RunDiagnostics(object oPC, object oTarget)
{
    SetLocalObject(oPC, MEMORIA_CONFIG_LOCAL_DIAGNOSTIC_TARGET, oTarget);
    json jModules = MEMORIA_CONFIG_GetModules(oPC);
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jModules); nIndex++)
    {
        string sDiagnostic = JsonGetString(JsonObjectGet(JsonArrayGet(jModules, nIndex), "diagnostic"));
        if (sDiagnostic != "")
            ExecuteScript(sDiagnostic, oPC);
    }
    DeleteLocalObject(oPC, MEMORIA_CONFIG_LOCAL_DIAGNOSTIC_TARGET);
}

void MEMORIA_CONFIG_LocalizeItem(object oItem, object oPC)
{
    SetName(oItem, MEMORIA_CONFIG_GetText(oPC, MEMORIA_CONFIG_TEXT_ITEM_NAME));
    string sDescription = MEMORIA_CONFIG_GetText(oPC, MEMORIA_CONFIG_TEXT_ITEM_DESCRIPTION);
    SetDescription(oItem, sDescription, TRUE);
    SetDescription(oItem, sDescription, FALSE);
    SetLocalString(oItem, MEMORIA_CONFIG_LOCAL_ITEM_LANGUAGE, MEMORIA_CONFIG_GetLanguage(oPC));
}

void MEMORIA_CONFIG_EnsureItem(object oPC)
{
    object oItem = GetLocalObject(oPC, MEMORIA_CONFIG_LOCAL_ITEM_OBJECT);
    int bCached = GetIsObjectValid(oItem) && GetItemPossessor(oItem) == oPC && GetTag(oItem) == MEMORIA_CONFIG_ITEM_TAG;
    if (!bCached) oItem = GetItemPossessedBy(oPC, MEMORIA_CONFIG_ITEM_TAG);
    if (GetIsObjectValid(oItem) && GetLocalInt(oItem, MEMORIA_CONFIG_LOCAL_ITEM_SCHEMA) == MEMORIA_CONFIG_ITEM_SCHEMA)
    {
        if (GetLocalString(oItem, MEMORIA_CONFIG_LOCAL_ITEM_LANGUAGE) != MEMORIA_CONFIG_GetLanguage(oPC)) MEMORIA_CONFIG_LocalizeItem(oItem, oPC);
        if (!bCached) SetLocalObject(oPC, MEMORIA_CONFIG_LOCAL_ITEM_OBJECT, oItem);
        return;
    }
    if (GetIsObjectValid(oItem) && GetLocalInt(oItem, MEMORIA_CONFIG_LOCAL_ITEM_SCHEMA) != MEMORIA_CONFIG_ITEM_SCHEMA)
    {
        DestroyObject(oItem);
        oItem = OBJECT_INVALID;
    }
    if (!GetIsObjectValid(oItem))
        oItem = CreateItemOnObject(MEMORIA_CONFIG_ITEM_RESREF, oPC, 1, MEMORIA_CONFIG_ITEM_TAG);
    if (GetIsObjectValid(oItem))
    {
        SetLocalInt(oItem, MEMORIA_CONFIG_LOCAL_ITEM_SCHEMA, MEMORIA_CONFIG_ITEM_SCHEMA);
        SetPlotFlag(oItem, TRUE);
        SetItemCursedFlag(oItem, TRUE);
        if (GetLocalString(oItem, MEMORIA_CONFIG_LOCAL_ITEM_LANGUAGE) != MEMORIA_CONFIG_GetLanguage(oPC)) MEMORIA_CONFIG_LocalizeItem(oItem, oPC);
        SetLocalObject(oPC, MEMORIA_CONFIG_LOCAL_ITEM_OBJECT, oItem);
    }
}

void MEMORIA_CONFIG_InstallHook()
{
    object oModule = GetModule();
    if (!ESI_IsRegistered(oModule, MEMORIA_CONFIG_ESI_KEY, EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, MEMORIA_CONFIG_ACTIVATE_HANDLER, ESI_INJECTION_PLACEMENT_FIRST)) ESI_InjectToObject(oModule, MEMORIA_CONFIG_ESI_KEY, EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, MEMORIA_CONFIG_ACTIVATE_HANDLER, ESI_INJECTION_PLACEMENT_FIRST);
}

void MEMORIA_CONFIG_Heartbeat(object oPC)
{
    if (!GetIsPC(oPC) || GetIsDM(oPC) || GetIsObjectValid(GetMaster(oPC)))
        return;
    MEMORIA_CONFIG_InstallHook();
    MEMORIA_CONFIG_EnsureItem(oPC);
}
