// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: rav_debug
/*
  Ravick's Debugging Library
 */
//::///////////////////////////////////////////////////////////////////////////
//:: Created By: Mischa Dutzik (aka Ravick)
//:: Created On: 10/10/2020
//::///////////////////////////////////////////////////////////////////////////

#include "rav_string"

const int RAV_DEBUG_PRINT_TO_GAME = FALSE;
const int RAV_DEBUG_PRINT_TO_LOG = FALSE;
const int RAV_DEBUG_PRINT_VARIABLES = FALSE;
const int RAV_DEBUG_PRINT_FUNCTIONS = FALSE;
const string RAV_DEBUG_PRINT_PREFIX = "RAV";

string RAV_GetObjectString(object oObject) 
{
    return ObjectToString(oObject) + "/" + GetName(oObject);
}

void RAV_PrintString(string sString) 
{
    if (RAV_DEBUG_PRINT_TO_GAME) {
        SendMessageToPC(GetFirstPC(), sString);
        SendMessageToAllDMs(sString);
    }
    if (RAV_DEBUG_PRINT_TO_LOG)
        PrintString(sString);
}

void RAV_Print(string sString, object oObject = OBJECT_INVALID) 
{
    if (GetIsObjectValid(oObject))
        sString = RAV_DEBUG_PRINT_PREFIX + ": [" + RAV_GetObjectString(oObject) + "] " + sString;
    else
        sString = RAV_DEBUG_PRINT_PREFIX + ": " + sString;
    RAV_PrintString(sString);
}

void RAV_PrintVariableInt(string sName, int iValue, object oObject = OBJECT_INVALID) 
{
    if (RAV_DEBUG_PRINT_VARIABLES) {
        string sString = sName + " = " + IntToString(iValue);
        RAV_Print(sString, oObject);
    }
}

void RAV_PrintVariableString(string sName, string sValue, object oObject = OBJECT_INVALID) 
{
    if (RAV_DEBUG_PRINT_VARIABLES) {
        string sString = sName + " = " + sValue;
        RAV_Print(sString, oObject);
    }
}

void RAV_PrintVariableBool(string sName, int bValue, object oObject = OBJECT_INVALID) 
{
    if (RAV_DEBUG_PRINT_VARIABLES) {
        string sString;
        if (bValue == TRUE)
            sString = sName + " = TRUE";
        else if (bValue == FALSE)
            sString = sName + " = FALSE";
        RAV_Print(sString, oObject);
    }
}

void RAV_PrintVariableObject(string sName, object oValue, object oObject = OBJECT_INVALID) 
{
    if (RAV_DEBUG_PRINT_VARIABLES) {
        string sString = sName + " = " + RAV_GetObjectString(oValue);
        RAV_Print(sString, oObject);
    }
}

void RAV_PrintFunction(string sName, object oObject = OBJECT_SELF, object oArg1 = OBJECT_INVALID, object oArg2 = OBJECT_INVALID, object oArg3 = OBJECT_INVALID, object oArg4 = OBJECT_INVALID) 
{
    if (RAV_DEBUG_PRINT_FUNCTIONS) {
        string sString = sName + "(";
        if (oArg1 != OBJECT_INVALID) sString = sString + RAV_GetObjectString(oArg1);
        if (oArg2 != OBJECT_INVALID) sString = sString + "," + RAV_GetObjectString(oArg2);
        if (oArg3 != OBJECT_INVALID) sString = sString + "," + RAV_GetObjectString(oArg3);
        if (oArg4 != OBJECT_INVALID) sString = sString + "," + RAV_GetObjectString(oArg4);
        sString = sString + ")";
        RAV_Print(sString, oObject);
    }
}

void RAV_PrintFunctionStrings(string sName, object oObject = OBJECT_SELF, string sArg1 = STRING_EMPTY, string sArg2 = STRING_EMPTY, string sArg3 = STRING_EMPTY, string sArg4 = STRING_EMPTY) 
{
    if (RAV_DEBUG_PRINT_FUNCTIONS) {
        string sString = sName + "(";
        if (sArg1 != STRING_EMPTY) sString = sString +       sArg1;
        if (sArg2 != STRING_EMPTY) sString = sString + "," + sArg2;
        if (sArg3 != STRING_EMPTY) sString = sString + "," + sArg3;
        if (sArg4 != STRING_EMPTY) sString = sString + "," + sArg4;
        sString = sString + ")";
        RAV_Print(sString, oObject);
    }
}
