#include "meio_storage"

void main()
{
    object oPC = GetModuleItemAcquiredBy();
    object oItem = GetModuleItemAcquired();
    int iAcquired = GetModuleItemAcquiredStackSize();
    MEIO_Debug(oPC, "OnAcquire entered acquired=" + IntToString(iAcquired) + " from=" + ObjectToString(GetModuleItemAcquiredFrom()) + " suppress=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)) + " suppressGeneration=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_GENERATION)) + " sortMode=" + IntToString(GetLocalInt(oPC, MEIO_CFG_SORT_MODE)) + " " + MEIO_DebugItemState(oPC, oItem));
    if (!MEIO_IsPC(oPC))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=not-supported-player");
        return;
    }
    if (GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=suppression-active " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (MEIO_IsKeepOut(oPC, oItem))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=keep-out " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (GetLocalInt(oPC, MEIO_CFG_SORT_MODE) == MEIO_SORT_MODE_MANUAL)
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=manual-mode " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (!MEIO_IsScroll(oItem) && !MEIO_IsUsablePotion(oItem))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=not-managed-item " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (!MEIO_IsDirectlyIn(oItem, oPC))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=not-directly-in-player-inventory " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (iAcquired <= 0)
    {
        iAcquired = GetItemStackSize(oItem);
    }
    MEIO_Debug(oPC, "OnAcquire decision=store requested=" + IntToString(iAcquired) + " " + MEIO_DebugItemState(oPC, oItem));
    int iMoved = MEIO_IsScroll(oItem) ? MEIO_StoreAmount(oPC, oItem, iAcquired) : MEIO_StorePotionAmount(oPC, oItem, iAcquired);
    MEIO_Debug(oPC, "OnAcquire store-finished moved=" + IntToString(iMoved) + " " + MEIO_DebugItemState(oPC, oItem));
}
