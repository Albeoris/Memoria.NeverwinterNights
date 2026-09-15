// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: m_lse_sin_lib
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

const string M_LSE_SIN_LOCAL_LANGUAGE = "M_LSE_SIN_TEXT_LANGUAGE";
const string M_LSE_SIN_LOCAL_INDEX = "M_LSE_SIN_TEXT_SCRIPT_INDEX";
const string M_LSE_SIN_PREFIX_INDEX = "M_LSE_SIN_TEXT_";
const string M_LSE_SIN_PARAM_STRREF = "nStrRef";
const string M_LSE_SIN_DEFAULT_INDEX = "m_lse_text";
const string M_LSE_SIN_DEFAULT_LANGUAGE = "en";

void M_LSE_SIN_SetLanguage(string sSinLanguage)
{
    RAV_SetLocalString(GetModule(), M_LSE_SIN_LOCAL_LANGUAGE, sSinLanguage);
}

void M_LSE_SIN_SetIndex(string sName)
{
    RAV_SetLocalString(GetModule(), M_LSE_SIN_LOCAL_INDEX, sName);
}

string M_LSE_SIN_GetClientLanguage()
{
    string sTestString = GetStringByStrRef(3);
    string sSinLanguage = ( sTestString == "Barden"    ? "de"
                       : sTestString == "Bards"     ? "en"
                       : sTestString == "Bardos"    ? "es"
                       : sTestString == "Bardes"    ? "fr"
                       : sTestString == "Bardi"     ? "it"
                       : sTestString == "Bardowie"  ? "pl"
                       : M_LSE_SIN_DEFAULT_LANGUAGE );
    return sSinLanguage;
}

string M_LSE_SIN_GetLanguage()
{
    object oModule = GetModule();
    string sResult = RAV_GetLocalString(oModule, M_LSE_SIN_LOCAL_LANGUAGE);
    string sClientLanguage = M_LSE_SIN_GetClientLanguage();
    if (sResult != sClientLanguage) 
    {
        M_LSE_SIN_SetLanguage(sClientLanguage);
        sResult = RAV_GetLocalString(oModule, M_LSE_SIN_LOCAL_LANGUAGE);
    }
    return sResult;
}

string M_LSE_SIN_GetIndex()
{
    object oModule = GetModule();
    string sResult = RAV_GetLocalString(oModule, M_LSE_SIN_LOCAL_INDEX);
    if (sResult == STRING_EMPTY) 
    {
        M_LSE_SIN_SetIndex(M_LSE_SIN_DEFAULT_INDEX);
        sResult = RAV_GetLocalString(oModule, M_LSE_SIN_LOCAL_INDEX);
    }
    return sResult;
}

string M_LSE_SIN_GetLanguageIndex()
{
    return M_LSE_SIN_GetIndex() + STRING_UNDERSCORE + M_LSE_SIN_GetLanguage();
}

void M_LSE_SIN_SetBufferedString(int nStrRef, string sString)
{
    RAV_SetLocalArrayString(GetModule(), M_LSE_SIN_GetLanguageIndex(), nStrRef, sString);
}

string M_LSE_SIN_GetBufferedString(int nStrRef)
{
    return RAV_GetLocalArrayString(GetModule(), M_LSE_SIN_GetLanguageIndex(), nStrRef);
}

string M_LSE_SIN_GetIndexString(int nStrRef)
{
    SetScriptParam(M_LSE_SIN_PARAM_STRREF, IntToString(nStrRef));
    RAV_ExecuteScript(M_LSE_SIN_GetLanguageIndex(), OBJECT_SELF);
    return M_LSE_SIN_GetBufferedString(nStrRef);
}

string M_LSE_SIN_GetText(int nStrRef, int bUseTalkTable = FALSE)
{
    string sResult;
    if (bUseTalkTable)
    {
        sResult = RAV_GetStringByStrRef(nStrRef);
    }
    else
    {
        sResult = M_LSE_SIN_GetBufferedString(nStrRef);
        if (sResult == STRING_EMPTY)
        {
            sResult = M_LSE_SIN_GetIndexString(nStrRef);
        }
        
    }
    return sResult;
}

void M_LSE_SIN_ClearBuffer(int nMaxStrRef = 1000)
{
    RAV_PrintString("Start clearing SIN text buffer up to index number " + IntToString(nMaxStrRef) + "...");
    object oModule = GetModule();
    int nStrRef;
    for (nStrRef = 0; nStrRef <= nMaxStrRef; nStrRef++)
    {
        string sFullVarName = M_LSE_SIN_GetLanguageIndex() + IntToString(nStrRef);
        DeleteLocalString(oModule, sFullVarName);
    }
    RAV_PrintString("Finished clearing SIN text buffer up to index number " + IntToString(nMaxStrRef) + "...");
}
