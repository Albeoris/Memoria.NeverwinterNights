#include "mecm_lib"

void main()
{
    object oPC = MECM_GetRootMaster(OBJECT_SELF);
    if (!MECM_IsRootPlayer(oPC))
        return;
    if (GetLocalInt(oPC, MECM_LOCAL_DEBUG))
        SetLocalInt(oPC, MECM_LOCAL_REPORT_PENDING, TRUE);
    if (!GetLocalInt(oPC, MECM_LOCAL_ENABLED))
    {
        MECM_CancelAllTasks(oPC);
        MECM_ClearCachedHighlights(oPC);
    }
    if (!GetLocalInt(oPC, MECM_LOCAL_HIGHLIGHT))
        MECM_ClearCachedHighlights(oPC);
    ExecuteScript("mecm_registry", oPC);
    if (GetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY) && !GetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY_CONFIRMED))
    {
        SetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY, FALSE);
        MECM_RemoveInventoryHooks(oPC);
        ExecuteScript("mecm_invwarn", oPC);
    }
    else if (!GetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY))
    {
        DeleteLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY_CONFIRMED);
        MECM_RemoveInventoryHooks(oPC);
    }
    ExecuteScript("mecm_lock", oPC);
}
