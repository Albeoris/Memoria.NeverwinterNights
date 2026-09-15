// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: melse_sin_lib
/*
  Scriptable Internationalization
  Library

  Enables managing of translatable strings using language dependant script files. 
  This allows for a more dynamic way of working with strings compared to a custom 
  TLK file, as such has to be explicitly assigned to a module in toolset and 
  misses any flexible or useful translation capabilities.
 */
//::///////////////////////////////////////////////////////////////////////////
//:: Created By: Mischa Dutzik (aka Ravick)
//:: Created On: 10/23/2020
//::///////////////////////////////////////////////////////////////////////////

#include "rav_util"

const string MELSE_SIN_LOCAL_LANGUAGE = "MELSE_SIN_TEXT_LANGUAGE";
const string MELSE_SIN_LOCAL_INDEX = "MELSE_SIN_TEXT_SCRIPT_INDEX";
const string MELSE_SIN_PREFIX_INDEX = "MELSE_SIN_TEXT_";
const string MELSE_SIN_PARAM_STRREF = "nStrRef";
const string MELSE_SIN_DEFAULT_INDEX = "melse_text";
const string MELSE_SIN_DEFAULT_LANGUAGE = "en";

void MELSE_SIN_SetLanguage(string sSinLanguage)
{
    RAV_SetLocalString(GetModule(), MELSE_SIN_LOCAL_LANGUAGE, sSinLanguage);
}

void MELSE_SIN_SetIndex(string sName)
{
    RAV_SetLocalString(GetModule(), MELSE_SIN_LOCAL_INDEX, sName);
}

string MELSE_SIN_GetClientLanguage()
{
    string sTestString = GetStringByStrRef(3);
    string sSinLanguage = ( sTestString == "Barden"    ? "de"
                       : sTestString == "Bards"     ? "en"
                       : sTestString == "Bardos"    ? "es"
                       : sTestString == "Bardes"    ? "fr"
                       : sTestString == "Bardi"     ? "it"
                       : sTestString == "Bardowie"  ? "pl"
                       : MELSE_SIN_DEFAULT_LANGUAGE );
    return sSinLanguage;
}

string MELSE_SIN_GetLanguage()
{
    object oModule = GetModule();
    string sResult = RAV_GetLocalString(oModule, MELSE_SIN_LOCAL_LANGUAGE);
    string sClientLanguage = MELSE_SIN_GetClientLanguage();
    if (sResult != sClientLanguage) 
    {
        MELSE_SIN_SetLanguage(sClientLanguage);
        sResult = RAV_GetLocalString(oModule, MELSE_SIN_LOCAL_LANGUAGE);
    }
    return sResult;
}

string MELSE_SIN_GetIndex()
{
    object oModule = GetModule();
    string sResult = RAV_GetLocalString(oModule, MELSE_SIN_LOCAL_INDEX);
    if (sResult == STRING_EMPTY) 
    {
        MELSE_SIN_SetIndex(MELSE_SIN_DEFAULT_INDEX);
        sResult = RAV_GetLocalString(oModule, MELSE_SIN_LOCAL_INDEX);
    }
    return sResult;
}

string MELSE_SIN_GetLanguageIndex()
{
    return MELSE_SIN_GetIndex() + STRING_UNDERSCORE + MELSE_SIN_GetLanguage();
}

void MELSE_SIN_SetBufferedString(int nStrRef, string sString)
{
    RAV_SetLocalArrayString(GetModule(), MELSE_SIN_GetLanguageIndex(), nStrRef, sString);
}

string MELSE_SIN_GetBufferedString(int nStrRef)
{
    return RAV_GetLocalArrayString(GetModule(), MELSE_SIN_GetLanguageIndex(), nStrRef);
}

string MELSE_SIN_GetIndexString(int nStrRef)
{
    SetScriptParam(MELSE_SIN_PARAM_STRREF, IntToString(nStrRef));
    RAV_ExecuteScript(MELSE_SIN_GetLanguageIndex(), OBJECT_SELF);
    return MELSE_SIN_GetBufferedString(nStrRef);
}

string MELSE_SIN_GetText(int nStrRef, int bUseTalkTable = FALSE)
{
    string sResult;
    if (bUseTalkTable)
    {
        sResult = RAV_GetStringByStrRef(nStrRef);
    }
    else
    {
        sResult = MELSE_SIN_GetBufferedString(nStrRef);
        if (sResult == STRING_EMPTY)
        {
            sResult = MELSE_SIN_GetIndexString(nStrRef);
        }
        
    }
    return sResult;
}

void MELSE_SIN_ClearBuffer(int nMaxStrRef = 1000)
{
    RAV_PrintString("Start clearing SIN text buffer up to index number " + IntToString(nMaxStrRef) + "...");
    object oModule = GetModule();
    int nStrRef;
    for (nStrRef = 0; nStrRef <= nMaxStrRef; nStrRef++)
    {
        string sFullVarName = MELSE_SIN_GetLanguageIndex() + IntToString(nStrRef);
        DeleteLocalString(oModule, sFullVarName);
    }
    RAV_PrintString("Finished clearing SIN text buffer up to index number " + IntToString(nMaxStrRef) + "...");
}
