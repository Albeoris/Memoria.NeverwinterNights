#include "m_calm_ui"

void main()
{
    object oPC = NuiGetEventPlayer();
    int iToken = NuiGetEventWindow();
    if (NuiGetEventType() != "click")
        return;
    string sElement = NuiGetEventElement();
    if (sElement == "save")
        M_CALM_SaveSettings(oPC, iToken);
    else if (sElement == "cancel")
        NuiDestroy(oPC, iToken);
}
