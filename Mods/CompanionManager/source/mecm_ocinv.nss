// Original Campaign henchman inventory persistence.

const int MECM_OC_INVENTORY_SCHEMA = 1;
const string MECM_OC_INVENTORY_STATE = "MECM_OC_INVENTORY_STATE";
const string MECM_OC_INVENTORY_STATE_INITIALIZED = "MECM_OC_INVENTORY_STATE_INITIALIZED";
const string MECM_OC_INVENTORY_RESTORED = "MECM_OC_INVENTORY_RESTORED";
const string MECM_OC_RESTORING_ITEMS = "MECM_OC_RESTORING_ITEMS";
const string MECM_OC_NATIVE_ITEM = "MECM_OC_NATIVE_ITEM";
const string MECM_OC_MANAGED_ITEM = "MECM_OC_MANAGED_ITEM";
const string MECM_OC_MANAGED_OWNER = "MECM_OC_MANAGED_OWNER";
const string MECM_OC_CAMPAIGN_DATABASE = "mecmocinventory";
const string MECM_OC_CAMPAIGN_VARIABLE = "state";
const string MECM_OC_ESI_ACQUIRE = "mecm.oc.inventory.acquire";
const string MECM_OC_ESI_LOSE = "mecm.oc.inventory.lose";
const string MECM_OC_RUNTIME_INITIALIZED = "mecm.oc.inventory.initialized";

void MECM_ProtectHenchmanInventory(object oHenchman);

int MECM_IsOriginalCampaign()
{
    string sModuleTag = GetStringUpperCase(GetTag(GetModule()));
    return sModuleTag == "PRELUDE" || sModuleTag == "CHAPTER1" || sModuleTag == "ENDMODULE1" || sModuleTag == "CHAPTER2" || sModuleTag == "ENDMODULE2" || sModuleTag == "CHAPTER3" || sModuleTag == "ENDMODULE3";
}

string MECM_GetOcHenchmanId(object oCreature)
{
    if (!GetIsObjectValid(oCreature) || GetObjectType(oCreature) != OBJECT_TYPE_CREATURE)
        return "";
    string sTag = GetStringUpperCase(GetTag(oCreature));
    if (sTag == "NW_HEN_DAE" || sTag == "NW_HEN_LIN" || sTag == "NW_HEN_SHA" || sTag == "NW_HEN_GAL" || sTag == "NW_HEN_GRI" || sTag == "NW_HEN_BOD")
        return sTag;
    return "";
}

int MECM_IsOcHenchman(object oCreature)
{
    return MECM_IsOriginalCampaign() && MECM_GetOcHenchmanId(oCreature) != "";
}

void MECM_OcInventoryDebug(object oPC, string sMessage)
{
    if (MECM_IsRootPlayer(oPC) && GetLocalInt(oPC, MECM_LOCAL_DEBUG))
        SendMessageToPC(oPC, "OC inventory: " + sMessage);
}

object MECM_GetOcPlayer()
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (MECM_IsRootPlayer(oPC))
            return oPC;
        oPC = GetNextPC();
    }
    return OBJECT_INVALID;
}

json MECM_NewOcInventoryState()
{
    json jState = JsonObject();
    jState = JsonObjectSet(jState, "schema", JsonInt(MECM_OC_INVENTORY_SCHEMA));
    jState = JsonObjectSet(jState, "companions", JsonObject());
    return jState;
}

json MECM_NormalizeOcInventoryState(json jState)
{
    if (JsonGetType(jState) != JSON_TYPE_OBJECT || JsonGetInt(JsonObjectGet(jState, "schema")) != MECM_OC_INVENTORY_SCHEMA)
        return MECM_NewOcInventoryState();
    if (JsonGetType(JsonObjectGet(jState, "companions")) != JSON_TYPE_OBJECT)
        jState = JsonObjectSet(jState, "companions", JsonObject());
    return jState;
}

void MECM_MirrorOcInventoryState(object oPC, json jState)
{
    SetCampaignJson(MECM_OC_CAMPAIGN_DATABASE, MECM_OC_CAMPAIGN_VARIABLE, jState, oPC);
}

int MECM_WriteOcInventoryState(object oPC, json jState)
{
    object oModule = GetModule();
    jState = MECM_NormalizeOcInventoryState(jState);
    if (JsonDump(GetLocalJson(oModule, MECM_OC_INVENTORY_STATE)) == JsonDump(jState))
        return FALSE;
    SetLocalJson(oModule, MECM_OC_INVENTORY_STATE, jState);
    MECM_MirrorOcInventoryState(oPC, jState);
    return TRUE;
}

json MECM_GetOcInventoryState()
{
    return MECM_NormalizeOcInventoryState(GetLocalJson(GetModule(), MECM_OC_INVENTORY_STATE));
}

json MECM_GetOcHenchmanItems(json jState, string sHenchmanId)
{
    json jCompanions = JsonObjectGet(jState, "companions");
    json jCompanion = JsonObjectGet(jCompanions, sHenchmanId);
    json jItems = JsonObjectGet(jCompanion, "items");
    return JsonGetType(jItems) == JSON_TYPE_ARRAY ? jItems : JsonArray();
}

json MECM_SetOcHenchmanItems(json jState, string sHenchmanId, json jItems)
{
    json jCompanions = JsonObjectGet(jState, "companions");
    if (JsonGetType(jCompanions) != JSON_TYPE_OBJECT)
        jCompanions = JsonObject();
    json jCompanion = JsonObjectGet(jCompanions, sHenchmanId);
    if (JsonGetType(jCompanion) != JSON_TYPE_OBJECT)
        jCompanion = JsonObject();
    jCompanion = JsonObjectSet(jCompanion, "items", jItems);
    jCompanions = JsonObjectSet(jCompanions, sHenchmanId, jCompanion);
    return JsonObjectSet(jState, "companions", jCompanions);
}

void MECM_InstallOcInventoryHooks()
{
    object oModule = GetModule();
    ESI_InjectToObject(oModule, MECM_OC_ESI_ACQUIRE, EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM, "mecm_ocacq", ESI_INJECTION_PLACEMENT_LAST);
    ESI_InjectToObject(oModule, MECM_OC_ESI_LOSE, EVENT_SCRIPT_MODULE_ON_LOSE_ITEM, "mecm_oclose", ESI_INJECTION_PLACEMENT_LAST);
}

int MECM_InitializeOcInventory(object oPC)
{
    if (!MECM_IsOriginalCampaign() || !MECM_IsRootPlayer(oPC))
        return FALSE;
    object oModule = GetModule();
    if (!ESI_IsRuntimeMarkerSet(oModule, MECM_OC_RUNTIME_INITIALIZED))
    {
        json jState;
        if (GetLocalInt(oModule, MECM_OC_INVENTORY_STATE_INITIALIZED))
        {
            jState = MECM_NormalizeOcInventoryState(GetLocalJson(oModule, MECM_OC_INVENTORY_STATE));
            SetLocalJson(oModule, MECM_OC_INVENTORY_STATE, jState);
            MECM_MirrorOcInventoryState(oPC, jState);
        }
        else
        {
            if (GetStringUpperCase(GetTag(oModule)) == "PRELUDE")
                jState = MECM_NewOcInventoryState();
            else
                jState = MECM_NormalizeOcInventoryState(GetCampaignJson(MECM_OC_CAMPAIGN_DATABASE, MECM_OC_CAMPAIGN_VARIABLE, oPC));
            SetLocalJson(oModule, MECM_OC_INVENTORY_STATE, jState);
            SetLocalInt(oModule, MECM_OC_INVENTORY_STATE_INITIALIZED, TRUE);
            MECM_MirrorOcInventoryState(oPC, jState);
        }
        ESI_SetRuntimeMarker(oModule, MECM_OC_RUNTIME_INITIALIZED);
    }
    MECM_InstallOcInventoryHooks();
    return TRUE;
}

void MECM_MarkNativeInventory(object oInventory)
{
    object oItem = GetFirstItemInInventory(oInventory);
    while (GetIsObjectValid(oItem))
    {
        if (!GetLocalInt(oItem, MECM_OC_MANAGED_ITEM))
        {
            SetLocalInt(oItem, MECM_OC_NATIVE_ITEM, TRUE);
            MECM_MarkNativeInventory(oItem);
        }
        oItem = GetNextItemInInventory(oInventory);
    }
}

void MECM_MarkNativeHenchmanItems(object oHenchman)
{
    MECM_MarkNativeInventory(oHenchman);
    int iSlot;
    for (iSlot = 0; iSlot < NUM_INVENTORY_SLOTS; iSlot++)
    {
        object oItem = GetItemInSlot(iSlot, oHenchman);
        if (!GetIsObjectValid(oItem) || GetLocalInt(oItem, MECM_OC_MANAGED_ITEM))
            continue;
        SetLocalInt(oItem, MECM_OC_NATIVE_ITEM, TRUE);
        MECM_MarkNativeInventory(oItem);
    }
}

int MECM_GetOcItemSlot(object oHenchman, object oItem)
{
    int iSlot;
    for (iSlot = 0; iSlot < NUM_INVENTORY_SLOTS; iSlot++)
    {
        if (GetItemInSlot(iSlot, oHenchman) == oItem)
            return iSlot;
    }
    return -1;
}

int MECM_IsManagedOcItem(object oItem, string sHenchmanId)
{
    return GetIsObjectValid(oItem) && GetLocalInt(oItem, MECM_OC_MANAGED_ITEM) && GetLocalString(oItem, MECM_OC_MANAGED_OWNER) == sHenchmanId;
}

void MECM_UpdateNestedManagedOcOwners(object oInventory, string sHenchmanId)
{
    object oItem = GetFirstItemInInventory(oInventory);
    while (GetIsObjectValid(oItem))
    {
        if (GetLocalInt(oItem, MECM_OC_MANAGED_ITEM))
            SetLocalString(oItem, MECM_OC_MANAGED_OWNER, sHenchmanId);
        MECM_UpdateNestedManagedOcOwners(oItem, sHenchmanId);
        oItem = GetNextItemInInventory(oInventory);
    }
}

void MECM_MarkManagedOcItem(object oItem, string sHenchmanId)
{
    DeleteLocalInt(oItem, MECM_OC_NATIVE_ITEM);
    SetLocalInt(oItem, MECM_OC_MANAGED_ITEM, TRUE);
    SetLocalString(oItem, MECM_OC_MANAGED_OWNER, sHenchmanId);
    SetItemCursedFlag(oItem, FALSE);
    GetObjectUUID(oItem);
    MECM_UpdateNestedManagedOcOwners(oItem, sHenchmanId);
}

void MECM_ClearManagedOcItem(object oItem)
{
    if (!GetIsObjectValid(oItem))
        return;
    DeleteLocalInt(oItem, MECM_OC_MANAGED_ITEM);
    DeleteLocalString(oItem, MECM_OC_MANAGED_OWNER);
    object oNested = GetFirstItemInInventory(oItem);
    while (GetIsObjectValid(oNested))
    {
        MECM_ClearManagedOcItem(oNested);
        oNested = GetNextItemInInventory(oItem);
    }
}

int MECM_OcRecordsContainUuid(json jItems, string sUuid)
{
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jItems); iIndex++)
    {
        if (JsonGetString(JsonObjectGet(JsonArrayGet(jItems, iIndex), "uuid")) == sUuid)
            return TRUE;
    }
    return FALSE;
}

json MECM_AppendManagedOcItem(json jItems, object oHenchman, object oItem, string sHenchmanId)
{
    if (!MECM_IsManagedOcItem(oItem, sHenchmanId))
        return jItems;
    string sUuid = GetObjectUUID(oItem);
    if (sUuid == "" || MECM_OcRecordsContainUuid(jItems, sUuid))
        return jItems;
    json jObject = ObjectToJson(oItem, TRUE);
    if (JsonGetType(jObject) != JSON_TYPE_OBJECT)
        return jItems;
    json jRecord = JsonObject();
    jRecord = JsonObjectSet(jRecord, "uuid", JsonString(sUuid));
    jRecord = JsonObjectSet(jRecord, "slot", JsonInt(MECM_GetOcItemSlot(oHenchman, oItem)));
    jRecord = JsonObjectSet(jRecord, "object", jObject);
    return JsonArrayInsert(jItems, jRecord);
}

json MECM_CollectManagedOcItems(json jItems, object oHenchman, object oInventory, string sHenchmanId)
{
    object oItem = GetFirstItemInInventory(oInventory);
    while (GetIsObjectValid(oItem))
    {
        if (GetLocalInt(oItem, MECM_OC_MANAGED_ITEM))
        {
            SetLocalString(oItem, MECM_OC_MANAGED_OWNER, sHenchmanId);
            DeleteLocalInt(oItem, MECM_OC_NATIVE_ITEM);
            SetItemCursedFlag(oItem, FALSE);
            jItems = MECM_AppendManagedOcItem(jItems, oHenchman, oItem, sHenchmanId);
        }
        else
            jItems = MECM_CollectManagedOcItems(jItems, oHenchman, oItem, sHenchmanId);
        oItem = GetNextItemInInventory(oInventory);
    }
    return jItems;
}

object MECM_FindManagedOcItemInInventory(object oInventory, string sHenchmanId, string sUuid)
{
    object oItem = GetFirstItemInInventory(oInventory);
    while (GetIsObjectValid(oItem))
    {
        if (MECM_IsManagedOcItem(oItem, sHenchmanId) && GetObjectUUID(oItem) == sUuid)
            return oItem;
        object oNested = MECM_FindManagedOcItemInInventory(oItem, sHenchmanId, sUuid);
        if (GetIsObjectValid(oNested))
            return oNested;
        oItem = GetNextItemInInventory(oInventory);
    }
    return OBJECT_INVALID;
}

object MECM_FindManagedOcItem(object oHenchman, string sHenchmanId, string sUuid)
{
    object oItem = MECM_FindManagedOcItemInInventory(oHenchman, sHenchmanId, sUuid);
    if (GetIsObjectValid(oItem))
        return oItem;
    int iSlot;
    for (iSlot = 0; iSlot < NUM_INVENTORY_SLOTS; iSlot++)
    {
        oItem = GetItemInSlot(iSlot, oHenchman);
        if (MECM_IsManagedOcItem(oItem, sHenchmanId) && GetObjectUUID(oItem) == sUuid)
            return oItem;
        if (GetIsObjectValid(oItem))
        {
            oItem = MECM_FindManagedOcItemInInventory(oItem, sHenchmanId, sUuid);
            if (GetIsObjectValid(oItem))
                return oItem;
        }
    }
    return OBJECT_INVALID;
}

void MECM_ReconcileOcHenchman(object oPC, object oHenchman)
{
    string sHenchmanId = MECM_GetOcHenchmanId(oHenchman);
    string sIncarnation = GetObjectUUID(oHenchman);
    if (sHenchmanId == "" || GetLocalString(oHenchman, MECM_OC_INVENTORY_RESTORED) != sIncarnation)
        return;
    json jState = MECM_GetOcInventoryState();
    json jOldItems = MECM_GetOcHenchmanItems(jState, sHenchmanId);
    json jItems = MECM_CollectManagedOcItems(JsonArray(), oHenchman, oHenchman, sHenchmanId);
    object oItem;
    int iSlot;
    for (iSlot = 0; iSlot < NUM_INVENTORY_SLOTS; iSlot++)
    {
        oItem = GetItemInSlot(iSlot, oHenchman);
        if (!GetIsObjectValid(oItem) || !GetLocalInt(oItem, MECM_OC_MANAGED_ITEM))
            continue;
        SetLocalString(oItem, MECM_OC_MANAGED_OWNER, sHenchmanId);
        DeleteLocalInt(oItem, MECM_OC_NATIVE_ITEM);
        SetItemCursedFlag(oItem, FALSE);
        jItems = MECM_AppendManagedOcItem(jItems, oHenchman, oItem, sHenchmanId);
    }
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jOldItems); iIndex++)
    {
        json jRecord = JsonArrayGet(jOldItems, iIndex);
        string sUuid = JsonGetString(JsonObjectGet(jRecord, "uuid"));
        if (JsonGetInt(JsonObjectGet(jRecord, "pending")) && !MECM_OcRecordsContainUuid(jItems, sUuid))
            jItems = JsonArrayInsert(jItems, jRecord);
    }
    if (JsonDump(jOldItems) == JsonDump(jItems))
        return;
    jState = MECM_SetOcHenchmanItems(jState, sHenchmanId, jItems);
    if (MECM_WriteOcInventoryState(oPC, jState))
        MECM_OcInventoryDebug(oPC, "saved " + IntToString(JsonGetLength(jItems)) + " items for " + sHenchmanId);
}

void MECM_RemoveOcItemRecord(object oPC, string sHenchmanId, string sUuid, object oItem)
{
    if (sHenchmanId == "" || sUuid == "")
        return;
    json jState = MECM_GetOcInventoryState();
    json jOldItems = MECM_GetOcHenchmanItems(jState, sHenchmanId);
    json jItems = JsonArray();
    int bRemoved;
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jOldItems); iIndex++)
    {
        json jRecord = JsonArrayGet(jOldItems, iIndex);
        if (JsonGetString(JsonObjectGet(jRecord, "uuid")) == sUuid)
            bRemoved = TRUE;
        else
            jItems = JsonArrayInsert(jItems, jRecord);
    }
    if (!bRemoved)
        return;
    jState = MECM_SetOcHenchmanItems(jState, sHenchmanId, jItems);
    MECM_WriteOcInventoryState(oPC, jState);
    MECM_OcInventoryDebug(oPC, "removed managed item " + (GetIsObjectValid(oItem) ? GetName(oItem) : sUuid) + " " + sUuid);
}

void MECM_VerifyOcEquipment(object oPC, object oHenchman, object oItem, int iSlot)
{
    if (!GetIsObjectValid(oItem) || GetItemPossessor(oItem, TRUE) != oHenchman)
        return;
    if (MECM_GetOcItemSlot(oHenchman, oItem) == iSlot)
        MECM_OcInventoryDebug(oPC, "restored " + GetName(oItem) + " to slot " + IntToString(iSlot));
    else
        MECM_OcInventoryDebug(oPC, "slot restore failed, kept " + GetName(oItem) + " in inventory");
}

int MECM_RestoreOcHenchmanItems(object oPC, object oHenchman, int bPendingOnly)
{
    string sHenchmanId = MECM_GetOcHenchmanId(oHenchman);
    json jState = MECM_GetOcInventoryState();
    json jItems = MECM_GetOcHenchmanItems(jState, sHenchmanId);
    int iRestored;
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jItems); iIndex++)
    {
        json jRecord = JsonArrayGet(jItems, iIndex);
        int bPending = JsonGetInt(JsonObjectGet(jRecord, "pending"));
        if (bPendingOnly && !bPending)
            continue;
        string sUuid = JsonGetString(JsonObjectGet(jRecord, "uuid"));
        object oItem = MECM_FindManagedOcItem(oHenchman, sHenchmanId, sUuid);
        if (GetIsObjectValid(oItem))
            continue;
        json jObject = JsonObjectGet(jRecord, "object");
        if (JsonGetType(jObject) != JSON_TYPE_OBJECT)
            continue;
        int iBaseItemType = JsonGetInt(JsonPointer(jObject, "/BaseItem/value"));
        if (!GetBaseItemFitsInInventory(iBaseItemType, oHenchman))
        {
            jRecord = JsonObjectSet(jRecord, "pending", JsonInt(TRUE));
            jItems = JsonArraySet(jItems, iIndex, jRecord);
            if (!bPending)
                MECM_OcInventoryDebug(oPC, "pending item, insufficient inventory space for " + sHenchmanId);
            continue;
        }
        SetLocalInt(GetModule(), MECM_OC_RESTORING_ITEMS, TRUE);
        oItem = JsonToObject(jObject, GetLocation(oHenchman), oHenchman, TRUE);
        DeleteLocalInt(GetModule(), MECM_OC_RESTORING_ITEMS);
        if (!GetIsObjectValid(oItem) || GetItemPossessor(oItem, TRUE) != oHenchman)
        {
            if (GetIsObjectValid(oItem))
                DestroyObject(oItem);
            jRecord = JsonObjectSet(jRecord, "pending", JsonInt(TRUE));
            jItems = JsonArraySet(jItems, iIndex, jRecord);
            if (!bPending)
                MECM_OcInventoryDebug(oPC, "pending item, insufficient inventory space for " + sHenchmanId);
            continue;
        }
        MECM_MarkManagedOcItem(oItem, sHenchmanId);
        iRestored++;
        int iSlot = JsonGetInt(JsonObjectGet(jRecord, "slot"));
        if (iSlot >= 0 && iSlot < NUM_INVENTORY_SLOTS)
        {
            AssignCommand(oHenchman, ActionEquipItem(oItem, iSlot));
            DelayCommand(1.0f, MECM_VerifyOcEquipment(oPC, oHenchman, oItem, iSlot));
        }
    }
    jState = MECM_SetOcHenchmanItems(jState, sHenchmanId, jItems);
    MECM_WriteOcInventoryState(oPC, jState);
    if (iRestored > 0)
        MECM_OcInventoryDebug(oPC, "restored " + IntToString(iRestored) + " items for " + sHenchmanId);
    return iRestored;
}

int MECM_IsActiveOcHenchman(object oPC, object oHenchman)
{
    int iNth = 1;
    object oCurrent = GetHenchman(oPC, iNth);
    while (GetIsObjectValid(oCurrent))
    {
        if (oCurrent == oHenchman)
            return TRUE;
        iNth++;
        oCurrent = GetHenchman(oPC, iNth);
    }
    return FALSE;
}

void MECM_ProcessOcHenchman(object oPC, object oHenchman)
{
    string sIncarnation = GetObjectUUID(oHenchman);
    int iRestored;
    if (!GetLocalInt(oHenchman, MECM_LOCAL_HENCHMAN_INVENTORY_PROCESSED) || GetLocalString(oHenchman, MECM_LOCAL_HENCHMAN_INVENTORY_PROCESSED_UUID) != sIncarnation)
    {
        MECM_OcInventoryDebug(oPC, "detected new " + GetName(oHenchman) + " incarnation");
        MECM_ProtectHenchmanInventory(oHenchman);
        MECM_OcInventoryDebug(oPC, "native inventory protected");
    }
    if (GetLocalString(oHenchman, MECM_OC_INVENTORY_RESTORED) != sIncarnation)
    {
        iRestored = MECM_RestoreOcHenchmanItems(oPC, oHenchman, FALSE);
        SetLocalString(oHenchman, MECM_OC_INVENTORY_RESTORED, sIncarnation);
    }
    else
        iRestored = MECM_RestoreOcHenchmanItems(oPC, oHenchman, TRUE);
    if (iRestored > 0)
        DelayCommand(1.1f, MECM_ReconcileOcHenchman(oPC, oHenchman));
    else
        MECM_ReconcileOcHenchman(oPC, oHenchman);
}

int MECM_SeparateNativeOcStack(object oPC, object oHenchman, object oItem, int iAcquired, string sHenchmanId)
{
    int iTotal = GetItemStackSize(oItem);
    int bWasCursed = GetItemCursedFlag(oItem);
    if (iAcquired <= 0 || iAcquired >= iTotal)
    {
        MECM_MarkManagedOcItem(oItem, sHenchmanId);
        return TRUE;
    }
    json jNative = ObjectToJson(oItem, TRUE);
    if (JsonGetType(jNative) != JSON_TYPE_OBJECT)
        return FALSE;
    if (!GetBaseItemFitsInInventory(GetBaseItemType(oItem), oHenchman))
    {
        MECM_OcInventoryDebug(oPC, "could not separate acquired stack because the henchman inventory is full");
        return FALSE;
    }
    SetItemStackSize(oItem, iAcquired);
    MECM_MarkManagedOcItem(oItem, sHenchmanId);
    ForceRefreshObjectUUID(oItem);
    SetLocalInt(GetModule(), MECM_OC_RESTORING_ITEMS, TRUE);
    object oNative = JsonToObject(jNative, GetLocation(oHenchman), oHenchman, TRUE);
    DeleteLocalInt(GetModule(), MECM_OC_RESTORING_ITEMS);
    if (!GetIsObjectValid(oNative) || GetItemPossessor(oNative, TRUE) != oHenchman)
    {
        if (GetIsObjectValid(oNative))
            DestroyObject(oNative);
        SetItemStackSize(oItem, iTotal);
        MECM_ClearManagedOcItem(oItem);
        SetLocalInt(oItem, MECM_OC_NATIVE_ITEM, TRUE);
        SetItemCursedFlag(oItem, bWasCursed);
        MECM_OcInventoryDebug(oPC, "could not separate acquired stack from protected native stack");
        return FALSE;
    }
    SetItemStackSize(oNative, iTotal - iAcquired);
    MECM_ClearManagedOcItem(oNative);
    SetLocalInt(oNative, MECM_OC_NATIVE_ITEM, TRUE);
    SetItemCursedFlag(oNative, TRUE);
    return TRUE;
}

object MECM_GetOcInventoryRoot(object oObject)
{
    if (!GetIsObjectValid(oObject))
        return OBJECT_INVALID;
    if (GetObjectType(oObject) == OBJECT_TYPE_ITEM)
        return GetItemPossessor(oObject, TRUE);
    return oObject;
}

void MECM_HandleOcItemAcquired(object oItem, object oAcquiredBy, object oFrom, int iAcquired)
{
    if (!MECM_IsOriginalCampaign() || !GetIsObjectValid(oItem) || GetLocalInt(GetModule(), MECM_OC_RESTORING_ITEMS))
        return;
    object oPC = MECM_GetOcPlayer();
    if (!MECM_IsRootPlayer(oPC))
        return;
    object oFinalOwner = GetItemPossessor(oItem, TRUE);
    string sNewHenchmanId = MECM_GetOcHenchmanId(oFinalOwner);
    string sOldHenchmanId = GetLocalString(oItem, MECM_OC_MANAGED_OWNER);
    string sUuid = GetLocalInt(oItem, MECM_OC_MANAGED_ITEM) ? GetObjectUUID(oItem) : "";
    object oFromRoot = MECM_GetOcInventoryRoot(oFrom);
    if (sNewHenchmanId != "" && MECM_IsActiveOcHenchman(oPC, oFinalOwner) && GetLocalString(oFinalOwner, MECM_OC_INVENTORY_RESTORED) == GetObjectUUID(oFinalOwner))
    {
        int bFromPlayer = oFromRoot == oPC;
        int bAlreadyManaged = GetLocalInt(oItem, MECM_OC_MANAGED_ITEM);
        if (!bFromPlayer && !bAlreadyManaged)
            return;
        if (sOldHenchmanId != "" && sOldHenchmanId != sNewHenchmanId)
            MECM_RemoveOcItemRecord(oPC, sOldHenchmanId, sUuid, oItem);
        if (bFromPlayer && GetLocalInt(oItem, MECM_OC_NATIVE_ITEM))
        {
            if (!MECM_SeparateNativeOcStack(oPC, oFinalOwner, oItem, iAcquired, sNewHenchmanId))
                return;
        }
        else
            MECM_MarkManagedOcItem(oItem, sNewHenchmanId);
        MECM_OcInventoryDebug(oPC, "acquired managed item " + GetName(oItem) + " " + GetObjectUUID(oItem));
        MECM_ReconcileOcHenchman(oPC, oFinalOwner);
        return;
    }
    if (GetLocalInt(oItem, MECM_OC_MANAGED_ITEM) && sOldHenchmanId != "")
    {
        MECM_RemoveOcItemRecord(oPC, sOldHenchmanId, sUuid, oItem);
        MECM_ClearManagedOcItem(oItem);
    }
}

void MECM_HandleOcItemLost(object oItem, object oLostBy, string sHenchmanId, string sUuid)
{
    if (!MECM_IsOriginalCampaign())
        return;
    object oPC = MECM_GetOcPlayer();
    object oHenchman = MECM_GetOcInventoryRoot(oLostBy);
    if (!MECM_IsRootPlayer(oPC) || !MECM_IsOcHenchman(oHenchman) || !MECM_IsActiveOcHenchman(oPC, oHenchman))
        return;
    MECM_ReconcileOcHenchman(oPC, oHenchman);
}
