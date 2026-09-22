#include "meio_ui"

void main()
{
    object oAcquiredBy = GetModuleItemAcquiredBy();
    object oItem = GetModuleItemAcquired();
    int iAcquired = GetModuleItemAcquiredStackSize();
    object oVault = oAcquiredBy;
    if (GetTag(oVault) != MEIO_SCRIPTORIUM_TAG)
    {
        object oPossessor = GetItemPossessor(oItem, TRUE);
        if (GetTag(oPossessor) == MEIO_SCRIPTORIUM_TAG)
        {
            oVault = oPossessor;
        }
    }
    object oPC = oAcquiredBy;
    if (GetTag(oVault) == MEIO_SCRIPTORIUM_TAG)
    {
        oPC = GetItemPossessor(oVault, TRUE);
        if (MEIO_IsPC(oPC))
        {
            MEIO_Debug(oPC, "OnAcquire decision=process-vault-item " + MEIO_DebugItemState(oPC, oItem));
            MEIO_ProcessVaultContents(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE);
        }
        return;
    }
    MEIO_Debug(oPC, "OnAcquire entered acquired=" + IntToString(iAcquired) + " from=" + ObjectToString(GetModuleItemAcquiredFrom()) + " suppress=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)) + " suppressGeneration=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_GENERATION)) + " " + MEIO_DebugItemState(oPC, oItem));
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
    if (MEIO_IsTransferBusy(oPC))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=bulk-transfer-active " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (MEIO_IsKeepOut(oPC, oItem))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=keep-out " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (!MEIO_IsAutomaticForItem(oPC, oItem))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=automatic-storage-disabled-for-type " + MEIO_DebugItemState(oPC, oItem));
        return;
    }
    if (!MEIO_CanStoreItem(oItem))
    {
        MEIO_Debug(oPC, "OnAcquire decision=ignore reason=not-eligible-managed-item " + MEIO_DebugItemState(oPC, oItem));
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
    int iMoved = MEIO_IsScroll(oItem) ? MEIO_StoreAmount(oPC, oItem, iAcquired) : MEIO_IsUsablePotion(oItem) ? MEIO_StorePotionAmount(oPC, oItem, iAcquired) : MEIO_StoreBookAmount(oPC, oItem, iAcquired);
    MEIO_Debug(oPC, "OnAcquire store-finished moved=" + IntToString(iMoved) + " " + MEIO_DebugItemState(oPC, oItem));
}
