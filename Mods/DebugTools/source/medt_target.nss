#include "medt_lib"

void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    if (!GetIsObjectValid(oPC)) return;
    int iMode = GetLocalInt(oPC, MEDT_LOCAL_TARGET_MODE);
    if (iMode != MEDT_TARGET_MODE_EXAMINE && iMode != MEDT_TARGET_MODE_DELETE) return;
    DeleteLocalInt(oPC, MEDT_LOCAL_TARGET_MODE);
    object oTarget = GetTargetingModeSelectedObject();
    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, MEDT_GetText(oPC, "selection_cancelled"));
        return;
    }
    if (iMode == MEDT_TARGET_MODE_EXAMINE) MEDT_Examine(oPC, oTarget);
    else MEDT_OpenDeleteConfirmation(oPC, oTarget);
}
