#include "memoria_config"

void main()
{
    object oPC = NuiGetEventPlayer();
    int nToken = NuiGetEventWindow();
    if (NuiGetEventType() != "click")
        return;
    string sElement = NuiGetEventElement();
    if (sElement == "close")
        NuiDestroy(oPC, nToken);
    else if (sElement == "save")
        MEMORIA_CONFIG_Save(oPC, nToken);
    else if (sElement == "module_select")
    {
        json jModules = MEMORIA_CONFIG_GetModules(oPC);
        int nIndex = NuiGetEventArrayIndex();
        if (nIndex >= 0 && nIndex < JsonGetLength(jModules))
            SetLocalString(oPC, MEMORIA_CONFIG_LOCAL_SELECTED_ID, JsonGetString(JsonObjectGet(JsonArrayGet(jModules, nIndex), "id")));
        MEMORIA_CONFIG_Open(oPC);
    }
    else if (GetSubString(sElement, 0, 7) == "action_")
    {
        MEMORIA_CONFIG_RunAction(oPC, StringToInt(GetSubString(sElement, 7, GetStringLength(sElement) - 7)));
        NuiDestroy(oPC, nToken);
    }
}
