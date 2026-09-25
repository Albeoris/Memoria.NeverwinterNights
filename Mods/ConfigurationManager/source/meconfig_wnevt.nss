#include "meconfig"

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    if (sEvent == "close")
    {
        MECONFIG_ClearEnableWarning(oPC);
        return;
    }
    if (sEvent != "click")
        return;
    string sElement = NuiGetEventElement();
    if (sElement == "confirm")
        MECONFIG_ConfirmEnableWarning(oPC);
    else if (sElement == "cancel")
        MECONFIG_ClearEnableWarning(oPC);
    else
        return;
    NuiDestroy(oPC, NuiGetEventWindow());
}
