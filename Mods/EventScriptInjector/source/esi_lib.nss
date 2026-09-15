// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: esi_lib
/*
  Event Script Injector
  Library

  Allows dynamic assignment of multiple scripts for a single event.
  Scripts can be injected to be executed before or after an original script.
  If no original script is set for an event, only injected scripts are executed. 
  This is done by remembering the original script in a local variable on object
  and replacing the event script by a so called "union script". Any injected 
  scripts will be saved as local variables too. The union script will determine
  all the scripts to run at runtime using the local variables. 
 */
//::///////////////////////////////////////////////////////////////////////////
//:: Created By: Mischa Dutzik (aka Ravick)
//:: Created On: 10/11/2020
//::///////////////////////////////////////////////////////////////////////////

#include "rav_util"
#include "x0_i0_stringlib"

const int ESI_INJECTION_PLACEMENT_FIRST = 1;
const int ESI_INJECTION_PLACEMENT_LAST = 2;

const int ESI_OBJECT_TYPE_AREA = 303;

const string ESI_PARAM_OBJECT_TYPE = "nObjectType";
const string ESI_PARAM_KEY = "sKey";
const string ESI_PARAM_HANDLER = "nHandler";
const string ESI_PARAM_SCRIPT = "sScript";
const string ESI_PARAM_PLACEMENT = "nPlacement";

const string ESI_SCRIPT_AREA_INJECT = "esi_are_inject";

const string ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_DEATH = "crtdeath" ;
const string ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_SPAWN_IN  = "crtspawn" ;
const string ESI_EVENT_NUMBER_ALIAS_ENCOUNTER_ON_OBJECT_ENTER = "encenter" ;
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACQUIRE_ITEM = "modacqit" ;
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACTIVATE_ITEM = "modact" ;
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_GUIEVENT = "guievt" ;
const string ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_TARGET = "modtarg" ;
const string ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_CLOSED = "plcclose" ;
const string ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_OPEN = "plcopen" ;
const string ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_UNLOCK = "plcunlck" ;
const string ESI_EVENT_NUMBER_ALIAS_AREA_ON_ENTER = "areenter" ;            

/* 
    Example: Local variables for two injections assigned to OnDeath event of a creature 
    Names are constructed as follows:
        [PREFIX="ESI_SCRIPT_"]
        [EVENT_NUMBER=EVENT_SCRIPT_CREATURE_ON_DEATH]
        [INJECTION_PLACEMENT=ESI_LOCAL_SUFFIX_INJECTION_FIRST/ESI_LOCAL_SUFFIX_INJECTION_LAST]
        (KEY=100/200)
            ESI_INJECTION_5010_FIRST and ESI_INJECTION_5010_LAST are fake arrays acessed via GetLocalArrayString 
            ESI_INJECTION_5010_FIRST(100) = "ev_crtdeath_dothis"
            ESI_INJECTION_5010_FIRST(200) = "ev_crtdeath_dothat"
            ESI_INJECTION_5010_LAST(100) = "ev_crtdeath_doafter"
*/
const string ESI_LOCAL_PREFIX_INJECTION = "ESI_SCRIPT_";
const string ESI_LOCAL_SUFFIX_INJECTION_FIRST = "_FIRST";
const string ESI_LOCAL_SUFFIX_INJECTION_LAST = "_LAST";
const string ESI_LOCAL_SUFFIX_INJECTION_COUNT = "_COUNT";
const string ESI_LOCAL_SUFFIX_INJECTION_DONE = "_DONE";
const string ESI_LOCAL_SUFFIX_INJECTION_KEYS = "_KEYS";
const string ESI_LOCAL_SUFFIX_SCRIPT_ORIGINAL = "_ORIGINAL";

/* 
    Example: two scripts, one for OnDeath and one for OnSpawn of a creature
        [PREFIX="esi_uni_"][EVENT_NUMBER_ALIAS=ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_DEATH/ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_SPAWN_IN]
            esi_uni_crtdeath - assigned to OnDeath event of a creature
            esi_uni_crtspawn - assigned to OnSpawn event of a creature
    Check ESI_NUMBER_ALIAS_* constants for valid values and probably add further constants for events not already taken into account.
    Note that a new constant also requires a corresponding entry for the condition in method ESI_GetEventNumberAlias.
*/
const string ESI_SCRIPT_PREFIX_UNION = "esi_uni_";

string ESI_GetLocalNameInjectionCount(int nHandler, int nPlacement)
{
    return ESI_LOCAL_PREFIX_INJECTION + IntToString(nHandler) 
        + ( nPlacement == ESI_INJECTION_PLACEMENT_FIRST ? ESI_LOCAL_SUFFIX_INJECTION_FIRST :
            nPlacement == ESI_INJECTION_PLACEMENT_LAST  ? ESI_LOCAL_SUFFIX_INJECTION_LAST  : STRING_EMPTY ) 
        + ESI_LOCAL_SUFFIX_INJECTION_COUNT;
}
string ESI_GetLocalNameInjection(int nHandler, int nPlacement)
{
    return ESI_LOCAL_PREFIX_INJECTION + IntToString(nHandler)
        + ( nPlacement == ESI_INJECTION_PLACEMENT_FIRST ? ESI_LOCAL_SUFFIX_INJECTION_FIRST :
            nPlacement == ESI_INJECTION_PLACEMENT_LAST  ? ESI_LOCAL_SUFFIX_INJECTION_LAST  : STRING_EMPTY );
}

string ESI_GetEventNumberAlias(int nHandler)
{
    return nHandler == EVENT_SCRIPT_CREATURE_ON_DEATH           ? ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_DEATH
         : nHandler == EVENT_SCRIPT_CREATURE_ON_SPAWN_IN        ? ESI_EVENT_NUMBER_ALIAS_CREATURE_ON_SPAWN_IN
         : nHandler == EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER   ? ESI_EVENT_NUMBER_ALIAS_ENCOUNTER_ON_OBJECT_ENTER
         : nHandler == EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM      ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACQUIRE_ITEM
         : nHandler == EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM     ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_ACTIVATE_ITEM
         : nHandler == EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT   ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_GUIEVENT
         : nHandler == EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET     ? ESI_EVENT_NUMBER_ALIAS_MODULE_ON_PLAYER_TARGET
         : nHandler == EVENT_SCRIPT_PLACEABLE_ON_CLOSED         ? ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_CLOSED
         : nHandler == EVENT_SCRIPT_PLACEABLE_ON_OPEN           ? ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_OPEN
         : nHandler == EVENT_SCRIPT_PLACEABLE_ON_UNLOCK         ? ESI_EVENT_NUMBER_ALIAS_PLACEABLE_ON_UNLOCK
         : nHandler == EVENT_SCRIPT_AREA_ON_ENTER               ? ESI_EVENT_NUMBER_ALIAS_AREA_ON_ENTER
         :                                                        STRING_EMPTY;
}

string ESI_GetUnionScript(int nHandler)
{
    string sResult = ESI_SCRIPT_PREFIX_UNION + ESI_GetEventNumberAlias(nHandler);
    return sResult;
}

string ESI_GetLocalNameInjectionDone(int nHandler, string sScript, int nPlacement)
{
    return ESI_GetLocalNameInjection(nHandler, nPlacement) + STRING_UNDERSCORE + sScript + ESI_LOCAL_SUFFIX_INJECTION_DONE;
}

string ESI_GetLocalNameAreaInjectionDone(int nObjectType, int nHandler, string sScript, int nPlacement)
{
    return ESI_GetLocalNameInjection(nHandler, nPlacement) + STRING_UNDERSCORE + IntToString(nObjectType) + STRING_UNDERSCORE + sScript + ESI_LOCAL_SUFFIX_INJECTION_DONE;
}

string RAV_GetLocalNameInjectionKeys(int nHandler, int nPlacement)
{
    return ESI_LOCAL_PREFIX_INJECTION + IntToString(nHandler) 
        + ( nPlacement == ESI_INJECTION_PLACEMENT_FIRST ? ESI_LOCAL_SUFFIX_INJECTION_FIRST :
            nPlacement == ESI_INJECTION_PLACEMENT_LAST  ? ESI_LOCAL_SUFFIX_INJECTION_LAST  : STRING_EMPTY ) 
        + ESI_LOCAL_SUFFIX_INJECTION_KEYS;
}

string ESI_GetLocalNameOriginalScript(int nHandler)
{
    return ESI_LOCAL_PREFIX_INJECTION + IntToString(nHandler) + ESI_LOCAL_SUFFIX_SCRIPT_ORIGINAL ;
}

void ESI_SetInjectionsKey(object oObject, int nHandler, int nPlacement, string sKey)
{
    string sLocalKeys = RAV_GetLocalNameInjectionKeys(nHandler, nPlacement);
    string sKeyList = RAV_GetLocalString(oObject, sLocalKeys);
    if (FindSubString(sKeyList, sKey) == -1)
    {
        if (sKeyList == STRING_EMPTY)
            RAV_SetLocalString(oObject, sLocalKeys, sKey);
        else
            RAV_SetLocalString(oObject, sLocalKeys, sKeyList + "|" + sKey);
    }
}

int ESI_InjectToObject(object oObject, string sKey, int nHandler, string sScript, int nPlacement)
{
    int bResult = TRUE;

    string sEventScript = GetEventScript(oObject, nHandler);
    string sUnionScript = ESI_GetUnionScript(nHandler);
    if (sEventScript != sUnionScript)
    {
        string sOriginalScriptLocal = ESI_GetLocalNameOriginalScript(nHandler);
        RAV_SetLocalString(oObject, sOriginalScriptLocal, sEventScript);
    }

    string sLocal = ESI_GetLocalNameInjection(nHandler, nPlacement);
    string sLocalScript = RAV_GetLocalArrayString(oObject, sLocal, StringToInt(sKey));
    if (sLocalScript != sScript)
    {
        ESI_SetInjectionsKey(oObject, nHandler, nPlacement, sKey);
        RAV_SetLocalArrayString(oObject, sLocal, StringToInt(sKey), sScript);
    }

    bResult = SetEventScript(oObject, nHandler, sUnionScript);
    return bResult;
}

void ESI_InjectToModuleObjects(object oModule, string sKey, int nObjectType, int nHandler, string sScript, int nPlacement)
{ 
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        if (nObjectType == ESI_OBJECT_TYPE_AREA)
        {
            ESI_InjectToObject(oArea, sKey, nHandler, sScript, nPlacement);
        }
        else
        {
            // Single script execution per area to circumvent too many instructions error
            SetScriptParam(ESI_PARAM_OBJECT_TYPE, IntToString(nObjectType));
            SetScriptParam(ESI_PARAM_KEY, sKey);
            SetScriptParam(ESI_PARAM_HANDLER, IntToString(nHandler));
            SetScriptParam(ESI_PARAM_SCRIPT, sScript);
            SetScriptParam(ESI_PARAM_PLACEMENT, IntToString(nPlacement));
            DelayCommand(0.0, RAV_ExecuteScript(ESI_SCRIPT_AREA_INJECT, oArea));
        }
        oArea = GetNextArea();
    }

    string sLocalNameAreaInjectionDone = ESI_GetLocalNameAreaInjectionDone(nObjectType, nHandler, sScript, nPlacement);
    RAV_SetLocalInt(oArea, sLocalNameAreaInjectionDone, TRUE);
}

void ESI_InjectToAreaObjects(object oArea, string sKey, int nObjectType, int nHandler, string sScript, int nPlacement)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == nObjectType && !GetIsPC(oObject))
            ESI_InjectToObject(oObject, sKey, nHandler, sScript, nPlacement);

        oObject = GetNextObjectInArea(oArea);
    }

    string sLocalNameAreaInjectionDone = ESI_GetLocalNameAreaInjectionDone(nObjectType, nHandler, sScript, nPlacement);
    RAV_SetLocalInt(oArea, sLocalNameAreaInjectionDone, TRUE);
}

void ESI_ExecuteEventScripts(object oObject, int nHandler)
{
    RAV_PrintFunctionStrings("ESI_ExecuteEventScripts", oObject, ESI_GetEventNumberAlias(nHandler));

    // Execute injected scripts placed before original script

    string sFirstLocal = ESI_GetLocalNameInjection(nHandler, ESI_INJECTION_PLACEMENT_FIRST);
    string sFirstKeysLocal = RAV_GetLocalNameInjectionKeys(nHandler, ESI_INJECTION_PLACEMENT_FIRST);
    string sFirstKeys = RAV_GetLocalString(oObject, sFirstKeysLocal);
    string sFirstKey;
    string sFirstScript;
    struct sStringTokenizer stFirstTokenizer = GetStringTokenizer(sFirstKeys, "|");
    while (HasMoreTokens(stFirstTokenizer))
    {
        stFirstTokenizer = AdvanceToNextToken(stFirstTokenizer);
        sFirstKey = GetNextToken(stFirstTokenizer);
        sFirstScript = RAV_GetLocalArrayString(oObject, sFirstLocal, StringToInt(sFirstKey));
        if (sFirstScript != STRING_EMPTY)
            RAV_ExecuteScript(sFirstScript, oObject);
    }

    // Execute original script

    string sOriginalScriptLocal = ESI_GetLocalNameOriginalScript(nHandler); 
    string sOriginalScript = RAV_GetLocalString(oObject, sOriginalScriptLocal);
    if (sOriginalScript != STRING_EMPTY)
        RAV_ExecuteScript(sOriginalScript, oObject);

    // Execute injected scripts placed after original script

    string sLastLocal = ESI_GetLocalNameInjection(nHandler, ESI_INJECTION_PLACEMENT_LAST);
    string sLastKeysLocal = RAV_GetLocalNameInjectionKeys(nHandler, ESI_INJECTION_PLACEMENT_LAST);
    string sLastKeys = RAV_GetLocalString(oObject, sLastKeysLocal);
    string sLastKey;
    string sLastScript;
    struct sStringTokenizer stLastTokenizer = GetStringTokenizer(sLastKeys, "|");
    while (HasMoreTokens(stLastTokenizer))
    {
        stLastTokenizer = AdvanceToNextToken(stLastTokenizer);
        sLastKey = GetNextToken(stLastTokenizer);
        sLastScript = RAV_GetLocalArrayString(oObject, sLastLocal, StringToInt(sLastKey));
        if (sLastScript != STRING_EMPTY)
            RAV_ExecuteScript(sLastScript, oObject);
    }
}
