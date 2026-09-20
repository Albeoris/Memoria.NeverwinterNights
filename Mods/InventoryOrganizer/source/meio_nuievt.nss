#include "meio_ui"

json MEIO_GetEventEntry(object oPC, string sElement)
{
    return JsonObjectGet(GetLocalJson(oPC, MEIO_LOCAL_DISPLAY_ENTRIES), sElement);
}

json MEIO_GetPotionEventEntry(object oPC, string sElement)
{
    return JsonObjectGet(GetLocalJson(oPC, MEIO_LOCAL_POTION_ENTRIES), sElement);
}

void MEIO_ReturnAllBatch(object oPC, int iToken, int iGeneration, int iBaseItem)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) != iGeneration)
    {
        return;
    }
    int bComplete = iBaseItem == BASE_ITEM_POTIONS ? MEIO_StorePotionInventoryBatch(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE) : MEIO_StoreInventoryBatch(oPC, MEIO_INITIAL_IMPORT_BATCH_SIZE);
    int iTotal = GetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL) + GetLocalInt(oPC, MEIO_LOCAL_BATCH_MOVED);
    SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, iTotal);
    if (NuiFindWindow(oPC, MEIO_WINDOW) == iToken)
    {
        MEIO_RebuildWindowIndex(oPC, iToken);
    }
    if (!bComplete)
    {
        DelayCommand(0.1f, MEIO_ReturnAllBatch(oPC, iToken, iGeneration, iBaseItem));
        return;
    }
    if (iTotal > 0)
    {
        SendMessageToPC(oPC, IntToString(iTotal) + " " + MEIO_GetText(oPC, iBaseItem == BASE_ITEM_POTIONS ? "potions_returned" : "returned"));
    }
    MEIO_Debug(oPC, "NUI explicit-return finished moved=" + IntToString(iTotal));
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
        if (GetLocalInt(oPC, MEIO_LOCAL_EXAMINE_DISABLED))
        {
            object oExamined = GetLocalObject(oPC, MEIO_LOCAL_EXAMINE_ITEM);
            SetGuiPanelDisabled(oPC, GUI_PANEL_EXAMINE_ITEM, TRUE, oExamined);
            DelayCommand(0.1f, SetGuiPanelDisabled(oPC, GUI_PANEL_EXAMINE_ITEM, FALSE, oExamined));
            DeleteLocalObject(oPC, MEIO_LOCAL_EXAMINE_ITEM);
            DeleteLocalInt(oPC, MEIO_LOCAL_EXAMINE_DISABLED);
        }
        DeleteLocalJson(oPC, MEIO_LOCAL_INDEX);
        DeleteLocalJson(oPC, MEIO_LOCAL_FILTERED_INDEX);
        DeleteLocalJson(oPC, MEIO_LOCAL_DISPLAY_ENTRIES);
        DeleteLocalJson(oPC, MEIO_LOCAL_POTION_INDEX);
        DeleteLocalJson(oPC, MEIO_LOCAL_POTION_ENTRIES);
        DeleteLocalJson(oPC, MEIO_LOCAL_LEVEL_CAPACITIES);
        DeleteLocalInt(oPC, MEIO_LOCAL_POTION_CAPACITY);
        return;
    }
    if (sEvent == "watch" && (sElement == "search" || sElement == "target"))
    {
        MEIO_RefreshWindow(oPC, iToken);
        return;
    }
    if (sEvent == "mousedown" && GetSubString(sElement, 0, 6) == "spell_" && JsonGetInt(JsonObjectGet(NuiGetEventPayload(), "mouse_btn")) == NUI_MOUSE_BUTTON_RIGHT)
    {
        json jSelected = MEIO_GetEventEntry(oPC, sElement);
        MEIO_Debug(oPC, "NUI decision=withdraw selection=" + JsonDump(jSelected));
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT && MEIO_WithdrawOne(oPC, jSelected))
        {
            MEIO_RemoveOneFromWindowIndex(oPC, iToken, jSelected);
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
        }
        return;
    }
    if (sEvent != "click")
    {
        return;
    }
    if (sElement == "return_scrolls")
    {
        MEIO_Debug(oPC, "NUI decision=explicit-return-all-carried-scrolls");
        int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1;
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, iGeneration);
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, 0);
        MEIO_ReturnAllBatch(oPC, iToken, iGeneration, BASE_ITEM_SPELLSCROLL);
        return;
    }
    if (sElement == "return_potions")
    {
        MEIO_Debug(oPC, "NUI decision=explicit-return-all-carried-potions");
        int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION) + 1;
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_GENERATION, iGeneration);
        SetLocalInt(oPC, MEIO_LOCAL_RETURN_TOTAL, 0);
        MEIO_ReturnAllBatch(oPC, iToken, iGeneration, BASE_ITEM_POTIONS);
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
    if (GetSubString(sElement, 0, 6) == "spell_")
    {
        json jSelected = MEIO_GetEventEntry(oPC, sElement);
        MEIO_Debug(oPC, "NUI decision=cast selection=" + JsonDump(jSelected));
        if (JsonGetType(jSelected) == JSON_TYPE_OBJECT && !MEIO_BeginCast(oPC, jSelected))
        {
            MEIO_RebuildWindowIndex(oPC, iToken);
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
    }
}
