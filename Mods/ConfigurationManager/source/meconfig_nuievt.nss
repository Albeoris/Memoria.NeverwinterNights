#include "meconfig"

void main()
{
    if (MEMORIA_NUI_HandleHelpEvent()) return;
    object oPC = NuiGetEventPlayer();
    int nToken = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    if (sEvent == "close")
    {
        MEMORIA_GUI_ScheduleItemExamineSuppression(oPC, GetLocalObject(oPC, MECONFIG_LOCAL_ITEM_OBJECT));
        if (MECONFIG_HasUnsavedChanges(oPC, nToken))
            MECONFIG_RequestClose(oPC, nToken);
        return;
    }
    if (sEvent == "watch" && GetSubString(NuiGetEventElement(), 0, 7) == "option_")
    {
        MECONFIG_RequestEnableWarning(oPC, nToken, StringToInt(GetSubString(NuiGetEventElement(), 7, GetStringLength(NuiGetEventElement()) - 7)));
        return;
    }
    if (sEvent != "click")
        return;
    string sElement = NuiGetEventElement();
    if (sElement == "save")
        MECONFIG_Save(oPC, nToken);
    else if (sElement == "module_select")
        MECONFIG_RequestModule(oPC, nToken, NuiGetEventArrayIndex());
    else if (GetSubString(sElement, 0, 7) == "action_")
    {
        MECONFIG_RunAction(oPC, StringToInt(GetSubString(sElement, 7, GetStringLength(sElement) - 7)));
        NuiDestroy(oPC, nToken);
    }
}
