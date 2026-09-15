// Shared rules and item presentation helpers for Memoria mods.

/// @brief Resolves a spell's localized display name with its 2DA label as a fallback.
/// @param iSpell Row index in spells.2da.
/// @return Localized spell name, or the spell label when the name string reference cannot be resolved.
string MEMORIA_GetSpellName(int iSpell)
{
    string sStrRef = Get2DAString("spells", "Name", iSpell);
    string sName = GetStringByStrRef(StringToInt(sStrRef));
    return sName == "" ? Get2DAString("spells", "Label", iSpell) : sName;
}

/// @brief Converts a spell's 2DA label into a space-separated alias.
/// @param iSpell Row index in spells.2da.
/// @return Spell label with underscores replaced by spaces.
string MEMORIA_GetSpellAlias(int iSpell)
{
    return RegExpReplace("_", Get2DAString("spells", "Label", iSpell), " ");
}

/// @brief Resolves the icon resource for a spell.
/// @param iSpell Row index in spells.2da.
/// @return Spell icon resref, or nui_test when the configured icon is empty or unavailable.
string MEMORIA_GetSpellIcon(int iSpell)
{
    string sIcon = Get2DAString("spells", "IconResRef", iSpell);
    return sIcon == "" || sIcon == "****" ? "nui_test" : sIcon;
}

/// @brief Formats an item model number with a minimum width of three digits.
/// @param iModel Item model number to format.
/// @return Decimal model number padded with leading zeroes when it contains fewer than three digits.
string MEMORIA_PadItemModel(int iModel)
{
    if (iModel < 10) return "00" + IntToString(iModel);
    if (iModel < 100) return "0" + IntToString(iModel);
    return IntToString(iModel);
}

/// @brief Resolves an item's default or model-specific icon and verifies that a model-specific resource exists.
/// @param oItem Item whose icon is resolved.
/// @return Applicable icon resref, or nui_test when no valid icon is available.
string MEMORIA_GetItemIcon(object oItem)
{
    int iBaseItem = GetBaseItemType(oItem);
    string sIcon = Get2DAString("baseitems", "DefaultIcon", iBaseItem);
    if (Get2DAString("baseitems", "ModelType", iBaseItem) == "0")
    {
        string sItemClass = Get2DAString("baseitems", "ItemClass", iBaseItem);
        int iModel = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);
        string sModelIcon = "i" + GetStringLowerCase(sItemClass) + "_" + MEMORIA_PadItemModel(iModel);
        if (sItemClass != "" && sItemClass != "****" && GetStringLowerCase(sItemClass) != "it_potion" && iModel >= 0 && (ResManGetAliasFor(sModelIcon, RESTYPE_TGA) != "" || ResManGetAliasFor(sModelIcon, RESTYPE_DDS) != "")) sIcon = sModelIcon;
    }
    return sIcon == "" || sIcon == "****" ? "nui_test" : sIcon;
}

/// @brief Resolves a class's localized display name with its 2DA label as a fallback.
/// @param iClass Row index in classes.2da.
/// @return Localized class name, or the class label when the name string reference cannot be resolved.
string MEMORIA_GetClassName(int iClass)
{
    string sName = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", iClass)));
    return sName == "" ? Get2DAString("classes", "Label", iClass) : sName;
}

/// @brief Determines whether a class uses spell memorization according to classes.2da.
/// @param iClass Row index in classes.2da.
/// @return TRUE when MemorizesSpells is 1; otherwise FALSE.
int MEMORIA_IsMemorizingClass(int iClass)
{
    return Get2DAString("classes", "MemorizesSpells", iClass) == "1";
}

/// @brief Resolves the localized display name for a metamagic constant.
/// @param iMetaMagic METAMAGIC_* value to map to metamagic.2da.
/// @return Localized metamagic name; unrecognized values use row 0.
string MEMORIA_GetMetamagicName(int iMetaMagic)
{
    int iRow = iMetaMagic == METAMAGIC_QUICKEN ? 1 : iMetaMagic == METAMAGIC_EMPOWER ? 2 : iMetaMagic == METAMAGIC_EXTEND ? 3 : iMetaMagic == METAMAGIC_MAXIMIZE ? 4 : iMetaMagic == METAMAGIC_SILENT ? 5 : iMetaMagic == METAMAGIC_STILL ? 6 : 0;
    return GetStringByStrRef(StringToInt(Get2DAString("metamagic", "Name", iRow)));
}

/// @brief Determines whether an item's cast-spell property currently has enough charges or daily uses.
/// @param oItem Item that owns the property and supplies its remaining charges.
/// @param ip Cast-spell item property to inspect.
/// @return TRUE when the property is currently usable or has no recognized usage restriction; otherwise FALSE.
int MEMORIA_IsCastPropertyAvailable(object oItem, itemproperty ip)
{
    int iUses = GetItemPropertyCostTableValue(ip);
    if (iUses == IP_CONST_CASTSPELL_NUMUSES_SINGLE_USE || iUses == IP_CONST_CASTSPELL_NUMUSES_0_CHARGES_PER_USE || iUses == IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE) return TRUE;
    if (iUses >= IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE && iUses <= IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE) return GetItemCharges(oItem) >= 7 - iUses;
    if (iUses >= IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY && iUses <= IP_CONST_CASTSPELL_NUMUSES_5_USES_PER_DAY) return GetItemPropertyUsesPerDayRemaining(oItem, ip) > 0;
    return TRUE;
}

/// @brief Converts one hexadecimal digit to its numeric value.
/// @param sDigit Single hexadecimal digit; alphabetic input is case-insensitive.
/// @return Value from 0 through 15; other input is interpreted by StringToInt.
int MEMORIA_HexDigit(string sDigit)
{
    sDigit = GetStringLowerCase(sDigit);
    if (sDigit == "a") return 10;
    if (sDigit == "b") return 11;
    if (sDigit == "c") return 12;
    if (sDigit == "d") return 13;
    if (sDigit == "e") return 14;
    if (sDigit == "f") return 15;
    return StringToInt(sDigit);
}

/// @brief Reads and parses an item's equippable-slot bit mask from baseitems.2da.
/// @param oItem Item whose base type supplies the EquipableSlots value.
/// @return Parsed decimal or hexadecimal slot bit mask.
int MEMORIA_GetEquipableSlots(object oItem)
{
    string sSlots = Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem));
    if (GetSubString(sSlots, 0, 2) != "0x" && GetSubString(sSlots, 0, 2) != "0X") return StringToInt(sSlots);
    int iValue;
    int iIndex;
    for (iIndex = 2; iIndex < GetStringLength(sSlots); iIndex++) iValue = iValue * 16 + MEMORIA_HexDigit(GetSubString(sSlots, iIndex, 1));
    return iValue;
}

/// @brief Finds the inventory slot in which a creature currently has an item equipped.
/// @param oCreature Creature whose equipment is searched.
/// @param oItem Item to locate.
/// @return INVENTORY_SLOT_* index containing the item, or -1 when the item is not equipped.
int MEMORIA_GetEquippedSlot(object oCreature, object oItem)
{
    int iSlot;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
        if (GetItemInSlot(iSlot, oCreature) == oItem) return iSlot;
    return -1;
}

/// @brief Selects the preferred compatible equipment slot for an item on a creature.
/// @param oCreature Creature whose equipped slots are considered.
/// @param oItem Item for which a slot is selected.
/// @return Current slot when already equipped, otherwise the first empty compatible slot, the first compatible occupied slot, or -1 when no slot is compatible.
int MEMORIA_FindPreferredEquipSlot(object oCreature, object oItem)
{
    int iEquipped = MEMORIA_GetEquippedSlot(oCreature, oItem);
    if (iEquipped >= 0) return iEquipped;
    int iSlots = MEMORIA_GetEquipableSlots(oItem);
    int iBit = 1;
    int iSlot;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
    {
        if ((iSlots / iBit) % 2 && !GetIsObjectValid(GetItemInSlot(iSlot, oCreature))) return iSlot;
        iBit *= 2;
    }
    iBit = 1;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
    {
        if ((iSlots / iBit) % 2) return iSlot;
        iBit *= 2;
    }
    return -1;
}
