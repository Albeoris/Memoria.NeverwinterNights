#include "esi_lib"
#include "memoria_loader"
#include "memoria_locale"
#include "memoria_loc"

const string MECONFIG_ITEM_RESREF = "meconfig";
const string MECONFIG_ITEM_TAG = "MECONFIG_ITEM";
const string MECONFIG_ACTIVATE_HANDLER = "meconfig_evact";
const string MECONFIG_ESI_KEY = "meconfig.module.activate";
const string MECONFIG_WINDOW_ID = "meconfig";
const string MECONFIG_LOC_PREFIX = "meconfig";
const string MECONFIG_LOCAL_ITEM_SCHEMA = "MECONFIG_ITEM_SCHEMA";
const string MECONFIG_LOCAL_SELECTED_ID = "MECONFIG_SELECTED_ID";
const string MECONFIG_LOCAL_DIAGNOSTIC_TARGET = "MECONFIG_DIAGNOSTIC_TARGET";
const string MECONFIG_LOCAL_LANGUAGE = "MECONFIG_LANGUAGE";
const string MECONFIG_LOCAL_ITEM_LANGUAGE = "MECONFIG_ITEM_LANGUAGE";
const string MECONFIG_LOCAL_ITEM_OBJECT = "MECONFIG_ITEM_OBJECT";
const int MECONFIG_ITEM_SCHEMA = 1;

const string MECONFIG_TEXT_ITEM_NAME = "item_name";
const string MECONFIG_TEXT_ITEM_DESCRIPTION = "item_description";
const string MECONFIG_TEXT_WINDOW_TITLE = "window_title";
const string MECONFIG_TEXT_NO_MODULES = "no_modules";
const string MECONFIG_TEXT_SAVE = "save";
const string MECONFIG_TEXT_CLOSE = "close";
const string MECONFIG_TEXT_RANGE_ERROR = "range_error";

string MECONFIG_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, MECONFIG_LOCAL_LANGUAGE);
}

string MECONFIG_GetText(object oPC, string sKey)
{
    return MEMORIA_LOC_GetText(MECONFIG_LOC_PREFIX, MECONFIG_GetLanguage(oPC), sKey);
}

int MECONFIG_CompareNames(string sLeft, string sRight)
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

string MECONFIG_GetLocalizedValue(object oPC, json jModule, json jValue, string sFallbackField, string sKeyField)
{
    string sFallback = JsonGetString(JsonObjectGet(jValue, sFallbackField));
    string sKey = JsonGetString(JsonObjectGet(jValue, sKeyField));
    string sPrefix = JsonGetString(JsonObjectGet(JsonObjectGet(jModule, "localization"), "prefix"));
    if (sKey == "" || sPrefix == "") return sFallback;
    string sLocalized = MEMORIA_LOC_GetText(sPrefix, MECONFIG_GetLanguage(oPC), sKey);
    return sLocalized == "" ? sFallback : sLocalized;
}

json MECONFIG_LocalizeModules(object oPC, json jModules)
{
    json jLocalized = JsonArray();
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jModules); nIndex++)
    {
        json jModule = JsonArrayGet(jModules, nIndex);
        jModule = JsonObjectSet(jModule, "name", JsonString(MECONFIG_GetLocalizedValue(oPC, jModule, jModule, "name", "name_key")));
        json jOptions = JsonObjectGet(jModule, "options");
        int nOption;
        for (nOption = 0; nOption < JsonGetLength(jOptions); nOption++)
        {
            json jOption = JsonArrayGet(jOptions, nOption);
            jOption = JsonObjectSet(jOption, "label", JsonString(MECONFIG_GetLocalizedValue(oPC, jModule, jOption, "label", "label_key")));
            jOptions = JsonArraySet(jOptions, nOption, jOption);
        }
        jModule = JsonObjectSet(jModule, "options", jOptions);
        int nInsert = JsonGetLength(jLocalized);
        string sName = JsonGetString(JsonObjectGet(jModule, "name"));
        jLocalized = JsonArrayInsert(jLocalized, jModule);
        while (nInsert > 0 && MECONFIG_CompareNames(sName, JsonGetString(JsonObjectGet(JsonArrayGet(jLocalized, nInsert - 1), "name"))) < 0)
        {
            jLocalized = JsonArraySet(jLocalized, nInsert, JsonArrayGet(jLocalized, nInsert - 1));
            nInsert--;
        }
        jLocalized = JsonArraySet(jLocalized, nInsert, jModule);
    }
    return jLocalized;
}

json MECONFIG_LoadModules(object oPC)
{
    json jModules = JsonArray();
    json jPackages = MEMORIA_GetPackages(oPC);
    int nPackage;
    for (nPackage = 0; nPackage < JsonGetLength(jPackages); nPackage++)
    {
        json jManifest = JsonArrayGet(jPackages, nPackage);
        json jModule = JsonObjectGet(jManifest, "configuration");
        string sId = JsonGetString(JsonObjectGet(jManifest, "id"));
        if (JsonGetType(jModule) == JSON_TYPE_OBJECT && JsonGetString(JsonObjectGet(jModule, "name")) != "")
        {
            jModule = JsonObjectSet(jModule, "id", JsonString(sId));
            int nInsert = JsonGetLength(jModules);
            string sName = JsonGetString(JsonObjectGet(jModule, "name"));
            jModules = JsonArrayInsert(jModules, jModule);
            while (nInsert > 0 && MECONFIG_CompareNames(sName, JsonGetString(JsonObjectGet(JsonArrayGet(jModules, nInsert - 1), "name"))) < 0)
            {
                jModules = JsonArraySet(jModules, nInsert, JsonArrayGet(jModules, nInsert - 1));
                nInsert--;
            }
            jModules = JsonArraySet(jModules, nInsert, jModule);
        }
    }
    return jModules;
}

json MECONFIG_GetModules(object oPC)
{
    return MECONFIG_LocalizeModules(oPC, MECONFIG_LoadModules(oPC));
}

json MECONFIG_GetSelectedModule(object oPC, json jModules)
{
    string sSelectedId = GetLocalString(oPC, MECONFIG_LOCAL_SELECTED_ID);
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
    SetLocalString(oPC, MECONFIG_LOCAL_SELECTED_ID, JsonGetString(JsonObjectGet(jModule, "id")));
    return jModule;
}

string MECONFIG_OptionBind(int nIndex)
{
    return "option_" + IntToString(nIndex);
}

object MECONFIG_GetOptionOwner(json jOption, object oPC)
{
    if (JsonGetString(JsonObjectGet(jOption, "scope")) == "module")
        return GetModule();
    return oPC;
}

json MECONFIG_BuildModuleList()
{
    json jTemplate = JsonArray();
    jTemplate = JsonArrayInsert(jTemplate, NuiListTemplateCell(NuiId(NuiButtonSelect(NuiBind("module_names"), NuiBind("module_selected")), "module_select"), 0.0f, TRUE));
    return NuiList(jTemplate, NuiBind("module_count"), 32.0f, TRUE, NUI_SCROLLBARS_Y);
}

json MECONFIG_BuildOptions(object oPC, json jModule)
{
    json jColumn = JsonArray();
    string sName = JsonGetString(JsonObjectGet(jModule, "name"));
    if (sName == "")
    {
        jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiLabel(JsonString(MECONFIG_GetText(oPC, MECONFIG_TEXT_NO_MODULES)), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 30.0f));
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
        string sBind = MECONFIG_OptionBind(nIndex);
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
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MECONFIG_GetText(oPC, MECONFIG_TEXT_SAVE))), "save"), 130.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MECONFIG_GetText(oPC, MECONFIG_TEXT_CLOSE))), "close"), 130.0f));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jButtons), 36.0f));
    return NuiCol(jColumn);
}

json MECONFIG_BuildWindow(object oPC, json jModule)
{
    json jRow = JsonArray();
    jRow = JsonArrayInsert(jRow, NuiWidth(NuiGroup(MECONFIG_BuildModuleList(), TRUE, NUI_SCROLLBARS_NONE), 250.0f));
    jRow = JsonArrayInsert(jRow, NuiWidth(NuiGroup(MECONFIG_BuildOptions(oPC, jModule), TRUE, NUI_SCROLLBARS_Y), 540.0f));
    return NuiWindow(NuiRow(jRow), JsonString(MECONFIG_GetText(oPC, MECONFIG_TEXT_WINDOW_TITLE)), NuiRect(-1.0f, -1.0f, 830.0f, 500.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void MECONFIG_SetOptionBinds(object oPC, int nToken, json jModule)
{
    json jOptions = JsonObjectGet(jModule, "options");
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jOptions); nIndex++)
    {
        json jOption = JsonArrayGet(jOptions, nIndex);
        string sType = JsonGetString(JsonObjectGet(jOption, "type"));
        object oOwner = MECONFIG_GetOptionOwner(jOption, oPC);
        string sLocal = JsonGetString(JsonObjectGet(jOption, "local"));
        string sBind = MECONFIG_OptionBind(nIndex);
        if (sType == "bool") NuiSetBind(oPC, nToken, sBind, JsonBool(GetLocalInt(oOwner, sLocal)));
        else if (sType == "int") NuiSetBind(oPC, nToken, sBind, JsonString(IntToString(GetLocalInt(oOwner, sLocal))));
        else if (sType == "float") NuiSetBind(oPC, nToken, sBind, JsonString(FloatToString(GetLocalFloat(oOwner, sLocal), 0, 1)));
    }
}

void MECONFIG_Open(object oPC)
{
    json jModules = MECONFIG_GetModules(oPC);
    json jModule = MECONFIG_GetSelectedModule(oPC, jModules);
    int nOldToken = NuiFindWindow(oPC, MECONFIG_WINDOW_ID);
    if (nOldToken > 0)
        NuiDestroy(oPC, nOldToken);
    int nToken = NuiCreate(oPC, MECONFIG_BuildWindow(oPC, jModule), MECONFIG_WINDOW_ID, "meconfig_nuievt");
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
    MECONFIG_SetOptionBinds(oPC, nToken, jModule);
}

int MECONFIG_IsValidNumber(string sValue, string sType)
{
    string sPattern = sType == "int" ? "^[+-]?[0-9]+$" : "^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$";
    return JsonGetLength(RegExpMatch(sPattern, sValue)) > 0;
}

int MECONFIG_Save(object oPC, int nToken)
{
    json jModule = MECONFIG_GetSelectedModule(oPC, MECONFIG_GetModules(oPC));
    json jOptions = JsonObjectGet(jModule, "options");
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jOptions); nIndex++)
    {
        json jOption = JsonArrayGet(jOptions, nIndex);
        string sType = JsonGetString(JsonObjectGet(jOption, "type"));
        if (sType != "int" && sType != "float")
            continue;
        string sValue = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, nToken, MECONFIG_OptionBind(nIndex))), ".");
        float fValue = StringToFloat(sValue);
        float fMinimum = JsonGetFloat(JsonObjectGet(jOption, "minimum"));
        float fMaximum = JsonGetFloat(JsonObjectGet(jOption, "maximum"));
        if (!MECONFIG_IsValidNumber(sValue, sType) || fValue < fMinimum || fValue > fMaximum)
        {
            SendMessageToPC(oPC, JsonGetString(JsonObjectGet(jOption, "label")) + " " + MECONFIG_GetText(oPC, MECONFIG_TEXT_RANGE_ERROR) + " " + FloatToString(fMinimum, 0, 1) + " - " + FloatToString(fMaximum, 0, 1) + ".");
            return FALSE;
        }
    }
    for (nIndex = 0; nIndex < JsonGetLength(jOptions); nIndex++)
    {
        json jOption = JsonArrayGet(jOptions, nIndex);
        string sType = JsonGetString(JsonObjectGet(jOption, "type"));
        object oOwner = MECONFIG_GetOptionOwner(jOption, oPC);
        string sLocal = JsonGetString(JsonObjectGet(jOption, "local"));
        string sValue = RegExpReplace(",", JsonGetString(NuiGetBind(oPC, nToken, MECONFIG_OptionBind(nIndex))), ".");
        if (sType == "bool") SetLocalInt(oOwner, sLocal, JsonGetInt(NuiGetBind(oPC, nToken, MECONFIG_OptionBind(nIndex))));
        else if (sType == "int") SetLocalInt(oOwner, sLocal, StringToInt(sValue));
        else if (sType == "float") SetLocalFloat(oOwner, sLocal, StringToFloat(sValue));
    }
    string sApply = JsonGetString(JsonObjectGet(jModule, "apply"));
    if (sApply != "")
        ExecuteScript(sApply, oPC);
    return TRUE;
}

void MECONFIG_RunAction(object oPC, int nActionIndex)
{
    json jModule = MECONFIG_GetSelectedModule(oPC, MECONFIG_GetModules(oPC));
    json jOptions = JsonObjectGet(jModule, "options");
    if (nActionIndex < 0 || nActionIndex >= JsonGetLength(jOptions))
        return;
    string sScript = JsonGetString(JsonObjectGet(JsonArrayGet(jOptions, nActionIndex), "script"));
    if (sScript != "")
        ExecuteScript(sScript, oPC);
}

void MECONFIG_RunDiagnostics(object oPC, object oTarget)
{
    SetLocalObject(oPC, MECONFIG_LOCAL_DIAGNOSTIC_TARGET, oTarget);
    json jModules = MECONFIG_GetModules(oPC);
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jModules); nIndex++)
    {
        string sDiagnostic = JsonGetString(JsonObjectGet(JsonArrayGet(jModules, nIndex), "diagnostic"));
        if (sDiagnostic != "")
            ExecuteScript(sDiagnostic, oPC);
    }
    DeleteLocalObject(oPC, MECONFIG_LOCAL_DIAGNOSTIC_TARGET);
}

void MECONFIG_LocalizeItem(object oItem, object oPC)
{
    SetName(oItem, MECONFIG_GetText(oPC, MECONFIG_TEXT_ITEM_NAME));
    string sDescription = MECONFIG_GetText(oPC, MECONFIG_TEXT_ITEM_DESCRIPTION);
    SetDescription(oItem, sDescription, TRUE);
    SetDescription(oItem, sDescription, FALSE);
    SetLocalString(oItem, MECONFIG_LOCAL_ITEM_LANGUAGE, MECONFIG_GetLanguage(oPC));
}

void MECONFIG_EnsureItem(object oPC)
{
    object oItem = GetLocalObject(oPC, MECONFIG_LOCAL_ITEM_OBJECT);
    int bCached = GetIsObjectValid(oItem) && GetItemPossessor(oItem) == oPC && GetTag(oItem) == MECONFIG_ITEM_TAG;
    if (!bCached) oItem = GetItemPossessedBy(oPC, MECONFIG_ITEM_TAG);
    if (GetIsObjectValid(oItem) && GetLocalInt(oItem, MECONFIG_LOCAL_ITEM_SCHEMA) == MECONFIG_ITEM_SCHEMA)
    {
        if (GetLocalString(oItem, MECONFIG_LOCAL_ITEM_LANGUAGE) != MECONFIG_GetLanguage(oPC)) MECONFIG_LocalizeItem(oItem, oPC);
        if (!bCached) SetLocalObject(oPC, MECONFIG_LOCAL_ITEM_OBJECT, oItem);
        return;
    }
    if (GetIsObjectValid(oItem) && GetLocalInt(oItem, MECONFIG_LOCAL_ITEM_SCHEMA) != MECONFIG_ITEM_SCHEMA)
    {
        DestroyObject(oItem);
        oItem = OBJECT_INVALID;
    }
    if (!GetIsObjectValid(oItem))
        oItem = CreateItemOnObject(MECONFIG_ITEM_RESREF, oPC, 1, MECONFIG_ITEM_TAG);
    if (GetIsObjectValid(oItem))
    {
        SetLocalInt(oItem, MECONFIG_LOCAL_ITEM_SCHEMA, MECONFIG_ITEM_SCHEMA);
        SetPlotFlag(oItem, TRUE);
        SetItemCursedFlag(oItem, TRUE);
        if (GetLocalString(oItem, MECONFIG_LOCAL_ITEM_LANGUAGE) != MECONFIG_GetLanguage(oPC)) MECONFIG_LocalizeItem(oItem, oPC);
        SetLocalObject(oPC, MECONFIG_LOCAL_ITEM_OBJECT, oItem);
    }
}

void MECONFIG_InstallHook()
{
    object oModule = GetModule();
    ESI_InjectToObject(oModule, MECONFIG_ESI_KEY, EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, MECONFIG_ACTIVATE_HANDLER, ESI_INJECTION_PLACEMENT_FIRST);
}

void MECONFIG_Heartbeat(object oPC)
{
    if (!GetIsPC(oPC) || GetIsDM(oPC) || GetIsObjectValid(GetMaster(oPC)))
        return;
    MECONFIG_InstallHook();
    MECONFIG_EnsureItem(oPC);
}
