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

int MEIO_BuildBookCapacity(object oPC, json jIndex)
{
    int iCapacity = JsonGetLength(jIndex) + 1;
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oPC) && MEIO_CanStoreBook(oItem))
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

json MEIO_BuildBookSlot(int iSlot)
{
    string sSlot = IntToString(iSlot);
    json jCell = JsonArray();
    json jButton = NuiTooltip(NuiId(NuiButtonImage(NuiBind("book_icon_" + sSlot)), "book_" + sSlot), NuiBind("book_tip_" + sSlot));
    jCell = JsonArrayInsert(jCell, NuiWidth(NuiHeight(jButton, 44.0f), 44.0f));
    jCell = JsonArrayInsert(jCell, NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind("book_quantity_" + sSlot), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(225, 190, 95)), 18.0f));
    json jSlot = NuiPadding(NuiGroup(NuiCol(jCell), FALSE, NUI_SCROLLBARS_NONE), 0.0f);
    return NuiWidth(NuiHeight(NuiVisible(jSlot, NuiBind("book_visible_" + sSlot)), 64.0f), 50.0f);
}

json MEIO_BuildBookGrid(int iCapacity)
{
    json jRows = JsonArray();
    int iSlot;
    for (iSlot = 0; iSlot < iCapacity; iSlot += MEIO_POTION_COLUMNS)
    {
        json jRow = JsonArray();
        int iColumn;
        for (iColumn = 0; iColumn < MEIO_POTION_COLUMNS && iSlot + iColumn < iCapacity; iColumn++)
        {
            jRow = JsonArrayInsert(jRow, MEIO_BuildBookSlot(iSlot + iColumn));
        }
        jRows = JsonArrayInsert(jRows, NuiHeight(NuiRow(jRow), 66.0f));
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
    float fQuantityHeight = 18.0f;
    float fRowHeight = fIconSize + fQuantityHeight + 2.0f;
    float fLevelWidth = 34.0f * fScale;
    float fRowSpacing = 2.0f;
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
    float fContentWidth = fLevelWidth + (fSlotWidth + fRowSpacing) * IntToFloat(iCapacity);
    jTemplate = JsonArrayInsert(jTemplate, NuiListTemplateCell(jRowElement, fContentWidth, TRUE));
    return NuiList(jTemplate, NuiBind("spell_level_count"), fRowHeight, FALSE, NUI_SCROLLBARS_BOTH);
}

json MEIO_BuildKeyItemList(int iItemCapacity)
{
    float fRowSpacing = 2.0f;
    json jRow = JsonArray();
    json jContainer = NuiTooltip(NuiImage(NuiBind("key_container_icon"), JsonInt(NUI_ASPECT_FIT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiBind("key_container_tip"));
    jRow = JsonArrayInsert(jRow, NuiWidth(NuiHeight(jContainer, 48.0f), 52.0f));
    int iSlot;
    for (iSlot = 0; iSlot < iItemCapacity; iSlot++)
    {
        string sSlot = IntToString(iSlot);
        json jDraw = JsonArray();
        jDraw = JsonArrayInsert(jDraw, NuiDrawListImage(JsonBool(TRUE), NuiBind("key_item_icon_" + sSlot), NuiBind("key_item_rect_" + sSlot), JsonInt(NUI_ASPECT_FIT), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
        jDraw = JsonArrayInsert(jDraw, NuiDrawListRect(NuiBind("key_item_cursed_" + sSlot), NuiColor(220, 45, 35), JsonBool(FALSE), JsonFloat(2.0f), NuiRect(1.0f, 1.0f, 42.0f, 42.0f)));
        json jButton = NuiDrawList(NuiId(NuiButton(JsonString("")), "key_item_" + sSlot), JsonBool(TRUE), jDraw);
        json jItem = NuiTooltip(jButton, NuiBind("key_item_tip_" + sSlot));
        jRow = JsonArrayInsert(jRow, NuiWidth(NuiHeight(NuiVisible(jItem, NuiBind("key_item_visible_" + sSlot)), 44.0f), 44.0f));
    }
    json jRowElement = NuiPadding(NuiGroup(NuiRow(jRow), FALSE, NUI_SCROLLBARS_NONE), 0.0f);
    jRowElement = NuiHeight(jRowElement, 52.0f);
    json jTemplate = JsonArray();
    float fContentWidth = 52.0f + (44.0f + fRowSpacing) * IntToFloat(iItemCapacity);
    jTemplate = JsonArrayInsert(jTemplate, NuiListTemplateCell(jRowElement, fContentWidth, TRUE));
    return NuiList(jTemplate, NuiBind("key_container_count"), 54.0f, FALSE, NUI_SCROLLBARS_BOTH);
}

json MEIO_BuildWindow(object oPC, json jCapacities, int iPotionCapacity, int iBookCapacity, int iKeyItemCapacity, int iTab)
{
    json jRoot = JsonArray();
    json jTabs = JsonArray();
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_scrolls"))), "tab_scrolls"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_potions"))), "tab_potions"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_books"))), "tab_books"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "tab_key_items"))), "tab_key_items"), 180.0f));
    jTabs = JsonArrayInsert(jTabs, NuiSpacer());
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiRow(jTabs), 30.0f));
    string sCommandKey = iTab == MEIO_TAB_POTIONS ? "potions_command_hint" : iTab == MEIO_TAB_BOOKS ? "books_command_hint" : iTab == MEIO_TAB_KEY_ITEMS ? "key_items_command_hint" : "scrolls_command_hint";
    json jCommandHint = NuiStyleForegroundColor(NuiLabel(JsonString(MEIO_GetText(oPC, sCommandKey)), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), NuiColor(180, 180, 180));
    jRoot = JsonArrayInsert(jRoot, NuiHeight(jCommandHint, 22.0f));
    if (iTab == MEIO_TAB_SCROLLS)
    {
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
        json jFooter = JsonArray();
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "return_scrolls"))), "store_scrolls"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "withdraw_all_scrolls"))), "withdraw_all_scrolls"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiSpacer());
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "withdraw_hint")), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 350.0f));
        jScrolls = JsonArrayInsert(jScrolls, NuiHeight(NuiRow(jFooter), 32.0f));
        jRoot = JsonArrayInsert(jRoot, NuiCol(jScrolls));
    }
    else if (iTab == MEIO_TAB_POTIONS)
    {
        json jPotions = JsonArray();
        jPotions = JsonArrayInsert(jPotions, NuiHeight(MEIO_BuildPotionGrid(iPotionCapacity), 367.0f));
        json jFooter = JsonArray();
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "return_potions"))), "store_potions"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "withdraw_all_potions"))), "withdraw_all_potions"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiSpacer());
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "potion_hint")), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 350.0f));
        jPotions = JsonArrayInsert(jPotions, NuiHeight(NuiRow(jFooter), 32.0f));
        jRoot = JsonArrayInsert(jRoot, NuiCol(jPotions));
    }
    else if (iTab == MEIO_TAB_BOOKS)
    {
        json jBooks = JsonArray();
        json jBookSearch = JsonArray();
        jBookSearch = JsonArrayInsert(jBookSearch, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "search")), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), 70.0f));
        jBookSearch = JsonArrayInsert(jBookSearch, NuiTextEdit(JsonString(MEIO_GetText(oPC, "book_search_hint")), NuiBind("book_search"), 80, FALSE));
        jBookSearch = JsonArrayInsert(jBookSearch, NuiWidth(NuiCheck(JsonString(MEIO_GetText(oPC, "english_names")), NuiBind("book_english_names")), 205.0f));
        jBooks = JsonArrayInsert(jBooks, NuiHeight(NuiRow(jBookSearch), 30.0f));
        jBooks = JsonArrayInsert(jBooks, NuiHeight(MEIO_BuildBookGrid(iBookCapacity), 337.0f));
        json jFooter = JsonArray();
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "return_books"))), "store_books"), 150.0f));
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "withdraw_all_books"))), "withdraw_all_books"), 150.0f));
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "burn_duplicates"))), "burn_duplicates"), 150.0f));
        jFooter = JsonArrayInsert(jFooter, NuiSpacer());
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiLabel(JsonString(MEIO_GetText(oPC, "book_hint")), JsonInt(NUI_HALIGN_RIGHT), JsonInt(NUI_VALIGN_MIDDLE)), 230.0f));
        jBooks = JsonArrayInsert(jBooks, NuiHeight(NuiRow(jFooter), 32.0f));
        jRoot = JsonArrayInsert(jRoot, NuiCol(jBooks));
    }
    else
    {
        json jKeyItems = JsonArray();
        jKeyItems = JsonArrayInsert(jKeyItems, NuiHeight(MEIO_BuildKeyItemList(iKeyItemCapacity), 367.0f));
        json jFooter = JsonArray();
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "new_key_container"))), "new_key_container"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "remove_empty_key_container"))), "remove_empty_key_container"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "store_key_items"))), "store_key_items"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiWidth(NuiId(NuiButton(JsonString(MEIO_GetText(oPC, "withdraw_key_items"))), "withdraw_key_items"), 170.0f));
        jFooter = JsonArrayInsert(jFooter, NuiSpacer());
        jKeyItems = JsonArrayInsert(jKeyItems, NuiHeight(NuiRow(jFooter), 32.0f));
        jRoot = JsonArrayInsert(jRoot, NuiCol(jKeyItems));
    }
    return NuiWindow(NuiCol(jRoot), JsonString(MEIO_GetText(oPC, "window_title")), NuiRect(-1.0f, -1.0f, 760.0f, 500.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

string MEIO_StripDescriptionColors(string sText)
{
    return RegExpReplace("<c[^>]*>|</c>", sText, "");
}

string MEIO_RemoveHiddenDescriptionText(string sText)
{
    string sProbe = "MEIO_HIDDEN_TEXT";
    string sWrapped = StringToRGBString(sProbe, STRING_COLOR_BLACK);
    int iProbe = FindSubString(sWrapped, sProbe);
    if (iProbe < 0)
    {
        return sText;
    }
    string sOpen = GetSubString(sWrapped, 0, iProbe);
    int iCloseStart = iProbe + GetStringLength(sProbe);
    string sClose = GetSubString(sWrapped, iCloseStart, GetStringLength(sWrapped) - iCloseStart);
    int iStart = FindSubString(sText, sOpen);
    while (iStart >= 0)
    {
        int iEnd = FindSubString(sText, sClose, iStart + GetStringLength(sOpen));
        if (iEnd < 0)
        {
            return sText;
        }
        int iAfter = iEnd + GetStringLength(sClose);
        sText = GetSubString(sText, 0, iStart) + GetSubString(sText, iAfter, GetStringLength(sText) - iAfter);
        iStart = FindSubString(sText, sOpen);
    }
    return sText;
}

int MEIO_FindLastDescriptionText(string sText, string sNeedle)
{
    int iLast = -1;
    int iFound = FindSubString(sText, sNeedle);
    while (iFound >= 0)
    {
        iLast = iFound;
        iFound = FindSubString(sText, sNeedle, iFound + 1);
    }
    return iLast;
}

int MEIO_FindDescriptionLineStart(string sText, int iPosition)
{
    int iLineStart;
    int iNewline = FindSubString(sText, "\n");
    while (iNewline >= 0 && iNewline < iPosition)
    {
        iLineStart = iNewline + 1;
        iNewline = FindSubString(sText, "\n", iNewline + 1);
    }
    return iLineStart;
}

float MEIO_GetDescriptionHeight(string sText)
{
    int iLines = 1 + GetStringLength(sText) / 54;
    int iOffset;
    int iNewline = FindSubString(sText, "\n");
    while (iNewline >= 0)
    {
        iLines++;
        iOffset = iNewline + 1;
        iNewline = FindSubString(sText, "\n", iOffset);
    }
    return IntToFloat(iLines * 21 + 8);
}

json MEIO_BuildBookDescriptionWindow(object oBook, int bEnglishNames)
{
    string sDescription = GetDescription(oBook, FALSE, TRUE);
    if (sDescription == "")
    {
        sDescription = GetDescription(oBook, TRUE, TRUE);
    }
    sDescription = MEIO_StripDescriptionColors(MEIO_RemoveHiddenDescriptionText(sDescription));
    string sMain = sDescription;
    string sMetadata;
    string sAcquiredFrom = GetLocalString(oBook, "MELSE_ACQUIRED_FROM_NAME");
    int iAcquiredFrom = sAcquiredFrom == "" ? -1 : MEIO_FindLastDescriptionText(sDescription, sAcquiredFrom);
    if (iAcquiredFrom >= 0)
    {
        int iMetadataStart = MEIO_FindDescriptionLineStart(sDescription, iAcquiredFrom);
        sMain = GetSubString(sDescription, 0, iMetadataStart);
        sMetadata = GetSubString(sDescription, iMetadataStart, GetStringLength(sDescription) - iMetadataStart);
    }
    json jBlocks = JsonArray();
    if (sMain != "")
    {
        jBlocks = JsonArrayInsert(jBlocks, NuiHeight(NuiText(JsonString(sMain), TRUE, NUI_SCROLLBARS_NONE), MEIO_GetDescriptionHeight(sMain)));
    }
    if (sMetadata != "")
    {
        json jMetadata = NuiStyleForegroundColor(NuiText(JsonString(sMetadata), TRUE, NUI_SCROLLBARS_NONE), NuiColor(30, 220, 70));
        jBlocks = JsonArrayInsert(jBlocks, NuiHeight(jMetadata, MEIO_GetDescriptionHeight(sMetadata)));
    }
    json jRoot = JsonArray();
    jRoot = JsonArrayInsert(jRoot, NuiHeight(NuiGroup(NuiCol(jBlocks), TRUE, NUI_SCROLLBARS_Y), 396.0f));
    string sEnglishName = MEIO_GetBookEnglishName(oBook);
    json jTitle = JsonString(bEnglishNames && sEnglishName != "" ? sEnglishName : GetName(oBook));
    return NuiWindow(NuiCol(jRoot), jTitle, NuiRect(-1.0f, -1.0f, 620.0f, 460.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void MEIO_ShowBookDescription(object oPC, json jBook, int bEnglishNames)
{
    object oBook = MEIO_ResolveBook(MEIO_EnsureBookStorage(oPC), JsonGetString(JsonObjectGet(jBook, "key")));
    if (!GetIsObjectValid(oBook))
    {
        return;
    }
    int iOldToken = NuiFindWindow(oPC, MEIO_BOOK_DESCRIPTION_WINDOW);
    if (iOldToken > 0)
    {
        NuiDestroy(oPC, iOldToken);
    }
    NuiCreate(oPC, MEIO_BuildBookDescriptionWindow(oBook, bEnglishNames), MEIO_BOOK_DESCRIPTION_WINDOW, "memoria_noop");
}

void MEIO_ShowKeyItemDescription(object oPC, json jItem)
{
    object oItem = MEIO_ResolveDisplayedKeyItem(oPC, jItem);
    if (!GetIsObjectValid(oItem))
    {
        return;
    }
    int iOldToken = NuiFindWindow(oPC, MEIO_BOOK_DESCRIPTION_WINDOW);
    if (iOldToken > 0)
    {
        NuiDestroy(oPC, iOldToken);
    }
    NuiCreate(oPC, MEIO_BuildBookDescriptionWindow(oItem, FALSE), MEIO_BOOK_DESCRIPTION_WINDOW, "memoria_noop");
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

string MEIO_BuildBookTip(json jEntry, int bEnglishNames)
{
    string sName = JsonGetString(JsonObjectGet(jEntry, "name"));
    string sEnglishName = JsonGetString(JsonObjectGet(jEntry, "alias"));
    return bEnglishNames && sEnglishName != "" ? sEnglishName : sName;
}

void MEIO_SetEmptyBookSlot(object oPC, int iToken, int iSlot)
{
    string sSlot = IntToString(iSlot);
    NuiSetBind(oPC, iToken, "book_visible_" + sSlot, JsonBool(FALSE));
    NuiSetBind(oPC, iToken, "book_icon_" + sSlot, JsonString(""));
    NuiSetBind(oPC, iToken, "book_quantity_" + sSlot, JsonString(""));
    NuiSetBind(oPC, iToken, "book_tip_" + sSlot, JsonString(""));
}

void MEIO_RefreshBookWindow(object oPC, int iToken)
{
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_BOOK_INDEX);
    json jFiltered = MEIO_FilterBookIndex(jIndex, NuiGetBind(oPC, iToken, "book_search"));
    int bEnglishNames = JsonGetInt(NuiGetBind(oPC, iToken, "book_english_names"));
    int iCapacity = GetLocalInt(oPC, MEIO_LOCAL_BOOK_CAPACITY);
    json jDisplay = JsonObject();
    int iSlot;
    for (iSlot = 0; iSlot < iCapacity; iSlot++)
    {
        if (iSlot < JsonGetLength(jFiltered))
        {
            json jEntry = JsonArrayGet(jFiltered, iSlot);
            string sSlot = IntToString(iSlot);
            NuiSetBind(oPC, iToken, "book_visible_" + sSlot, JsonBool(TRUE));
            NuiSetBind(oPC, iToken, "book_icon_" + sSlot, JsonObjectGet(jEntry, "icon"));
            NuiSetBind(oPC, iToken, "book_quantity_" + sSlot, JsonString("x" + IntToString(JsonGetInt(JsonObjectGet(jEntry, "quantity")))));
            NuiSetBind(oPC, iToken, "book_tip_" + sSlot, JsonString(MEIO_BuildBookTip(jEntry, bEnglishNames)));
            jDisplay = JsonObjectSet(jDisplay, "book_" + sSlot, jEntry);
        }
        else
        {
            MEIO_SetEmptyBookSlot(oPC, iToken, iSlot);
        }
    }
    SetLocalJson(oPC, MEIO_LOCAL_BOOK_ENTRIES, jDisplay);
}

void MEIO_RefreshKeyItemWindow(object oPC, int iToken)
{
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_KEY_INDEX);
    int iContainerCapacity = GetLocalInt(oPC, MEIO_LOCAL_KEY_CONTAINER_CAPACITY);
    int iItemCapacity = GetLocalInt(oPC, MEIO_LOCAL_KEY_ITEM_CAPACITY);
    json jContainerIcons = JsonArray();
    json jContainerTips = JsonArray();
    json jVisibleBySlot = JsonObject();
    json jIconsBySlot = JsonObject();
    json jTipsBySlot = JsonObject();
    json jRectsBySlot = JsonObject();
    json jCursedBySlot = JsonObject();
    json jDisplayRows = JsonArray();
    int iSlot;
    for (iSlot = 0; iSlot < iItemCapacity; iSlot++)
    {
        string sSlot = IntToString(iSlot);
        jVisibleBySlot = JsonObjectSet(jVisibleBySlot, sSlot, JsonArray());
        jIconsBySlot = JsonObjectSet(jIconsBySlot, sSlot, JsonArray());
        jTipsBySlot = JsonObjectSet(jTipsBySlot, sSlot, JsonArray());
        jRectsBySlot = JsonObjectSet(jRectsBySlot, sSlot, JsonArray());
        jCursedBySlot = JsonObjectSet(jCursedBySlot, sSlot, JsonArray());
    }
    int iContainer;
    for (iContainer = 0; iContainer < iContainerCapacity; iContainer++)
    {
        json jEntry = iContainer < JsonGetLength(jIndex) ? JsonArrayGet(jIndex, iContainer) : JsonObject();
        json jItems = JsonObjectGet(jEntry, "items");
        json jDisplayRow = JsonObject();
        jContainerIcons = JsonArrayInsert(jContainerIcons, iContainer < JsonGetLength(jIndex) ? JsonObjectGet(jEntry, "icon") : JsonString(""));
        jContainerTips = JsonArrayInsert(jContainerTips, iContainer < JsonGetLength(jIndex) ? JsonObjectGet(jEntry, "name") : JsonString(""));
        for (iSlot = 0; iSlot < iItemCapacity; iSlot++)
        {
            string sSlot = IntToString(iSlot);
            json jVisible = JsonObjectGet(jVisibleBySlot, sSlot);
            json jIcons = JsonObjectGet(jIconsBySlot, sSlot);
            json jTips = JsonObjectGet(jTipsBySlot, sSlot);
            json jRects = JsonObjectGet(jRectsBySlot, sSlot);
            json jCursed = JsonObjectGet(jCursedBySlot, sSlot);
            int bVisible = iContainer < JsonGetLength(jIndex) && iSlot < JsonGetLength(jItems);
            json jItem = bVisible ? JsonArrayGet(jItems, iSlot) : JsonObject();
            int bCursed = bVisible && JsonGetInt(JsonObjectGet(jItem, "cursed"));
            string sTip = bVisible ? JsonGetString(JsonObjectGet(jItem, "name")) : "";
            if (bCursed)
            {
                sTip += "\n" + MEIO_GetText(oPC, "cursed_key_item_locked");
            }
            jVisibleBySlot = JsonObjectSet(jVisibleBySlot, sSlot, JsonArrayInsert(jVisible, JsonBool(bVisible)));
            jIconsBySlot = JsonObjectSet(jIconsBySlot, sSlot, JsonArrayInsert(jIcons, bVisible ? JsonObjectGet(jItem, "icon") : JsonString("")));
            jTipsBySlot = JsonObjectSet(jTipsBySlot, sSlot, JsonArrayInsert(jTips, JsonString(sTip)));
            jRectsBySlot = JsonObjectSet(jRectsBySlot, sSlot, JsonArrayInsert(jRects, bVisible && JsonGetInt(JsonObjectGet(jItem, "small")) ? NuiRect(6.0f, 6.0f, 32.0f, 32.0f) : NuiRect(0.0f, 0.0f, 44.0f, 44.0f)));
            jCursedBySlot = JsonObjectSet(jCursedBySlot, sSlot, JsonArrayInsert(jCursed, JsonBool(bCursed)));
            if (bVisible)
            {
                jDisplayRow = JsonObjectSet(jDisplayRow, "key_item_" + sSlot, jItem);
            }
        }
        jDisplayRows = JsonArrayInsert(jDisplayRows, jDisplayRow);
    }
    NuiSetBind(oPC, iToken, "key_container_icon", jContainerIcons);
    NuiSetBind(oPC, iToken, "key_container_tip", jContainerTips);
    for (iSlot = 0; iSlot < iItemCapacity; iSlot++)
    {
        string sSlot = IntToString(iSlot);
        NuiSetBind(oPC, iToken, "key_item_visible_" + sSlot, JsonObjectGet(jVisibleBySlot, sSlot));
        NuiSetBind(oPC, iToken, "key_item_icon_" + sSlot, JsonObjectGet(jIconsBySlot, sSlot));
        NuiSetBind(oPC, iToken, "key_item_tip_" + sSlot, JsonObjectGet(jTipsBySlot, sSlot));
        NuiSetBind(oPC, iToken, "key_item_rect_" + sSlot, JsonObjectGet(jRectsBySlot, sSlot));
        NuiSetBind(oPC, iToken, "key_item_cursed_" + sSlot, JsonObjectGet(jCursedBySlot, sSlot));
    }
    NuiSetBind(oPC, iToken, "key_container_count", JsonInt(JsonGetLength(jIndex)));
    SetLocalJson(oPC, MEIO_LOCAL_KEY_ENTRIES, jDisplayRows);
    MEIO_Debug(oPC, "Key item window refreshed token=" + IntToString(iToken) + " rows=" + IntToString(JsonGetLength(jIndex)) + " rowCapacity=" + IntToString(iContainerCapacity) + " itemCapacity=" + IntToString(iItemCapacity));
}

void MEIO_RebuildWindowIndex(object oPC, int iToken)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB) == MEIO_TAB_KEY_ITEMS)
    {
        json jKeyIndex = MEIO_BuildKeyItemIndex(oPC);
        if (JsonGetLength(jKeyIndex) > GetLocalInt(oPC, MEIO_LOCAL_KEY_CONTAINER_CAPACITY) || MEIO_GetKeyItemCapacity(jKeyIndex) > GetLocalInt(oPC, MEIO_LOCAL_KEY_ITEM_CAPACITY))
        {
            MEIO_OpenTab(oPC, MEIO_TAB_KEY_ITEMS);
            return;
        }
        SetLocalJson(oPC, MEIO_LOCAL_KEY_INDEX, jKeyIndex);
        MEIO_RefreshKeyItemWindow(oPC, iToken);
        return;
    }
    object oStorage = MEIO_EnsureStorage(oPC);
    object oPotionStorage = MEIO_EnsurePotionStorage(oPC);
    object oBookStorage = MEIO_EnsureBookStorage(oPC);
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
    json jBookIndex = MEIO_BuildBookIndex(oBookStorage);
    if (GetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB) == MEIO_TAB_BOOKS && JsonGetLength(jBookIndex) > GetLocalInt(oPC, MEIO_LOCAL_BOOK_CAPACITY))
    {
        json jSearch = NuiGetBind(oPC, iToken, "book_search");
        int bEnglishNames = JsonGetInt(NuiGetBind(oPC, iToken, "book_english_names"));
        MEIO_OpenTab(oPC, MEIO_TAB_BOOKS);
        int iNewToken = NuiFindWindow(oPC, MEIO_WINDOW);
        if (iNewToken > 0)
        {
            NuiSetBind(oPC, iNewToken, "book_search", jSearch);
            NuiSetBind(oPC, iNewToken, "book_english_names", JsonBool(bEnglishNames));
            MEIO_RefreshBookWindow(oPC, iNewToken);
        }
        return;
    }
    SetLocalJson(oPC, MEIO_LOCAL_BOOK_INDEX, jBookIndex);
    if (GetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB) == MEIO_TAB_POTIONS)
    {
        MEIO_RefreshPotionWindow(oPC, iToken);
    }
    else if (GetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB) == MEIO_TAB_BOOKS)
    {
        MEIO_RefreshBookWindow(oPC, iToken);
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

void MEIO_RemoveOneFromBookWindowIndex(object oPC, int iToken, json jSelected)
{
    string sKey = JsonGetString(JsonObjectGet(jSelected, "key"));
    json jIndex = GetLocalJson(oPC, MEIO_LOCAL_BOOK_INDEX);
    json jUpdated = JsonArray();
    int bRemoved;
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jIndex); iIndex++)
    {
        json jEntry = JsonArrayGet(jIndex, iIndex);
        if (!bRemoved && JsonGetString(JsonObjectGet(jEntry, "key")) == sKey)
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
    SetLocalJson(oPC, MEIO_LOCAL_BOOK_INDEX, jUpdated);
    MEIO_RefreshBookWindow(oPC, iToken);
}

void MEIO_RebuildOpenWindowIndex(object oPC)
{
    int iToken = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iToken > 0)
    {
        MEIO_RebuildWindowIndex(oPC, iToken);
    }
}

void MEIO_OpenKeyItemsTab(object oPC)
{
    object oScriptorium = MEIO_EnsureScriptorium(oPC);
    if (!GetIsObjectValid(oScriptorium))
    {
        return;
    }
    json jIndex = MEIO_BuildKeyItemIndex(oPC);
    int iContainerCapacity = JsonGetLength(jIndex);
    int iItemCapacity = MEIO_GetKeyItemCapacity(jIndex);
    SetLocalJson(oPC, MEIO_LOCAL_KEY_INDEX, jIndex);
    SetLocalInt(oPC, MEIO_LOCAL_KEY_CONTAINER_CAPACITY, iContainerCapacity);
    SetLocalInt(oPC, MEIO_LOCAL_KEY_ITEM_CAPACITY, iItemCapacity);
    int iOld = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iOld > 0)
    {
        NuiDestroy(oPC, iOld);
    }
    int iToken = MEMORIA_NUI_Create(oPC, MEIO_BuildWindow(oPC, JsonArray(), 0, 0, iItemCapacity, MEIO_TAB_KEY_ITEMS), MEIO_WINDOW, "meio_nuievt");
    if (iToken > 0)
    {
        MEIO_RefreshKeyItemWindow(oPC, iToken);
    }
}

void MEIO_OpenTab(object oPC, int iTab)
{
    if (iTab != MEIO_TAB_POTIONS && iTab != MEIO_TAB_BOOKS && iTab != MEIO_TAB_KEY_ITEMS)
    {
        iTab = MEIO_TAB_SCROLLS;
    }
    SetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB, iTab);
    if (iTab == MEIO_TAB_KEY_ITEMS)
    {
        MEIO_OpenKeyItemsTab(oPC);
        return;
    }
    object oScriptorium = MEIO_EnsureScriptorium(oPC);
    object oStorage = MEIO_EnsureStorage(oPC);
    object oPotionStorage = MEIO_EnsurePotionStorage(oPC);
    object oBookStorage = MEIO_EnsureBookStorage(oPC);
    if (!GetIsObjectValid(oScriptorium) || !GetIsObjectValid(oStorage) || !GetIsObjectValid(oPotionStorage) || !GetIsObjectValid(oBookStorage))
    {
        return;
    }
    MEIO_ValidateContents(oPC, oStorage);
    MEIO_ValidatePotionContents(oPC, oPotionStorage);
    MEIO_ValidateBookContents(oPC, oBookStorage);
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
    json jBookIndex = MEIO_BuildBookIndex(oBookStorage);
    json jCapacities = MEIO_BuildCapacities(oPC, jIndex);
    int iPotionCapacity = MEIO_BuildPotionCapacity(oPC, jPotionIndex);
    int iBookCapacity = MEIO_BuildBookCapacity(oPC, jBookIndex);
    SetLocalJson(oPC, MEIO_LOCAL_INDEX, jIndex);
    SetLocalJson(oPC, MEIO_LOCAL_POTION_INDEX, jPotionIndex);
    SetLocalJson(oPC, MEIO_LOCAL_BOOK_INDEX, jBookIndex);
    SetLocalJson(oPC, MEIO_LOCAL_LEVEL_CAPACITIES, jCapacities);
    SetLocalInt(oPC, MEIO_LOCAL_POTION_CAPACITY, iPotionCapacity);
    SetLocalInt(oPC, MEIO_LOCAL_BOOK_CAPACITY, iBookCapacity);
    int iOld = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iOld > 0)
    {
        NuiDestroy(oPC, iOld);
    }
    int iToken = MEMORIA_NUI_Create(oPC, MEIO_BuildWindow(oPC, jCapacities, iPotionCapacity, iBookCapacity, 12, iTab), MEIO_WINDOW, "meio_nuievt");
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
        else if (iTab == MEIO_TAB_POTIONS)
        {
            MEIO_RefreshPotionWindow(oPC, iToken);
        }
        else if (iTab == MEIO_TAB_BOOKS)
        {
            NuiSetBind(oPC, iToken, "book_search", JsonString(""));
            NuiSetBind(oPC, iToken, "book_english_names", JsonBool(FALSE));
            MEIO_RefreshBookWindow(oPC, iToken);
            NuiSetBindWatch(oPC, iToken, "book_search", TRUE);
            NuiSetBindWatch(oPC, iToken, "book_english_names", TRUE);
        }
    }
}

void MEIO_Open(object oPC)
{
    MEIO_OpenTab(oPC, MEIO_TAB_SCROLLS);
}
