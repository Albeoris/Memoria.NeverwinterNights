// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: esi_lib
/*
  Event Script Injector
  Library

  Allows dynamic assignment of multiple scripts for a single event.
  Scripts can be injected to be executed before or after an original script.
  The union script and the remembered original event script are persistent.
  Active injected scripts are kept in a transient NUI user-data registry and
  must be registered again when a runtime session starts.
 */
//::///////////////////////////////////////////////////////////////////////////
//:: Created By: Mischa Dutzik (aka Ravick)
//:: Created On: 10/11/2020
//::///////////////////////////////////////////////////////////////////////////

#include "rav_util"
#include "x0_i0_stringlib"
#include "nw_inc_nui"

const int ESI_INJECTION_PLACEMENT_FIRST = 1;
const int ESI_INJECTION_PLACEMENT_LAST = 2;

const int ESI_OBJECT_TYPE_AREA = 303;

const string ESI_PARAM_OBJECT_TYPE = "nObjectType";
const string ESI_PARAM_KEY = "sKey";
const string ESI_PARAM_HANDLER = "nHandler";
const string ESI_PARAM_SCRIPT = "sScript";
const string ESI_PARAM_PLACEMENT = "nPlacement";

const string ESI_SCRIPT_AREA_INJECT = "esi_are_inject";

const string ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_DEATH = "crtdeath";
const string ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_SPAWN_IN = "crtspawn";
const string ESI_EVENT_NUMBER_ALIAS_ENCOUNTER_ON_OBJECT_ENTER = "encenter";
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACQUIRE_ITEM = "modacqit";
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACTIVATE_ITEM = "modact";
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_GUIEVENT = "guievt";
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_TARGET = "modtarg";
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_CHAT = "modchat";
const string ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_CLOSED = "plcclose";
const string ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_OPEN = "plcopen";
const string ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_UNLOCK = "plcunlck";
const string ESI_EVENT_NUMBER_ALIAS_AREA_ON_ENTER = "areenter";

const string ESI_LOCAL_PREFIX_INJECTION = "ESI_SCRIPT_";
const string ESI_LOCAL_SUFFIX_INJECTION_FIRST = "_FIRST";
const string ESI_LOCAL_SUFFIX_INJECTION_LAST = "_LAST";
const string ESI_LOCAL_SUFFIX_INJECTION_COUNT = "_COUNT";
const string ESI_LOCAL_SUFFIX_INJECTION_KEYS = "_KEYS";
const string ESI_LOCAL_SUFFIX_INJECTION_MAP = "_MAP";
const string ESI_LOCAL_SUFFIX_SCRIPT_ORIGINAL = "_ORIGINAL";
const string ESI_LOCAL_SUFFIX_STORAGE_SCHEMA = "_SCHEMA";
const int ESI_STORAGE_SCHEMA = 2;

const string ESI_SCRIPT_PREFIX_UNION = "esi_uni_";

const string ESI_RUNTIME_WINDOW = "meesi_runtime";
const string ESI_RUNTIME_FIELD_SCHEMA = "schema";
const string ESI_RUNTIME_FIELD_MODULE = "module";
const string ESI_RUNTIME_FIELD_SLOTS = "slots";
const string ESI_RUNTIME_FIELD_MARKERS = "markers";
const string ESI_RUNTIME_HOOK_KEY = "key";
const string ESI_RUNTIME_HOOK_SCRIPT = "script";
const int ESI_RUNTIME_SCHEMA = 1;

string ESI_GetLocalNameInjection(int nHandler, int nPlacement)
{
    return ESI_LOCAL_PREFIX_INJECTION + IntToString(nHandler) + (nPlacement == ESI_INJECTION_PLACEMENT_FIRST ? ESI_LOCAL_SUFFIX_INJECTION_FIRST : nPlacement == ESI_INJECTION_PLACEMENT_LAST ? ESI_LOCAL_SUFFIX_INJECTION_LAST : STRING_EMPTY);
}

string ESI_GetLocalNameInjectionCount(int nHandler, int nPlacement)
{
    return ESI_GetLocalNameInjection(nHandler, nPlacement) + ESI_LOCAL_SUFFIX_INJECTION_COUNT;
}

string ESI_GetLocalNameInjectionKeys(int nHandler, int nPlacement)
{
    return ESI_GetLocalNameInjection(nHandler, nPlacement) + ESI_LOCAL_SUFFIX_INJECTION_KEYS;
}

string ESI_GetLocalNameInjectionMap(int nHandler, int nPlacement)
{
    return ESI_GetLocalNameInjection(nHandler, nPlacement) + ESI_LOCAL_SUFFIX_INJECTION_MAP;
}

string ESI_GetLocalNameOriginalScript(int nHandler)
{
    return ESI_LOCAL_PREFIX_INJECTION + IntToString(nHandler) + ESI_LOCAL_SUFFIX_SCRIPT_ORIGINAL;
}

string ESI_GetLocalNameStorageSchema(int nHandler)
{
    return ESI_LOCAL_PREFIX_INJECTION + IntToString(nHandler) + ESI_LOCAL_SUFFIX_STORAGE_SCHEMA;
}

string ESI_GetEventNumberAlias(int nHandler)
{
    return nHandler == EVENT_SCRIPT_CREATURE_ON_DEATH ? ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_DEATH
         : nHandler == EVENT_SCRIPT_CREATURE_ON_SPAWN_IN ? ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_SPAWN_IN
         : nHandler == EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER ? ESI_EVENT_NUMBER_ALIAS_ENCOUNTER_ON_OBJECT_ENTER
         : nHandler == EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACQUIRE_ITEM
         : nHandler == EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACTIVATE_ITEM
         : nHandler == EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_GUIEVENT
         : nHandler == EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_TARGET
         : nHandler == EVENT_SCRIPT_MODULE_ON_PLAYER_CHAT ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_CHAT
         : nHandler == EVENT_SCRIPT_PLACEABLE_ON_CLOSED ? ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_CLOSED
         : nHandler == EVENT_SCRIPT_PLACEABLE_ON_OPEN ? ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_OPEN
         : nHandler == EVENT_SCRIPT_PLACEABLE_ON_UNLOCK ? ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_UNLOCK
         : nHandler == EVENT_SCRIPT_AREA_ON_ENTER ? ESI_EVENT_NUMBER_ALIAS_AREA_ON_ENTER
         : STRING_EMPTY;
}

string ESI_GetUnionScript(int nHandler)
{
    return ESI_SCRIPT_PREFIX_UNION + ESI_GetEventNumberAlias(nHandler);
}

json ESI_BuildRuntimeWindow()
{
    return NuiWindow(NuiVisible(NuiSpacer(), JsonBool(FALSE)), JsonString(""), NuiRect(-100.0f, -100.0f, 1.0f, 1.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(FALSE));
}

json ESI_NewRuntimeRegistry()
{
    json jRegistry = JsonObject();
    jRegistry = JsonObjectSet(jRegistry, ESI_RUNTIME_FIELD_SCHEMA, JsonInt(ESI_RUNTIME_SCHEMA));
    jRegistry = JsonObjectSet(jRegistry, ESI_RUNTIME_FIELD_MODULE, JsonString(GetModuleName() + ":" + ObjectToString(GetModule())));
    jRegistry = JsonObjectSet(jRegistry, ESI_RUNTIME_FIELD_SLOTS, JsonObject());
    jRegistry = JsonObjectSet(jRegistry, ESI_RUNTIME_FIELD_MARKERS, JsonObject());
    return jRegistry;
}

int ESI_IsRuntimeRegistry(json jRegistry)
{
    return JsonGetType(jRegistry) == JSON_TYPE_OBJECT && JsonGetInt(JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_SCHEMA)) == ESI_RUNTIME_SCHEMA && JsonGetString(JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_MODULE)) == GetModuleName() + ":" + ObjectToString(GetModule()) && JsonGetType(JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_SLOTS)) == JSON_TYPE_OBJECT && JsonGetType(JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_MARKERS)) == JSON_TYPE_OBJECT;
}

object ESI_GetRuntimeOwner()
{
    object oPlayer = GetFirstPC();
    while (GetIsObjectValid(oPlayer))
    {
        int nToken = NuiFindWindow(oPlayer, ESI_RUNTIME_WINDOW);
        if (nToken > 0 && ESI_IsRuntimeRegistry(NuiGetUserData(oPlayer, nToken))) return oPlayer;
        oPlayer = GetNextPC();
    }
    return OBJECT_INVALID;
}

int ESI_EnsureRuntime(object oPlayer)
{
    if (GetIsObjectValid(ESI_GetRuntimeOwner())) return TRUE;
    if (!GetIsPC(oPlayer) || GetIsDM(oPlayer) || GetIsObjectValid(GetMaster(oPlayer))) return FALSE;
    int nToken = NuiFindWindow(oPlayer, ESI_RUNTIME_WINDOW);
    if (nToken == 0) nToken = NuiCreate(oPlayer, ESI_BuildRuntimeWindow(), ESI_RUNTIME_WINDOW, "memoria_noop");
    if (nToken == 0) return FALSE;
    NuiSetUserData(oPlayer, nToken, ESI_NewRuntimeRegistry());
    return TRUE;
}

json ESI_GetRuntimeRegistry()
{
    object oOwner = ESI_GetRuntimeOwner();
    if (!GetIsObjectValid(oOwner)) return JsonNull();
    int nToken = NuiFindWindow(oOwner, ESI_RUNTIME_WINDOW);
    return nToken > 0 ? NuiGetUserData(oOwner, nToken) : JsonNull();
}

int ESI_SetRuntimeRegistry(json jRegistry)
{
    object oOwner = ESI_GetRuntimeOwner();
    if (!GetIsObjectValid(oOwner) || !ESI_IsRuntimeRegistry(jRegistry)) return FALSE;
    int nToken = NuiFindWindow(oOwner, ESI_RUNTIME_WINDOW);
    if (nToken == 0) return FALSE;
    NuiSetUserData(oOwner, nToken, jRegistry);
    return TRUE;
}

string ESI_GetRuntimeSlot(object oObject, int nHandler, int nPlacement)
{
    return ObjectToString(oObject) + ":" + IntToString(nHandler) + ":" + IntToString(nPlacement);
}

json ESI_GetRuntimeHooks(json jRegistry, object oObject, int nHandler, int nPlacement)
{
    json jSlots = JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_SLOTS);
    json jHooks = JsonObjectGet(jSlots, ESI_GetRuntimeSlot(oObject, nHandler, nPlacement));
    return JsonGetType(jHooks) == JSON_TYPE_ARRAY ? jHooks : JsonArray();
}

int ESI_IsRegistered(object oObject, string sKey, int nHandler, string sScript, int nPlacement)
{
    if (!GetIsObjectValid(oObject) || sKey == STRING_EMPTY || sScript == STRING_EMPTY || ESI_GetEventNumberAlias(nHandler) == STRING_EMPTY || (nPlacement != ESI_INJECTION_PLACEMENT_FIRST && nPlacement != ESI_INJECTION_PLACEMENT_LAST)) return FALSE;
    json jRegistry = ESI_GetRuntimeRegistry();
    if (!ESI_IsRuntimeRegistry(jRegistry)) return FALSE;
    json jHooks = ESI_GetRuntimeHooks(jRegistry, oObject, nHandler, nPlacement);
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jHooks); nIndex++)
    {
        json jHook = JsonArrayGet(jHooks, nIndex);
        if (JsonGetString(JsonObjectGet(jHook, ESI_RUNTIME_HOOK_KEY)) == sKey && JsonGetString(JsonObjectGet(jHook, ESI_RUNTIME_HOOK_SCRIPT)) == sScript) return TRUE;
    }
    return FALSE;
}

string ESI_GetRuntimeMarkerKey(object oObject, string sKey)
{
    return ObjectToString(oObject) + ":" + sKey;
}

int ESI_IsRuntimeMarkerSet(object oObject, string sKey)
{
    if (!GetIsObjectValid(oObject) || sKey == STRING_EMPTY) return FALSE;
    json jRegistry = ESI_GetRuntimeRegistry();
    if (!ESI_IsRuntimeRegistry(jRegistry)) return FALSE;
    json jMarkers = JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_MARKERS);
    return JsonGetInt(JsonObjectGet(jMarkers, ESI_GetRuntimeMarkerKey(oObject, sKey)));
}

int ESI_SetRuntimeMarker(object oObject, string sKey)
{
    if (!GetIsObjectValid(oObject) || sKey == STRING_EMPTY) return FALSE;
    json jRegistry = ESI_GetRuntimeRegistry();
    if (!ESI_IsRuntimeRegistry(jRegistry)) return FALSE;
    json jMarkers = JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_MARKERS);
    jMarkers = JsonObjectSet(jMarkers, ESI_GetRuntimeMarkerKey(oObject, sKey), JsonInt(TRUE));
    jRegistry = JsonObjectSet(jRegistry, ESI_RUNTIME_FIELD_MARKERS, jMarkers);
    return ESI_SetRuntimeRegistry(jRegistry);
}

void ESI_DeleteLegacyPlacement(object oObject, int nHandler, int nPlacement)
{
    string sKeyList = RAV_GetLocalString(oObject, ESI_GetLocalNameInjectionKeys(nHandler, nPlacement));
    struct sStringTokenizer stKeys = GetStringTokenizer(sKeyList, "|");
    while (HasMoreTokens(stKeys))
    {
        stKeys = AdvanceToNextToken(stKeys);
        string sKey = GetNextToken(stKeys);
        DeleteLocalString(oObject, ESI_GetLocalNameInjection(nHandler, nPlacement) + IntToString(StringToInt(sKey)));
    }
    DeleteLocalString(oObject, ESI_GetLocalNameInjectionKeys(nHandler, nPlacement));
    DeleteLocalInt(oObject, ESI_GetLocalNameInjectionCount(nHandler, nPlacement));
    DeleteLocalJson(oObject, ESI_GetLocalNameInjectionMap(nHandler, nPlacement));
}

int ESI_EnsureTrampoline(object oObject, int nHandler)
{
    string sEventAlias = ESI_GetEventNumberAlias(nHandler);
    if (!GetIsObjectValid(oObject) || sEventAlias == STRING_EMPTY) return FALSE;
    string sEventScript = GetEventScript(oObject, nHandler);
    string sUnionScript = ESI_SCRIPT_PREFIX_UNION + sEventAlias;
    if (sEventScript != sUnionScript)
    {
        RAV_SetLocalString(oObject, ESI_GetLocalNameOriginalScript(nHandler), sEventScript);
        if (!SetEventScript(oObject, nHandler, sUnionScript)) return FALSE;
    }
    if (GetLocalInt(oObject, ESI_GetLocalNameStorageSchema(nHandler)) != ESI_STORAGE_SCHEMA)
    {
        ESI_DeleteLegacyPlacement(oObject, nHandler, ESI_INJECTION_PLACEMENT_FIRST);
        ESI_DeleteLegacyPlacement(oObject, nHandler, ESI_INJECTION_PLACEMENT_LAST);
        SetLocalInt(oObject, ESI_GetLocalNameStorageSchema(nHandler), ESI_STORAGE_SCHEMA);
    }
    return TRUE;
}

int ESI_RegisterRuntimeHook(object oObject, string sKey, int nHandler, string sScript, int nPlacement)
{
    if (!GetIsObjectValid(oObject) || sKey == STRING_EMPTY || sScript == STRING_EMPTY || ESI_GetEventNumberAlias(nHandler) == STRING_EMPTY || (nPlacement != ESI_INJECTION_PLACEMENT_FIRST && nPlacement != ESI_INJECTION_PLACEMENT_LAST)) return FALSE;
    json jRegistry = ESI_GetRuntimeRegistry();
    if (!ESI_IsRuntimeRegistry(jRegistry)) return FALSE;
    json jSlots = JsonObjectGet(jRegistry, ESI_RUNTIME_FIELD_SLOTS);
    string sSlot = ESI_GetRuntimeSlot(oObject, nHandler, nPlacement);
    json jHooks = ESI_GetRuntimeHooks(jRegistry, oObject, nHandler, nPlacement);
    json jHook;
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jHooks); nIndex++)
    {
        if (JsonGetString(JsonObjectGet(JsonArrayGet(jHooks, nIndex), ESI_RUNTIME_HOOK_KEY)) == sKey)
        {
            if (JsonGetString(JsonObjectGet(JsonArrayGet(jHooks, nIndex), ESI_RUNTIME_HOOK_SCRIPT)) == sScript) return TRUE;
            if (!ESI_EnsureTrampoline(oObject, nHandler)) return FALSE;
            jHook = JsonObject();
            jHook = JsonObjectSet(jHook, ESI_RUNTIME_HOOK_KEY, JsonString(sKey));
            jHook = JsonObjectSet(jHook, ESI_RUNTIME_HOOK_SCRIPT, JsonString(sScript));
            jHooks = JsonArraySet(jHooks, nIndex, jHook);
            jSlots = JsonObjectSet(jSlots, sSlot, jHooks);
            jRegistry = JsonObjectSet(jRegistry, ESI_RUNTIME_FIELD_SLOTS, jSlots);
            return ESI_SetRuntimeRegistry(jRegistry);
        }
    }
    if (!ESI_EnsureTrampoline(oObject, nHandler)) return FALSE;
    jHook = JsonObject();
    jHook = JsonObjectSet(jHook, ESI_RUNTIME_HOOK_KEY, JsonString(sKey));
    jHook = JsonObjectSet(jHook, ESI_RUNTIME_HOOK_SCRIPT, JsonString(sScript));
    jHooks = JsonArrayInsert(jHooks, jHook);
    jSlots = JsonObjectSet(jSlots, sSlot, jHooks);
    jRegistry = JsonObjectSet(jRegistry, ESI_RUNTIME_FIELD_SLOTS, jSlots);
    return ESI_SetRuntimeRegistry(jRegistry);
}

// Compatibility facade: the original API now installs a persistent trampoline and registers a transient runtime hook.
int ESI_InjectToObject(object oObject, string sKey, int nHandler, string sScript, int nPlacement)
{
    return ESI_RegisterRuntimeHook(oObject, sKey, nHandler, sScript, nPlacement);
}

void ESI_InjectToModuleObjects(object oModule, string sKey, int nObjectType, int nHandler, string sScript, int nPlacement)
{
    if (!GetIsObjectValid(oModule)) return;
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        if (nObjectType == ESI_OBJECT_TYPE_AREA)
        {
            ESI_InjectToObject(oArea, sKey, nHandler, sScript, nPlacement);
        }
        else
        {
            SetScriptParam(ESI_PARAM_OBJECT_TYPE, IntToString(nObjectType));
            SetScriptParam(ESI_PARAM_KEY, sKey);
            SetScriptParam(ESI_PARAM_HANDLER, IntToString(nHandler));
            SetScriptParam(ESI_PARAM_SCRIPT, sScript);
            SetScriptParam(ESI_PARAM_PLACEMENT, IntToString(nPlacement));
            DelayCommand(0.0, RAV_ExecuteScript(ESI_SCRIPT_AREA_INJECT, oArea));
        }
        oArea = GetNextArea();
    }
}

string ESI_GetInjectedScript(object oObject, int nHandler, int nPlacement, string sKey)
{
    json jRegistry = ESI_GetRuntimeRegistry();
    if (!ESI_IsRuntimeRegistry(jRegistry)) return STRING_EMPTY;
    json jHooks = ESI_GetRuntimeHooks(jRegistry, oObject, nHandler, nPlacement);
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jHooks); nIndex++)
    {
        json jHook = JsonArrayGet(jHooks, nIndex);
        if (JsonGetString(JsonObjectGet(jHook, ESI_RUNTIME_HOOK_KEY)) == sKey) return JsonGetString(JsonObjectGet(jHook, ESI_RUNTIME_HOOK_SCRIPT));
    }
    return STRING_EMPTY;
}

void ESI_InjectToAreaObjects(object oArea, string sKey, int nObjectType, int nHandler, string sScript, int nPlacement)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == nObjectType && !GetIsPC(oObject)) ESI_InjectToObject(oObject, sKey, nHandler, sScript, nPlacement);
        oObject = GetNextObjectInArea(oArea);
    }
}

void ESI_ExecuteRuntimeHooks(json jRegistry, object oObject, int nHandler, int nPlacement)
{
    json jHooks = ESI_GetRuntimeHooks(jRegistry, oObject, nHandler, nPlacement);
    int nIndex;
    for (nIndex = 0; nIndex < JsonGetLength(jHooks); nIndex++)
    {
        string sScript = JsonGetString(JsonObjectGet(JsonArrayGet(jHooks, nIndex), ESI_RUNTIME_HOOK_SCRIPT));
        if (sScript != STRING_EMPTY) RAV_ExecuteScript(sScript, oObject);
    }
}

void ESI_ExecuteEventScripts(object oObject, int nHandler)
{
    RAV_PrintFunctionStrings("ESI_ExecuteEventScripts", oObject, ESI_GetEventNumberAlias(nHandler));
    json jRegistry = ESI_GetRuntimeRegistry();
    if (ESI_IsRuntimeRegistry(jRegistry)) ESI_ExecuteRuntimeHooks(jRegistry, oObject, nHandler, ESI_INJECTION_PLACEMENT_FIRST);
    string sOriginalScript = RAV_GetLocalString(oObject, ESI_GetLocalNameOriginalScript(nHandler));
    if (sOriginalScript != STRING_EMPTY) RAV_ExecuteScript(sOriginalScript, oObject);
    if (ESI_IsRuntimeRegistry(jRegistry)) ESI_ExecuteRuntimeHooks(jRegistry, oObject, nHandler, ESI_INJECTION_PLACEMENT_LAST);
}
