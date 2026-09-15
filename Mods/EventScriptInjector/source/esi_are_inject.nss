// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "esi_lib"

void main()
{
    object oArea = OBJECT_SELF;
    int nObjectType = StringToInt(GetScriptParam(ESI_PARAM_OBJECT_TYPE));
    string sKey = GetScriptParam(ESI_PARAM_KEY);
    int nHandler = StringToInt(GetScriptParam(ESI_PARAM_HANDLER));
    string sScript = GetScriptParam(ESI_PARAM_SCRIPT);
    int nPlacement = StringToInt(GetScriptParam(ESI_PARAM_PLACEMENT));

    ESI_InjectToAreaObjects(oArea, sKey, nObjectType, nHandler, sScript, nPlacement);
}