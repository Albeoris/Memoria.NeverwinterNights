#include "medt_lib"

void main()
{
    if (NuiGetEventType() != "click") return;
    object oPC = NuiGetEventPlayer();
    int iToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    if (sElement == "cancel")
    {
        DeleteLocalObject(oPC, MEDT_LOCAL_DELETE_TARGET);
        NuiDestroy(oPC, iToken);
        return;
    }
    if (sElement != "delete") return;
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
