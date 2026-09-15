#include "m_calm_lib"

void main()
{
    object oPC = M_CALM_GetRootMaster(OBJECT_SELF);
    if (!M_CALM_IsRootPlayer(oPC))
        return;
    if (GetLocalInt(oPC, M_CALM_LOCAL_DEBUG))
        SetLocalInt(oPC, M_CALM_LOCAL_REPORT_PENDING, TRUE);
    if (!GetLocalInt(oPC, M_CALM_LOCAL_ENABLED))
    {
        M_CALM_CancelAllTasks(oPC);
        M_CALM_ClearCachedHighlights(oPC);
    }
    if (!GetLocalInt(oPC, M_CALM_LOCAL_HIGHLIGHT))
        M_CALM_ClearCachedHighlights(oPC);
    ExecuteScript("m_calm_registry", oPC);
    ExecuteScript("m_calm_lock", oPC);
}