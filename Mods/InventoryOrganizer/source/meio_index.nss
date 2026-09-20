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
