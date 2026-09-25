#include "meconfig"

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    if (sEvent == "close")
    {
        if (GetLocalString(oPC, MECONFIG_LOCAL_PENDING_MODE) == "close")
            MECONFIG_ReopenDraft(oPC);
        MECONFIG_ClearPending(oPC);
        return;
    }
    if (sEvent != "click")
        return;
    string sElement = NuiGetEventElement();
    string sMode = GetLocalString(oPC, MECONFIG_LOCAL_PENDING_MODE);
    if (sElement == "save")
    {
        int nConfigToken = sMode == "close" ? MECONFIG_ReopenDraft(oPC) : NuiFindWindow(oPC, MECONFIG_WINDOW_ID);
        if (nConfigToken <= 0 || !MECONFIG_Save(oPC, nConfigToken))
        {
            MECONFIG_ClearPending(oPC);
            NuiDestroy(oPC, NuiGetEventWindow());
            return;
        }
        if (sMode == "close")
        {
            NuiDestroy(oPC, nConfigToken);
            MECONFIG_ClearPending(oPC);
            NuiDestroy(oPC, NuiGetEventWindow());
            return;
        }
    }
    else if (sElement != "discard")
        return;
    if (sMode == "close")
    {
        MECONFIG_ClearPending(oPC);
        NuiDestroy(oPC, NuiGetEventWindow());
        return;
    }
    MECONFIG_SelectPendingModule(oPC);
    NuiDestroy(oPC, NuiGetEventWindow());
}
