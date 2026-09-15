// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: rav_util
/*
  Ravick's Utility Library
 */
//::///////////////////////////////////////////////////////////////////////////
//:: Created By: Mischa Dutzik (aka Ravick)
//:: Created On: 10/10/2020
//::///////////////////////////////////////////////////////////////////////////

#include "rav_debug"

const string RAV_TYPE_BOOL = "bool";
const string RAV_TYPE_INT = "int";
const string RAV_TYPE_FLOAT = "float";
const string RAV_TYPE_STRING = "string";

//::///////////////////////////////////////////////////////////////////////////
//:: Methods copied from nw_o0_itemmaker.nss

string GetLocalArrayString(object oObject, string sVarName, int nVarNum)
{
    string sFullVarName = sVarName + IntToString(nVarNum) ;
    return GetLocalString(oObject, sFullVarName);
}

void SetLocalArrayString(object oObject, string sVarName, int nVarNum, string sValue)
{
    string sFullVarName = sVarName + IntToString(nVarNum) ;
    SetLocalString(oObject, sFullVarName, sValue);
}

int GetLocalArrayInt(object oObject, string sVarName, int nVarNum)
{
    string sFullVarName = sVarName + IntToString(nVarNum) ;
    return GetLocalInt(oObject, sFullVarName);
}

void SetLocalArrayInt(object oObject, string sVarName, int nVarNum, int nValue)
{
    string sFullVarName = sVarName + IntToString(nVarNum) ;
    SetLocalInt(oObject, sFullVarName, nValue);
}

//::///////////////////////////////////////////////////////////////////////////

void RAV_SetLocalInt(object oObject, string sVarName, int nValue) 
{
    SetLocalInt(oObject, sVarName, nValue);
    RAV_PrintVariableInt("SetLocalInt->" + sVarName, nValue, oObject);
}

void RAV_SetLocalString(object oObject, string sVarName, string sValue) 
{
    SetLocalString(oObject, sVarName, sValue);
    RAV_PrintVariableString("SetLocalString->" + sVarName, sValue, oObject);
}

void RAV_SetLocalFloat(object oObject, string sVarName, float fValue) 
{
    SetLocalFloat(oObject, sVarName, fValue);
    RAV_PrintVariableString("SetLocalFloat->" + sVarName, FloatToString(fValue), oObject);
}

void RAV_SetLocalArrayString(object oObject, string sVarName, int nVarNum, string sValue) 
{
    SetLocalArrayString(oObject, sVarName, nVarNum, sValue);
    RAV_PrintVariableString("SetLocalArrayString->" + sVarName + "[" + IntToString(nVarNum) + "]", sValue, oObject);
}

void RAV_SetLocalObject(object oObject, string sVarName, object oValue) 
{
    SetLocalObject(oObject, sVarName, oValue);
    RAV_PrintVariableObject("RAV_SetLocalObject->" + sVarName, oValue, oObject);
}

void RAV_DeleteLocalInt(object oObject, string sVarName) 
{
    DeleteLocalInt(oObject, sVarName);
    RAV_PrintFunctionStrings("RAV_DeleteLocalInt", oObject, sVarName);
}

void RAV_DeleteLocalString(object oObject, string sVarName) 
{
    DeleteLocalString(oObject, sVarName);
    RAV_PrintFunctionStrings("RAV_DeleteLocalString", oObject, sVarName);
}

int RAV_GetLocalInt(object oObject, string sVarName) 
{
    int nValue = GetLocalInt(oObject, sVarName);
    //RAV_PrintVariableInt("RAV_GetLocalInt->" + sVarName, nValue, oObject);
    return nValue;
}

float RAV_GetLocalFloat(object oObject, string sVarName) 
{
    float fValue = GetLocalFloat(oObject, sVarName);
    //RAV_PrintVariableFloat("RAV_PrintVariableFloat->" + sVarName, fValue, oObject);
    return fValue;
}

string RAV_GetLocalString(object oObject, string sVarName) 
{
    string sValue = GetLocalString(oObject, sVarName);
    //RAV_PrintVariableString("RAV_GetLocalString->" + sVarName, sValue, oObject);
    return sValue;
}

string RAV_GetLocalArrayString(object oObject, string sVarName, int nVarNum) 
{
    string sValue = GetLocalArrayString(oObject, sVarName, nVarNum);
    // RAV_PrintVariableString("RAV_GetLocalArrayString->" + sVarName + "[" + IntToString(nVarNum) + "]", sValue, oObject);
    return sValue;
}

object RAV_GetLocalObject(object oObject, string sVarName) 
{
    object oValue = GetLocalObject(oObject, sVarName);
    // RAV_PrintVariableObject("RAV_GetLocalObject->" + sVarName, oValue, oObject);
    return oValue;
}

int RAV_IsItemGold(object oItem, int iStackSize) 
{
    return oItem == OBJECT_INVALID && iStackSize > 0;
}

int RAV_IsItemValid(object oItem, int iStackSize) 
{
    int bResult = GetIsObjectValid(oItem) || RAV_IsItemGold(oItem, iStackSize);
    //if (iResult) RAV_PrintVariableBool("RAV_IsItemValid", TRUE, oItem);
    return bResult;
}

void RAV_ExecuteScript(string sScript, object oTarget)
{
    RAV_PrintFunctionStrings("ExecuteScript", oTarget, sScript);
    ExecuteScript(sScript, oTarget);
}
