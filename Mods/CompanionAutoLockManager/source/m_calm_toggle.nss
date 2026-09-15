#include "m_calm_lib"

void main()
{
    object oPC = M_CALM_GetRootMaster(OBJECT_SELF);
    if (!M_CALM_IsRootPlayer(oPC))
        return;

    int bEnabled = !GetLocalInt(oPC, M_CALM_LOCAL_ENABLED);
    SetLocalInt(oPC, M_CALM_LOCAL_ENABLED, bEnabled);
    if (bEnabled)
    {
        SetLocalInt(oPC, M_CALM_LOCAL_REPORT_PENDING, TRUE);
        ExecuteScript("m_calm_registry", oPC);
        ExecuteScript("m_calm_lock", oPC);
    }
    else
    {
        M_CALM_CancelAllTasks(oPC);
        M_CALM_ClearCachedHighlights(oPC);
    }
    object oItem = GetItemPossessedBy(oPC, M_CALM_ITEM_TAG);
    if (GetIsObjectValid(oItem))
        M_CALM_LocalizeItem(oItem, oPC);
    SendMessageToPC(oPC, M_CALM_GetText(bEnabled ? M_CALM_TEXT_MODE_ENABLED : M_CALM_TEXT_MODE_DISABLED, oPC));
}
