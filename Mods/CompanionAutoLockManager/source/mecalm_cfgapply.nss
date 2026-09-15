#include "mecalm_lib"

void main()
{
    object oPC = MECALM_GetRootMaster(OBJECT_SELF);
    if (!MECALM_IsRootPlayer(oPC))
        return;
    if (GetLocalInt(oPC, MECALM_LOCAL_DEBUG))
        SetLocalInt(oPC, MECALM_LOCAL_REPORT_PENDING, TRUE);
    if (!GetLocalInt(oPC, MECALM_LOCAL_ENABLED))
    {
        MECALM_CancelAllTasks(oPC);
        MECALM_ClearCachedHighlights(oPC);
    }
    if (!GetLocalInt(oPC, MECALM_LOCAL_HIGHLIGHT))
        MECALM_ClearCachedHighlights(oPC);
    ExecuteScript("mecalm_registry", oPC);
    ExecuteScript("mecalm_lock", oPC);
}