// Compact level-grouped Scriptorium NUI with live search and filters.

#include "meio_cast"

void MEIO_OpenTab(object oPC, int iTab);

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
        jCapacities = JsonArrayInsert(jCapacities, JsonInt(MEIO_CountLevel(jIndex, iLevel)));
    }
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsScroll(oItem) && MEIO_CanStoreItem(oItem))
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

int MEIO_GetSpellRowCapacity(json jCapacities)
{
    int iCapacity;
    int iLevel;
    for (iLevel = 0; iLevel <= 9; iLevel++)
    {
        int iLevelCapacity = JsonGetInt(JsonArrayGet(jCapacities, iLevel));
        if (iLevelCapacity > iCapacity)
        {
            iCapacity = iLevelCapacity;
        }
    }
    return iCapacity > 0 ? iCapacity : 1;
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
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_IsUsablePotion(oItem) && MEIO_CanStoreItem(oItem))
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

json MEIO_BuildSpellSlot(int iSlot, float fSlotWidth, float fIconSize, float fQuantityHeight)
{
    string sSlot = IntToString(iSlot);
    json jCell = JsonArray();
    json jButton = NuiTooltip(NuiId(NuiButtonImage(NuiBind("spell_icon_" + sSlot)), "spell_" + sSlot), NuiBind("spell_tip_" + sSlot));
    jCell = JsonArrayInsert(jCell, NuiWidth(NuiHeight(jButton, fIconSize), fIconSize));
    jCell = JsonArrayInsert(jCell, NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind("spell_quantity_" + sSlot), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(225, 190, 95)), fQuantityHeight));
    json jSlot = NuiPadding(NuiGroup(NuiCol(jCell), FALSE, NUI_SCROLLBARS_NONE), 0.0f);
    return NuiWidth(NuiHeight(NuiVisible(jSlot, NuiBind("spell_visible_" + sSlot)), fIconSize + fQuantityHeight), fSlotWidth);
}

json MEIO_BuildLevelList(object oPC, json jCapacities)
{
    int iCapacity = MEIO_GetSpellRowCapacity(jCapacities);
    float fScale = MEIO_GetUIScale(oPC);
    float fIconSize = 44.0f * fScale;
    float fSlotWidth = 48.0f * fScale;
    float fQuantityHeight = 12.0f;
    float fRowHeight = fIconSize + fQuantityHeight + 1.0f;
    float fLevelWidth = 34.0f * fScale;
    json jRow = JsonArray();
    json jLevel = NuiStyleForegroundColor(NuiLabel(NuiBind("spell_level"), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(225, 190, 95));
    jRow = JsonArrayInsert(jRow, NuiWidth(jLevel, fLevelWidth));
    int iSlot;
    for (iSlot = 0; iSlot < iCapacity; iSlot++)
    {
        jRow = JsonArrayInsert(jRow, MEIO_BuildSpellSlot(iSlot, fSlotWidth, fIconSize, fQuantityHeight));
    }
    json jRowElement = NuiPadding(NuiGroup(NuiRow(jRow), FALSE, NUI_SCROLLBARS_NONE), 0.0f);
    jRowElement = NuiHeight(jRowElement, fRowHeight);
    json jTemplate = JsonArray();
    jTemplate = JsonArrayInsert(jTemplate, NuiListTemplateCell(jRowElement, fLevelWidth + fSlotWidth * IntToFloat(iCapacity), FALSE));
    return NuiList(jTemplate, NuiBind("spell_level_count"), fRowHeight, FALSE, NUI_SCROLLBARS_BOTH);
}

json MEIO_BuildWindow(object oPC, json jCapacities, int iPotionCapacity, int iTab)
{
    json jRoot = JsonArray();
    json jTabs = JsonArray();
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_scrolls"))), "tab_scrolls"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_potions"))), "tab_potions"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiSpacer());
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jTabs), 30.0f));
    string sCommandKey = iTab == MEIO_TAB_POTIONS ? "potions_command_hint" : "scrolls_command_hint";
    json jCommandHint = NuiStyleForegroundColor(NuiLabel(JsonString(MEIO_GetText(oPC, sCommandKey)), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(180, 180, 180));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(jCommandHint, 22.0f));
    json jScrolls = JsonArray();
    json jSearch = JsonArray();
    jSearch = JsonArrayInsert(jSearch, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "search")), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 70.0f));
    jSearch = JsonArrayInsert(jSearch, NuiTextEdit(JsonString(MEIO_GetText(oPC, "search_hint")), NuiBind("search"), 80, FALSE));
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiRow(jSearch), 30.0f));
    json jFilters = JsonArray();
    jFilters = JsonArrayInsert(jFilters, NuiWidth(NuiCombo(MEIO_TargetEntries(oPC), NuiBind("target")), 220.0f));
    jFilters = JsonArrayInsert(jFilters, NuiWidth(NuiCheck(JsonString(MEIO_GetText(oPC, "english_names")), NuiBind("english_names")), 205.0f));
    jFilters = JsonArrayInsert(jFilters, NuiWidth(NuiCheck(JsonString(MEIO_GetText(oPC, "show_caster_level")), NuiBind("show_caster_level")), 205.0f));
    jFilters = JsonArrayInsert(jFilters, NuiSpacer());
    jFilters = JsonArrayInsert(jFilters, NuiWidth(NuiLabel(NuiBind("result_count"), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 90.0f));
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiRow(jFilters), 30.0f));
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(MEIO_BuildLevelList(oPC, jCapacities), 307.0f));
    json jScrollFooter = JsonArray();
    jScrollFooter = JsonArrayInsert(jScrollFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "return_scrolls"))), "store_scrolls"), 170.0f));
    jScrollFooter = JsonArrayInsert(jScrollFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "withdraw_all_scrolls"))), "withdraw_all_scrolls"), 170.0f));
    jScrollFooter = JsonArrayInsert(jScrollFooter, NuiSpacer());
    jScrollFooter = JsonArrayInsert(jScrollFooter, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "withdraw_hint")), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 350.0f));
    jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiRow(jScrollFooter), 32.0f));
    if (iTab == MEIO_TAB_SCROLLS)
    {
        jRoot = JsonArrayInsert(jRoot, NuiCol(jScrolls));
    }
    json jPotions = JsonArray();
    jPotions = JsonArrayInsert(jPotions, NuiHeight(MEIO_BuildPotionGrid(iPotionCapacity), 367.0f));
    json jPotionFooter = JsonArray();
    jPotionFooter = JsonArrayInsert(jPotionFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "return_potions"))), "store_potions"), 170.0f));
    jPotionFooter = JsonArrayInsert(jPotionFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "withdraw_all_potions"))), "withdraw_all_potions"), 170.0f));
    jPotionFooter = JsonArrayInsert(jPotionFooter, NuiSpacer());
    jPotionFooter = JsonArrayInsert(jPotionFooter, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "potion_hint")), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 350.0f));
    jPotions = JsonArrayInsert(jPotions, NuiHeight(NuiRow(jPotionFooter), 32.0f));
    if (iTab == MEIO_TAB_POTIONS)
    {
        jRoot = JsonArrayInsert(jRoot, NuiCol(jPotions));
    }
    return NuiWindow(NuiCol(jRoot), JsonString(MEIO_GetText(oPC, "window_title")), NuiRect(-1.0f, -1.0f, 760.0f, 500.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

string MEIO_BuildSpellTip(object oPC, json jEntry, int bEnglishNames, int bShowCasterLevel)
{
    string sLocalizedName = JsonGetString(JsonObjectGet(jEntry, "name"));
    string sEnglishName = JsonGetString(JsonObjectGet(jEntry, "alias"));
    string sTip = bEnglishNames && sEnglishName != "" ? sEnglishName : sLocalizedName;
    int iCasterLevel = JsonGetInt(JsonObjectGet(jEntry, "caster_level"));
    if (bShowCasterLevel && iCasterLevel > 0)
    {
        sTip += " (" + MEIO_GetText(oPC, "caster_level") + " " + IntToString(iCasterLevel) + ")";
    }
    return sTip;
}

void MEIO_RefreshWindow(object oPC, int iToken)
{
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_INDEX);
    json jFiltered = MEIO_FilterIndex(jIndex, NuiGetBind(oPC, iToken, "search"), JsonGetInt(NuiGetBind(oPC, iToken, "target")));
    int bEnglishNames = JsonGetInt(NuiGetBind(oPC, iToken, "english_names"));
    int bShowCasterLevel = JsonGetInt(NuiGetBind(oPC, iToken, "show_caster_level"));
    SetLocalJson(oPC, MEIO_LOCAL_FILTERED_INDEX, jFiltered);
    json jCapacities = GetLocalJson(oPC, MEIO_LOCAL_LEVEL_CAPACITIES);
    int iCapacity = MEIO_GetSpellRowCapacity(jCapacities);
    json jLevels = JsonArray();
    json jVisibleBySlot = JsonObject();
    json jIconsBySlot = JsonObject();
    json jTipsBySlot = JsonObject();
    json jQuantitiesBySlot = JsonObject();
    json jDisplayRows = JsonArray();
    int iBindSlot;
    for (iBindSlot = 0; iBindSlot < iCapacity; iBindSlot++)
    {
        string sBindSlot = IntToString(iBindSlot);
        jVisibleBySlot = JsonObjectSet(jVisibleBySlot, sBindSlot, JsonArray());
        jIconsBySlot = JsonObjectSet(jIconsBySlot, sBindSlot, JsonArray());
        jTipsBySlot = JsonObjectSet(jTipsBySlot, sBindSlot, JsonArray());
        jQuantitiesBySlot = JsonObjectSet(jQuantitiesBySlot, sBindSlot, JsonArray());
    }
    int iLevel;
    for (iLevel = 9; iLevel >= 0; iLevel--)
    {
        json jLevelEntries = JsonArray();
        int iIndex;
        for (iIndex = 0; iIndex < JsonGetLength(jFiltered); iIndex++)
        {
            json jEntry = JsonArrayGet(jFiltered, iIndex);
            if (JsonGetInt(JsonObjectGet(jEntry, "level")) == iLevel)
            {
                jLevelEntries = JsonArrayInsert(jLevelEntries, jEntry);
            }
        }
        int iLevelCount = JsonGetLength(jLevelEntries);
        if (iLevelCount == 0)
        {
            continue;
        }
        jLevels = JsonArrayInsert(jLevels, JsonString(IntToString(iLevel)));
        json jDisplayRow = JsonObject();
        int iSlot;
        for (iSlot = 0; iSlot < iCapacity; iSlot++)
        {
            string sSlot = IntToString(iSlot);
            json jVisible = JsonObjectGet(jVisibleBySlot, sSlot);
            json jIcons = JsonObjectGet(jIconsBySlot, sSlot);
            json jTips = JsonObjectGet(jTipsBySlot, sSlot);
            json jQuantities = JsonObjectGet(jQuantitiesBySlot, sSlot);
            if (iSlot < iLevelCount)
            {
                json jEntry = JsonArrayGet(jLevelEntries, iSlot);
                jVisible = JsonArrayInsert(jVisible, JsonBool(TRUE));
                jIcons = JsonArrayInsert(jIcons, JsonObjectGet(jEntry, "icon"));
                jTips = JsonArrayInsert(jTips, JsonString(MEIO_BuildSpellTip(oPC, jEntry, bEnglishNames, bShowCasterLevel)));
                jQuantities = JsonArrayInsert(jQuantities, JsonString("x" + IntToString(JsonGetInt(JsonObjectGet(jEntry, "quantity")))));
                jDisplayRow = JsonObjectSet(jDisplayRow, "spell_" + sSlot, jEntry);
            }
            else
            {
                jVisible = JsonArrayInsert(jVisible, JsonBool(FALSE));
                jIcons = JsonArrayInsert(jIcons, JsonString(""));
                jTips = JsonArrayInsert(jTips, JsonString(""));
                jQuantities = JsonArrayInsert(jQuantities, JsonString(""));
            }
            jVisibleBySlot = JsonObjectSet(jVisibleBySlot, sSlot, jVisible);
            jIconsBySlot = JsonObjectSet(jIconsBySlot, sSlot, jIcons);
            jTipsBySlot = JsonObjectSet(jTipsBySlot, sSlot, jTips);
            jQuantitiesBySlot = JsonObjectSet(jQuantitiesBySlot, sSlot, jQuantities);
        }
        jDisplayRows = JsonArrayInsert(jDisplayRows, jDisplayRow);
    }
    int iSlot;
    for (iSlot = 0; iSlot < iCapacity; iSlot++)
    {
        string sSlot = IntToString(iSlot);
        NuiSetBind(oPC, iToken, "spell_visible_" + sSlot, JsonObjectGet(jVisibleBySlot, sSlot));
        NuiSetBind(oPC, iToken, "spell_icon_" + sSlot, JsonObjectGet(jIconsBySlot, sSlot));
        NuiSetBind(oPC, iToken, "spell_tip_" + sSlot, JsonObjectGet(jTipsBySlot, sSlot));
        NuiSetBind(oPC, iToken, "spell_quantity_" + sSlot, JsonObjectGet(jQuantitiesBySlot, sSlot));
    }
    NuiSetBind(oPC, iToken, "spell_level", jLevels);
    NuiSetBind(oPC, iToken, "spell_level_count", JsonInt(JsonGetLength(jLevels)));
    SetLocalJson(oPC, MEIO_LOCAL_DISPLAY_ENTRIES, jDisplayRows);
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
    json jIndex = MEIO_BuildIndex(oStorage);
    if (GetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB) == MEIO_TAB_SCROLLS)
    {
        int iRequiredCapacity;
        int iLevel;
        for (iLevel = 0; iLevel <= 9; iLevel++)
        {
            int iLevelCount = MEIO_CountLevel(jIndex, iLevel);
            if (iLevelCount > iRequiredCapacity)
            {
                iRequiredCapacity = iLevelCount;
            }
        }
        if (iRequiredCapacity > MEIO_GetSpellRowCapacity(GetLocalJson(oPC, MEIO_LOCAL_LEVEL_CAPACITIES)))
        {
            json jSearch = NuiGetBind(oPC, iToken, "search");
            int iTarget = JsonGetInt(NuiGetBind(oPC, iToken, "target"));
            int bEnglishNames = JsonGetInt(NuiGetBind(oPC, iToken, "english_names"));
            int bShowCasterLevel = JsonGetInt(NuiGetBind(oPC, iToken, "show_caster_level"));
            MEIO_OpenTab(oPC, MEIO_TAB_SCROLLS);
            int iNewToken = NuiFindWindow(oPC, MEIO_WINDOW);
            if (iNewToken > 0)
            {
                NuiSetBind(oPC, iNewToken, "search", jSearch);
                NuiSetBind(oPC, iNewToken, "target", JsonInt(iTarget));
                NuiSetBind(oPC, iNewToken, "english_names", JsonBool(bEnglishNames));
                NuiSetBind(oPC, iNewToken, "show_caster_level", JsonBool(bShowCasterLevel));
                MEIO_RefreshWindow(oPC, iNewToken);
            }
            return;
        }
    }
    SetLocalJson(oPC, MEIO_LOCAL_INDEX, jIndex);
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
            NuiSetBind(oPC, iToken, "english_names", JsonBool(FALSE));
            NuiSetBind(oPC, iToken, "show_caster_level", JsonBool(FALSE));
            MEIO_RefreshWindow(oPC, iToken);
            NuiSetBindWatch(oPC, iToken, "search", TRUE);
            NuiSetBindWatch(oPC, iToken, "target", TRUE);
            NuiSetBindWatch(oPC, iToken, "english_names", TRUE);
            NuiSetBindWatch(oPC, iToken, "show_caster_level", TRUE);
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
