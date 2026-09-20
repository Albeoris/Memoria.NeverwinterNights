#include "medt_iconlib"

void main()
{
    object oPC = NuiGetEventPlayer();
    int iToken = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    if (sEvent == "close")
    {
        if (iToken == NuiFindWindow(oPC, MEDT_ICON_WINDOW_ID))
        {
            DeleteLocalObject(oPC, MEDT_LOCAL_ICON_TARGET);
        }
        return;
    }
    if (sEvent != "click")
    {
        return;
    }
    string sElement = NuiGetEventElement();
    if (GetStringLeft(sElement, 5) == "icon_")
    {
        MEDT_ChangeItemIcon(oPC, iToken, StringToInt(GetSubString(sElement, 5, GetStringLength(sElement) - 5)));
        return;
    }
    if (sElement == "cancel")
    {
        DeleteLocalObject(oPC, MEDT_LOCAL_DELETE_TARGET);
        NuiDestroy(oPC, iToken);
        return;
    }
    if (sElement != "delete")
    {
        return;
    }
    object oTarget = GetLocalObject(oPC, MEDT_LOCAL_DELETE_TARGET);
    DeleteLocalObject(oPC, MEDT_LOCAL_DELETE_TARGET);
    NuiDestroy(oPC, iToken);
    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, MEDT_GetText(oPC, "target_missing"));
        return;
    }
    string sMessage = MEDT_FormatObjectText(oPC, "deleted", oTarget);
    DestroyObject(oTarget);
    SendMessageToPC(oPC, sMessage);
}
