#include "metact_core"
#include "memoria_string"

const int METACT_PICKER_COLUMNS = 16;
const int METACT_PICKER_ROWS = 6;
const int METACT_PICKER_PAGE_SIZE = 96;

string METACT_GetSpellAlias(int iSpell)
{
    return MEMORIA_GetSpellAlias(iSpell);
}

string METACT_GetSpellIcon(int iSpell)
{
    return MEMORIA_GetSpellIcon(iSpell);
}

string METACT_PadItemModel(int iModel)
{
    return MEMORIA_PadItemModel(iModel);
}

string METACT_GetItemIcon(object oItem)
{
    return MEMORIA_GetItemIcon(oItem);
}

string METACT_UnicodeJsonLower(string sValue)
{
    return MEMORIA_FoldJsonSearchText(sValue);
}

string METACT_JsonSearchText(json jValue)
{
    return MEMORIA_GetJsonSearchText(jValue);
}

string METACT_GetClassName(int iClass)
{
    return MEMORIA_GetClassName(iClass);
}

int METACT_IsMemorizingClass(int iClass)
{
    return MEMORIA_IsMemorizingClass(iClass);
}

string METACT_GetMetamagicName(int iMetaMagic)
{
    return MEMORIA_GetMetamagicName(iMetaMagic);
}

int METACT_CandidateExists(json jCandidates, string sType, int iSpell, int iClass, int iMetaMagic, int iDomain, string sItemResRef, int iProperty)
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

json METACT_AddSpellCandidate(json jCandidates, int iSpell, int iClass, int iLevel, int iMetaMagic, int iDomain)
{
    if (iSpell < 0 || METACT_CandidateExists(jCandidates, "spell", iSpell, iClass, iMetaMagic, iDomain, "", -1))
        return jCandidates;
    json jCandidate = JsonObject();
    jCandidate = JsonObjectSet(jCandidate, "type", JsonString("spell"));
    jCandidate = JsonObjectSet(jCandidate, "spell", JsonInt(iSpell));
    jCandidate = JsonObjectSet(jCandidate, "class", JsonInt(iClass));
    jCandidate = JsonObjectSet(jCandidate, "level", JsonInt(iLevel));
    jCandidate = JsonObjectSet(jCandidate, "metamagic", JsonInt(iMetaMagic));
    jCandidate = JsonObjectSet(jCandidate, "domain", JsonInt(iDomain));
    jCandidate = JsonObjectSet(jCandidate, "name", JsonString(MEMORIA_GetSpellName(iSpell)));
    jCandidate = JsonObjectSet(jCandidate, "alias", JsonString(METACT_GetSpellAlias(iSpell)));
    jCandidate = JsonObjectSet(jCandidate, "icon", JsonString(METACT_GetSpellIcon(iSpell)));
    string sDetail = METACT_GetClassName(iClass) + " - " + IntToString(iLevel);
    if (iMetaMagic != METAMAGIC_NONE) sDetail += " - " + METACT_GetMetamagicName(iMetaMagic);
    if (iDomain > 0) sDetail += " [D]";
    if (METACT_GetLanguage(OBJECT_SELF) == "ru") sDetail = METACT_GetSpellAlias(iSpell) + " - " + sDetail;
    jCandidate = JsonObjectSet(jCandidate, "detail", JsonString(sDetail));
    jCandidate = JsonObjectSet(jCandidate, "search", JsonString(METACT_JsonSearchText(JsonString(MEMORIA_GetSpellName(iSpell) + " " + METACT_GetSpellAlias(iSpell) + " " + sDetail))));
    jCandidate = JsonObjectSet(jCandidate, "item_resref", JsonString(""));
    jCandidate = JsonObjectSet(jCandidate, "item_property", JsonInt(-1));
    return JsonArrayInsert(jCandidates, jCandidate);
}

json METACT_AddItemCandidate(json jCandidates, object oItem, itemproperty ip)
{
    int iProperty = GetItemPropertySubType(ip);
    int iSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", iProperty));
    string sResRef = GetResRef(oItem);
    if (iSpell < 0 || METACT_CandidateExists(jCandidates, "item", iSpell, CLASS_TYPE_INVALID, METAMAGIC_NONE, 0, sResRef, iProperty))
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
    jCandidate = JsonObjectSet(jCandidate, "alias", JsonString(METACT_GetSpellAlias(iSpell)));
    int iBaseItem = GetBaseItemType(oItem);
    string sIcon = iBaseItem == BASE_ITEM_SCROLL || iBaseItem == BASE_ITEM_SPELLSCROLL ? METACT_GetSpellIcon(iSpell) : METACT_GetItemIcon(oItem);
    if (sIcon == "" || sIcon == "****") sIcon = METACT_GetSpellIcon(iSpell);
    jCandidate = JsonObjectSet(jCandidate, "icon", JsonString(sIcon));
    int iWidth = StringToInt(Get2DAString("baseitems", "InvSlotWidth", iBaseItem));
    int iHeight = StringToInt(Get2DAString("baseitems", "InvSlotHeight", iBaseItem));
    jCandidate = JsonObjectSet(jCandidate, "width", JsonInt(iWidth > 0 ? iWidth : 1));
    jCandidate = JsonObjectSet(jCandidate, "height", JsonInt(iHeight > 0 ? iHeight : 1));
    jCandidate = JsonObjectSet(jCandidate, "detail", JsonString(GetName(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "search", JsonString(METACT_JsonSearchText(JsonString(MEMORIA_GetSpellName(iSpell) + " " + METACT_GetSpellAlias(iSpell) + " " + GetName(oItem)))));
    jCandidate = JsonObjectSet(jCandidate, "item_resref", JsonString(sResRef));
    jCandidate = JsonObjectSet(jCandidate, "item_property", JsonInt(iProperty));
    return JsonArrayInsert(jCandidates, jCandidate);
}

int METACT_EquipCandidateExists(json jCandidates, string sUUID)
{
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jCandidates); iIndex++)
    {
        json jCandidate = JsonArrayGet(jCandidates, iIndex);
        if (JsonGetString(JsonObjectGet(jCandidate, "type")) == "equip" && JsonGetString(JsonObjectGet(jCandidate, "item_uuid")) == sUUID) return TRUE;
    }
    return FALSE;
}

json METACT_AddEquipCandidate(json jCandidates, object oItem)
{
    if (MEMORIA_GetEquipableSlots(oItem) <= 0) return jCandidates;
    string sUUID = GetObjectUUID(oItem);
    if (sUUID == "")
    {
        ForceRefreshObjectUUID(oItem);
        sUUID = GetObjectUUID(oItem);
    }
    if (sUUID == "" || METACT_EquipCandidateExists(jCandidates, sUUID)) return jCandidates;
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
    jCandidate = JsonObjectSet(jCandidate, "icon", JsonString(METACT_GetItemIcon(oItem)));
    int iWidth = StringToInt(Get2DAString("baseitems", "InvSlotWidth", iBaseItem));
    int iHeight = StringToInt(Get2DAString("baseitems", "InvSlotHeight", iBaseItem));
    jCandidate = JsonObjectSet(jCandidate, "width", JsonInt(iWidth > 0 ? iWidth : 1));
    jCandidate = JsonObjectSet(jCandidate, "height", JsonInt(iHeight > 0 ? iHeight : 1));
    jCandidate = JsonObjectSet(jCandidate, "detail", JsonString(GetName(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "search", JsonString(METACT_JsonSearchText(JsonString(GetName(oItem) + " " + GetResRef(oItem)))));
    jCandidate = JsonObjectSet(jCandidate, "item_resref", JsonString(GetResRef(oItem)));
    jCandidate = JsonObjectSet(jCandidate, "item_uuid", JsonString(sUUID));
    jCandidate = JsonObjectSet(jCandidate, "item_property", JsonInt(-1));
    return JsonArrayInsert(jCandidates, jCandidate);
}

int METACT_IsActionableFeat(object oActor, int iFeat)
{
    if (!GetHasFeat(iFeat, oActor, TRUE)) return FALSE;
    string sCategory = Get2DAString("feat", "CATEGORY", iFeat);
    if (sCategory != "" && sCategory != "****") return TRUE;
    string sUsesPerDay = Get2DAString("feat", "USESPERDAY", iFeat);
    if (sUsesPerDay != "" && sUsesPerDay != "****" && StringToInt(sUsesPerDay) > 0) return TRUE;
    string sSpell = Get2DAString("feat", "SPELLID", iFeat);
    return sSpell != "" && sSpell != "****" && StringToInt(sSpell) >= 0;
}

json METACT_AddFeatCandidates(json jCandidates, object oActor)
{
    int iFeat;
    for (iFeat = 0; iFeat < Get2DARowCount("feat"); iFeat++)
    {
        if (!METACT_IsActionableFeat(oActor, iFeat)) continue;
        string sNameStrRef = Get2DAString("feat", "FEAT", iFeat);
        string sName = sNameStrRef == "" || sNameStrRef == "****" ? "" : GetStringByStrRef(StringToInt(sNameStrRef));
        if (sName == "") continue;
        string sIcon = Get2DAString("feat", "ICON", iFeat);
        if (sIcon == "" || sIcon == "****") sIcon = "ife_alertness";
        string sSpell = Get2DAString("feat", "SPELLID", iFeat);
        int iSpell = sSpell == "" || sSpell == "****" ? -1 : StringToInt(sSpell);
        json jCandidate = JsonObject();
        jCandidate = JsonObjectSet(jCandidate, "type", JsonString("feat"));
        jCandidate = JsonObjectSet(jCandidate, "feat", JsonInt(iFeat));
        jCandidate = JsonObjectSet(jCandidate, "spell", JsonInt(iSpell));
        jCandidate = JsonObjectSet(jCandidate, "class", JsonInt(CLASS_TYPE_INVALID));
        jCandidate = JsonObjectSet(jCandidate, "level", JsonInt(-1));
        jCandidate = JsonObjectSet(jCandidate, "metamagic", JsonInt(METAMAGIC_NONE));
        jCandidate = JsonObjectSet(jCandidate, "domain", JsonInt(0));
        jCandidate = JsonObjectSet(jCandidate, "name", JsonString(sName));
        jCandidate = JsonObjectSet(jCandidate, "alias", JsonString(Get2DAString("feat", "LABEL", iFeat)));
        jCandidate = JsonObjectSet(jCandidate, "icon", JsonString(sIcon));
        jCandidate = JsonObjectSet(jCandidate, "detail", JsonString(sName));
        jCandidate = JsonObjectSet(jCandidate, "search", JsonString(METACT_JsonSearchText(JsonString(sName + " " + Get2DAString("feat", "LABEL", iFeat)))));
        jCandidate = JsonObjectSet(jCandidate, "target_self", JsonBool(MEMORIA_IsFeatTargetSelf(iFeat)));
        jCandidate = JsonObjectSet(jCandidate, "item_resref", JsonString(""));
        jCandidate = JsonObjectSet(jCandidate, "item_property", JsonInt(-1));
        jCandidates = JsonArrayInsert(jCandidates, jCandidate);
    }
    return jCandidates;
}

json METACT_AddItemCandidates(json jCandidates, object oItem)
{
    jCandidates = METACT_AddEquipCandidate(jCandidates, oItem);
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL && MEMORIA_IsCastPropertyAvailable(oItem, ip)) jCandidates = METACT_AddItemCandidate(jCandidates, oItem, ip);
        ip = GetNextItemProperty(oItem);
    }
    return jCandidates;
}

json METACT_EnumerateCandidates(object oActor)
{
    json jCandidates = METACT_AddFeatCandidates(JsonArray(), oActor);
    int iPosition;
    for (iPosition = 1; iPosition <= 8; iPosition++)
    {
        int iClass = GetClassByPosition(iPosition, oActor);
        if (iClass != CLASS_TYPE_INVALID && Get2DAString("classes", "SpellCaster", iClass) == "1")
        {
            int iLevel;
            for (iLevel = 0; iLevel <= 9; iLevel++)
            {
                if (METACT_IsMemorizingClass(iClass))
                {
                    int iSlot;
                    for (iSlot = 0; iSlot < GetMemorizedSpellCountByLevel(oActor, iClass, iLevel); iSlot++)
                    {
                        int iSpell = GetMemorizedSpellId(oActor, iClass, iLevel, iSlot);
                        int iMetaMagic = GetMemorizedSpellMetaMagic(oActor, iClass, iLevel, iSlot);
                        int iDomain = GetMemorizedSpellIsDomainSpell(oActor, iClass, iLevel, iSlot) ? iLevel : 0;
                        jCandidates = METACT_AddSpellCandidate(jCandidates, iSpell, iClass, iLevel, iMetaMagic, iDomain);
                    }
                }
                else
                {
                    int iKnown;
                    for (iKnown = 0; iKnown < GetKnownSpellCount(oActor, iClass, iLevel); iKnown++)
                        jCandidates = METACT_AddSpellCandidate(jCandidates, GetKnownSpellId(oActor, iClass, iLevel, iKnown), iClass, iLevel, METAMAGIC_NONE, 0);
                }
            }
        }
    }
    object oItem = GetFirstItemInInventory(oActor);
    while (GetIsObjectValid(oItem))
    {
        jCandidates = METACT_AddItemCandidates(jCandidates, oItem);
        oItem = GetNextItemInInventory(oActor);
    }
    int iSlot;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
    {
        oItem = GetItemInSlot(iSlot, oActor);
        if (GetIsObjectValid(oItem)) jCandidates = METACT_AddItemCandidates(jCandidates, oItem);
    }
    return jCandidates;
}

json METACT_FilterCandidates(json jCandidates, json jSearch, string sMode)
{
    string sSearch = METACT_JsonSearchText(jSearch);
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
