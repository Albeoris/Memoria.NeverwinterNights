// Dynamic Scriptorium index built exclusively from current physical contents.

#include "meio_storage"

int MEIO_GetSpellTargetCategory(int iSpell)
{
    int iFlags = StringToInt(Get2DAString("spells", "TargetFlags", iSpell));
    if (Get2DAString("spells", "HostileSetting", iSpell) == "1" || (iFlags & SPELL_TARGETING_FLAGS_HARMS_ENEMIES))
    {
        return MEIO_TARGET_ENEMY;
    }
    if (iFlags & SPELL_TARGETING_FLAGS_HELPS_ALLIES)
    {
        return MEIO_TARGET_ALLY;
    }
    return Get2DAString("spells", "Range", iSpell) == "P" ? MEIO_TARGET_SELF : MEIO_TARGET_ALLY;
}

json MEIO_NewEntry(object oScroll, int iSubtype)
{
    int iSpell = MEIO_GetSpell(iSubtype);
    int iLevel = MEIO_GetSpellLevel(iSpell);
    json jEntry = JsonObject();
    jEntry = JsonObjectSet(jEntry, "key", JsonString(MEIO_GetVariantKey(oScroll, iSubtype)));
    jEntry = JsonObjectSet(jEntry, "subtype", JsonInt(iSubtype));
    jEntry = JsonObjectSet(jEntry, "spell", JsonInt(iSpell));
    jEntry = JsonObjectSet(jEntry, "level", JsonInt(iLevel));
    jEntry = JsonObjectSet(jEntry, "name", JsonString(MEMORIA_GetSpellName(iSpell)));
    jEntry = JsonObjectSet(jEntry, "alias", JsonString(MEMORIA_GetSpellAlias(iSpell)));
    jEntry = JsonObjectSet(jEntry, "icon", JsonString(MEMORIA_GetSpellIcon(iSpell)));
    jEntry = JsonObjectSet(jEntry, "caster_level", JsonInt(MEIO_GetCasterLevel(iSubtype)));
    jEntry = JsonObjectSet(jEntry, "quantity", JsonInt(GetItemStackSize(oScroll)));
    jEntry = JsonObjectSet(jEntry, "target", JsonInt(MEIO_GetSpellTargetCategory(iSpell)));
    jEntry = JsonObjectSet(jEntry, "search", JsonString(MEMORIA_GetJsonSearchText(JsonString(MEMORIA_GetSpellName(iSpell) + " " + MEMORIA_GetSpellAlias(iSpell)))));
    return jEntry;
}

json MEIO_FilterIndex(json jIndex, json jSearch, int iTarget)
{
    string sSearch = MEMORIA_GetJsonSearchText(jSearch);
    json jFiltered = JsonArray();
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jIndex); iIndex++)
    {
        json jEntry = JsonArrayGet(jIndex, iIndex);
        if (iTarget != MEIO_TARGET_ALL && JsonGetInt(JsonObjectGet(jEntry, "target")) != iTarget)
        {
            continue;
        }
        if (sSearch == "" || FindSubString(JsonGetString(JsonObjectGet(jEntry, "search")), sSearch) >= 0)
        {
            jFiltered = JsonArrayInsert(jFiltered, jEntry);
        }
    }
    return jFiltered;
}

json MEIO_BuildIndex(object oStorage)
{
    json jIndex = JsonArray();
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oStorage) && MEIO_IsScroll(oItem))
        {
            int iSubtype = MEIO_GetOnlyCastSubtype(oItem);
            int iSpell = iSubtype >= 0 ? MEIO_GetSpell(iSubtype) : -1;
            int iLevel = iSpell >= 0 ? MEIO_GetSpellLevel(iSpell) : -1;
            if (iSubtype >= 0 && iSpell >= 0 && iLevel >= 0)
            {
                string sKey = MEIO_GetVariantKey(oItem, iSubtype);
                int iFound = -1;
                int iIndex;
                for (iIndex = 0; iIndex < JsonGetLength(jIndex); iIndex++)
                {
                    if (JsonGetString(JsonObjectGet(JsonArrayGet(jIndex, iIndex), "key")) == sKey)
                    {
                        iFound = iIndex;
                    }
                }
                if (iFound >= 0)
                {
                    json jEntry = JsonArrayGet(jIndex, iFound);
                    jEntry = JsonObjectSet(jEntry, "quantity", JsonInt(JsonGetInt(JsonObjectGet(jEntry, "quantity")) + GetItemStackSize(oItem)));
                    jIndex = JsonArraySet(jIndex, iFound, jEntry);
                }
                else
                {
                    jIndex = JsonArrayInsert(jIndex, MEIO_NewEntry(oItem, iSubtype));
                }
            }
        }
        oItem = GetNextItemInInventory(oStorage);
    }
    return jIndex;
}

object MEIO_ResolveScroll(object oStorage, string sKey, int iSubtype)
{
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oStorage) && MEIO_IsScroll(oItem) && MEIO_GetOnlyCastSubtype(oItem) == iSubtype && MEIO_GetVariantKey(oItem, iSubtype) == sKey)
        {
            return oItem;
        }
        oItem = GetNextItemInInventory(oStorage);
    }
    return OBJECT_INVALID;
}

int MEIO_GetPotionCategory(int iSpell)
{
    string sAlias = MEMORIA_GetSpellAlias(iSpell);
    if (FindSubString(sAlias, "Cure") >= 0 || FindSubString(sAlias, "Heal") >= 0 || FindSubString(sAlias, "Restoration") >= 0)
    {
        return 0;
    }
    if (sAlias == "Bull's Strength" || sAlias == "Cat's Grace" || sAlias == "Endurance" || sAlias == "Fox's Cunning" || sAlias == "Owl's Wisdom" || sAlias == "Eagle's Splendor")
    {
        return 1;
    }
    if (FindSubString(sAlias, "Armor") >= 0 || FindSubString(sAlias, "Shield") >= 0 || FindSubString(sAlias, "Protection") >= 0 || FindSubString(sAlias, "Skin") >= 0 || FindSubString(sAlias, "Blur") >= 0 || FindSubString(sAlias, "Displacement") >= 0 || FindSubString(sAlias, "Invisibility") >= 0 || FindSubString(sAlias, "Sanctuary") >= 0 || FindSubString(sAlias, "Resistance") >= 0)
    {
        return 2;
    }
    if (Get2DAString("spells", "HostileSetting", iSpell) == "1")
    {
        return 4;
    }
    return 3;
}

json MEIO_NewPotionEntry(object oPotion, int iSubtype)
{
    int iSpell = MEIO_GetSpell(iSubtype);
    json jEntry = JsonObject();
    jEntry = JsonObjectSet(jEntry, "key", JsonString(MEIO_GetPotionKey(oPotion, iSubtype)));
    jEntry = JsonObjectSet(jEntry, "subtype", JsonInt(iSubtype));
    jEntry = JsonObjectSet(jEntry, "spell", JsonInt(iSpell));
    jEntry = JsonObjectSet(jEntry, "name", JsonString(GetName(oPotion)));
    jEntry = JsonObjectSet(jEntry, "alias", JsonString(MEMORIA_GetSpellAlias(iSpell)));
    jEntry = JsonObjectSet(jEntry, "bottom", JsonString(MEIO_GetPotionIconLayer(oPotion, ITEM_APPR_WEAPON_MODEL_BOTTOM)));
    jEntry = JsonObjectSet(jEntry, "middle", JsonString(MEIO_GetPotionIconLayer(oPotion, ITEM_APPR_WEAPON_MODEL_MIDDLE)));
    jEntry = JsonObjectSet(jEntry, "top", JsonString(MEIO_GetPotionIconLayer(oPotion, ITEM_APPR_WEAPON_MODEL_TOP)));
    jEntry = JsonObjectSet(jEntry, "quantity", JsonInt(GetItemStackSize(oPotion)));
    jEntry = JsonObjectSet(jEntry, "category", JsonInt(MEIO_GetPotionCategory(iSpell)));
    return jEntry;
}

json MEIO_BuildPotionIndex(object oStorage)
{
    json jUnsorted = JsonArray();
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oStorage) && MEIO_IsPotion(oItem))
        {
            int iSubtype = MEIO_GetOnlyCastSubtype(oItem);
            int iSpell = iSubtype >= 0 ? MEIO_GetSpell(iSubtype) : -1;
            if (iSubtype >= 0 && iSpell >= 0)
            {
                string sKey = MEIO_GetPotionKey(oItem, iSubtype);
                int iFound = -1;
                int iIndex;
                for (iIndex = 0; iIndex < JsonGetLength(jUnsorted); iIndex++)
                {
                    if (JsonGetString(JsonObjectGet(JsonArrayGet(jUnsorted, iIndex), "key")) == sKey)
                    {
                        iFound = iIndex;
                    }
                }
                if (iFound >= 0)
                {
                    json jEntry = JsonArrayGet(jUnsorted, iFound);
                    jEntry = JsonObjectSet(jEntry, "quantity", JsonInt(JsonGetInt(JsonObjectGet(jEntry, "quantity")) + GetItemStackSize(oItem)));
                    jUnsorted = JsonArraySet(jUnsorted, iFound, jEntry);
                }
                else
                {
                    jUnsorted = JsonArrayInsert(jUnsorted, MEIO_NewPotionEntry(oItem, iSubtype));
                }
            }
        }
        oItem = GetNextItemInInventory(oStorage);
    }
    json jSorted = JsonArray();
    int iCategory;
    for (iCategory = 0; iCategory <= 4; iCategory++)
    {
        int iIndex;
        for (iIndex = 0; iIndex < JsonGetLength(jUnsorted); iIndex++)
        {
            json jEntry = JsonArrayGet(jUnsorted, iIndex);
            if (JsonGetInt(JsonObjectGet(jEntry, "category")) == iCategory)
            {
                jSorted = JsonArrayInsert(jSorted, jEntry);
            }
        }
    }
    return jSorted;
}

object MEIO_ResolvePotion(object oStorage, string sKey, int iSubtype)
{
    object oItem = GetFirstItemInInventory(oStorage);
    while (GetIsObjectValid(oItem))
    {
        if (MEIO_IsDirectlyIn(oItem, oStorage) && MEIO_IsPotion(oItem) && MEIO_GetOnlyCastSubtype(oItem) == iSubtype && MEIO_GetPotionKey(oItem, iSubtype) == sKey)
        {
            return oItem;
        }
        oItem = GetNextItemInInventory(oStorage);
    }
    return OBJECT_INVALID;
}
