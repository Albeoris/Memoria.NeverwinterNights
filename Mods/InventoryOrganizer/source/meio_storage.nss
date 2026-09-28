// Persistent physical scroll storage and inventory transfer.

#include "meio_core"

int MEIO_CopyAmount(object oSource, object oTarget, int iRequested);
void MEIO_RebuildOpenWindowIndex(object oPC);
int MEIO_InitializeStoragePersistence(object oPC);

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

int MEIO_CountBookVariant(object oContainer, string sKey)
{
    int iCount;
    object oItem = GetFirstItemInInventory(oContainer);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oContainer) && MEIO_IsBook(oItem) && MEIO_GetBookKey(oItem) == sKey)
        {
            iCount += GetItemStackSize(oItem);
        }
        oItem = GetNextItemInInventory(oContainer);
    }
    return iCount;
}

int MEIO_IsInScriptorium(object oStorage, object oItem)
{
    return MEIO_IsDirectlyIn(oItem, oStorage);
}

object MEIO_FindRuntimeStorageSlot(object oPC, string sLocal, string sTag, string sSlot)
{
    object oStorage = GetLocalObject(oPC, sLocal);
    if (GetIsObjectValid(oStorage) && GetObjectType(oStorage) == OBJECT_TYPE_STORE && GetTag(oStorage) == sTag)
    {
        return oStorage;
    }
    int iIndex;
    oStorage = GetObjectByTag(sTag, iIndex);
    while (GetIsObjectValid(oStorage))
    {
        object oOwner = GetLocalObject(oStorage, MEIO_LOCAL_STORAGE_OWNER);
        if (GetObjectType(oStorage) == OBJECT_TYPE_STORE && (oOwner == oPC || !GetIsObjectValid(oOwner)))
        {
            SetLocalString(oStorage, MEIO_LOCAL_STORAGE_SLOT, sSlot);
            SetLocalObject(oStorage, MEIO_LOCAL_STORAGE_OWNER, oPC);
            SetLocalObject(oPC, sLocal, oStorage);
            return oStorage;
        }
        iIndex++;
        oStorage = GetObjectByTag(sTag, iIndex);
    }
    return OBJECT_INVALID;
}

object MEIO_FindRuntimeStorage(object oPC)
{
    return MEIO_FindRuntimeStorageSlot(oPC, MEIO_LOCAL_STORAGE, MEIO_STORAGE_TAG, MEIO_STORAGE_SLOT_SCROLLS);
}

object MEIO_FindRuntimePotionStorage(object oPC)
{
    return MEIO_FindRuntimeStorageSlot(oPC, MEIO_LOCAL_POTION_STORAGE, MEIO_POTION_STORAGE_TAG, MEIO_STORAGE_SLOT_POTIONS);
}

object MEIO_FindRuntimeBookStorage(object oPC)
{
    return MEIO_FindRuntimeStorageSlot(oPC, MEIO_LOCAL_BOOK_STORAGE, MEIO_BOOK_STORAGE_TAG, MEIO_STORAGE_SLOT_BOOKS);
}

object MEIO_AdoptStorage(object oPC, object oStorage, string sLocal, string sTag, string sSlot)
{
    if (!GetIsObjectValid(oStorage) || GetObjectType(oStorage) != OBJECT_TYPE_STORE)
    {
        return OBJECT_INVALID;
    }
    SetTag(oStorage, sTag);
    SetLocalString(oStorage, MEIO_LOCAL_STORAGE_SLOT, sSlot);
    SetLocalObject(oStorage, MEIO_LOCAL_STORAGE_OWNER, oPC);
    SetLocalObject(oPC, sLocal, oStorage);
    return oStorage;
}

object MEIO_CreateStorage(object oPC, string sResRef, string sLocal, string sTag, string sSlot)
{
    return MEIO_AdoptStorage(oPC, CreateObject(OBJECT_TYPE_STORE, sResRef, GetLocation(oPC), FALSE, sTag), sLocal, sTag, sSlot);
}

json MEIO_NewPersistenceState()
{
    json jState = JsonObject();
    jState = JsonObjectSet(jState, "schema", JsonInt(MEIO_PERSIST_SCHEMA));
    jState = JsonObjectSet(jState, "revision", JsonString(""));
    jState = JsonObjectSet(jState, "scrolls", JsonBool(FALSE));
    jState = JsonObjectSet(jState, "potions", JsonBool(FALSE));
    jState = JsonObjectSet(jState, "books", JsonBool(FALSE));
    return jState;
}

int MEIO_IsPersistenceState(json jState)
{
    return JsonGetType(jState) == JSON_TYPE_OBJECT && JsonGetInt(JsonObjectGet(jState, "schema")) == MEIO_PERSIST_SCHEMA;
}

string MEIO_GetPersistenceRevision(json jState)
{
    return MEIO_IsPersistenceState(jState) ? JsonGetString(JsonObjectGet(jState, "revision")) : "";
}

int MEIO_GetPersistenceMask(json jState)
{
    if (!MEIO_IsPersistenceState(jState))
    {
        return 0;
    }
    return (JsonGetInt(JsonObjectGet(jState, "scrolls")) ? MEIO_STORAGE_MASK_SCROLLS : 0) | (JsonGetInt(JsonObjectGet(jState, "potions")) ? MEIO_STORAGE_MASK_POTIONS : 0) | (JsonGetInt(JsonObjectGet(jState, "books")) ? MEIO_STORAGE_MASK_BOOKS : 0);
}

int MEIO_FlushStoragePersistence(object oPC)
{
    DeleteLocalInt(oPC, MEIO_LOCAL_STORAGE_FLUSH_SCHEDULED);
    int iDirty = GetLocalInt(oPC, MEIO_LOCAL_STORAGE_DIRTY_MASK);
    if (!iDirty)
    {
        return TRUE;
    }
    int iRemaining = iDirty;
    if ((iDirty & MEIO_STORAGE_MASK_SCROLLS) && MEMORIA_PersistStoreObject(oPC, MEIO_PERSIST_NAMESPACE, "scrolls", MEIO_FindRuntimeStorage(oPC), FALSE))
    {
        iRemaining &= ~MEIO_STORAGE_MASK_SCROLLS;
    }
    if ((iDirty & MEIO_STORAGE_MASK_POTIONS) && MEMORIA_PersistStoreObject(oPC, MEIO_PERSIST_NAMESPACE, "potions", MEIO_FindRuntimePotionStorage(oPC), FALSE))
    {
        iRemaining &= ~MEIO_STORAGE_MASK_POTIONS;
    }
    if ((iDirty & MEIO_STORAGE_MASK_BOOKS) && MEMORIA_PersistStoreObject(oPC, MEIO_PERSIST_NAMESPACE, "books", MEIO_FindRuntimeBookStorage(oPC), FALSE))
    {
        iRemaining &= ~MEIO_STORAGE_MASK_BOOKS;
    }
    SetLocalInt(oPC, MEIO_LOCAL_STORAGE_DIRTY_MASK, iRemaining);
    if (iRemaining)
    {
        SetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES, GetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES) + 1);
        MEIO_ReportError(oPC, "StoreCampaignObject failed; dirty state retained mask=" + IntToString(iRemaining));
        MEIO_Debug(oPC, "Storage persistence commit failed dirtyMask=" + IntToString(iRemaining));
        return FALSE;
    }
    json jState = MEIO_NewPersistenceState();
    jState = JsonObjectSet(jState, "revision", JsonString(GetRandomUUID()));
    jState = JsonObjectSet(jState, "scrolls", JsonBool(GetIsObjectValid(MEIO_FindRuntimeStorage(oPC))));
    jState = JsonObjectSet(jState, "potions", JsonBool(GetIsObjectValid(MEIO_FindRuntimePotionStorage(oPC))));
    jState = JsonObjectSet(jState, "books", JsonBool(GetIsObjectValid(MEIO_FindRuntimeBookStorage(oPC))));
    MEMORIA_PersistCommitJson(oPC, MEIO_PERSIST_NAMESPACE, MEIO_PERSIST_STATE, jState);
    SetLocalInt(oPC, MEIO_LOCAL_PERSIST_COMMITS, GetLocalInt(oPC, MEIO_LOCAL_PERSIST_COMMITS) + 1);
    return TRUE;
}

void MEIO_RunScheduledStorageFlush(object oPC, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_STORAGE_FLUSH_GENERATION) != iGeneration)
    {
        return;
    }
    DeleteLocalInt(oPC, MEIO_LOCAL_STORAGE_FLUSH_SCHEDULED);
    MEIO_FlushStoragePersistence(oPC);
}

void MEIO_ScheduleStorageFlush(object oPC)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_STORAGE_FLUSH_SCHEDULED))
    {
        return;
    }
    int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_STORAGE_FLUSH_GENERATION) + 1;
    SetLocalInt(oPC, MEIO_LOCAL_STORAGE_FLUSH_GENERATION, iGeneration);
    SetLocalInt(oPC, MEIO_LOCAL_STORAGE_FLUSH_SCHEDULED, TRUE);
    DelayCommand(0.01f, MEIO_RunScheduledStorageFlush(oPC, iGeneration));
}

void MEIO_BeginStorageTransaction(object oPC)
{
    SetLocalInt(oPC, MEIO_LOCAL_STORAGE_TRANSACTION_DEPTH, GetLocalInt(oPC, MEIO_LOCAL_STORAGE_TRANSACTION_DEPTH) + 1);
}

void MEIO_EndStorageTransaction(object oPC)
{
    int iDepth = GetLocalInt(oPC, MEIO_LOCAL_STORAGE_TRANSACTION_DEPTH);
    if (iDepth > 1)
    {
        SetLocalInt(oPC, MEIO_LOCAL_STORAGE_TRANSACTION_DEPTH, iDepth - 1);
        return;
    }
    DeleteLocalInt(oPC, MEIO_LOCAL_STORAGE_TRANSACTION_DEPTH);
    MEIO_ScheduleStorageFlush(oPC);
}

void MEIO_ScheduleStorageSave(object oPC, int iMask)
{
    SetLocalInt(oPC, MEIO_LOCAL_STORAGE_DIRTY_MASK, GetLocalInt(oPC, MEIO_LOCAL_STORAGE_DIRTY_MASK) | iMask);
    if (!GetLocalInt(oPC, MEIO_LOCAL_STORAGE_TRANSACTION_DEPTH))
    {
        MEIO_ScheduleStorageFlush(oPC);
    }
}

int MEIO_IsExpectedStorage(object oStorage)
{
    return GetIsObjectValid(oStorage) && GetObjectType(oStorage) == OBJECT_TYPE_STORE;
}

string MEIO_DescribeStorage(object oStorage)
{
    if (!GetIsObjectValid(oStorage))
    {
        return "invalid";
    }
    return "object=" + ObjectToString(oStorage) + ",type=" + IntToString(GetObjectType(oStorage)) + ",tag=" + GetTag(oStorage) + ",resref=" + GetResRef(oStorage);
}

void MEIO_DestroyStartupStorage(object oStorage)
{
    if (GetIsObjectValid(oStorage))
    {
        DestroyObject(oStorage);
    }
}

int MEIO_InitializeStoragePersistence(object oPC)
{
    if (ESI_IsRuntimeMarkerSet(oPC, MEIO_RUNTIME_PERSISTENCE))
    {
        return GetLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK) == 0;
    }
    DeleteLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK);
    object oScrolls = MEIO_FindRuntimeStorage(oPC);
    object oPotions = MEIO_FindRuntimePotionStorage(oPC);
    object oBooks = MEIO_FindRuntimeBookStorage(oPC);
    if (GetIsObjectValid(oScrolls) && !MEIO_IsExpectedStorage(oScrolls))
    {
        DeleteLocalObject(oPC, MEIO_LOCAL_STORAGE);
        oScrolls = OBJECT_INVALID;
    }
    if (GetIsObjectValid(oPotions) && !MEIO_IsExpectedStorage(oPotions))
    {
        DeleteLocalObject(oPC, MEIO_LOCAL_POTION_STORAGE);
        oPotions = OBJECT_INVALID;
    }
    if (GetIsObjectValid(oBooks) && !MEIO_IsExpectedStorage(oBooks))
    {
        DeleteLocalObject(oPC, MEIO_LOCAL_BOOK_STORAGE);
        oBooks = OBJECT_INVALID;
    }
    if (GetIsObjectValid(oScrolls))
    {
        MEIO_AdoptStorage(oPC, oScrolls, MEIO_LOCAL_STORAGE, MEIO_STORAGE_TAG, MEIO_STORAGE_SLOT_SCROLLS);
    }
    if (GetIsObjectValid(oPotions))
    {
        MEIO_AdoptStorage(oPC, oPotions, MEIO_LOCAL_POTION_STORAGE, MEIO_POTION_STORAGE_TAG, MEIO_STORAGE_SLOT_POTIONS);
    }
    if (GetIsObjectValid(oBooks))
    {
        MEIO_AdoptStorage(oPC, oBooks, MEIO_LOCAL_BOOK_STORAGE, MEIO_BOOK_STORAGE_TAG, MEIO_STORAGE_SLOT_BOOKS);
    }
    int iExisting = (GetIsObjectValid(oScrolls) ? MEIO_STORAGE_MASK_SCROLLS : 0) | (GetIsObjectValid(oPotions) ? MEIO_STORAGE_MASK_POTIONS : 0) | (GetIsObjectValid(oBooks) ? MEIO_STORAGE_MASK_BOOKS : 0);
    int bHasLocal = MEMORIA_PersistHasLocalJson(MEIO_PERSIST_NAMESPACE, MEIO_PERSIST_STATE);
    if (bHasLocal)
    {
        json jLocal = MEMORIA_PersistGetLocalJson(MEIO_PERSIST_NAMESPACE, MEIO_PERSIST_STATE);
        int iExpected = MEIO_GetPersistenceMask(jLocal);
        if (!MEIO_IsPersistenceState(jLocal) || (iExisting & iExpected) != iExpected)
        {
            int iBlocked = !MEIO_IsPersistenceState(jLocal) ? MEIO_STORAGE_MASK_ALL : iExpected & ~iExisting;
            SetLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK, iBlocked);
            SetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES, GetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES) + 1);
            MEIO_ReportError(oPC, "Save-local storage metadata requires missing or invalid runtime stores; operations blocked mask=" + IntToString(iBlocked));
            MEIO_Debug(oPC, "Storage persistence blocked missing save-local stores mask=" + IntToString(iBlocked));
            return FALSE;
        }
        json jCampaign = MEMORIA_PersistGetCampaignJson(oPC, MEIO_PERSIST_NAMESPACE, MEIO_PERSIST_STATE);
        if (MEIO_GetPersistenceRevision(jLocal) != MEIO_GetPersistenceRevision(jCampaign))
        {
            SetLocalInt(oPC, MEIO_LOCAL_STORAGE_DIRTY_MASK, iExpected);
            if (!MEIO_FlushStoragePersistence(oPC))
            {
                return FALSE;
            }
        }
        else
        {
            MEMORIA_PersistInitializeJson(oPC, MEIO_PERSIST_NAMESPACE, MEIO_PERSIST_STATE, MEIO_NewPersistenceState(), TRUE);
        }
        ESI_SetRuntimeMarker(oPC, MEIO_RUNTIME_PERSISTENCE);
        MEIO_Debug(oPC, "Storage persistence adopted save-local stores mask=" + IntToString(iExisting));
        return TRUE;
    }
    if (iExisting)
    {
        if (!GetIsObjectValid(oScrolls))
        {
            oScrolls = MEIO_CreateStorage(oPC, MEIO_STORAGE_RESREF, MEIO_LOCAL_STORAGE, MEIO_STORAGE_TAG, MEIO_STORAGE_SLOT_SCROLLS);
        }
        if (!GetIsObjectValid(oPotions))
        {
            oPotions = MEIO_CreateStorage(oPC, MEIO_POTION_STORAGE_RESREF, MEIO_LOCAL_POTION_STORAGE, MEIO_POTION_STORAGE_TAG, MEIO_STORAGE_SLOT_POTIONS);
        }
        if (!GetIsObjectValid(oBooks))
        {
            oBooks = MEIO_CreateStorage(oPC, MEIO_BOOK_STORAGE_RESREF, MEIO_LOCAL_BOOK_STORAGE, MEIO_BOOK_STORAGE_TAG, MEIO_STORAGE_SLOT_BOOKS);
        }
        if (!GetIsObjectValid(oScrolls) || !GetIsObjectValid(oPotions) || !GetIsObjectValid(oBooks))
        {
            MEIO_ReportError(oPC, "Legacy storage migration could not create all missing STORE objects; migration will retry");
            return FALSE;
        }
        SetLocalInt(oPC, MEIO_LOCAL_STORAGE_DIRTY_MASK, MEIO_STORAGE_MASK_ALL);
        if (!MEIO_FlushStoragePersistence(oPC))
        {
            return FALSE;
        }
        ESI_SetRuntimeMarker(oPC, MEIO_RUNTIME_PERSISTENCE);
        MEIO_Debug(oPC, "Storage persistence exported legacy stores");
        return TRUE;
    }
    json jCampaign = MEMORIA_PersistGetCampaignJson(oPC, MEIO_PERSIST_NAMESPACE, MEIO_PERSIST_STATE);
    if (JsonGetType(jCampaign) != JSON_TYPE_NULL && !MEIO_IsPersistenceState(jCampaign))
    {
        SetLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK, MEIO_STORAGE_MASK_ALL);
        SetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES, GetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES) + 1);
        MEIO_ReportError(oPC, "Campaign storage metadata has an unsupported schema; empty replacement refused");
        return FALSE;
    }
    int bRestore = MEIO_IsPersistenceState(jCampaign);
    int iCampaignMask = MEIO_GetPersistenceMask(jCampaign);
    oScrolls = iCampaignMask & MEIO_STORAGE_MASK_SCROLLS ? MEMORIA_PersistRetrieveObject(oPC, MEIO_PERSIST_NAMESPACE, "scrolls", GetLocation(oPC)) : MEIO_CreateStorage(oPC, MEIO_STORAGE_RESREF, MEIO_LOCAL_STORAGE, MEIO_STORAGE_TAG, MEIO_STORAGE_SLOT_SCROLLS);
    oPotions = iCampaignMask & MEIO_STORAGE_MASK_POTIONS ? MEMORIA_PersistRetrieveObject(oPC, MEIO_PERSIST_NAMESPACE, "potions", GetLocation(oPC)) : MEIO_CreateStorage(oPC, MEIO_POTION_STORAGE_RESREF, MEIO_LOCAL_POTION_STORAGE, MEIO_POTION_STORAGE_TAG, MEIO_STORAGE_SLOT_POTIONS);
    oBooks = iCampaignMask & MEIO_STORAGE_MASK_BOOKS ? MEMORIA_PersistRetrieveObject(oPC, MEIO_PERSIST_NAMESPACE, "books", GetLocation(oPC)) : MEIO_CreateStorage(oPC, MEIO_BOOK_STORAGE_RESREF, MEIO_LOCAL_BOOK_STORAGE, MEIO_BOOK_STORAGE_TAG, MEIO_STORAGE_SLOT_BOOKS);
    int iBlocked = (!MEIO_IsExpectedStorage(oScrolls) ? MEIO_STORAGE_MASK_SCROLLS : 0) | (!MEIO_IsExpectedStorage(oPotions) ? MEIO_STORAGE_MASK_POTIONS : 0) | (!MEIO_IsExpectedStorage(oBooks) ? MEIO_STORAGE_MASK_BOOKS : 0);
    if (iBlocked)
    {
        MEIO_DestroyStartupStorage(oScrolls);
        MEIO_DestroyStartupStorage(oPotions);
        MEIO_DestroyStartupStorage(oBooks);
        SetLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK, iBlocked);
        SetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES, GetLocalInt(oPC, MEIO_LOCAL_PERSIST_FAILURES) + 1);
        MEIO_ReportError(oPC, "RetrieveCampaignObject returned a missing or non-STORE object; empty replacement refused mask=" + IntToString(iBlocked) + " scrolls={" + MEIO_DescribeStorage(oScrolls) + "} potions={" + MEIO_DescribeStorage(oPotions) + "} books={" + MEIO_DescribeStorage(oBooks) + "}");
        MEIO_Debug(oPC, "Storage persistence restore blocked mask=" + IntToString(iBlocked));
        return FALSE;
    }
    MEIO_AdoptStorage(oPC, oScrolls, MEIO_LOCAL_STORAGE, MEIO_STORAGE_TAG, MEIO_STORAGE_SLOT_SCROLLS);
    MEIO_AdoptStorage(oPC, oPotions, MEIO_LOCAL_POTION_STORAGE, MEIO_POTION_STORAGE_TAG, MEIO_STORAGE_SLOT_POTIONS);
    MEIO_AdoptStorage(oPC, oBooks, MEIO_LOCAL_BOOK_STORAGE, MEIO_BOOK_STORAGE_TAG, MEIO_STORAGE_SLOT_BOOKS);
    if (bRestore)
    {
        MEMORIA_PersistInitializeJson(oPC, MEIO_PERSIST_NAMESPACE, MEIO_PERSIST_STATE, MEIO_NewPersistenceState(), TRUE);
        SetLocalInt(oPC, MEIO_LOCAL_PERSIST_RESTORES, GetLocalInt(oPC, MEIO_LOCAL_PERSIST_RESTORES) + 1);
    }
    int iCreated = MEIO_STORAGE_MASK_ALL & ~iCampaignMask;
    if (iCreated)
    {
        SetLocalInt(oPC, MEIO_LOCAL_STORAGE_DIRTY_MASK, iCreated);
        if (!MEIO_FlushStoragePersistence(oPC))
        {
            return FALSE;
        }
    }
    ESI_SetRuntimeMarker(oPC, MEIO_RUNTIME_PERSISTENCE);
    MEIO_Debug(oPC, bRestore ? "Storage persistence restored campaign stores" : "Storage persistence created fresh stores");
    return TRUE;
}

object MEIO_EnsureStorage(object oPC)
{
    if (!MEIO_InitializeStoragePersistence(oPC) || (GetLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK) & MEIO_STORAGE_MASK_SCROLLS))
    {
        return OBJECT_INVALID;
    }
    return MEIO_FindRuntimeStorage(oPC);
}

object MEIO_EnsurePotionStorage(object oPC)
{
    if (!MEIO_InitializeStoragePersistence(oPC) || (GetLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK) & MEIO_STORAGE_MASK_POTIONS))
    {
        return OBJECT_INVALID;
    }
    return MEIO_FindRuntimePotionStorage(oPC);
}

object MEIO_EnsureBookStorage(object oPC)
{
    if (!MEIO_InitializeStoragePersistence(oPC) || (GetLocalInt(oPC, MEIO_LOCAL_STORAGE_BLOCKED_MASK) & MEIO_STORAGE_MASK_BOOKS))
    {
        return OBJECT_INVALID;
    }
    return MEIO_FindRuntimeBookStorage(oPC);
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

int MEIO_CopyBookAmount(object oSource, object oTarget, int iRequested)
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
    string sKey = MEIO_GetBookKey(oSource);
    int iBefore = MEIO_CountBookVariant(oTarget, sKey);
    if (iRequested < iSourceSize)
    {
        SetItemStackSize(oSource, iRequested);
    }
    object oCopy = CopyItem(oSource, oTarget, TRUE);
    if (iRequested < iSourceSize)
    {
        SetItemStackSize(oSource, iSourceSize);
    }
    int iMoved = MEIO_CountBookVariant(oTarget, sKey) - iBefore;
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
        MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_SCROLLS);
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
        MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_POTIONS);
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

int MEIO_StoreBookAmountInternal(object oPC, object oBook, int iRequested, int bIgnoreSuppression)
{
    if (!MEIO_CanStoreBook(oBook) || !MEIO_IsDirectlyIn(oBook, oPC) || (!bIgnoreSuppression && GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT)))
    {
        return 0;
    }
    object oStorage = MEIO_EnsureBookStorage(oPC);
    if (!GetIsObjectValid(oStorage))
    {
        return 0;
    }
    MEIO_UnmarkKeepOut(oPC, oBook);
    int iMoved = MEIO_CopyBookAmount(oBook, oStorage, iRequested);
    if (iMoved > 0)
    {
        int iStack = GetItemStackSize(oBook);
        if (iMoved >= iStack)
        {
            DestroyObject(oBook);
        }
        else
        {
            SetItemStackSize(oBook, iStack - iMoved);
        }
        MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_BOOKS);
    }
    return iMoved;
}

int MEIO_StoreBookAmount(object oPC, object oBook, int iRequested)
{
    return MEIO_StoreBookAmountInternal(oPC, oBook, iRequested, FALSE);
}

int MEIO_StoreBookAmountExplicit(object oPC, object oBook, int iRequested)
{
    return MEIO_StoreBookAmountInternal(oPC, oBook, iRequested, TRUE);
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
    MEIO_BeginStorageTransaction(oPC);
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
    MEIO_EndStorageTransaction(oPC);
    return iMoved;
}

int MEIO_SortExistingInventory(object oPC)
{
    return MEIO_SortInventory(oPC, TRUE);
}

int MEIO_StoreInventoryBatch(object oPC, int iLimit)
{
    MEIO_BeginStorageTransaction(oPC);
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
                MEIO_EndStorageTransaction(oPC);
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
    MEIO_Debug(oPC, "Inventory storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=1");
    MEIO_EndStorageTransaction(oPC);
    return TRUE;
}

int MEIO_StorePotionInventoryBatch(object oPC, int iLimit)
{
    MEIO_BeginStorageTransaction(oPC);
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
                MEIO_EndStorageTransaction(oPC);
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
    MEIO_Debug(oPC, "Potion storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=1");
    MEIO_EndStorageTransaction(oPC);
    return TRUE;
}

int MEIO_StoreBookInventoryBatch(object oPC, int iLimit)
{
    MEIO_BeginStorageTransaction(oPC);
    int iAttempted;
    int iMoved;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oPC);
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_CanStoreBook(oItem))
        {
            iAttempted++;
            iMoved += MEIO_StoreBookAmountExplicit(oPC, oItem, GetItemStackSize(oItem));
            if (iAttempted >= iLimit)
            {
                SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
                MEIO_EndStorageTransaction(oPC);
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
    MEIO_EndStorageTransaction(oPC);
    return TRUE;
}

void MEIO_BeginBookDuplicateBurn(object oPC)
{
    SetLocalInt(oPC, MEIO_LOCAL_BURN_GENERATION, GetLocalInt(oPC, MEIO_LOCAL_BURN_GENERATION) + 1);
    SetLocalJson(oPC, MEIO_LOCAL_BURN_SEEN, JsonObject());
}

int MEIO_BurnBookDuplicatesBatch(object oPC, int iLimit)
{
    MEIO_BeginStorageTransaction(oPC);
    object oStorage = MEIO_EnsureBookStorage(oPC);
    json jSeen = GetLocalJson(oPC, MEIO_LOCAL_BURN_SEEN);
    int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_BURN_GENERATION);
    int iRemoved;
    int iInspected;
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oStorage);
        if (MEIO_IsDirectlyIn(oItem, oStorage) && MEIO_IsBook(oItem) && GetLocalInt(oItem, MEIO_LOCAL_BURN_PROCESSED) != iGeneration)
        {
            SetLocalInt(oItem, MEIO_LOCAL_BURN_PROCESSED, iGeneration);
            iInspected++;
            string sKey = MEIO_GetBookKey(oItem);
            int iKept = JsonGetInt(JsonObjectGet(jSeen, sKey));
            int iStack = GetItemStackSize(oItem);
            if (!iKept)
            {
                jSeen = JsonObjectSet(jSeen, sKey, JsonBool(TRUE));
                if (iStack > 1)
                {
                    SetItemStackSize(oItem, 1);
                    iRemoved += iStack - 1;
                }
            }
            else
            {
                iRemoved += iStack;
                DestroyObject(oItem);
            }
            if (iInspected >= iLimit)
            {
                SetLocalJson(oPC, MEIO_LOCAL_BURN_SEEN, jSeen);
                SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iRemoved);
                if (iRemoved > 0)
                {
                    MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_BOOKS);
                }
                MEIO_EndStorageTransaction(oPC);
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalJson(oPC, MEIO_LOCAL_BURN_SEEN, jSeen);
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iRemoved);
    if (iRemoved > 0)
    {
        MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_BOOKS);
    }
    oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        DeleteLocalInt(oItem, MEIO_LOCAL_BURN_PROCESSED);
        oItem = GetNextItemInInventory(oStorage);
    }
    DeleteLocalJson(oPC, MEIO_LOCAL_BURN_SEEN);
    MEIO_EndStorageTransaction(oPC);
    return TRUE;
}

void MEIO_MarkInitialImportItems(object oPC)
{
    int iMarked;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_CanStoreItem(oItem) && MEIO_IsAutomaticForItem(oPC, oItem))
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
    MEIO_BeginStorageTransaction(oPC);
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
            int iItemMoved = MEIO_IsScroll(oItem) ? MEIO_StoreAmountExplicit(oPC, oItem, iRequested) : MEIO_IsUsablePotion(oItem) ? MEIO_StorePotionAmountExplicit(oPC, oItem, iRequested) : MEIO_StoreBookAmountExplicit(oPC, oItem, iRequested);
            iMoved += iItemMoved;
            if (iItemMoved < iRequested && GetIsObjectValid(oItem))
            {
                SetLocalInt(oItem, MEIO_LOCAL_INITIAL_IMPORT_ITEM, TRUE);
            }
            if (iAttempted >= iLimit)
            {
                SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
                MEIO_Debug(oPC, "Initial inventory storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=0");
                MEIO_EndStorageTransaction(oPC);
                return FALSE;
            }
        }
        oItem = oNext;
    }
    SetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED, iMoved);
    MEIO_Debug(oPC, "Initial inventory storage batch completed attempted=" + IntToString(iAttempted) + " moved=" + IntToString(iMoved) + " complete=1");
    MEIO_EndStorageTransaction(oPC);
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
        MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_SCROLLS);
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
        MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_POTIONS);
    }
}

void MEIO_ValidateBookContents(object oPC, object oStorage)
{
    int bChanged;
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        object oNext = GetNextItemInInventory(oStorage);
        if (MEIO_IsDirectlyIn(oItem, oStorage) && !MEIO_CanStoreBook(oItem))
        {
            MEIO_DropCopy(oPC, oItem);
            bChanged = TRUE;
        }
        oItem = oNext;
    }
    if (bChanged)
    {
        MEIO_ScheduleStorageSave(oPC, MEIO_STORAGE_MASK_BOOKS);
    }
}

int MEIO_ReturnVaultItem(object oPC, object oItem)
{
    if (!GetBaseItemFitsInInventory(GetBaseItemType(oItem), oPC))
    {
        return FALSE;
    }
    object oCopy = CopyItem(oItem, oPC, TRUE);
    if (!MEIO_IsDirectlyIn(oCopy, oPC))
    {
        if (GetIsObjectValid(oCopy))
        {
            DestroyObject(oCopy);
        }
        return FALSE;
    }
    MEIO_MarkKeepOut(oPC, oCopy);
    DestroyObject(oItem);
    return TRUE;
}

int MEIO_StoreVaultItem(object oPC, object oItem)
{
    object oTarget = MEIO_IsScroll(oItem) ? MEIO_EnsureStorage(oPC) : MEIO_IsUsablePotion(oItem) ? MEIO_EnsurePotionStorage(oPC) : MEIO_IsBook(oItem) ? MEIO_EnsureBookStorage(oPC) : OBJECT_INVALID;
    if (!GetIsObjectValid(oTarget) || !MEIO_CanStoreItem(oItem))
    {
        return FALSE;
    }
    int iStorageMask = MEIO_IsScroll(oItem) ? MEIO_STORAGE_MASK_SCROLLS : MEIO_IsUsablePotion(oItem) ? MEIO_STORAGE_MASK_POTIONS : MEIO_STORAGE_MASK_BOOKS;
    int iRequested = GetItemStackSize(oItem);
    int iMoved = MEIO_IsScroll(oItem) ? MEIO_CopyAmount(oItem, oTarget, iRequested) : MEIO_IsUsablePotion(oItem) ? MEIO_CopyPotionAmount(oItem, oTarget, iRequested) : MEIO_CopyBookAmount(oItem, oTarget, iRequested);
    if (iMoved <= 0)
    {
        return FALSE;
    }
    if (iMoved >= GetItemStackSize(oItem))
    {
        DestroyObject(oItem);
    }
    else
    {
        SetItemStackSize(oItem, GetItemStackSize(oItem) - iMoved);
    }
    MEIO_ScheduleStorageSave(oPC, iStorageMask);
    return TRUE;
}

void MEIO_ProcessVaultContents(object oPC, int iLimit)
{
    if (MEIO_IsTransferBusy(oPC))
    {
        return;
    }
    object oVault = MEIO_FindScriptorium(oPC);
    if (!GetIsObjectValid(oVault))
    {
        return;
    }
    MEIO_BeginStorageTransaction(oPC);
    int iAttempted;
    int bChanged;
    object oItem = GetFirstItemInInventory(oVault);
    while (GetIsObjectValid(oItem) && iAttempted < iLimit)
    {
        object oNext = GetNextItemInInventory(oVault);
        if (MEIO_IsDirectlyIn(oItem, oVault))
        {
            iAttempted++;
            bChanged = MEIO_StoreVaultItem(oPC, oItem) || MEIO_ReturnVaultItem(oPC, oItem) || bChanged;
        }
        oItem = oNext;
    }
    if (bChanged)
    {
        MEIO_RebuildOpenWindowIndex(oPC);
    }
    MEIO_EndStorageTransaction(oPC);
}
