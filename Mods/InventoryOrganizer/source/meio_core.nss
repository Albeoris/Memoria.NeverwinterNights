// Shared constants and scroll-property helpers for Memoria Inventory Organizer.

#include "esi_lib"
#include "memoria_item"
#include "memoria_diag"
#include "memoria_locale"
#include "memoria_loc"
#include "memoria_nui"
#include "memoria_string"

const string MEIO_SCRIPTORIUM_RESREF = "meio_vault";
const string MEIO_SCRIPTORIUM_TAG = "MEIO_VAULT";
const string MEIO_STORAGE_RESREF = "meio_storage";
const string MEIO_STORAGE_TAG = "MEIO_STORAGE";
const string MEIO_POTION_STORAGE_RESREF = "meio_potions";
const string MEIO_POTION_STORAGE_TAG = "MEIO_POTIONS";
const string MEIO_WINDOW = "meio_vault";
const string MEIO_LOCAL_SCRIPTORIUM = "MEIO_VAULT_OBJECT";
const string MEIO_LOCAL_STORAGE = "MEIO_STORAGE_OBJECT";
const string MEIO_LOCAL_POTION_STORAGE = "MEIO_POTION_STORAGE_OBJECT";
const string MEIO_LOCAL_STORAGE_OWNER = "MEIO_STORAGE_OWNER";
const string MEIO_LOCAL_SCHEMA = "MEIO_SCHEMA";
const string MEIO_LOCAL_INITIAL_IMPORT_DONE = "MEIO_INITIAL_IMPORT_V3_DONE";
const string MEIO_LOCAL_INITIAL_IMPORT_SNAPSHOT_DONE = "MEIO_INITIAL_IMPORT_V3_SNAPSHOT";
const string MEIO_LOCAL_INITIAL_IMPORT_ITEM = "MEIO_INITIAL_IMPORT_ITEM";
const string MEIO_LOCAL_INITIAL_IMPORT_RUNNING = "MEIO_INITIAL_IMPORT_RUNNING";
const string MEIO_LOCAL_INITIAL_IMPORT_GENERATION = "MEIO_INITIAL_IMPORT_GENERATION";
const string MEIO_LOCAL_BATCH_MOVED = "MEIO_BATCH_MOVED";
const string MEIO_LOCAL_RETURN_GENERATION = "MEIO_RETURN_GENERATION";
const string MEIO_LOCAL_RETURN_TOTAL = "MEIO_RETURN_TOTAL";
const string MEIO_LOCAL_SUPPRESS_SORT = "MEIO_SUPPRESS_SORT";
const string MEIO_LOCAL_KEEP_OUT = "MEIO_KEEP_OUT";
const string MEIO_LOCAL_KEEP_OUT_REGISTRY = "MEIO_KEEP_OUT_REGISTRY";
const string MEIO_LOCAL_ORIGINAL_TAG = "MEIO_ORIGINAL_TAG";
const string MEIO_LOCAL_HAS_ORIGINAL_TAG = "MEIO_HAS_ORIGINAL_TAG";
const string MEIO_LOCAL_INDEX = "MEIO_INDEX";
const string MEIO_LOCAL_FILTERED_INDEX = "MEIO_FILTERED_INDEX";
const string MEIO_LOCAL_DISPLAY_ENTRIES = "MEIO_DISPLAY_ENTRIES";
const string MEIO_LOCAL_POTION_INDEX = "MEIO_POTION_INDEX";
const string MEIO_LOCAL_POTION_ENTRIES = "MEIO_POTION_ENTRIES";
const string MEIO_LOCAL_LEVEL_CAPACITIES = "MEIO_LEVEL_CAPACITIES";
const string MEIO_LOCAL_POTION_CAPACITY = "MEIO_POTION_CAPACITY";
const string MEIO_LOCAL_ACTIVE_TAB = "MEIO_ACTIVE_TAB";
const string MEIO_LOCAL_EXAMINE_ITEM = "MEIO_EXAMINE_ITEM";
const string MEIO_LOCAL_EXAMINE_DISABLED = "MEIO_EXAMINE_DISABLED";
const string MEIO_CFG_SORT_MODE = "MEIO_CFG_SORT_MODE";
const string MEIO_CFG_DEBUG = "MEIO_CFG_DEBUG";
const string MEIO_LOCAL_RESERVED = "MEIO_RESERVED";
const string MEIO_LOCAL_RESERVED_KEY = "MEIO_RESERVED_KEY";
const string MEIO_LOCAL_RESERVED_TAG = "MEIO_RESERVED_TAG";
const string MEIO_LOCAL_RESERVED_ISSUED = "MEIO_RESERVED_ISSUED";
const string MEIO_LOCAL_CLEANUP_GENERATION = "MEIO_CLEANUP_GENERATION";
const string MEIO_LOCAL_SUPPRESS_GENERATION = "MEIO_SUPPRESS_GENERATION";
const string MEIO_LOCAL_LANGUAGE = "MEIO_LANGUAGE";
const string MEIO_LOCAL_ITEM_LANGUAGE = "MEIO_ITEM_LANGUAGE";
const string MEIO_ESI_ACQUIRE = "meio.module.acquire";
const string MEIO_ESI_ACTIVATE = "meio.module.activate";
const string MEIO_ESI_GUI = "meio.module.gui";
const string MEIO_ESI_TARGET = "meio.module.target";
const string MEIO_ESI_CHAT = "meio.module.chat";
const string MEIO_RUNTIME_RESERVATION = "meio.reservation";
const string MEIO_RUNTIME_INITIAL_IMPORT = "meio.initial_import";
const int MEIO_SCHEMA = 1;
const int MEIO_TARGET_ALL = 0;
const int MEIO_TARGET_SELF = 1;
const int MEIO_TARGET_ALLY = 2;
const int MEIO_TARGET_ENEMY = 3;
const int MEIO_TAB_SCROLLS = 0;
const int MEIO_TAB_POTIONS = 1;
const int MEIO_SORT_MODE_AUTOMATIC = 0;
const int MEIO_SORT_MODE_MANUAL = 1;
const int MEIO_INITIAL_IMPORT_BATCH_SIZE = 4;
const int MEIO_POTION_COLUMNS = 12;

void MEIO_MarkKeepOut(object oPC, object oItem)
{
    if (!GetIsObjectValid(oItem))
    {
        return;
    }
    SetLocalInt(oItem, MEIO_LOCAL_KEEP_OUT, TRUE);
    json jRegistry = GetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY);
    if (JsonGetType(jRegistry) != JSON_TYPE_OBJECT)
    {
        jRegistry = JsonObject();
    }
    SetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY, JsonObjectSet(jRegistry, ObjectToString(oItem), JsonBool(TRUE)));
}

void MEIO_UnmarkKeepOut(object oPC, object oItem)
{
    if (!GetIsObjectValid(oItem))
    {
        return;
    }
    DeleteLocalInt(oItem, MEIO_LOCAL_KEEP_OUT);
    json jRegistry = GetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY);
    if (JsonGetType(jRegistry) == JSON_TYPE_OBJECT)
    {
        SetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY, JsonObjectDel(jRegistry, ObjectToString(oItem)));
    }
}

int MEIO_IsKeepOut(object oPC, object oItem)
{
    if (!GetIsObjectValid(oItem))
    {
        return FALSE;
    }
    if (GetLocalInt(oItem, MEIO_LOCAL_KEEP_OUT) || GetSubString(GetTag(oItem), 0, 10) == "MEIO_CAST_")
    {
        return TRUE;
    }
    json jRegistry = GetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY);
    return JsonGetInt(JsonObjectGet(jRegistry, ObjectToString(oItem)));
}

void MEIO_CleanupKeepOutRegistry(object oPC)
{
    json jRegistry = GetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY);
    if (JsonGetType(jRegistry) != JSON_TYPE_OBJECT)
    {
        return;
    }
    json jKeys = JsonObjectKeys(jRegistry);
    int iKey;
    for (iKey = 0; iKey < JsonGetLength(jKeys); iKey++)
    {
        string sKey = JsonGetString(JsonArrayGet(jKeys, iKey));
        object oItem = StringToObject(sKey);
        if (!GetIsObjectValid(oItem) || GetItemPossessor(oItem, TRUE) != oPC)
        {
            jRegistry = JsonObjectDel(jRegistry, sKey);
        }
    }
    SetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY, jRegistry);
}

string MEIO_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, MEIO_LOCAL_LANGUAGE);
}

string MEIO_GetText(object oPC, string sKey)
{
    return MEMORIA_LOC_GetText("meio", MEIO_GetLanguage(oPC), sKey);
}

int MEIO_IsPC(object oPC)
{
    return GetIsPC(oPC) && !GetIsDM(oPC) && !GetIsObjectValid(GetMaster(oPC));
}

int MEIO_IsDirectlyIn(object oItem, object oContainer)
{
    return GetIsObjectValid(oItem) && GetItemPossessor(oItem, TRUE) == oContainer;
}

void MEIO_NormalizeExtractedTag(object oItem)
{
    if (!GetIsObjectValid(oItem) || !GetLocalInt(oItem, MEIO_LOCAL_HAS_ORIGINAL_TAG))
    {
        return;
    }
    SetTag(oItem, GetLocalString(oItem, MEIO_LOCAL_ORIGINAL_TAG));
    DeleteLocalString(oItem, MEIO_LOCAL_ORIGINAL_TAG);
    DeleteLocalInt(oItem, MEIO_LOCAL_HAS_ORIGINAL_TAG);
}

void MEIO_Debug(object oPC, string sMessage)
{
    if (!GetIsObjectValid(oPC) || !GetLocalInt(oPC, MEIO_CFG_DEBUG))
    {
        return;
    }
    string sLine = "[MEIO DEBUG] " + sMessage;
    SendMessageToPC(oPC, sLine);
    WriteTimestampedLogEntry(sLine + " pc=" + ObjectToString(oPC));
}

string MEIO_DebugItemState(object oPC, object oItem)
{
    if (!GetIsObjectValid(oItem))
    {
        return "item=invalid";
    }
    json jRegistry = GetLocalJson(oPC, MEIO_LOCAL_KEEP_OUT_REGISTRY);
    int bRegistry = JsonGetInt(JsonObjectGet(jRegistry, ObjectToString(oItem)));
    return "item=" + ObjectToString(oItem) + " name=\"" + GetName(oItem) + "\" tag=\"" + GetTag(oItem) + "\" base=" + IntToString(GetBaseItemType(oItem)) + " stack=" + IntToString(GetItemStackSize(oItem)) + " possessor=" + ObjectToString(GetItemPossessor(oItem, TRUE)) + " keepLocal=" + IntToString(GetLocalInt(oItem, MEIO_LOCAL_KEEP_OUT)) + " keepRegistry=" + IntToString(bRegistry) + " keepResolved=" + IntToString(MEIO_IsKeepOut(oPC, oItem));
}

int MEIO_IsScroll(object oItem)
{
    return GetIsObjectValid(oItem) && GetBaseItemType(oItem) == BASE_ITEM_SPELLSCROLL;
}

int MEIO_IsPotion(object oItem)
{
    return GetIsObjectValid(oItem) && GetBaseItemType(oItem) == BASE_ITEM_POTIONS;
}

string MEIO_PadItemAppearance(int iAppearance)
{
    if (iAppearance < 10)
    {
        return "00" + IntToString(iAppearance);
    }
    if (iAppearance < 100)
    {
        return "0" + IntToString(iAppearance);
    }
    return IntToString(iAppearance);
}

string MEIO_GetPotionIconLayer(object oPotion, int iPart)
{
    int iColor = GetItemAppearance(oPotion, ITEM_APPR_TYPE_WEAPON_COLOR, iPart);
    int iModel = GetItemAppearance(oPotion, ITEM_APPR_TYPE_WEAPON_MODEL, iPart);
    string sPart = iPart == ITEM_APPR_WEAPON_MODEL_BOTTOM || iModel > 3 ? "b" : iPart == ITEM_APPR_WEAPON_MODEL_MIDDLE ? "m" : "t";
    return "iit_potion_" + sPart + "_" + MEIO_PadItemAppearance(iColor * 10 + iModel);
}

int MEIO_GetOnlyCastSubtype(object oScroll)
{
    int iSubtype = -1;
    int iCount;
    itemproperty ip = GetFirstItemProperty(oScroll);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL)
        {
            iSubtype = GetItemPropertySubType(ip);
            iCount++;
        }
        ip = GetNextItemProperty(oScroll);
    }
    return iCount == 1 ? iSubtype : -1;
}

itemproperty MEIO_FindCastProperty(object oScroll, int iSubtype)
{
    itemproperty ip = GetFirstItemProperty(oScroll);
    while (GetIsItemPropertyValid(ip))
    {
            if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL && GetItemPropertySubType(ip) == iSubtype)
            {
                return ip;
            }
        ip = GetNextItemProperty(oScroll);
    }
    return ip;
}

int MEIO_GetSpell(int iSubtype)
{
    string sSpell = Get2DAString("iprp_spells", "SpellIndex", iSubtype);
    return sSpell == "" || sSpell == "****" ? -1 : StringToInt(sSpell);
}

int MEIO_IsUsablePotion(object oItem)
{
    if (!MEIO_IsPotion(oItem))
    {
        return FALSE;
    }
    int iSubtype = MEIO_GetOnlyCastSubtype(oItem);
    return iSubtype >= 0 && MEIO_GetSpell(iSubtype) >= 0;
}

int MEIO_GetSpellLevel(int iSpell)
{
    string sLevel = Get2DAString("spells", "Innate", iSpell);
    int iLevel = sLevel == "" || sLevel == "****" ? -1 : StringToInt(sLevel);
    return iLevel >= 0 && iLevel <= 9 ? iLevel : -1;
}

string MEIO_GetVariantKey(object oScroll, int iSubtype)
{
    return IntToString(iSubtype);
}

string MEIO_GetPotionKey(object oPotion, int iSubtype)
{
    return GetResRef(oPotion) + "|" + IntToString(iSubtype) + "|" + IntToString(GetItemAppearance(oPotion, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM)) + "|" + IntToString(GetItemAppearance(oPotion, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE)) + "|" + IntToString(GetItemAppearance(oPotion, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_TOP));
}

int MEIO_GetCasterLevel(int iSubtype)
{
    string sLevel = Get2DAString("iprp_spells", "CasterLvl", iSubtype);
    if (sLevel == "" || sLevel == "****") sLevel = Get2DAString("iprp_spells", "CasterLevel", iSubtype);
    return sLevel == "" || sLevel == "****" ? -1 : StringToInt(sLevel);
}
