#include "medt_iconlib"

void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    if (!GetIsObjectValid(oPC))
    {
        return;
    }
    int iMode = GetLocalInt(oPC, MEDT_LOCAL_TARGET_MODE);
    if (iMode != MEDT_TARGET_MODE_EXAMINE && iMode != MEDT_TARGET_MODE_DELETE && iMode != MEDT_TARGET_MODE_ICON && iMode != MEDT_TARGET_MODE_USEABLE && iMode != MEDT_TARGET_MODE_CURSE)
    {
        return;
    }
    DeleteLocalInt(oPC, MEDT_LOCAL_TARGET_MODE);
    object oTarget = GetTargetingModeSelectedObject();
    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oPC, MEDT_GetText(oPC, "selection_cancelled"));
        return;
    }
    if (iMode == MEDT_TARGET_MODE_EXAMINE)
    {
        MEDT_Examine(oPC, oTarget);
    }
    else if (iMode == MEDT_TARGET_MODE_DELETE)
    {
        MEDT_OpenDeleteConfirmation(oPC, oTarget);
    }
    else if (iMode == MEDT_TARGET_MODE_ICON)
    {
        MEDT_OpenIconPicker(oPC, oTarget);
    }
    else if (iMode == MEDT_TARGET_MODE_USEABLE)
    {
        MEDT_ToggleUseable(oPC, oTarget, GetTargetingModeSelectedPosition());
    }
    else
    {
        MEDT_ToggleCurse(oPC, oTarget);
    }
}
