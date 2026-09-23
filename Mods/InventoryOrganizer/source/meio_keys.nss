// Physical key-item containers and original-object inventory transfers.

#include "meio_storage"

void MEIO_StoreAllKeyItemsStep(object oPC, int iGeneration);
void MEIO_WithdrawAllKeyItemsStep(object oPC, int iGeneration);
void MEIO_TouchKeyTransfer(object oPC);

void MEIO_StartKeyItemStoreBatch(object oPC, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration || GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != MEIO_TRANSFER_STORE_KEY_ITEMS)
    {
        return;
    }
    MEIO_TouchKeyTransfer(oPC);
    DelayCommand(0.1f, MEIO_StoreAllKeyItemsStep(oPC, iGeneration));
}

void MEIO_StartKeyItemWithdrawal(object oPC, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration || GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != MEIO_TRANSFER_WITHDRAW_KEY_ITEMS)
    {
        return;
    }
    MEIO_TouchKeyTransfer(oPC);
    DelayCommand(0.1f, MEIO_WithdrawAllKeyItemsStep(oPC, iGeneration));
}

void MEIO_TouchKeyTransfer(object oPC)
{
    SetLocalInt(oPC, MEIO_LOCAL_KEY_TRANSFER_LEASE, GetLocalInt(oPC, MEIO_LOCAL_HEARTBEAT_COUNTER) + 1);
}

void MEIO_EndKeyTransfer(object oPC, int iMode)
{
    DeleteLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM);
    DeleteLocalInt(oPC, MEIO_LOCAL_KEY_TRANSFER_LEASE);
    MEIO_EndTransfer(oPC, iMode);
}

void MEIO_RecoverStaleKeyTransfer(object oPC)
{
    int iMode = GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE);
    if (iMode != MEIO_TRANSFER_STORE_KEY_ITEMS && iMode != MEIO_TRANSFER_WITHDRAW_KEY_ITEMS)
    {
        return;
    }
    int iLease = GetLocalInt(oPC, MEIO_LOCAL_KEY_TRANSFER_LEASE);
    int iHeartbeat = GetLocalInt(oPC, MEIO_LOCAL_HEARTBEAT_COUNTER) + 1;
    if (iLease > 0 && iHeartbeat - iLease < 2)
    {
        return;
    }
    object oPending = GetLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM);
    if (GetIsObjectValid(oPending))
    {
        DeleteLocalInt(oPending, MEIO_LOCAL_KEY_MOVE_PENDING);
    }
    SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1);
    MEIO_EndKeyTransfer(oPC, iMode);
    SendMessageToPC(oPC, MEIO_GetText(oPC, "key_transfer_recovered"));
    MEIO_Debug(oPC, "Recovered stale key item transfer mode=" + IntToString(iMode));
}

void MEIO_UpdateKeyContainer(object oPC, object oContainer)
{
    string sItemLanguage = MEIO_GetLanguage(oPC);
    string sDescription = MEIO_GetText(oPC, "key_container_description");
    if (!MEIO_IsKeyItemContainer(oContainer) || GetLocalString(oContainer, MEIO_LOCAL_ITEM_LANGUAGE) == sItemLanguage)
    {
        return;
    }
    SetName(oContainer, MEIO_GetText(oPC, "key_container_name"));
    SetDescription(oContainer, sDescription, TRUE);
    SetDescription(oContainer, sDescription, FALSE);
    SetLocalString(oContainer, MEIO_LOCAL_ITEM_LANGUAGE, sItemLanguage);
}

int MEIO_GetInventoryFootprint(object oItem)
{
    int iBaseItem = GetBaseItemType(oItem);
    int iWidth = StringToInt(Get2DAString("baseitems", "InvSlotWidth", iBaseItem));
    int iHeight = StringToInt(Get2DAString("baseitems", "InvSlotHeight", iBaseItem));
    if (iWidth < 1)
    {
        iWidth = 1;
    }
    if (iHeight < 1)
    {
        iHeight = 1;
    }
    return iWidth * iHeight;
}

object MEIO_FindFirstKeyItemContainer(object oPC, int bRequireEmpty)
{
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsKeyItemContainer(oItem) && (!bRequireEmpty || !GetIsObjectValid(GetFirstItemInInventory(oItem))))
        {
            return oItem;
        }
        oItem = GetNextItemInInventory(oPC);
    }
    return OBJECT_INVALID;
}

int MEIO_HasKeyItemContainer(object oPC)
{
    return GetIsObjectValid(MEIO_FindFirstKeyItemContainer(oPC, FALSE));
}

object MEIO_FindKeyItemContainerWithRoom(object oPC, object oItem)
{
    int iBaseItem = GetBaseItemType(oItem);
    object oCandidate = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oCandidate))
    {
        if (MEIO_IsDirectlyIn(oCandidate, oPC) && MEIO_IsKeyItemContainer(oCandidate) && GetBaseItemFitsInInventory(iBaseItem, oCandidate))
        {
            return oCandidate;
        }
        oCandidate = GetNextItemInInventory(oPC);
    }
    return OBJECT_INVALID;
}

object MEIO_FindLargestStorableKeyItem(object oPC, int iGeneration)
{
    object oBest = OBJECT_INVALID;
    int iBestFootprint;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_CanStoreKeyItem(oItem) && GetLocalInt(oItem, MEIO_LOCAL_KEY_BATCH_GENERATION) != iGeneration && !GetLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING))
        {
            int iFootprint = MEIO_GetInventoryFootprint(oItem);
            if (!GetIsObjectValid(oBest) || iFootprint > iBestFootprint)
            {
                oBest = oItem;
                iBestFootprint = iFootprint;
            }
        }
        oItem = GetNextItemInInventory(oPC);
    }
    return oBest;
}

object MEIO_FindFirstContainedItem(object oPC, int bRequireInventoryRoom)
{
    object oContainer = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oContainer))
    {
        if (MEIO_IsDirectlyIn(oContainer, oPC) && MEIO_IsKeyItemContainer(oContainer))
        {
            object oItem = GetFirstItemInInventory(oContainer);
            while (GetIsObjectValid(oItem))
            {
                if (MEIO_IsDirectlyIn(oItem, oContainer) && !MEIO_IsCursedItem(oItem) && !MEIO_IsRecallStone(oItem) && !GetLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING) && (!bRequireInventoryRoom || GetBaseItemFitsInInventory(GetBaseItemType(oItem), oPC)))
                {
                    return oItem;
                }
                oItem = GetNextItemInInventory(oContainer);
            }
        }
        oContainer = GetNextItemInInventory(oPC);
    }
    return OBJECT_INVALID;
}

json MEIO_NewKeyContainerRow(object oContainer, string sIcon, string sName)
{
    json jRow = JsonObject();
    jRow = JsonObjectSet(jRow, "oid", JsonString(GetIsObjectValid(oContainer) ? ObjectToString(oContainer) : "inventory"));
    jRow = JsonObjectSet(jRow, "icon", JsonString(sIcon));
    jRow = JsonObjectSet(jRow, "name", JsonString(sName));
    jRow = JsonObjectSet(jRow, "items", JsonArray());
    return jRow;
}

json MEIO_NewKeyItemEntry(object oItem)
{
    json jItem = JsonObject();
    jItem = JsonObjectSet(jItem, "oid", JsonString(ObjectToString(oItem)));
    jItem = JsonObjectSet(jItem, "icon", JsonString(MEMORIA_GetItemIcon(oItem)));
    jItem = JsonObjectSet(jItem, "name", JsonString(GetName(oItem)));
    jItem = JsonObjectSet(jItem, "cursed", JsonBool(MEIO_IsCursedItem(oItem)));
    jItem = JsonObjectSet(jItem, "small", JsonBool(MEIO_GetInventoryFootprint(oItem) == 1));
    return jItem;
}

json MEIO_AddKeyItemToRows(json jRows, object oContainer, object oItem)
{
    string sOID = ObjectToString(oContainer);
    int iRow;
    for (iRow = 0; iRow < JsonGetLength(jRows); iRow++)
    {
        json jRow = JsonArrayGet(jRows, iRow);
        if (JsonGetString(JsonObjectGet(jRow, "oid")) == sOID)
        {
            json jItems = JsonObjectGet(jRow, "items");
            jRow = JsonObjectSet(jRow, "items", JsonArrayInsert(jItems, MEIO_NewKeyItemEntry(oItem)));
            return JsonArraySet(jRows, iRow, jRow);
        }
    }
    json jRow = MEIO_NewKeyContainerRow(oContainer, MEMORIA_GetItemIcon(oContainer), GetName(oContainer));
    jRow = JsonObjectSet(jRow, "items", JsonArrayInsert(JsonArray(), MEIO_NewKeyItemEntry(oItem)));
    return JsonArrayInsert(jRows, jRow);
}

json MEIO_EnsureKeyContainerRow(json jRows, object oContainer)
{
    string sOID = ObjectToString(oContainer);
    int iRow;
    for (iRow = 0; iRow < JsonGetLength(jRows); iRow++)
    {
        if (JsonGetString(JsonObjectGet(JsonArrayGet(jRows, iRow), "oid")) == sOID)
        {
            return jRows;
        }
    }
    return JsonArrayInsert(jRows, MEIO_NewKeyContainerRow(oContainer, MEMORIA_GetItemIcon(oContainer), GetName(oContainer)));
}

json MEIO_BuildKeyItemIndex(object oPC)
{
    json jLooseItems = JsonArray();
    json jOrdinaryContainers = JsonArray();
    json jKeyContainers = JsonArray();
    object oTopLevelItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oTopLevelItem))
    {
        if (!MEIO_IsDirectlyIn(oTopLevelItem, oPC))
        {
            oTopLevelItem = GetNextItemInInventory(oPC);
            continue;
        }
        if (MEIO_IsKeyItemContainer(oTopLevelItem))
        {
            MEIO_UpdateKeyContainer(oPC, oTopLevelItem);
            jKeyContainers = MEIO_EnsureKeyContainerRow(jKeyContainers, oTopLevelItem);
        }
        else if (MEIO_IsKeyItem(oTopLevelItem) && !MEIO_IsMemoriaItem(oTopLevelItem) && !MEIO_IsRecallStone(oTopLevelItem))
        {
            jLooseItems = JsonArrayInsert(jLooseItems, MEIO_NewKeyItemEntry(oTopLevelItem));
        }
        if (GetBaseItemType(oTopLevelItem) == BASE_ITEM_LARGEBOX)
        {
            object oContainedItem = GetFirstItemInInventory(oTopLevelItem);
            while (GetIsObjectValid(oContainedItem))
            {
                if (MEIO_IsDirectlyIn(oContainedItem, oTopLevelItem))
                {
                    if (MEIO_IsKeyItemContainer(oTopLevelItem) && !MEIO_IsRecallStone(oContainedItem))
                    {
                        jKeyContainers = MEIO_AddKeyItemToRows(jKeyContainers, oTopLevelItem, oContainedItem);
                    }
                    else if (MEIO_IsKeyItem(oContainedItem) && !MEIO_IsMemoriaItem(oContainedItem) && !MEIO_IsRecallStone(oContainedItem))
                    {
                        jOrdinaryContainers = MEIO_AddKeyItemToRows(jOrdinaryContainers, oTopLevelItem, oContainedItem);
                    }
                }
                oContainedItem = GetNextItemInInventory(oTopLevelItem);
            }
        }
        oTopLevelItem = GetNextItemInInventory(oPC);
    }
    json jIndex = JsonArray();
    if (JsonGetLength(jLooseItems) > 0)
    {
        json jLooseRow = MEIO_NewKeyContainerRow(OBJECT_INVALID, "ir_inventory", MEIO_GetText(oPC, "loose_key_items"));
        jLooseRow = JsonObjectSet(jLooseRow, "items", jLooseItems);
        jIndex = JsonArrayInsert(jIndex, jLooseRow);
    }
    int iRow;
    for (iRow = 0; iRow < JsonGetLength(jOrdinaryContainers); iRow++)
    {
        jIndex = JsonArrayInsert(jIndex, JsonArrayGet(jOrdinaryContainers, iRow));
    }
    for (iRow = 0; iRow < JsonGetLength(jKeyContainers); iRow++)
    {
        jIndex = JsonArrayInsert(jIndex, JsonArrayGet(jKeyContainers, iRow));
    }
    MEIO_Debug(oPC, "Key item index built rows=" + IntToString(JsonGetLength(jIndex)) + " loose=" + IntToString(JsonGetLength(jLooseItems)) + " ordinaryContainers=" + IntToString(JsonGetLength(jOrdinaryContainers)) + " keyContainers=" + IntToString(JsonGetLength(jKeyContainers)));
    return jIndex;
}

int MEIO_GetKeyItemCapacity(json jIndex)
{
    int iCapacity = 12;
    int iContainer;
    for (iContainer = 0; iContainer < JsonGetLength(jIndex); iContainer++)
    {
        int iCount = JsonGetLength(JsonObjectGet(JsonArrayGet(jIndex, iContainer), "items"));
        if (iCount > iCapacity)
        {
            iCapacity = iCount;
        }
    }
    return iCapacity;
}

void MEIO_RebuildOpenKeyItemWindow(object oPC)
{
    DelayCommand(0.05f, MEIO_RebuildOpenWindowIndex(oPC));
}

void MEIO_ConfirmKeyItemStored(object oPC, object oItem, object oContainer, int iGeneration, int bBulk)
{
    int bMoved = MEIO_IsDirectlyIn(oItem, oContainer) && MEIO_IsKeyItemContainer(oContainer);
    MEIO_Debug(oPC, "Key item store completed moved=" + IntToString(bMoved) + " container=" + ObjectToString(oContainer) + " " + MEIO_DebugItemState(oPC, oItem));
    if (GetIsObjectValid(oItem))
    {
        DeleteLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING);
        if (bMoved)
        {
            MEIO_UnmarkKeepOut(oPC, oItem);
        }
    }
    if (GetLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM) == oItem)
    {
        DeleteLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM);
    }
    if (bMoved && bBulk && GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) == iGeneration && GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) == MEIO_TRANSFER_STORE_KEY_ITEMS)
    {
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL) + 1);
    }
    MEIO_RebuildOpenKeyItemWindow(oPC);
    if (bBulk && GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) == iGeneration && GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) == MEIO_TRANSFER_STORE_KEY_ITEMS)
    {
        MEIO_TouchKeyTransfer(oPC);
        DelayCommand(0.1f, MEIO_StoreAllKeyItemsStep(oPC, iGeneration));
    }
}

int MEIO_StoreKeyItem(object oPC, object oItem, int iGeneration, int bBulk)
{
    if (!MEIO_IsDirectlyIn(oItem, oPC) || !MEIO_CanStoreKeyItem(oItem) || GetLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING))
    {
        return FALSE;
    }
    object oContainer = MEIO_FindKeyItemContainerWithRoom(oPC, oItem);
    if (!GetIsObjectValid(oContainer))
    {
        return FALSE;
    }
    SetLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING, TRUE);
    SetLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM, oItem);
    MEIO_Debug(oPC, "Key item store queued container=" + ObjectToString(oContainer) + " bulk=" + IntToString(bBulk) + " " + MEIO_DebugItemState(oPC, oItem));
    AssignCommand(oPC, ActionGiveItem(oItem, oContainer));
    AssignCommand(oPC, ActionDoCommand(MEIO_ConfirmKeyItemStored(oPC, oItem, oContainer, iGeneration, bBulk)));
    return TRUE;
}

void MEIO_ConfirmKeyItemWithdrawn(object oPC, object oItem, object oContainer, int iGeneration)
{
    int bMoved = MEIO_IsDirectlyIn(oItem, oPC);
    MEIO_Debug(oPC, "Key item withdrawal completed moved=" + IntToString(bMoved) + " container=" + ObjectToString(oContainer) + " " + MEIO_DebugItemState(oPC, oItem));
    if (GetIsObjectValid(oItem))
    {
        DeleteLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING);
        if (!bMoved)
        {
            MEIO_UnmarkKeepOut(oPC, oItem);
        }
    }
    if (GetLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM) == oItem)
    {
        DeleteLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM);
    }
    if (bMoved && GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) == iGeneration && GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) == MEIO_TRANSFER_WITHDRAW_KEY_ITEMS)
    {
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL) + 1);
    }
    MEIO_RebuildOpenKeyItemWindow(oPC);
    if (!bMoved && GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) == iGeneration && GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) == MEIO_TRANSFER_WITHDRAW_KEY_ITEMS)
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "inventory_full_key_items"));
        MEIO_EndKeyTransfer(oPC, MEIO_TRANSFER_WITHDRAW_KEY_ITEMS);
        return;
    }
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) == iGeneration && GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) == MEIO_TRANSFER_WITHDRAW_KEY_ITEMS)
    {
        MEIO_TouchKeyTransfer(oPC);
        DelayCommand(0.1f, MEIO_WithdrawAllKeyItemsStep(oPC, iGeneration));
    }
}

int MEIO_WithdrawKeyItem(object oPC, object oItem, int iGeneration)
{
    object oContainer = GetItemPossessor(oItem, TRUE);
    if (GetObjectType(oContainer) != OBJECT_TYPE_ITEM || !MEIO_IsDirectlyIn(oContainer, oPC) || !MEIO_IsDirectlyIn(oItem, oContainer) || GetLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING) || !GetBaseItemFitsInInventory(GetBaseItemType(oItem), oPC))
    {
        return FALSE;
    }
    MEIO_MarkKeepOut(oPC, oItem);
    SetLocalInt(oItem, MEIO_LOCAL_KEY_MOVE_PENDING, TRUE);
    SetLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM, oItem);
    MEIO_Debug(oPC, "Key item withdrawal queued container=" + ObjectToString(oContainer) + " " + MEIO_DebugItemState(oPC, oItem));
    AssignCommand(oPC, ActionTakeItem(oItem, oContainer));
    AssignCommand(oPC, ActionDoCommand(MEIO_ConfirmKeyItemWithdrawn(oPC, oItem, oContainer, iGeneration)));
    return TRUE;
}

object MEIO_ResolveDisplayedKeyItem(object oPC, json jEntry)
{
    object oItem = StringToObject(JsonGetString(JsonObjectGet(jEntry, "oid")));
    if (!GetIsObjectValid(oItem) || MEIO_IsRecallStone(oItem))
    {
        return OBJECT_INVALID;
    }
    object oPossessor = GetItemPossessor(oItem, TRUE);
    if (oPossessor == oPC)
    {
        return oItem;
    }
    if (GetObjectType(oPossessor) == OBJECT_TYPE_ITEM && MEIO_IsDirectlyIn(oPossessor, oPC) && MEIO_IsDirectlyIn(oItem, oPossessor))
    {
        return oItem;
    }
    return OBJECT_INVALID;
}

int MEIO_MoveDisplayedKeyItem(object oPC, json jEntry)
{
    object oItem = MEIO_ResolveDisplayedKeyItem(oPC, jEntry);
    if (!GetIsObjectValid(oItem))
    {
        return FALSE;
    }
    if (MEIO_IsCursedItem(oItem))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "cursed_key_item_locked"));
        return FALSE;
    }
    if (MEIO_IsTransferBusy(oPC) || GetIsObjectValid(GetLocalObject(oPC, MEIO_LOCAL_KEY_PENDING_ITEM)))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "transfer_busy"));
        return FALSE;
    }
    if (MEIO_IsDirectlyIn(oItem, oPC))
    {
        if (!MEIO_HasKeyItemContainer(oPC))
        {
            SendMessageToPC(oPC, MEIO_GetText(oPC, "no_key_container"));
            return FALSE;
        }
        if (!MEIO_StoreKeyItem(oPC, oItem, 0, FALSE))
        {
            SendMessageToPC(oPC, MEIO_GetText(oPC, "key_containers_full"));
            return FALSE;
        }
        return TRUE;
    }
    if (!GetBaseItemFitsInInventory(GetBaseItemType(oItem), oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "inventory_full_key_items"));
        return FALSE;
    }
    return MEIO_WithdrawKeyItem(oPC, oItem, 0);
}

object MEIO_CreateKeyItemContainer(object oPC)
{
    if (!GetBaseItemFitsInInventory(BASE_ITEM_LARGEBOX, oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "key_container_no_space"));
        return OBJECT_INVALID;
    }
    object oContainer = CreateItemOnObject(MEIO_KEY_CONTAINER_RESREF, oPC, 1, MEIO_KEY_CONTAINER_TAG);
    if (!MEIO_IsDirectlyIn(oContainer, oPC))
    {
        if (GetIsObjectValid(oContainer))
        {
            DestroyObject(oContainer);
        }
        SendMessageToPC(oPC, MEIO_GetText(oPC, "key_container_no_space"));
        return OBJECT_INVALID;
    }
    SetTag(oContainer, MEIO_KEY_CONTAINER_TAG);
    SetItemCursedFlag(oContainer, TRUE);
    SetPlotFlag(oContainer, FALSE);
    SetLocalInt(oContainer, MEIO_LOCAL_KEY_CONTAINER_SCHEMA, MEIO_KEY_CONTAINER_SCHEMA);
    MEIO_UpdateKeyContainer(oPC, oContainer);
    MEIO_Debug(oPC, "Key item container created container=" + ObjectToString(oContainer));
    SendMessageToPC(oPC, MEIO_GetText(oPC, "key_container_created"));
    return oContainer;
}

int MEIO_RemoveEmptyKeyItemContainer(object oPC)
{
    object oContainer = MEIO_FindFirstKeyItemContainer(oPC, TRUE);
    if (!GetIsObjectValid(oContainer))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "no_empty_key_container"));
        return FALSE;
    }
    if (!MEIO_IsDirectlyIn(oContainer, oPC) || !MEIO_IsKeyItemContainer(oContainer) || GetIsObjectValid(GetFirstItemInInventory(oContainer)))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "no_empty_key_container"));
        return FALSE;
    }
    DestroyObject(oContainer);
    MEIO_Debug(oPC, "Empty key item container removed container=" + ObjectToString(oContainer));
    SendMessageToPC(oPC, MEIO_GetText(oPC, "key_container_removed"));
    return TRUE;
}

void MEIO_CreateKeyItemContainerFromUI(object oPC)
{
    if (MEIO_IsTransferBusy(oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "transfer_busy"));
        return;
    }
    if (GetIsObjectValid(MEIO_CreateKeyItemContainer(oPC)))
    {
        MEIO_RebuildOpenKeyItemWindow(oPC);
    }
}

void MEIO_RemoveEmptyKeyItemContainerFromUI(object oPC)
{
    if (MEIO_IsTransferBusy(oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "transfer_busy"));
        return;
    }
    if (MEIO_RemoveEmptyKeyItemContainer(oPC))
    {
        MEIO_RebuildOpenKeyItemWindow(oPC);
    }
}

void MEIO_StoreAllKeyItemsStep(object oPC, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration || GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != MEIO_TRANSFER_STORE_KEY_ITEMS)
    {
        return;
    }
    MEIO_TouchKeyTransfer(oPC);
    object oItem = MEIO_FindLargestStorableKeyItem(oPC, iGeneration);
    if (GetIsObjectValid(oItem))
    {
        if (MEIO_StoreKeyItem(oPC, oItem, iGeneration, TRUE))
        {
            return;
        }
        SetLocalInt(oItem, MEIO_LOCAL_KEY_BATCH_GENERATION, iGeneration);
        DelayCommand(0.1f, MEIO_StoreAllKeyItemsStep(oPC, iGeneration));
        return;
    }
    int iTotal = GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL);
    SendMessageToPC(oPC, IntToString(iTotal) + " " + MEIO_GetText(oPC, "key_items_stored"));
    MEIO_EndKeyTransfer(oPC, MEIO_TRANSFER_STORE_KEY_ITEMS);
    MEIO_RebuildOpenKeyItemWindow(oPC);
}

void MEIO_WithdrawAllKeyItemsStep(object oPC, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration || GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != MEIO_TRANSFER_WITHDRAW_KEY_ITEMS)
    {
        return;
    }
    MEIO_TouchKeyTransfer(oPC);
    object oItem = MEIO_FindFirstContainedItem(oPC, TRUE);
    if (!GetIsObjectValid(oItem))
    {
        int iTotal = GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL);
        if (GetIsObjectValid(MEIO_FindFirstContainedItem(oPC, FALSE)))
        {
            SendMessageToPC(oPC, MEIO_GetText(oPC, "inventory_full_key_items"));
        }
        else
        {
            SendMessageToPC(oPC, IntToString(iTotal) + " " + MEIO_GetText(oPC, "key_items_withdrawn"));
        }
        MEIO_EndKeyTransfer(oPC, MEIO_TRANSFER_WITHDRAW_KEY_ITEMS);
        MEIO_RebuildOpenKeyItemWindow(oPC);
        return;
    }
    if (!MEIO_WithdrawKeyItem(oPC, oItem, iGeneration))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "inventory_full_key_items"));
        MEIO_EndKeyTransfer(oPC, MEIO_TRANSFER_WITHDRAW_KEY_ITEMS);
        MEIO_RebuildOpenKeyItemWindow(oPC);
    }
}
