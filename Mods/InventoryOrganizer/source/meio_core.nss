// Shared constants and scroll-property helpers for Memoria Inventory Organizer.

#include "esi_lib"
#include "memoria_item"
#include "memoria_diag"
#include "memoria_gui"
#include "memoria_locale"
#include "memoria_loc"
#include "memoria_nui"
#include "memoria_string"
#include "x3_inc_string"

const string MEIO_SCRIPTORIUM_RESREF = "meio_vault";
const string MEIO_SCRIPTORIUM_TAG = "MEIO_VAULT";
const string MEIO_STORAGE_RESREF = "meio_storage";
const string MEIO_STORAGE_TAG = "MEIO_STORAGE";
const string MEIO_POTION_STORAGE_RESREF = "meio_potions";
const string MEIO_POTION_STORAGE_TAG = "MEIO_POTIONS";
const string MEIO_BOOK_STORAGE_RESREF = "meio_books";
const string MEIO_BOOK_STORAGE_TAG = "MEIO_BOOKS";
const string MEIO_KEY_CONTAINER_RESREF = "meio_keys";
const string MEIO_KEY_CONTAINER_TAG = "MEIO_KEY_CONTAINER";
const string MEIO_WINDOW = "meio_vault";
const string MEIO_BOOK_DESCRIPTION_WINDOW = "meio_book_description";
const string MEIO_LOCAL_SCRIPTORIUM = "MEIO_VAULT_OBJECT";
const string MEIO_LOCAL_STORAGE = "MEIO_STORAGE_OBJECT";
const string MEIO_LOCAL_POTION_STORAGE = "MEIO_POTION_STORAGE_OBJECT";
const string MEIO_LOCAL_BOOK_STORAGE = "MEIO_BOOK_STORAGE_OBJECT";
const string MEIO_LOCAL_STORAGE_OWNER = "MEIO_STORAGE_OWNER";
const string MEIO_LOCAL_SCHEMA = "MEIO_SCHEMA";
const string MEIO_LOCAL_INITIAL_IMPORT_DONE = "MEIO_INITIAL_IMPORT_V4_DONE";
const string MEIO_LOCAL_INITIAL_IMPORT_SNAPSHOT_DONE = "MEIO_INITIAL_IMPORT_V4_SNAPSHOT";
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
const string MEIO_LOCAL_BOOK_INDEX = "MEIO_BOOK_INDEX";
const string MEIO_LOCAL_BOOK_ENTRIES = "MEIO_BOOK_ENTRIES";
const string MEIO_LOCAL_KEY_INDEX = "MEIO_KEY_INDEX";
const string MEIO_LOCAL_KEY_ENTRIES = "MEIO_KEY_ENTRIES";
const string MEIO_LOCAL_LEVEL_CAPACITIES = "MEIO_LEVEL_CAPACITIES";
const string MEIO_LOCAL_POTION_CAPACITY = "MEIO_POTION_CAPACITY";
const string MEIO_LOCAL_BOOK_CAPACITY = "MEIO_BOOK_CAPACITY";
const string MEIO_LOCAL_KEY_CONTAINER_CAPACITY = "MEIO_KEY_CONTAINER_CAPACITY";
const string MEIO_LOCAL_KEY_ITEM_CAPACITY = "MEIO_KEY_ITEM_CAPACITY";
const string MEIO_LOCAL_KEY_CONTAINER_SCHEMA = "MEIO_KEY_CONTAINER_SCHEMA";
const string MEIO_LOCAL_KEY_MOVE_PENDING = "MEIO_KEY_MOVE_PENDING";
const string MEIO_LOCAL_KEY_BATCH_GENERATION = "MEIO_KEY_BATCH_GENERATION";
const string MEIO_LOCAL_KEY_PENDING_ITEM = "MEIO_KEY_PENDING_ITEM";
const string MEIO_LOCAL_KEY_TRANSFER_LEASE = "MEIO_KEY_TRANSFER_LEASE";
const string MEIO_LOCAL_HEARTBEAT_COUNTER = "MEIO_HEARTBEAT_COUNTER";
const string MEIO_LOCAL_ACTIVE_TAB = "MEIO_ACTIVE_TAB";
const string MEIO_LOCAL_TRANSFER_MODE = "MEIO_TRANSFER_MODE";
const string MEIO_LOCAL_BATCH_BLOCKED = "MEIO_BATCH_BLOCKED";
const string MEIO_LOCAL_BURN_SEEN = "MEIO_BURN_SEEN";
const string MEIO_LOCAL_BURN_GENERATION = "MEIO_BURN_GENERATION";
const string MEIO_LOCAL_BURN_PROCESSED = "MEIO_BURN_PROCESSED";
const string MEIO_CFG_AUTO_SCROLLS = "MEIO_CFG_AUTO_SCROLLS";
const string MEIO_CFG_AUTO_POTIONS = "MEIO_CFG_AUTO_POTIONS";
const string MEIO_CFG_AUTO_BOOKS = "MEIO_CFG_AUTO_BOOKS";
const string MEIO_CFG_AUTO_INITIALIZED = "MEIO_CFG_AUTO_INITIALIZED";
const string MEIO_CFG_KEEP_UNTARGETED_OPEN = "MEIO_CFG_KEEP_UNTARGETED_OPEN";
const string MEIO_CFG_UI_SCALE = "MEIO_CFG_UI_SCALE";
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
const int MEIO_TAB_BOOKS = 2;
const int MEIO_TAB_KEY_ITEMS = 3;
const int MEIO_INITIAL_IMPORT_BATCH_SIZE = 4;
const int MEIO_UI_SCALE_MINIMUM = 25;
const int MEIO_UI_SCALE_MAXIMUM = 100;
const int MEIO_UI_SCALE_DEFAULT = 75;
const int MEIO_POTION_COLUMNS = 12;
const int MEIO_TRANSFER_NONE = 0;
const int MEIO_TRANSFER_STORE_SCROLLS = 1;
const int MEIO_TRANSFER_STORE_POTIONS = 2;
const int MEIO_TRANSFER_WITHDRAW_SCROLLS = 3;
const int MEIO_TRANSFER_WITHDRAW_POTIONS = 4;
const int MEIO_TRANSFER_INITIAL_IMPORT = 5;
const int MEIO_TRANSFER_STORE_BOOKS = 6;
const int MEIO_TRANSFER_WITHDRAW_BOOKS = 7;
const int MEIO_TRANSFER_BURN_BOOKS = 8;
const int MEIO_TRANSFER_STORE_KEY_ITEMS = 9;
const int MEIO_TRANSFER_WITHDRAW_KEY_ITEMS = 10;
const int MEIO_KEY_CONTAINER_SCHEMA = 1;

void MEIO_EnsureAutomaticSettings(object oPC)
{
    if (GetLocalInt(oPC, MEIO_CFG_AUTO_INITIALIZED))
    {
        return;
    }
    SetLocalInt(oPC, MEIO_CFG_AUTO_SCROLLS, TRUE);
    SetLocalInt(oPC, MEIO_CFG_AUTO_POTIONS, TRUE);
    SetLocalInt(oPC, MEIO_CFG_AUTO_BOOKS, TRUE);
    SetLocalInt(oPC, MEIO_CFG_AUTO_INITIALIZED, TRUE);
}

int MEIO_GetUIScalePercent(object oPC)
{
    int iScale = GetLocalInt(oPC, MEIO_CFG_UI_SCALE);
    if (iScale < MEIO_UI_SCALE_MINIMUM || iScale > MEIO_UI_SCALE_MAXIMUM)
    {
        iScale = MEIO_UI_SCALE_DEFAULT;
        SetLocalInt(oPC, MEIO_CFG_UI_SCALE, iScale);
    }
    return iScale;
}

float MEIO_GetUIScale(object oPC)
{
    return IntToFloat(MEIO_GetUIScalePercent(oPC)) / 100.0f;
}

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

void MEIO_ScheduleExamineSuppression(object oPC, object oItem, string sReason)
{
    if (!MEIO_IsDirectlyIn(oItem, oPC) || GetTag(oItem) != MEIO_SCRIPTORIUM_TAG)
    {
        MEIO_Debug(oPC, "Examine suppression skipped reason=" + sReason + " item=" + ObjectToString(oItem));
        return;
    }
    MEMORIA_GUI_ScheduleItemExamineSuppression(oPC, oItem);
    MEIO_Debug(oPC, "Examine suppression scheduled reason=" + sReason + " item=" + ObjectToString(oItem));
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

int MEIO_IsBook(object oItem)
{
    return GetIsObjectValid(oItem) && GetBaseItemType(oItem) == BASE_ITEM_BOOK;
}

int MEIO_IsKeyItem(object oItem)
{
    return GetIsObjectValid(oItem) && (GetPlotFlag(oItem) || GetGoldPieceValue(oItem) == 0);
}

int MEIO_IsCursedItem(object oItem)
{
    return GetIsObjectValid(oItem) && GetItemCursedFlag(oItem);
}

int MEIO_IsRecallStone(object oItem)
{
    return GetIsObjectValid(oItem) && (GetTag(oItem) == "NW_IT_RECALL" || GetResRef(oItem) == "nw_it_recall");
}

int MEIO_IsKeyItemContainer(object oItem)
{
    return GetIsObjectValid(oItem) && GetBaseItemType(oItem) == BASE_ITEM_LARGEBOX && GetResRef(oItem) == MEIO_KEY_CONTAINER_RESREF && GetTag(oItem) == MEIO_KEY_CONTAINER_TAG && GetLocalInt(oItem, MEIO_LOCAL_KEY_CONTAINER_SCHEMA) == MEIO_KEY_CONTAINER_SCHEMA;
}

int MEIO_IsMemoriaItem(object oItem)
{
    if (!GetIsObjectValid(oItem))
    {
        return FALSE;
    }
    if (MEIO_IsKeyItemContainer(oItem))
    {
        return TRUE;
    }
    return GetBaseItemType(oItem) == BASE_ITEM_LARGEBOX && GetResRef(oItem) == MEIO_SCRIPTORIUM_RESREF && GetTag(oItem) == MEIO_SCRIPTORIUM_TAG;
}

int MEIO_CanStoreKeyItem(object oItem)
{
    return MEIO_IsKeyItem(oItem) && !MEIO_IsCursedItem(oItem) && !MEIO_IsMemoriaItem(oItem) && !MEIO_IsRecallStone(oItem);
}

int MEIO_HasItemProperties(object oItem)
{
    return GetIsItemPropertyValid(GetFirstItemProperty(oItem));
}

int MEIO_CanStoreBook(object oItem)
{
    return MEIO_IsBook(oItem) && !GetPlotFlag(oItem) && !GetItemCursedFlag(oItem) && GetGoldPieceValue(oItem) > 0 && !GetInfiniteFlag(oItem) && !MEIO_HasItemProperties(oItem);
}

int MEIO_IsUsablePotion(object oItem);

int MEIO_CanStoreItem(object oItem)
{
    return GetIsObjectValid(oItem) && !GetPlotFlag(oItem) && !GetItemCursedFlag(oItem) && GetGoldPieceValue(oItem) > 0 && (MEIO_IsScroll(oItem) || MEIO_IsUsablePotion(oItem) || MEIO_CanStoreBook(oItem));
}

int MEIO_IsAutomaticForItem(object oPC, object oItem)
{
    MEIO_EnsureAutomaticSettings(oPC);
    return MEIO_IsScroll(oItem) ? GetLocalInt(oPC, MEIO_CFG_AUTO_SCROLLS) : MEIO_IsUsablePotion(oItem) ? GetLocalInt(oPC, MEIO_CFG_AUTO_POTIONS) : MEIO_IsBook(oItem) ? GetLocalInt(oPC, MEIO_CFG_AUTO_BOOKS) : FALSE;
}

int MEIO_IsTransferBusy(object oPC)
{
    return GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) != MEIO_TRANSFER_NONE;
}

int MEIO_BeginTransfer(object oPC, int iMode, int bNotify)
{
    if (MEIO_IsTransferBusy(oPC) || GetIsObjectValid(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)))
    {
        if (bNotify)
        {
            SendMessageToPC(oPC, MEIO_GetText(oPC, "transfer_busy"));
        }
        return FALSE;
    }
    SetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE, iMode);
    return TRUE;
}

void MEIO_EndTransfer(object oPC, int iMode)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE) == iMode)
    {
        DeleteLocalInt(oPC, MEIO_LOCAL_TRANSFER_MODE);
    }
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

int MEIO_GetPotionIconAppearance(object oPotion, int iPart)
{
    int iColor = GetItemAppearance(oPotion, ITEM_APPR_TYPE_WEAPON_COLOR, iPart);
    int iModel = GetItemAppearance(oPotion, ITEM_APPR_TYPE_WEAPON_MODEL, iPart);
    return iModel * 10 + iColor;
}

string MEIO_GetPotionIconLayer(object oPotion, int iPart)
{
    string sPart = iPart == ITEM_APPR_WEAPON_MODEL_BOTTOM ? "b" : iPart == ITEM_APPR_WEAPON_MODEL_MIDDLE ? "m" : "t";
    return "iit_potion_" + sPart + "_" + MEIO_PadItemAppearance(MEIO_GetPotionIconAppearance(oPotion, iPart));
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
    return GetResRef(oPotion) + "|" + IntToString(iSubtype) + "|" + IntToString(MEIO_GetPotionIconAppearance(oPotion, ITEM_APPR_WEAPON_MODEL_BOTTOM)) + "|" + IntToString(MEIO_GetPotionIconAppearance(oPotion, ITEM_APPR_WEAPON_MODEL_MIDDLE)) + "|" + IntToString(MEIO_GetPotionIconAppearance(oPotion, ITEM_APPR_WEAPON_MODEL_TOP));
}

string MEIO_GetBookEnglishName(object oBook)
{
    json jName = JsonPointer(ObjectToJson(oBook), "/LocalizedName/value");
    string sName = JsonGetString(JsonObjectGet(jName, "0"));
    if (sName == "")
    {
        jName = JsonPointer(TemplateToJson(GetResRef(oBook), RESTYPE_UTI), "/LocalizedName/value");
        sName = JsonGetString(JsonObjectGet(jName, "0"));
    }
    return sName == "" ? GetName(oBook, TRUE) : sName;
}

string MEIO_GetBookKey(object oBook)
{
    return GetResRef(oBook) + "|" + GetTag(oBook) + "|" + GetName(oBook) + "|" + MEIO_GetBookEnglishName(oBook) + "|" + GetDescription(oBook, TRUE, TRUE) + "|" + IntToString(GetItemAppearance(oBook, ITEM_APPR_TYPE_SIMPLE_MODEL, 0));
}

int MEIO_GetCasterLevel(int iSubtype)
{
    string sLevel = Get2DAString("iprp_spells", "CasterLvl", iSubtype);
    if (sLevel == "" || sLevel == "****") sLevel = Get2DAString("iprp_spells", "CasterLevel", iSubtype);
    return sLevel == "" || sLevel == "****" ? -1 : StringToInt(sLevel);
}
