#include "meio_ui"

json MEIO_GetEventEntry(object oPC, string sElement)
{
    json jRows = GetLocalJson(oPC, MEIO_LOCAL_DISPLAY_ENTRIES);
    int iRow = NuiGetEventArrayIndex();
    if (JsonGetType(jRows) != JSON_TYPE_ARRAY || iRow < 0 || iRow >= JsonGetLength(jRows))
    {
        return JsonNull();
    }
    return JsonObjectGet(JsonArrayGet(jRows, iRow), sElement);
}

json MEIO_GetPotionEventEntry(object oPC, string sElement)
{
    return JsonObjectGet(GetLocalJson(oPC, MEIO_LOCAL_POTION_ENTRIES), sElement);
}

json MEIO_GetBookEventEntry(object oPC, string sElement)
{
    return JsonObjectGet(GetLocalJson(oPC, MEIO_LOCAL_BOOK_ENTRIES), sElement);
}

void MEIO_RefreshBatchWindow(object oPC, int iToken)
{
    if (NuiFindWindow(oPC, MEIO_WINDOW) == iToken)
    {
        MEIO_RebuildWindowIndex(oPC, iToken);
    }
}

void MEIO_ScheduleMutationRefresh(object oPC, int iToken)
{
    DelayCommand(0.05f, MEIO_RefreshBatchWindow(oPC, iToken));
}

void MEIO_ReturnAllBatch(object oPC, int iToken, int iGeneration, int iBaseItem)
{
    int iMode = iBaseItem == BASE_ITEM_POTIONS ? MEIO_TRANSFER_STORE_POTIONS : iBaseItem == BASE_ITEM_BOOK ? MEIO_TRANSFER_STORE_BOOKS : MEIO_TRANSFER_STORE_SCROLLS;
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration || GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != iMode)
    {
        return;
    }
    int bComplete = iBaseItem == BASE_ITEM_POTIONS ? MEIO_StorePotionInventoryBatch(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE) : iBaseItem == BASE_ITEM_BOOK ? MEIO_StoreBookInventoryBatch(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE) : MEIO_StoreInventoryBatch(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE);
    int iTotal = GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL) + GetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED);
    SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, iTotal);
    DelayCommand(0.01f, MEIO_RefreshBatchWindow(oPC, iToken));
    if (!bComplete)
    {
        DelayCommand(0.1f, MEIO_ReturnAllBatch(oPC, iToken, iGeneration, iBaseItem));
        return;
    }
    if (iTotal > 0)
    {
        SendMessageToPC(oPC, IntToString(iTotal) + " " + MEIO_GetText(oPC, iBaseItem == BASE_ITEM_POTIONS ? "potions_returned" : iBaseItem == BASE_ITEM_BOOK ? "books_returned" : "returned"));
    }
    MEIO_Debug(oPC, "NUI explicit-return finished moved=" + IntToString(iTotal));
    MEIO_EndTransfer(oPC, iMode);
}

void MEIO_WithdrawAllBatch(object oPC, int iToken, int iGeneration, int iBaseItem)
{
    int iMode = iBaseItem == BASE_ITEM_POTIONS ? MEIO_TRANSFER_WITHDRAW_POTIONS : iBaseItem == BASE_ITEM_BOOK ? MEIO_TRANSFER_WITHDRAW_BOOKS : MEIO_TRANSFER_WITHDRAW_SCROLLS;
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration || GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != iMode)
    {
        return;
    }
    int bComplete = MEIO_WithdrawStorageBatch(oPC, iBaseItem, MEIO_INITIAL_IMPORT_BATCH_SIZE);
    int iTotal = GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL) + GetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED);
    SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, iTotal);
    DelayCommand(0.01f, MEIO_RefreshBatchWindow(oPC, iToken));
    if (!bComplete)
    {
        DelayCommand(0.1f, MEIO_WithdrawAllBatch(oPC, iToken, iGeneration, iBaseItem));
        return;
    }
    if (iTotal > 0)
    {
        SendMessageToPC(oPC, IntToString(iTotal) + " " + MEIO_GetText(oPC, iBaseItem == BASE_ITEM_POTIONS ? "potions_withdrawn_all" : iBaseItem == BASE_ITEM_BOOK ? "books_withdrawn_all" : "scrolls_withdrawn_all"));
    }
    if (GetLocalInt(oPC, MEIO_LOCAL_BATCH_BLOCKED))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "inventory_full"));
    }
    MEIO_EndTransfer(oPC, iMode);
}

void MEIO_BurnDuplicatesBatch(object oPC, int iToken, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration || GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != MEIO_TRANSFER_BURN_BOOKS)
    {
        return;
    }
    int bComplete = MEIO_BurnBookDuplicatesBatch(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE);
    int iTotal = GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL) + GetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED);
    SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, iTotal);
    DelayCommand(0.01f, MEIO_RefreshBatchWindow(oPC, iToken));
    if (!bComplete)
    {
        DelayCommand(0.1f, MEIO_BurnDuplicatesBatch(oPC, iToken, iGeneration));
        return;
    }
    SendMessageToPC(oPC, IntToString(iTotal) + " " + MEIO_GetText(oPC, "book_duplicates_burned"));
    MEIO_EndTransfer(oPC, MEIO_TRANSFER_BURN_BOOKS);
}

void main()
{
    object oPC = NuiGetEventPlayer();
    int iToken = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElement = NuiGetEventElement();
    MEIO_Debug(oPC, "NUI event type=\"" + sEvent + "\" element=\"" + sElement + "\" token=" + IntToString(iToken));
    if (sEvent == "close")
    {
        MEIO_ScheduleExamineSuppression(oPC, MEIO_FindScriptorium(oPC), "nui-close");
        DeleteLocalJson(oPC, MEIO_LOCAL_INDEX);
        DeleteLocalJson(oPC, MEIO_LOCAL_FILTERED_INDEX);
        DeleteLocalJson(oPC, MEIO_LOCAL_DISPLAY_ENTRIES);
        DeleteLocalJson(oPC, MEIO_LOCAL_POTION_INDEX);
        DeleteLocalJson(oPC, MEIO_LOCAL_POTION_ENTRIES);
        DeleteLocalJson(oPC, MEIO_LOCAL_BOOK_INDEX);
        DeleteLocalJson(oPC, MEIO_LOCAL_BOOK_ENTRIES);
        DeleteLocalJson(oPC, MEIO_LOCAL_LEVEL_CAPACITIES);
        DeleteLocalInt(oPC, MEIO_LOCAL_POTION_CAPACITY);
        DeleteLocalInt(oPC, MEIO_LOCAL_BOOK_CAPACITY);
        return;
    }
    if (sEvent == "watch" && (sElement == "search" || sElement == "target" || sElement == "english_names" || sElement == "show_caster_level"))
    {
        MEIO_RefreshWindow(oPC, iToken);
        return;
    }
    if (sEvent == "watch" && (sElement == "book_search" || sElement == "book_english_names"))
    {
        MEIO_RefreshBookWindow(oPC, iToken);
        return;
    }
    if (sEvent == "mousedown" && GetSubString(sElement, 0, 6) == "spell_" && JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn")) == NUI_MOUSE_BUTTON_RIGHT)
    {
        json jSelected = MEIO_GetEventEntry(oPC, sElement);
        MEIO_Debug(oPC, "NUI decision=withdraw selection=" + JsonDump(jSelected));
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT && MEIO_WithdrawOne(oPC, jSelected))
        {
            MEIO_RemoveOneFromWindowIndex(oPC, iToken, jSelected);
            MEIO_ScheduleMutationRefresh(oPC, iToken);
        }
        return;
    }
    if (sEvent == "mousedown" && GetSubString(sElement, 0, 7) == "potion_" && JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn")) == NUI_MOUSE_BUTTON_RIGHT)
    {
        json jSelected = MEIO_GetPotionEventEntry(oPC, sElement);
        MEIO_Debug(oPC, "NUI decision=withdraw-potion selection=" + JsonDump(jSelected));
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT && MEIO_WithdrawPotionOne(oPC, jSelected))
        {
            MEIO_RemoveOneFromPotionWindowIndex(oPC, iToken, jSelected);
            MEIO_ScheduleMutationRefresh(oPC, iToken);
        }
        return;
    }
    if (sEvent == "mousedown" && GetSubString(sElement, 0, 5) == "book_" && JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn")) == NUI_MOUSE_BUTTON_RIGHT)
    {
        json jSelected = MEIO_GetBookEventEntry(oPC, sElement);
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT && MEIO_WithdrawBookOne(oPC, jSelected))
        {
            MEIO_RemoveOneFromBookWindowIndex(oPC, iToken, jSelected);
            MEIO_ScheduleMutationRefresh(oPC, iToken);
        }
        return;
    }
    if (sEvent != "click")
    {
        return;
    }
    if (sElement == "store_scrolls")
    {
        if (!MEIO_BeginTransfer(oPC, MEIO_TRANSFER_STORE_SCROLLS, TRUE))
        {
            return;
        }
        MEIO_Debug(oPC, "NUI decision=explicit-return-all-carried-scrolls");
        int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1;
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, iGeneration);
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, 0);
        MEIO_ReturnAllBatch(oPC, iToken, iGeneration, BASE_ITEM_SPELLSCROLL);
        return;
    }
    if (sElement == "store_potions")
    {
        if (!MEIO_BeginTransfer(oPC, MEIO_TRANSFER_STORE_POTIONS, TRUE))
        {
            return;
        }
        MEIO_Debug(oPC, "NUI decision=explicit-return-all-carried-potions");
        int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1;
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, iGeneration);
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, 0);
        MEIO_ReturnAllBatch(oPC, iToken, iGeneration, BASE_ITEM_POTIONS);
        return;
    }
    if (sElement == "store_books")
    {
        if (!MEIO_BeginTransfer(oPC, MEIO_TRANSFER_STORE_BOOKS, TRUE))
        {
            return;
        }
        int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1;
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, iGeneration);
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, 0);
        MEIO_ReturnAllBatch(oPC, iToken, iGeneration, BASE_ITEM_BOOK);
        return;
    }
    if (sElement == "withdraw_all_scrolls" || sElement == "withdraw_all_potions" || sElement == "withdraw_all_books")
    {
        int iBaseItem = sElement == "withdraw_all_potions" ? BASE_ITEM_POTIONS : sElement == "withdraw_all_books" ? BASE_ITEM_BOOK : BASE_ITEM_SPELLSCROLL;
        int iMode = iBaseItem == BASE_ITEM_POTIONS ? MEIO_TRANSFER_WITHDRAW_POTIONS : iBaseItem == BASE_ITEM_BOOK ? MEIO_TRANSFER_WITHDRAW_BOOKS : MEIO_TRANSFER_WITHDRAW_SCROLLS;
        if (!MEIO_BeginTransfer(oPC, iMode, TRUE))
        {
            return;
        }
        int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1;
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, iGeneration);
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, 0);
        MEIO_WithdrawAllBatch(oPC, iToken, iGeneration, iBaseItem);
        return;
    }
    if (sElement == "burn_duplicates")
    {
        if (!MEIO_BeginTransfer(oPC, MEIO_TRANSFER_BURN_BOOKS, TRUE))
        {
            return;
        }
        int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1;
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, iGeneration);
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, 0);
        MEIO_BeginBookDuplicateBurn(oPC);
        MEIO_BurnDuplicatesBatch(oPC, iToken, iGeneration);
        return;
    }
    if (sElement == "tab_scrolls")
    {
        MEIO_OpenTab(oPC, MEIO_TAB_SCROLLS);
        return;
    }
    if (sElement == "tab_potions")
    {
        MEIO_OpenTab(oPC, MEIO_TAB_POTIONS);
        return;
    }
    if (sElement == "tab_books")
    {
        MEIO_OpenTab(oPC, MEIO_TAB_BOOKS);
        return;
    }
    if (GetSubString(sElement, 0, 5) == "book_")
    {
        json jSelected = MEIO_GetBookEventEntry(oPC, sElement);
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT)
        {
            MEIO_ShowBookDescription(oPC, jSelected, JsonGetInt(NuiGetBind(oPC, iToken, "book_english_names")));
        }
        return;
    }
    if (GetSubString(sElement, 0, 6) == "spell_")
    {
        json jSelected = MEIO_GetEventEntry(oPC, sElement);
        MEIO_Debug(oPC, "NUI decision=cast selection=" + JsonDump(jSelected));
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT && !MEIO_BeginCast(oPC, jSelected))
        {
            MEIO_RebuildWindowIndex(oPC, iToken);
        }
        else
        {
            MEIO_ScheduleMutationRefresh(oPC, iToken);
        }
        return;
    }
    if (GetSubString(sElement, 0, 7) == "potion_")
    {
        json jSelected = MEIO_GetPotionEventEntry(oPC, sElement);
        MEIO_Debug(oPC, "NUI decision=use-potion selection=" + JsonDump(jSelected));
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT && !MEIO_BeginPotionUse(oPC, jSelected))
        {
            MEIO_RebuildWindowIndex(oPC, iToken);
        }
        else
        {
            MEIO_ScheduleMutationRefresh(oPC, iToken);
        }
    }
}
