// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "m_lse_lib"

int StartingConditional()
{
    string sConvOption = GetScriptParam("M_LSE_CONV_OPTION");
    struct ConfigOption strOption = M_LSE_GetConfigOption(StringToInt(sConvOption));

    if (strOption.Name != STRING_EMPTY)
        return TRUE;    
    else 
        return FALSE;
}