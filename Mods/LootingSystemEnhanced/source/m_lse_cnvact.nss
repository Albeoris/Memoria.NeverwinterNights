// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "m_lse_lib"

void main()
{
    string sConvOption = GetScriptParam("M_LSE_CONV_OPTION");
    string sConvOptionValue = GetScriptParam("M_LSE_CONV_OPTION_VALUE");
    struct ConfigOption strOption = M_LSE_GetConfigOption(StringToInt(sConvOption));

    object oSpeaker = GetLastSpeaker();
    object oFeatTarget = GetLocalObject(oSpeaker, M_LSE_LOCAL_LAST_FEAT_TARGET);

    if (strOption.Name != STRING_EMPTY)
    {
        if (strOption.Type == RAV_TYPE_BOOL)
            M_LSE_ToggleConfigBool(strOption.Name);
        else if (strOption.Type == RAV_TYPE_INT)
        {
            int nConfigValue = M_LSE_GetConfigInt(strOption.Name);
            int nConfigValueNew = nConfigValue + StringToInt(sConvOptionValue);
            M_LSE_SetConfigInt(strOption.Name, nConfigValueNew);
        }
        else if (strOption.Type == RAV_TYPE_FLOAT)
            M_LSE_SetConfigFloat(strOption.Name, StringToFloat(sConvOptionValue));
        else if (strOption.Type == RAV_TYPE_STRING)
            M_LSE_SetConfigString(strOption.Name, sConvOptionValue);
    }
    else
    {
        switch (StringToInt(sConvOption))
        {
            case 951:
                M_LSE_DestroyCorpse(oFeatTarget);
                break;
            case 952:
                M_LSE_DestroyCorpses(GetModule(), GetArea(oFeatTarget));
                break;
            case 953:
                M_LSE_DestroyCorpses(GetModule());
                break;
        }
    }

    DeleteLocalObject(oSpeaker, M_LSE_LOCAL_LAST_FEAT_TARGET);
}