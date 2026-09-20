// Compact level-grouped Scriptorium NUI with live search and filters.

#include "meio_cast"

string MEIO_SlotSuffix(int iLevel, int iSlot)
{
    return IntToString(iLevel) + "_" + IntToString(iSlot);
}

int MEIO_CountLevel(json jIndex, int iLevel)
{
    int iCount;
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jIndex); iIndex++)
    {
        if (JsonGetInt(JsonObjectGet(JsonArrayGet(jIndex, iIndex), "level")) == iLevel)
        {
            iCount++;
        }
    }
    return iCount;
}

json MEIO_BuildCapacities(object oPC, json jIndex)
{
    json jCapacities = JsonArray();
    int iLevel;
    for (iLevel = 0; iLevel <= 9; iLevel++)
    {
        jCapacities = JsonArrayInsert(jCapacities, JsonInt(MEIO_CountLevel(jIndex, iLevel) + 1));
    }
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsScroll(oItem))
        {
            int iSubtype = MEIO_GetOnlyCastSubtype(oItem);
            int iSpell = iSubtype >= 0 ? MEIO_GetSpell(iSubtype) : -1;
            int iSpellLevel = iSpell >= 0 ? MEIO_GetSpellLevel(iSpell) : -1;
            if (iSpellLevel >= 0)
            {
                jCapacities = JsonArraySet(jCapacities, iSpellLevel, JsonInt(JsonGetInt(JsonArrayGet(jCapacities, iSpellLevel)) + 1));
            }
        }
        oItem = GetNextItemInInventory(oPC);
    }
    return jCapacities;
}

json MEIO_TargetEntries(object oPC)
{
    json jEntries = JsonArray();
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(MEIO_GetText(oPC, "filter_all_targets"), MEIO_TARGET_ALL));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(MEIO_GetText(oPC, "filter_self"), MEIO_TARGET_SELF));
    jEntries = JsonArrayInsert(jEntries, NuiComboEntry(MEIO_GetText(oPC, "filter_ally"), MEIO_TARGET_ALLY));
    return JsonArrayInsert(jEntries, NuiComboEntry(MEIO_GetText(oPC, "filter_enemy"), MEIO_TARGET_ENEMY));
}

int MEIO_BuildPotionCapacity(object oPC, json jIndex)
{
    int iCapacity = JsonGetLength(jIndex) + 1;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsUsablePotion(oItem))
        {
            iCapacity++;
        }
        oItem = GetNextItemInInventory(oPC);
    }
    return iCapacity;
}

json MEIO_BuildPotionSlot(int iSlot)
{
    string sSlot = IntToString(iSlot);
    json jDraw = JsonArray();
    json jRect = NuiRect(8.0f, 2.0f, 32.0f, 64.0f);
    jDraw = JsonArrayInsert(jDraw, NuiDrawListImage(JsonBool(TRUE), NuiBind("potion_bottom_" + sSlot), jRect, JsonInt(NUI_ASPECT_EXACT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jDraw = JsonArrayInsert(jDraw, NuiDrawListImage(JsonBool(TRUE), NuiBind("potion_middle_" + sSlot), jRect, JsonInt(NUI_ASPECT_EXACT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jDraw = JsonArrayInsert(jDraw, NuiDrawListImage(JsonBool(TRUE), NuiBind("potion_top_" + sSlot), jRect, JsonInt(NUI_ASPECT_EXACT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jDraw = JsonArrayInsert(jDraw, NuiDrawListText(JsonBool(TRUE), NuiColor(225, 190, 95), NuiRect(24.0f, 48.0f, 26.0f, 18.0f), NuiBind("potion_quantity_" + sSlot)));
    json jButton = NuiDrawList(NuiId(NuiButton(JsonString("")), "potion_" + sSlot), JsonBool(TRUE), jDraw);
    return NuiWidth(NuiHeight(NuiVisible(NuiTooltip(jButton, NuiBind("potion_tip_" + sSlot)), NuiBind("potion_visible_" + sSlot)), 70.0f), 54.0f);
}

json MEIO_BuildPotionGrid(int iCapacity)
{
    json jRows = JsonArray();
    int iSlot;
    for (iSlot = 0; iSlot < iCapacity; iSlot += MEIO_POTION_COLUMNS)
    {
        json jRow = JsonArray();
        int iColumn;
        for (iColumn = 0; iColumn < MEIO_POTION_COLUMNS && iSlot + iColumn < iCapacity; iColumn++)
        {
            jRow = JsonArrayInsert(jRow, MEIO_BuildPotionSlot(iSlot + iColumn));
        }
        jRows = JsonArrayInsert(jRows, NuiHeight(NuiRow(jRow), 72.0f));
    }
    return NuiGroup(NuiCol(jRows), TRUE, NUI_SCROLLBARS_Y);
}

json MEIO_BuildSpellSlot(int iLevel, int iSlot)
{
    string sSuffix = MEIO_SlotSuffix(iLevel, iSlot);
    json jCell = JsonArray();
    json jButton = NuiTooltip(NuiId(NuiButtonImage(NuiBind("icon_" + sSuffix)), "spell_" + sSuffix), NuiBind("tip_" + sSuffix));
    jCell = JsonArrayInsert(jCell, NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind("quantity_" + sSuffix), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(225, 190, 95)), 18.0f));
    jCell = JsonArrayInsert(jCell, NuiHeight(jButton, 44.0f));
    return NuiWidth(NuiVisible(NuiCol(jCell), NuiBind("visible_" + sSuffix)), 48.0f);
}

json MEIO_BuildLevelRow(json jCapacities, int iLevel)
{
    json jSpells = JsonArray();
    int iCapacity = JsonGetInt(JsonArrayGet(jCapacities, iLevel));
    int iSlot;
    for (iSlot = 0; iSlot < iCapacity; iSlot++)
    {
        jSpells = JsonArrayInsert(jSpells, MEIO_BuildSpellSlot(iLevel, iSlot));
    }
    json jRow = JsonArray();
    jRow = JsonArrayInsert(jRow, NuiWidth(NuiStyleForegroundColor(NuiLabel(JsonString(IntToString(iLevel)), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(225, 190, 95)), 34.0f));
    jRow = JsonArrayInsert(jRow, NuiGroup(NuiRow(jSpells), FALSE, NUI_SCROLLBARS_X));
    return NuiHeight(NuiRow(jRow), 82.0f);
}

json MEIO_BuildWindow(object oPC, json jCapacities, int iPotionCapacity, int iTab)
{
    json jRoot = JsonArray();
    json jTabs = JsonArray();
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_scrolls"))), "tab_scrolls"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_potions"))), "tab_potions"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiSpacer());
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jTabs), 30.0f));
    json jScrolls = JsonArray();
    json jSearch = JsonArray();
    jSearch = JsonArrayInsert(jSearch, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "search")), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 70.0f));
    jSearch = JsonArrayInsert(jSearch, NuiTextEdit(JsonString(MEIO_GetText(oPC, "search_hint")), NuiBind("search"), 80, FALSE));
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiRow(jSearch), 30.0f));
    json jFilters = JsonArray();
    jFilters = JsonArrayInsert(jFilters, NuiWidth(NuiCombo(MEIO_TargetEntries(oPC), NuiBind("target")), 500.0f));
    jFilters = JsonArrayInsert(jFilters, NuiSpacer());
    jFilters = JsonArrayInsert(jFilters, NuiWidth(NuiLabel(NuiBind("result_count"), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 110.0f));
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiRow(jFilters), 30.0f));
    json jRows = JsonArray();
    int iLevel;
    for (iLevel = 0; iLevel <= 9; iLevel++)
    {
        jRows = JsonArrayInsert(jRows, MEIO_BuildLevelRow(jCapacities, iLevel));
    }
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiGroup(NuiCol(jRows), TRUE, NUI_SCROLLBARS_Y), 322.0f));
    json jScrollFooter = JsonArray();
    jScrollFooter = JsonArrayInsert(jScrollFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "return_scrolls"))), "return_scrolls"), 190.0f));
    jScrollFooter = JsonArrayInsert(jScrollFooter, NuiSpacer());
    jScrollFooter = JsonArrayInsert(jScrollFooter, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "withdraw_hint")), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 430.0f));
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiRow(jScrollFooter), 32.0f));
    if (iTab == MEIO_TAB_SCROLLS)
    {
        jRoot = JsonArrayInsert(jRoot, NuiCol(jScrolls));
    }
    json jPotions = JsonArray();
    jPotions = JsonArrayInsert(jPotions, NuiHeight(MEIO_BuildPotionGrid(iPotionCapacity), 382.0f));
    json jPotionFooter = JsonArray();
    jPotionFooter = JsonArrayInsert(jPotionFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "return_potions"))), "return_potions"), 190.0f));
    jPotionFooter = JsonArrayInsert(jPotionFooter, NuiSpacer());
    jPotionFooter = JsonArrayInsert(jPotionFooter, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "potion_hint")), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 430.0f));
    jPotions = JsonArrayInsert(jPotions, NuiHeight(NuiRow(jPotionFooter), 32.0f));
    if (iTab == MEIO_TAB_POTIONS)
    {
        jRoot = JsonArrayInsert(jRoot, NuiCol(jPotions));
    }
    return NuiWindow(NuiCol(jRoot), JsonString(MEIO_GetText(oPC, "window_title")), NuiRect(-1.0f, -1.0f, 760.0f, 500.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

string MEIO_BuildSpellTip(object oPC, json jEntry)
{
    string sName = JsonGetString(JsonObjectGet(jEntry, "name"));
    string sDetails = JsonGetString(JsonObjectGet(jEntry, "alias"));
    string sTip = sDetails == "" || sDetails == sName ? sName : sName + ": " + sDetails;
    int iCasterLevel = JsonGetInt(JsonObjectGet(jEntry, "caster_level"));
    if (iCasterLevel > 0)
    {
        sTip += " (" + MEIO_GetText(oPC, "caster_level") + " " + IntToString(iCasterLevel) + ")";
    }
    return sTip;
}

void MEIO_SetEmptySlot(object oPC, int iToken, int iLevel, int iSlot)
{
    string sSuffix = MEIO_SlotSuffix(iLevel, iSlot);
    NuiSetBind(oPC, iToken, "visible_" + sSuffix, JsonBool(FALSE));
    NuiSetBind(oPC, iToken, "icon_" + sSuffix, JsonString(""));
    NuiSetBind(oPC, iToken, "tip_" + sSuffix, JsonString(""));
    NuiSetBind(oPC, iToken, "quantity_" + sSuffix, JsonString(""));
}

void MEIO_RefreshWindow(object oPC, int iToken)
{
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_INDEX);
    json jFiltered = MEIO_FilterIndex(jIndex, NuiGetBind(oPC, iToken, "search"), JsonGetInt(NuiGetBind(oPC, iToken, "target")));
    SetLocalJson(oPC, MEIO_LOCAL_FILTERED_INDEX, jFiltered);
    json jCapacities = GetLocalJson(oPC, MEIO_LOCAL_LEVEL_CAPACITIES);
    json jDisplay = JsonObject();
    int iLevel;
    for (iLevel = 0; iLevel <= 9; iLevel++)
    {
        int iSlot = 0;
        int iIndex;
        for (iIndex = 0; iIndex < JsonGetLength(jFiltered); iIndex++)
        {
            json jEntry = JsonArrayGet(jFiltered, iIndex);
            if (JsonGetInt(JsonObjectGet(jEntry, "level")) != iLevel)
            {
                continue;
            }
            if (iSlot >= JsonGetInt(JsonArrayGet(jCapacities, iLevel)))
            {
                break;
            }
            string sSuffix = MEIO_SlotSuffix(iLevel, iSlot);
            NuiSetBind(oPC, iToken, "visible_" + sSuffix, JsonBool(TRUE));
            NuiSetBind(oPC, iToken, "icon_" + sSuffix, JsonObjectGet(jEntry, "icon"));
            NuiSetBind(oPC, iToken, "tip_" + sSuffix, JsonString(MEIO_BuildSpellTip(oPC, jEntry)));
            NuiSetBind(oPC, iToken, "quantity_" + sSuffix, JsonString("x" + IntToString(JsonGetInt(JsonObjectGet(jEntry, "quantity")))));
            jDisplay = JsonObjectSet(jDisplay, "spell_" + sSuffix, jEntry);
            iSlot++;
        }
        int iCapacity = JsonGetInt(JsonArrayGet(jCapacities, iLevel));
        while (iSlot < iCapacity)
        {
            MEIO_SetEmptySlot(oPC, iToken, iLevel, iSlot);
            iSlot++;
        }
    }
    SetLocalJson(oPC, MEIO_LOCAL_DISPLAY_ENTRIES, jDisplay);
    NuiSetBind(oPC, iToken, "result_count", JsonString(IntToString(JsonGetLength(jFiltered)) + " / " + IntToString(JsonGetLength(jIndex))));
}

string MEIO_BuildPotionTip(json jEntry)
{
    string sName = JsonGetString(JsonObjectGet(jEntry, "name"));
    string sDetails = JsonGetString(JsonObjectGet(jEntry, "alias"));
    return sDetails == "" || sDetails == sName ? sName : sName + ": " + sDetails;
}

void MEIO_SetEmptyPotionSlot(object oPC, int iToken, int iSlot)
{
    string sSlot = IntToString(iSlot);
    NuiSetBind(oPC, iToken, "potion_visible_" + sSlot, JsonBool(FALSE));
    NuiSetBind(oPC, iToken, "potion_bottom_" + sSlot, JsonString(""));
    NuiSetBind(oPC, iToken, "potion_middle_" + sSlot, JsonString(""));
    NuiSetBind(oPC, iToken, "potion_top_" + sSlot, JsonString(""));
    NuiSetBind(oPC, iToken, "potion_quantity_" + sSlot, JsonString(""));
    NuiSetBind(oPC, iToken, "potion_tip_" + sSlot, JsonString(""));
}

void MEIO_RefreshPotionWindow(object oPC, int iToken)
{
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_POTION_INDEX);
    int iCapacity = GetLocalInt(oPC, MEIO_LOCAL_POTION_CAPACITY);
    json jDisplay = JsonObject();
    int iSlot;
    for (iSlot = 0; iSlot < iCapacity; iSlot++)
    {
        if (iSlot < JsonGetLength(jIndex))
        {
            json jEntry = JsonArrayGet(jIndex, iSlot);
            string sSlot = IntToString(iSlot);
            NuiSetBind(oPC, iToken, "potion_visible_" + sSlot, JsonBool(TRUE));
            NuiSetBind(oPC, iToken, "potion_bottom_" + sSlot, JsonObjectGet(jEntry, "bottom"));
            NuiSetBind(oPC, iToken, "potion_middle_" + sSlot, JsonObjectGet(jEntry, "middle"));
            NuiSetBind(oPC, iToken, "potion_top_" + sSlot, JsonObjectGet(jEntry, "top"));
            NuiSetBind(oPC, iToken, "potion_quantity_" + sSlot, JsonString("x" + IntToString(JsonGetInt(JsonObjectGet(jEntry, "quantity")))));
            NuiSetBind(oPC, iToken, "potion_tip_" + sSlot, JsonString(MEIO_BuildPotionTip(jEntry)));
            jDisplay = JsonObjectSet(jDisplay, "potion_" + sSlot, jEntry);
        }
        else
        {
            MEIO_SetEmptyPotionSlot(oPC, iToken, iSlot);
        }
    }
    SetLocalJson(oPC, MEIO_LOCAL_POTION_ENTRIES, jDisplay);
}

void MEIO_RebuildWindowIndex(object oPC, int iToken)
{
    object oStorage = MEIO_EnsureStorage(oPC);
    object oPotionStorage = MEIO_EnsurePotionStorage(oPC);
    SetLocalJson(oPC, MEIO_LOCAL_INDEX, MEIO_BuildIndex(oStorage));
    SetLocalJson(oPC, MEIO_LOCAL_POTION_INDEX, MEIO_BuildPotionIndex(oPotionStorage));
    if (GetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB) == MEIO_TAB_POTIONS)
    {
        MEIO_RefreshPotionWindow(oPC, iToken);
    }
    else
    {
        MEIO_RefreshWindow(oPC, iToken);
    }
}

void MEIO_RemoveOneFromWindowIndex(object oPC, int iToken, json jSelected)
{
    string sKey = JsonGetString(JsonObjectGet(jSelected, "key"));
    int iSubtype = JsonGetInt(JsonObjectGet(jSelected, "subtype"));
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_INDEX);
    json jUpdated = JsonArray();
    int bRemoved;
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jIndex); iIndex++)
    {
        json jEntry = JsonArrayGet(jIndex, iIndex);
        if (!bRemoved && JsonGetString(JsonObjectGet(jEntry, "key")) == sKey && JsonGetInt(JsonObjectGet(jEntry, "subtype")) == iSubtype)
        {
            int iQuantity = JsonGetInt(JsonObjectGet(jEntry, "quantity")) - 1;
            if (iQuantity > 0)
            {
                jUpdated = JsonArrayInsert(jUpdated, JsonObjectSet(jEntry, "quantity", JsonInt(iQuantity)));
            }
            bRemoved = TRUE;
        }
        else
        {
            jUpdated = JsonArrayInsert(jUpdated, jEntry);
        }
    }
    SetLocalJson(oPC, MEIO_LOCAL_INDEX, jUpdated);
    MEIO_RefreshWindow(oPC, iToken);
}

void MEIO_RemoveOneFromPotionWindowIndex(object oPC, int iToken, json jSelected)
{
    string sKey = JsonGetString(JsonObjectGet(jSelected, "key"));
    int iSubtype = JsonGetInt(JsonObjectGet(jSelected, "subtype"));
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_POTION_INDEX);
    json jUpdated = JsonArray();
    int bRemoved;
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jIndex); iIndex++)
    {
        json jEntry = JsonArrayGet(jIndex, iIndex);
        if (!bRemoved && JsonGetString(JsonObjectGet(jEntry, "key")) == sKey && JsonGetInt(JsonObjectGet(jEntry, "subtype")) == iSubtype)
        {
            int iQuantity = JsonGetInt(JsonObjectGet(jEntry, "quantity")) - 1;
            if (iQuantity > 0)
            {
                jUpdated = JsonArrayInsert(jUpdated, JsonObjectSet(jEntry, "quantity", JsonInt(iQuantity)));
            }
            bRemoved = TRUE;
        }
        else
        {
            jUpdated = JsonArrayInsert(jUpdated, jEntry);
        }
    }
    SetLocalJson(oPC, MEIO_LOCAL_POTION_INDEX, jUpdated);
    MEIO_RefreshPotionWindow(oPC, iToken);
}

void MEIO_RebuildOpenWindowIndex(object oPC)
{
    int iToken = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iToken > 0)
    {
        MEIO_RebuildWindowIndex(oPC, iToken);
    }
}

void MEIO_OpenTab(object oPC, int iTab)
{
    if (iTab != MEIO_TAB_POTIONS)
    {
        iTab = MEIO_TAB_SCROLLS;
    }
    SetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB, iTab);
    object oScriptorium = MEIO_EnsureScriptorium(oPC);
    object oStorage = MEIO_EnsureStorage(oPC);
    object oPotionStorage = MEIO_EnsurePotionStorage(oPC);
    if (!GetIsObjectValid(oScriptorium) || !GetIsObjectValid(oStorage) || !GetIsObjectValid(oPotionStorage))
    {
        return;
    }
    MEIO_ValidateContents(oPC, oStorage);
    MEIO_ValidatePotionContents(oPC, oPotionStorage);
    int iUnsupported;
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oStorage) && MEIO_IsScroll(oItem) && (MEIO_GetOnlyCastSubtype(oItem) < 0 || MEIO_GetSpell(MEIO_GetOnlyCastSubtype(oItem)) < 0))
        {
            iUnsupported++;
        }
        oItem = GetNextItemInInventory(oStorage);
    }
    if (iUnsupported > 0)
    {
        SendMessageToPC(oPC, "[MEIO] " + IntToString(iUnsupported) + " " + MEIO_GetText(oPC, "unsupported_scrolls"));
    }
    json jIndex = MEIO_BuildIndex(oStorage);
    json jPotionIndex = MEIO_BuildPotionIndex(oPotionStorage);
    json jCapacities = MEIO_BuildCapacities(oPC, jIndex);
    int iPotionCapacity = MEIO_BuildPotionCapacity(oPC, jPotionIndex);
    SetLocalJson(oPC, MEIO_LOCAL_INDEX, jIndex);
    SetLocalJson(oPC, MEIO_LOCAL_POTION_INDEX, jPotionIndex);
    SetLocalJson(oPC, MEIO_LOCAL_LEVEL_CAPACITIES, jCapacities);
    SetLocalInt(oPC, MEIO_LOCAL_POTION_CAPACITY, iPotionCapacity);
    int iOld = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iOld > 0)
    {
        NuiDestroy(oPC, iOld);
    }
    int iToken = MEMORIA_NUI_Create(oPC, MEIO_BuildWindow(oPC, jCapacities, iPotionCapacity, iTab), MEIO_WINDOW, "meio_nuievt");
    if (iToken > 0)
    {
        if (iTab == MEIO_TAB_SCROLLS)
        {
            NuiSetBind(oPC, iToken, "search", JsonString(""));
            NuiSetBind(oPC, iToken, "target", JsonInt(MEIO_TARGET_ALL));
            MEIO_RefreshWindow(oPC, iToken);
            NuiSetBindWatch(oPC, iToken, "search", TRUE);
            NuiSetBindWatch(oPC, iToken, "target", TRUE);
        }
        else
        {
            MEIO_RefreshPotionWindow(oPC, iToken);
        }
    }
}

void MEIO_Open(object oPC)
{
    MEIO_OpenTab(oPC, MEIO_TAB_SCROLLS);
}
