#include "meconfig"

void main()
{
    object oPC = NuiGetEventPlayer();
    int nToken = NuiGetEventWindow();
    if (NuiGetEventType() != "click")
        return;
    string sElement = NuiGetEventElement();
    if (sElement == "save")
        MECONFIG_Save(oPC, nToken);
    else if (sElement == "module_select")
    {
        json jModules = MECONFIG_GetModules(oPC);
        int nIndex = NuiGetEventArrayIndex();
        if (nIndex >= 0 && nIndex < JsonGetLength(jModules))
            SetLocalString(oPC, MECONFIG_LOCAL_SELECTED_ID, JsonGetString(JsonObjectGet(JsonArrayGet(jModules, nIndex), "id")));
        MECONFIG_Open(oPC);
    }
    else if (GetSubString(sElement, 0, 7) == "action_")
    {
        MECONFIG_RunAction(oPC, StringToInt(GetSubString(sElement, 7, GetStringLength(sElement) - 7)));
        NuiDestroy(oPC, nToken);
    }
}
