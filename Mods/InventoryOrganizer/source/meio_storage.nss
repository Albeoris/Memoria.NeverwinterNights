// Persistent physical scroll storage and inventory transfer.

#include "meio_core"

int MEIO_CopyAmount(object oSource, object oTarget, int iRequested);

int MEIO_CountVariant(object oContainer, string sKey)
{
    int iCount;
    object oItem = GetFirstItemInInventory(oContainer);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oContainer) && MEIO_IsScroll(oItem))
        {
            int iSubtype = MEIO_GetOnlyCastSubtype(oItem);
            if (iSubtype >= 0 && MEIO_GetVariantKey(oItem, iSubtype) == sKey)
            {
                iCount += GetItemStackSize(oItem);
            }
        }
        oItem = GetNextItemInInventory(oContainer);
    }
    return iCount;
}

int MEIO_CountPotionVariant(object oContainer, string sKey)
{
    int iCount;
    object oItem = GetFirstItemInInventory(oContainer);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oContainer) && MEIO_IsPotion(oItem))
        {
            int iSubtype = MEIO_GetOnlyCastSubtype(oItem);
            if (iSubtype >= 0 && MEIO_GetPotionKey(oItem, iSubtype) == sKey)
            {
                iCount += GetItemStackSize(oItem);
            }
        }
        oItem = GetNextItemInInventory(oContainer);
    }
    return iCount;
}

int MEIO_IsInScriptorium(object oStorage, object oItem)
{
    return MEIO_IsDirectlyIn(oItem, oStorage);
}

object MEIO_FindRuntimeStorage(object oPC)
{
    object oStorage = GetLocalObject(oPC, MEIO_LOCAL_STORAGE);
    if (GetIsObjectValid(oStorage) && GetObjectType(oStorage) == OBJECT_TYPE_STORE && GetTag(oStorage) == MEIO_STORAGE_TAG)
    {
        return oStorage;
    }
    int iIndex;
    oStorage = GetObjectByTag(MEIO_STORAGE_TAG, iIndex);
    while (GetIsObjectValid(oStorage))
    {
        if (GetObjectType(oStorage) == OBJECT_TYPE_STORE && GetLocalObject(oStorage, MEIO_LOCAL_STORAGE_OWNER) == oPC)
        {
            SetLocalObject(oPC, MEIO_LOCAL_STORAGE, oStorage);
            return oStorage;
        }
        iIndex++;
        oStorage = GetObjectByTag(MEIO_STORAGE_TAG, iIndex);
    }
    return OBJECT_INVALID;
}

object MEIO_EnsureStorage(object oPC)
{
    object oStorage = MEIO_FindRuntimeStorage(oPC);
    if (!GetIsObjectValid(oStorage))
    {
        oStorage = CreateObject(OBJECT_TYPE_STORE, MEIO_STORAGE_RESREF, GetLocation(oPC), FALSE, MEIO_STORAGE_TAG);
    }
    if (!GetIsObjectValid(oStorage))
    {
        return OBJECT_INVALID;
    }
    SetTag(oStorage, MEIO_STORAGE_TAG);
    SetLocalObject(oStorage, MEIO_LOCAL_STORAGE_OWNER, oPC);
    SetLocalObject(oPC, MEIO_LOCAL_STORAGE, oStorage);
    return oStorage;
}

object MEIO_FindRuntimePotionStorage(object oPC)
{
    object oStorage = GetLocalObject(oPC, MEIO_LOCAL_POTION_STORAGE);
    if (GetIsObjectValid(oStorage) && GetObjectType(oStorage) == OBJECT_TYPE_STORE && GetTag(oStorage) == MEIO_POTION_STORAGE_TAG)
    {
        return oStorage;
    }
    int iIndex;
    oStorage = GetObjectByTag(MEIO_POTION_STORAGE_TAG, iIndex);
    while (GetIsObjectValid(oStorage))
    {
        if (GetObjectType(oStorage) == OBJECT_TYPE_STORE && GetLocalObject(oStorage, MEIO_LOCAL_STORAGE_OWNER) == oPC)
        {
            SetLocalObject(oPC, MEIO_LOCAL_POTION_STORAGE, oStorage);
            return oStorage;
        }
        iIndex++;
        oStorage = GetObjectByTag(MEIO_POTION_STORAGE_TAG, iIndex);
    }
    return OBJECT_INVALID;
}

object MEIO_EnsurePotionStorage(object oPC)
{
    object oStorage = MEIO_FindRuntimePotionStorage(oPC);
    if (!GetIsObjectValid(oStorage))
    {
        oStorage = CreateObject(OBJECT_TYPE_STORE, MEIO_POTION_STORAGE_RESREF, GetLocation(oPC), FALSE, MEIO_POTION_STORAGE_TAG);
    }
    if (!GetIsObjectValid(oStorage))
    {
        return OBJECT_INVALID;
    }
    SetTag(oStorage, MEIO_POTION_STORAGE_TAG);
    SetLocalObject(oStorage, MEIO_LOCAL_STORAGE_OWNER, oPC);
    SetLocalObject(oPC, MEIO_LOCAL_POTION_STORAGE, oStorage);
    return oStorage;
}

void MEIO_ScheduleStorageSave(object oPC)
{
    MEIO_Debug(oPC, "Storage changed; persistence is owned by the current save game");
}

object MEIO_FindScriptorium(object oPC)
{
    object oCached = GetLocalObject(oPC, MEIO_LOCAL_SCRIPTORIUM);
    if (MEIO_IsDirectlyIn(oCached, oPC) && GetTag(oCached) == MEIO_SCRIPTORIUM_TAG && GetBaseItemType(oCached) == BASE_ITEM_LARGEBOX)
    {
        return oCached;
    }
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && GetTag(oItem) == MEIO_SCRIPTORIUM_TAG && GetBaseItemType(oItem) == BASE_ITEM_LARGEBOX)
        {
            SetLocalObject(oPC, MEIO_LOCAL_SCRIPTORIUM, oItem);
            return oItem;
        }
        oItem = GetNextItemInInventory(oPC);
    }
    return OBJECT_INVALID;
}

int MEIO_CopyAmount(object oSource, object oTarget, int iRequested)
{
    if (!GetIsObjectValid(oSource) || !GetIsObjectValid(oTarget) || iRequested <= 0)
    {
        return 0;
    }
    int iSourceSize = GetItemStackSize(oSource);
    if (iRequested > iSourceSize)
    {
        iRequested = iSourceSize;
    }
    int iSubtype = MEIO_GetOnlyCastSubtype(oSource);
    string sKey = iSubtype >= 0 ? MEIO_GetVariantKey(oSource, iSubtype) : "";
    int iBefore = sKey == "" ? 0 : MEIO_CountVariant(oTarget, sKey);
    if (iRequested < iSourceSize)
    {
        SetItemStackSize(oSource, iRequested);
    }
    object oCopy = CopyItem(oSource, oTarget, TRUE);
    if (iRequested < iSourceSize)
    {
        SetItemStackSize(oSource, iSourceSize);
    }
    int iAfter = sKey == "" ? 0 : MEIO_CountVariant(oTarget, sKey);
    int iMoved = iAfter - iBefore;
    if (iMoved < 0)
    {
        iMoved = 0;
    }
    if (iMoved > iRequested)
    {
        iMoved = iRequested;
    }
    if (iMoved == 0 && GetIsObjectValid(oCopy) && !MEIO_IsDirectlyIn(oCopy, oTarget))
    {
        DestroyObject(oCopy);
    }
    return iMoved;
}

int MEIO_CopyPotionAmount(object oSource, object oTarget, int iRequested)
{
    if (!GetIsObjectValid(oSource) || !GetIsObjectValid(oTarget) || iRequested <= 0)
    {
        return 0;
    }
    int iSourceSize = GetItemStackSize(oSource);
    if (iRequested > iSourceSize)
    {
        iRequested = iSourceSize;
    }
    int iSubtype = MEIO_GetOnlyCastSubtype(oSource);
    string sKey = iSubtype >= 0 ? MEIO_GetPotionKey(oSource, iSubtype) : "";
    int iBefore = sKey == "" ? 0 : MEIO_CountPotionVariant(oTarget, sKey);
    if (iRequested < iSourceSize)
    {
        SetItemStackSize(oSource, iRequested);
    }
    object oCopy = CopyItem(oSource, oTarget, TRUE);
    if (iRequested < iSourceSize)
    {
        SetItemStackSize(oSource, iSourceSize);
    }
    int iAfter = sKey == "" ? 0 : MEIO_CountPotionVariant(oTarget, sKey);
    int iMoved = iAfter - iBefore;
    if (iMoved < 0)
    {
        iMoved = 0;
    }
    if (iMoved > iRequested)
    {
        iMoved = iRequested;
    }
    if (iMoved == 0 && GetIsObjectValid(oCopy) && !MEIO_IsDirectlyIn(oCopy, oTarget))
    {
        DestroyObject(oCopy);
    }
    return iMoved;
}

int MEIO_StoreAmountInternal(object oPC, object oScroll, int iRequested, int bIgnoreSuppression)
{
    MEIO_Debug(oPC, "StoreAmount entered requested=" + IntToString(iRequested) + " explicit=" + IntToString(bIgnoreSuppression) + " suppress=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)) + " " + MEIO_DebugItemState(oPC, oScroll));
    if (!MEIO_IsScroll(oScroll) || !MEIO_CanStoreItem(oScroll))
    {
        MEIO_Debug(oPC, "StoreAmount decision=ignore reason=not-scroll " + MEIO_DebugItemState(oPC, oScroll));
        return 0;
    }
    if (!MEIO_IsDirectlyIn(oScroll, oPC))
    {
        MEIO_Debug(oPC, "StoreAmount decision=ignore reason=not-directly-in-player-inventory " + MEIO_DebugItemState(oPC, oScroll));
        return 0;
    }
    if (!bIgnoreSuppression && GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT))
    {
        MEIO_Debug(oPC, "StoreAmount decision=ignore reason=suppression-active " + MEIO_DebugItemState(oPC, oScroll));
        return 0;
    }
    object oStorage = MEIO_EnsureStorage(oPC);
    if (!GetIsObjectValid(oStorage))
    {
        MEIO_Debug(oPC, "StoreAmount decision=ignore reason=storage-invalid");
        return 0;
    }
    MEIO_Debug(oPC, "StoreAmount decision=store storage=" + ObjectToString(oStorage) + " before-unmark " + MEIO_DebugItemState(oPC, oScroll));
    MEIO_NormalizeExtractedTag(oScroll);
    MEIO_UnmarkKeepOut(oPC, oScroll);
    int iRemaining = iRequested;
    if (iRemaining > GetItemStackSize(oScroll))
    {
        iRemaining = GetItemStackSize(oScroll);
    }
    int iMoved;
    while (iRemaining > 0 && GetIsObjectValid(oScroll))
    {
        int iCopied;
        int iChunk = iRemaining;
        while (iChunk > 0 && iCopied == 0)
        {
            MEIO_Debug(oPC, "StoreAmount copy-attempt chunk=" + IntToString(iChunk) + " remaining=" + IntToString(iRemaining) + " " + MEIO_DebugItemState(oPC, oScroll));
            iCopied = MEIO_CopyAmount(oScroll, oStorage, iChunk);
            if (iCopied == 0)
            {
                iChunk /= 2;
            }
        }
        if (iCopied == 0)
        {
            break;
        }
        iMoved += iCopied;
        iRemaining -= iCopied;
        int iStack = GetItemStackSize(oScroll);
        if (iCopied >= iStack)
        {
            DestroyObject(oScroll);
            oScroll = OBJECT_INVALID;
        }
        else
        {
            SetItemStackSize(oScroll, iStack - iCopied);
        }
    }
    if (iMoved > 0)
    {
        MEIO_ScheduleStorageSave(oPC);
    }
    MEIO_Debug(oPC, "StoreAmount finished moved=" + IntToString(iMoved) + " requested=" + IntToString(iRequested) + " " + MEIO_DebugItemState(oPC, oScroll));
    return iMoved;
}

int MEIO_StoreAmount(object oPC, object oScroll, int iRequested)
{
    return MEIO_StoreAmountInternal(oPC, oScroll, iRequested, FALSE);
}

int MEIO_StoreAmountExplicit(object oPC, object oScroll, int iRequested)
{
    return MEIO_StoreAmountInternal(oPC, oScroll, iRequested, TRUE);
}

int MEIO_StorePotionAmountInternal(object oPC, object oPotion, int iRequested, int bIgnoreSuppression)
{
    MEIO_Debug(oPC, "StorePotionAmount entered requested=" + IntToString(iRequested) + " explicit=" + IntToString(bIgnoreSuppression) + " suppress=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)) + " " + MEIO_DebugItemState(oPC, oPotion));
    if (!MEIO_IsUsablePotion(oPotion) || !MEIO_CanStoreItem(oPotion) || !MEIO_IsDirectlyIn(oPotion, oPC) || (!bIgnoreSuppression && GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)))
    {
        return 0;
    }
    object oStorage = MEIO_EnsurePotionStorage(oPC);
    if (!GetIsObjectValid(oStorage))
    {
        return 0;
    }
    MEIO_NormalizeExtractedTag(oPotion);
    MEIO_UnmarkKeepOut(oPC, oPotion);
    int iRemaining = iRequested;
    if (iRemaining > GetItemStackSize(oPotion))
    {
        iRemaining = GetItemStackSize(oPotion);
    }
    int iMoved;
    while (iRemaining > 0 && GetIsObjectValid(oPotion))
    {
        int iCopied;
        int iChunk = iRemaining;
        while (iChunk > 0 && iCopied == 0)
        {
            iCopied = MEIO_CopyPotionAmount(oPotion, oStorage, iChunk);
            if (iCopied == 0)
            {
                iChunk /= 2;
            }
        }
        if (iCopied == 0)
        {
            break;
        }
        iMoved += iCopied;
        iRemaining -= iCopied;
        int iStack = GetItemStackSize(oPotion);
        if (iCopied >= iStack)
        {
            DestroyObject(oPotion);
            oPotion = OBJECT_INVALID;
        }
        else
        {
            SetItemStackSize(oPotion, iStack - iCopied);
        }
    }
    if (iMoved > 0)
    {
        MEIO_ScheduleStorageSave(oPC);
    }
    MEIO_Debug(oPC, "StorePotionAmount finished moved=" + IntToString(iMoved) + " requested=" + IntToString(iRequested) + " " + MEIO_DebugItemState(oPC, oPotion));
    return iMoved;
}

int MEIO_StorePotionAmount(object oPC, object oPotion, int iRequested)
{
    return MEIO_StorePotionAmountInternal(oPC, oPotion, iRequested, FALSE);
}

int MEIO_StorePotionAmountExplicit(object oPC, object oPotion, int iRequested)
{
    return MEIO_StorePotionAmountInternal(oPC, oPotion, iRequested, TRUE);
}

int MEIO_DropCopy(object oPC, object oItem)
{
    string sTag = GetTag(oItem);
    SetTag(oItem, "MEIO_DROP_" + ObjectToString(oItem));
    object oCopy = CopyObject(oItem, GetLocation(oPC), OBJECT_INVALID, "", TRUE);
    SetTag(oItem, sTag);
    if (GetIsObjectValid(oCopy))
    {
        SetTag(oCopy, sTag);
        DestroyObject(oItem);
        return TRUE;
    }
    return FALSE;
}

object MEIO_EnsureScriptorium(object oPC)
{
    object oStorage = MEIO_EnsureStorage(oPC);
    if (!GetIsObjectValid(oStorage))
    {
        return OBJECT_INVALID;
    }
    object oScriptorium = MEIO_FindScriptorium(oPC);
    if (!GetIsObjectValid(oScriptorium))
    {
        oScriptorium = CreateItemOnObject(MEIO_SCRIPTORIUM_RESREF, oPC, 1, MEIO_SCRIPTORIUM_TAG);
    }
    if (!GetIsObjectValid(oScriptorium))
    {
        return OBJECT_INVALID;
    }
    SetPlotFlag(oScriptorium, TRUE);
    SetItemCursedFlag(oScriptorium, TRUE);
    SetDroppableFlag(oScriptorium, FALSE);
    if (GetLocalString(oScriptorium, MEIO_LOCAL_ITEM_LANGUAGE) != MEIO_GetLanguage(oPC))
    {
        SetName(oScriptorium, MEIO_GetText(oPC, "item_name"));
        string sDescription = MEIO_GetText(oPC, "item_description");
        SetDescription(oScriptorium, sDescription, TRUE);
        SetDescription(oScriptorium, sDescription, FALSE);
        SetLocalString(oScriptorium, MEIO_LOCAL_ITEM_LANGUAGE, MEIO_GetLanguage(oPC));
    }
    SetLocalInt(oScriptorium, MEIO_LOCAL_SCHEMA, MEIO_SCHEMA);
    SetLocalObject(oPC, MEIO_LOCAL_SCRIPTORIUM, oScriptorium);
    return oScriptorium;
}

void MEIO_ReconcileDuplicates(object oPC, object oPrimary)
{
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oPC);
        if (oItem != oPrimary && MEIO_IsDirectlyIn(oItem, oPC) && (GetTag(oItem) == MEIO_SCRIPTORIUM_TAG || GetTag(oItem) == "MEIO_SCRIPTORIUM"))
        {
            DestroyObject(oItem, 0.1f);
        }
        oItem = oNext;
    }
}

int MEIO_SortInventory(object oPC, int bIncludeKeptOut)
{
    int iMoved;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oPC);
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsScroll(oItem) && MEIO_CanStoreItem(oItem) && (bIncludeKeptOut || !MEIO_IsKeepOut(oPC, oItem)))
        {
            iMoved += bIncludeKeptOut ? MEIO_StoreAmountExplicit(oPC, oItem, GetItemStackSize(oItem)) : MEIO_StoreAmount(oPC, oItem, GetItemStackSize(oItem));
        }
        oItem = oNext;
    }
    return iMoved;
}

int MEIO_SortExistingInventory(object oPC)
{
    return MEIO_SortInventory(oPC, TRUE);
}

int MEIO_StoreInventoryBatch(object oPC, int iLimit)
{
    int iAttempted;
    int iMoved;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oPC);
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsScroll(oItem) && MEIO_CanStoreItem(oItem))
        {
            iAttempted++;
            iMoved += MEIO_StoreAmountExplicit(oPC, oItem, GetItemStackSize(oItem));
            if (iAttempted >= iLimit)
            {
                SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
                MEIO_Debug(oPC, "Inventory storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=0");
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
    MEIO_Debug(oPC, "Inventory storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=1");
    return TRUE;
}

int MEIO_StorePotionInventoryBatch(object oPC, int iLimit)
{
    int iAttempted;
    int iMoved;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oPC);
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsUsablePotion(oItem) && MEIO_CanStoreItem(oItem))
        {
            iAttempted++;
            iMoved += MEIO_StorePotionAmountExplicit(oPC, oItem, GetItemStackSize(oItem));
            if (iAttempted >= iLimit)
            {
                SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
                MEIO_Debug(oPC, "Potion storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=0");
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
    MEIO_Debug(oPC, "Potion storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=1");
    return TRUE;
}

void MEIO_MarkInitialImportItems(object oPC)
{
    int iMarked;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_CanStoreItem(oItem))
        {
            SetLocalInt(oItem, MEIO_LOCAL_INITIAL_IMPORT_ITEM, TRUE);
            iMarked++;
        }
        oItem = GetNextItemInInventory(oPC);
    }
    MEIO_Debug(oPC, "Initial Scriptorium import snapshot marked=" + IntToString(iMarked));
}

int MEIO_StoreInitialInventoryBatch(object oPC, int iLimit)
{
    int iAttempted;
    int iMoved;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oPC);
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_CanStoreItem(oItem) && GetLocalInt(oItem, MEIO_LOCAL_INITIAL_IMPORT_ITEM))
        {
            iAttempted++;
            int iRequested = GetItemStackSize(oItem);
            DeleteLocalInt(oItem, MEIO_LOCAL_INITIAL_IMPORT_ITEM);
            int iItemMoved = MEIO_IsScroll(oItem) ? MEIO_StoreAmountExplicit(oPC, oItem, iRequested) : MEIO_StorePotionAmountExplicit(oPC, oItem, iRequested);
            iMoved += iItemMoved;
            if (iItemMoved < iRequested && GetIsObjectValid(oItem))
            {
                SetLocalInt(oItem, MEIO_LOCAL_INITIAL_IMPORT_ITEM, TRUE);
            }
            if (iAttempted >= iLimit)
            {
                SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
                MEIO_Debug(oPC, "Initial inventory storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=0");
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
    MEIO_Debug(oPC, "Initial inventory storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=1");
    return TRUE;
}

void MEIO_ValidateContents(object oPC, object oStorage)
{
    int bChanged;
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oStorage);
        if (MEIO_IsDirectlyIn(oItem, oStorage) && !MEIO_IsScroll(oItem))
        {
            MEIO_DropCopy(oPC, oItem);
            bChanged = TRUE;
        }
        oItem = oNext;
    }
    if (bChanged)
    {
        MEIO_ScheduleStorageSave(oPC);
    }
}

void MEIO_ValidatePotionContents(object oPC, object oStorage)
{
    int bChanged;
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oStorage);
        if (MEIO_IsDirectlyIn(oItem, oStorage) && !MEIO_IsUsablePotion(oItem))
        {
            MEIO_DropCopy(oPC, oItem);
            bChanged = TRUE;
        }
        oItem = oNext;
    }
    if (bChanged)
    {
        MEIO_ScheduleStorageSave(oPC);
    }
}
