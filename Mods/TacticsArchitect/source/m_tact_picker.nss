#include "m_tact_core"
#include "memoria_string"

const int M_TACT_PICKER_COLUMNS = 16;
const int M_TACT_PICKER_ROWS = 6;
const int M_TACT_PICKER_PAGE_SIZE = 96;

string M_TACT_GetSpellAlias(int iSpell)
{
    return MEMORIA_GetSpellAlias(iSpell);
}

string M_TACT_GetSpellIcon(int iSpell)
{
    return MEMORIA_GetSpellIcon(iSpell);
}

string M_TACT_PadItemModel(int iModel)
{
    return MEMORIA_PadItemModel(iModel);
}

string M_TACT_GetItemIcon(object oItem)
{
    return MEMORIA_GetItemIcon(oItem);
}

string M_TACT_UnicodeJsonLower(string sValue)
{
    return MEMORIA_FoldJsonSearchText(sValue);
}

string M_TACT_JsonSearchText(json jValue)
{
    return MEMORIA_GetJsonSearchText(jValue);
}

string M_TACT_GetClassName(int iClass)
{
    return MEMORIA_GetClassName(iClass);
}

int M_TACT_IsMemorizingClass(int iClass)
{
    return MEMORIA_IsMemorizingClass(iClass);
}

string M_TACT_GetMetamagicName(int iMetaMagic)
{
    return MEMORIA_GetMetamagicName(iMetaMagic);
}

int M_TACT_CandidateExists(json jCandidates, string sType, int iSpell, int iClass, int iMetaMagic, int iDomain, string sItemResRef, int iProperty)
{
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jCandidates); iIndex++)
    {
        json jCandidate = JsonArrayGet(jCandidates, iIndex);
        if (JsonGetString(JsonObjectGet(jCandidate, "type")) == sType && JsonGetInt(JsonObjectGet(jCandidate, "spell")) == iSpell && JsonGetInt(JsonObjectGet(jCandidate, "class")) == iClass && JsonGetInt(JsonObjectGet(jCandidate, "metamagic")) == iMetaMagic && JsonGetInt(JsonObjectGet(jCandidate, "domain")) == iDomain && JsonGetString(JsonObjectGet(jCandidate, "item_resref")) == sItemResRef && JsonGetInt(JsonObjectGet(jCandidate, "item_property")) == iProperty)
            return TRUE;
    }
    return FALSE;
}

json M_TACT_AddSpellCandidate(json jCandidates, int iSpell, int iClass, int iLevel, int iMetaMagic, int iDomain)
{
    if (iSpell < 0 || M_TACT_CandidateExists(jCandidates, "spell", iSpell, iClass, iMetaMagic, iDomain, "", -1))
        return jCandidates;
    json jCandidate = JsonObject();
    jCandidate = JsonObjectSet(jCandidate, "type", JsonString("spell"));
    jCandidate = JsonObjectSet(jCandidate, "spell", JsonInt(iSpell));
    jCandidate = JsonObjectSet(jCandidate, "class", JsonInt(iClass));
    jCandidate = JsonObjectSet(jCandidate, "level", JsonInt(iLevel));
    jCandidate = JsonObjectSet(jCandidate, "metamagic", JsonInt(iMetaMagic));
    jCandidate = JsonObjectSet(jCandidate, "domain", JsonInt(iDomain));
    jCandidate = JsonObjectSet(jCandidate, "name", JsonString(MEMORIA_GetSpellName(iSpell)));
    jCandidate = JsonObjectSet(jCandidate, "alias", JsonString(M_TACT_GetSpellAlias(iSpell)));
    jCandidate = JsonObjectSet(jCandidate, "icon", JsonString(M_TACT_GetSpellIcon(iSpell)));
    string sDetail = M_TACT_GetClassName(iClass) + " - " + IntToString(iLevel);
    if (iMetaMagic != METAMAGIC_NONE) sDetail += " - " + M_TACT_GetMetamagicName(iMetaMagic);
    if (iDomain > 0) sDetail += " [D]";
    if (M_TACT_GetLanguage(OBJECT_SELF) == "ru") sDetail = M_TACT_GetSpellAlias(iSpell) + " - " + sDetail;
    jCandidate = JsonObjectSet(jCandidate, "detail", JsonString(sDetail));
    jCandidate = JsonObjectSet(jCandidate, "search", JsonString(M_TACT_JsonSearchText(JsonString(MEMORIA_GetSpellName(iSpell) + " " + M_TACT_GetSpellAlias(iSpell) + " " + sDetail))));
    jCandidate = JsonObjectSet(jCandidate, "item_resref", JsonString(""));
    jCandidate = JsonObjectSet(jCandidate, "item_property", JsonInt(-1));
    return JsonArrayInsert(jCandidates, jCandidate);
}

json M_TACT_AddItemCandidate(json jCandidates, object oItem, itemproperty ip)
{
    int iProperty = GetItemPropertySubType(ip);
    int iSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", iProperty));
    string sResRef = GetResRef(oItem);
    if (iSpell < 0 || M_TACT_CandidateExists(jCandidates, "item", iSpell, CLASS_TYPE_INVALID, METAMAGIC_NONE, 0, sResRef, iProperty))
        return jCandidates;
    json jCandidate = JsonObject();
    string sInnateLevel = Get2DAString("spells", "Innate", iSpell);
    int iSpellLevel = sInnateLevel == "" || sInnateLevel == "****" ? -1 : StringToInt(sInnateLevel);
    jCandidate = JsonObjectSet(jCandidate, "type", JsonString("item"));
    jCandidate = JsonObjectSet(jCandidate, "spell", JsonInt(iSpell));
    jCandidate = JsonObjectSet(jCandidate, "class", JsonInt(CLASS_TYPE_INVALID));
    jCandidate = JsonObjectSet(jCandidate, "level", JsonInt(iSpellLevel));
    jCandidate = JsonObjectSet(jCandidate, "metamagic", JsonInt(METAMAGIC_NONE));
    jCandidate = JsonObjectSet(jCandidate, "domain", JsonInt(0));
    jCandidate = JsonObjectSet(jCandidate, "name", JsonString(MEMORIA_GetSpellName(iSpell)));
    jCandidate = JsonObjectSet(jCandidate, "alias", JsonString(M_TACT_GetSpellAlias(iSpell)));
    int iBaseItem = GetBaseItemType(oItem);
    string sIcon = M_TACT_GetItemIcon(oItem);
    if (sIcon == "" || sIcon == "****") sIcon = M_TACT_GetSpellIcon(iSpell);
    jCandidate = JsonObjectSet(jCandidate, "icon", JsonString(sIcon));
    int iWidth = StringToInt(Get2DAString("baseitems", "InvSlotWidth", iBaseItem));
    int iHeight = StringToInt(Get2DAString("baseitems", "InvSlotHeight", iBaseItem));
    jCandidate = JsonObjectSet(jCandidate, "width", JsonInt(iWidth > 0 ? iWidth : 1));
    jCandidate = JsonObjectSet(jCandidate, "height", JsonInt(iHeight > 0 ? iHeight : 1));
    jCandidate = JsonObjectSet(jCandidate, "detail", JsonString(GetName(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "search", JsonString(M_TACT_JsonSearchText(JsonString(MEMORIA_GetSpellName(iSpell) + " " + M_TACT_GetSpellAlias(iSpell) + " " + GetName(oItem)))));
    jCandidate = JsonObjectSet(jCandidate, "item_resref", JsonString(sResRef));
    jCandidate = JsonObjectSet(jCandidate, "item_property", JsonInt(iProperty));
    return JsonArrayInsert(jCandidates, jCandidate);
}

int M_TACT_EquipCandidateExists(json jCandidates, string sUUID)
{
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jCandidates); iIndex++)
    {
        json jCandidate = JsonArrayGet(jCandidates, iIndex);
        if (JsonGetString(JsonObjectGet(jCandidate, "type")) == "equip" && JsonGetString(JsonObjectGet(jCandidate, "item_uuid")) == sUUID) return TRUE;
    }
    return FALSE;
}

json M_TACT_AddEquipCandidate(json jCandidates, object oItem)
{
    if (MEMORIA_GetEquipableSlots(oItem) <= 0) return jCandidates;
    string sUUID = GetObjectUUID(oItem);
    if (sUUID == "")
    {
        ForceRefreshObjectUUID(oItem);
        sUUID = GetObjectUUID(oItem);
    }
    if (sUUID == "" || M_TACT_EquipCandidateExists(jCandidates, sUUID)) return jCandidates;
    int iBaseItem = GetBaseItemType(oItem);
    json jCandidate = JsonObject();
    jCandidate = JsonObjectSet(jCandidate, "type", JsonString("equip"));
    jCandidate = JsonObjectSet(jCandidate, "spell", JsonInt(-1));
    jCandidate = JsonObjectSet(jCandidate, "class", JsonInt(CLASS_TYPE_INVALID));
    jCandidate = JsonObjectSet(jCandidate, "level", JsonInt(-1));
    jCandidate = JsonObjectSet(jCandidate, "metamagic", JsonInt(METAMAGIC_NONE));
    jCandidate = JsonObjectSet(jCandidate, "domain", JsonInt(0));
    jCandidate = JsonObjectSet(jCandidate, "name", JsonString(GetName(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "alias", JsonString(GetResRef(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "icon", JsonString(M_TACT_GetItemIcon(oItem)));
    int iWidth = StringToInt(Get2DAString("baseitems", "InvSlotWidth", iBaseItem));
    int iHeight = StringToInt(Get2DAString("baseitems", "InvSlotHeight", iBaseItem));
    jCandidate = JsonObjectSet(jCandidate, "width", JsonInt(iWidth > 0 ? iWidth : 1));
    jCandidate = JsonObjectSet(jCandidate, "height", JsonInt(iHeight > 0 ? iHeight : 1));
    jCandidate = JsonObjectSet(jCandidate, "detail", JsonString(GetName(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "search", JsonString(M_TACT_JsonSearchText(JsonString(GetName(oItem) + " " + GetResRef(oItem)))));
    jCandidate = JsonObjectSet(jCandidate, "item_resref", JsonString(GetResRef(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "item_uuid", JsonString(sUUID));
    jCandidate = JsonObjectSet(jCandidate, "item_property", JsonInt(-1));
    return JsonArrayInsert(jCandidates, jCandidate);
}

json M_TACT_AddItemCandidates(json jCandidates, object oItem)
{
    jCandidates = M_TACT_AddEquipCandidate(jCandidates, oItem);
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL && MEMORIA_IsCastPropertyAvailable(oItem, ip)) jCandidates = M_TACT_AddItemCandidate(jCandidates, oItem, ip);
        ip = GetNextItemProperty(oItem);
    }
    return jCandidates;
}

json M_TACT_EnumerateCandidates(object oActor)
{
    json jCandidates = JsonArray();
    int iPosition;
    for (iPosition = 1; iPosition <= 8; iPosition++)
    {
        int iClass = GetClassByPosition(iPosition, oActor);
        if (iClass != CLASS_TYPE_INVALID && Get2DAString("classes", "SpellCaster", iClass) == "1")
        {
            int iLevel;
            for (iLevel = 0; iLevel <= 9; iLevel++)
            {
                if (M_TACT_IsMemorizingClass(iClass))
                {
                    int iSlot;
                    for (iSlot = 0; iSlot < GetMemorizedSpellCountByLevel(oActor, iClass, iLevel); iSlot++)
                    {
                        int iSpell = GetMemorizedSpellId(oActor, iClass, iLevel, iSlot);
                        int iMetaMagic = GetMemorizedSpellMetaMagic(oActor, iClass, iLevel, iSlot);
                        int iDomain = GetMemorizedSpellIsDomainSpell(oActor, iClass, iLevel, iSlot) ? iLevel : 0;
                        jCandidates = M_TACT_AddSpellCandidate(jCandidates, iSpell, iClass, iLevel, iMetaMagic, iDomain);
                    }
                }
                else
                {
                    int iKnown;
                    for (iKnown = 0; iKnown < GetKnownSpellCount(oActor, iClass, iLevel); iKnown++)
                        jCandidates = M_TACT_AddSpellCandidate(jCandidates, GetKnownSpellId(oActor, iClass, iLevel, iKnown), iClass, iLevel, METAMAGIC_NONE, 0);
                }
            }
        }
    }
    object oItem = GetFirstItemInInventory(oActor);
    while (GetIsObjectValid(oItem))
    {
        jCandidates = M_TACT_AddItemCandidates(jCandidates, oItem);
        oItem = GetNextItemInInventory(oActor);
    }
    int iSlot;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
    {
        oItem = GetItemInSlot(iSlot, oActor);
        if (GetIsObjectValid(oItem)) jCandidates = M_TACT_AddItemCandidates(jCandidates, oItem);
    }
    return jCandidates;
}

json M_TACT_FilterCandidates(json jCandidates, json jSearch, string sMode)
{
    string sSearch = M_TACT_JsonSearchText(jSearch);
    json jFiltered = JsonArray();
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jCandidates); iIndex++)
    {
        json jCandidate = JsonArrayGet(jCandidates, iIndex);
        if (JsonGetString(JsonObjectGet(jCandidate, "type")) != sMode) continue;
        string sHaystack = JsonGetString(JsonObjectGet(jCandidate, "search"));
        if (sSearch == "" || FindSubString(sHaystack, sSearch) >= 0)
        {
            if (sMode != "item" && sMode != "equip") jFiltered = JsonArrayInsert(jFiltered, jCandidate);
            else
            {
                int iArea = JsonGetInt(JsonObjectGet(jCandidate, "width")) * JsonGetInt(JsonObjectGet(jCandidate, "height"));
                int iInsert = JsonGetLength(jFiltered);
                int iSorted;
                for (iSorted = 0; iSorted < JsonGetLength(jFiltered); iSorted++)
                {
                    json jSorted = JsonArrayGet(jFiltered, iSorted);
                    int iSortedArea = JsonGetInt(JsonObjectGet(jSorted, "width")) * JsonGetInt(JsonObjectGet(jSorted, "height"));
                    if (iArea > iSortedArea) { iInsert = iSorted; break; }
                }
                if (iInsert < JsonGetLength(jFiltered)) jFiltered = JsonArrayInsert(jFiltered, jCandidate, iInsert);
                else jFiltered = JsonArrayInsert(jFiltered, jCandidate);
            }
        }
    }
    return jFiltered;
}
