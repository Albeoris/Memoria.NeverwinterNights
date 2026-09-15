// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: melse_lib
/*
  Looting System Enhanced
  Event Handling & Library

  All event scripts should point to a corresponding event handler here.
 */
//::///////////////////////////////////////////////////////////////////////////
//:: Created By: Mischa Dutzik (aka Ravick)
//:: Created On: 09/20/2020
//::///////////////////////////////////////////////////////////////////////////

#include "x3_inc_string"
#include "nw_i0_tool"
#include "nw_i0_spells"
#include "esi_lib"
#include "rav_util"
#include "memoria_locale"
#include "memoria_i18n"

const string MELSE_VERSION = "1.1";
const string MELSE_VERSION_BUILD = "1010";

const string MELSE_SOUND_TAKE_GOLD = "it_coins";
const string MELSE_SOUND_TAKE_ITEM = "it_generictiny";
const string MELSE_SOUND_LEAVE_PLOT = "as_sw_x2gong1";
const string MELSE_SOUND_LEAVE_ITEM = "as_sw_x2gong2";

const string MELSE_LOCAL_FEATURE_TREASURE_SCANNING = "MELSE_FEATURE_TREASURE_SCANNING";
const string MELSE_LOCAL_FEATURE_TREASURE_TRACKING = "MELSE_FEATURE_TREASURE_TRACKING";
const string MELSE_LOCAL_FEATURE_TREASURE_LOOTING = "MELSE_FEATURE_TREASURE_LOOTING";
const string MELSE_LOCAL_FEATURE_CORPSE_LOOTABLE = "MELSE_FEATURE_CORPSE_LOOTABLE";
const string MELSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED = "MELSE_FEATURE_CORPSE_DECAYING_LOOTED";
const string MELSE_LOCAL_FEATURE_CORPSE_DECAYING_TIMED = "MELSE_FEATURE_CORPSE_DECAYING_TIMED";
const string MELSE_LOCAL_FEATURE_CORPSE_RAISEABLE = "MELSE_FEATURE_CORPSE_RAISEABLE";
const string MELSE_LOCAL_FEATURE_CORPSE_LOOTING_EXAMINED = "MELSE_FEATURE_CORPSE_LOOTING_EXAMINED";
const string MELSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED = "MELSE_FEATURE_CORPSE_LOOTING_KILLED";
const string MELSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH = "MELSE_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH";
const string MELSE_LOCAL_FEATURE_ITEM_DESCRIPTION_ACQUIRED = "MELSE_FEATURE_ITEM_DESCRIPTION_ACQUIRED";
const string MELSE_LOCAL_PARAM_DELAY_CORPSE_DECAY = "MELSE_PARAM_DELAY_CORPSE_DECAY";
const string MELSE_LOCAL_PARAM_THRESHOLD_ITEM_VALUE = "MELSE_PARAM_THRESHOLD_ITEM_PRICE";
const string MELSE_LOCAL_PARAM_THRESHOLD_ITEM_WEIGHT = "MELSE_PARAM_THRESHOLD_ITEM_WEIGHT";
const string MELSE_LOCAL_INITIALIZED = "MELSE_INITIALIZED";
const string MELSE_LOCAL_MOD_LOOTABLE = "MELSE_MOD_LOOTABLE";
const string MELSE_LOCAL_MOD_DESTROYABLE = "MELSE_MOD_DESTROYABLE";
const string MELSE_LOCAL_MOD_USEABLE = "MELSE_MOD_USEABLE";
const string MELSE_LOCAL_MOD_DESCRIPTION = "MELSE_MOD_DESCRIPTION";
const string MELSE_LOCAL_AREA_SCANNED_LAST = "MELSE_AREA_SCANNED_LAST";
const string MELSE_LOCAL_AREA_VISITED_LAST = "MELSE_AREA_VISITED_LAST";
const string MELSE_LOCAL_CONTAINER_EXAMINED = "MELSE_EXAMINED";
const string MELSE_LOCAL_CONTAINER_UNTRACKED = "MELSE_UNTRACKED";
const string MELSE_LOCAL_OBJECT_LOOTED = "MELSE_LOOTED";
const string MELSE_LOCAL_ITEM_ACQUIRED_FROM_UUID = "MELSE_ACQUIRED_FROM_UUID";
const string MELSE_LOCAL_ITEM_ACQUIRED_FROM_RESREF = "MELSE_ACQUIRED_FROM_RESREF";
const string MELSE_LOCAL_ITEM_ACQUIRED_FROM_NAME = "MELSE_ACQUIRED_FROM_NAME";
const string MELSE_LOCAL_ITEM_ACQUIRED_FROM_AREA_NAME = "MELSE_ACQUIRED_FROM_AREA_NAME";
const string MELSE_LOCAL_NOLOOTING = "MELSE_NOLOOTING";
const string MELSE_LOCAL_CORPSE = "MELSE_CORPSE";
const string MELSE_LOCAL_VERSION_BUILD = "MELSE_VERSION_BUILD";
const string MELSE_LOCAL_EVENTS_BUILD = "MELSE_EVENTS_BUILD";
const string MELSE_LOCAL_AREA_EVENTS_BUILD = "MELSE_AREA_EVENTS_BUILD";

const string MELSE_TAG_BODYBAG = "BodyBag";
const string MELSE_TAG_GOLD = "NW_IT_GOLD001";
const string MELSE_TAG_IPBOX = "x2_plc_ipbox";
const string MELSE_TAG_BELLY = "NW_IT_MSMLMISC08";

const float MELSE_DELAY_TREASURE_NOTIFY = 0.1f;
const float MELSE_DELAY_TREASURE_TRACK = 0.1f;
const float MELSE_DELAY_CORPSE_INITIALIZE = 1.0f;

const string MELSE_I18N_PREFIX = "melse";
const string MELSE_LOCAL_LANGUAGE = "MELSE_LANGUAGE";
const string MELSE_LOCAL_IS_RUSSIAN = "MELSE_LANGUAGE_IS_RUSSIAN";

const int MELSE_TEXT_ITEM_TAKEN = 1;
const int MELSE_TEXT_ITEM_NOTIFY_PLOT = 2;
const int MELSE_TEXT_ITEM_NOTIFY_SLOT = 3;
const int MELSE_TEXT_GOLD_TAKEN = 4;
const int MELSE_TEXT_ITEM_LOOTED_FROM = 5;
const int MELSE_TEXT_ITEM_LOOTED_FROM_AREA = 6;
const int MELSE_TEXT_ITEM_IGNORED = 7;

const string MELSE_STRREF_MAINTENANCE_INSTALL = "installed_version_message";
const string MELSE_STRREF_MAINTENANCE_UPDATE = "updated_version_message";

const string MELSE_STRREF_TREASURE_FOUND = "treasure_area_hint";
const string MELSE_STRREF_TREASURE_NOT_FOUND = "treasure_area_clear";
const string MELSE_STRREF_ACQUIRED_ITEM = "acquired_item_message";
const string MELSE_STRREF_ACQUIRED_GOLD = "acquired_gold_message";
const string MELSE_STRREF_ACQUIRED_FROM = "acquired_from_message";
const string MELSE_STRREF_DROPPED_ITEM_PLOT = "dropped_quest_item";
const string MELSE_STRREF_DROPPED_ITEM_SLOT = "dropped_equipped_item";
const string MELSE_STRREF_ITEM_LOOTED_FROM = "item_looted_from_label";
const string MELSE_STRREF_ITEM_LOOTED_FROM_AREA = "item_looted_from_area_label";
const string MELSE_STRREF_ITEM_NAME_UNIDENTIFIED = "item_name_unidentified";
const string MELSE_STRREF_ITEM_IGNORED = "item_ignored_suffix";

string MELSE_GetLanguage()
{
    string sResult = GetLocalString(GetModule(), MELSE_LOCAL_LANGUAGE);
    return sResult == "" ? "en" : sResult;
}

void MELSE_DetectLanguage(object oPC)
{
    object oModule = GetModule();
    if (GetLocalString(oModule, MELSE_LOCAL_LANGUAGE) != "") return;
    SetLocalString(oModule, MELSE_LOCAL_LANGUAGE, MEMORIA_GetLanguage(oPC, MELSE_LOCAL_LANGUAGE, "melse_is_ru", MELSE_LOCAL_IS_RUSSIAN));
}

string MELSE_GetLocalizedText(string sKey)
{
    return MEMORIA_I18N_GetText(MELSE_I18N_PREFIX, MELSE_GetLanguage(), sKey);
}

const string MELSE_SCRIPT_EVENT_MODULE_ACQUIRED_ITEM = "melse_modacqit";
const string MELSE_SCRIPT_EVENT_CREATURE_DEATH = "melse_crtdeath";
const string MELSE_SCRIPT_EVENT_PLACEABLE_CLOSE = "melse_plcclose";
const string MELSE_SCRIPT_EVENT_PLACEABLE_OPEN = "melse_plcopen";
const string MELSE_SCRIPT_EVENT_PLACEABLE_UNLOCK = "melse_plcunlck";
const string MELSE_SCRIPT_EVENT_AREA_ENTER = "melse_areenter";

const string MELSE_INJECT_KEY_MODULE_ACQUIRED_ITEM = "100";
const string MELSE_INJECT_KEY_AREA_ENTER = "200";
const string MELSE_INJECT_KEY_CREATURE_DEATH = "300";
const string MELSE_INJECT_KEY_PLACEABLE_CLOSE = "400";
const string MELSE_INJECT_KEY_PLACEABLE_OPEN = "410";
const string MELSE_INJECT_KEY_PLACEABLE_UNLOCK = "500";

const string MELSE_STRING_TAG_DESCRIPTION_START = "[MELSE]";
const string MELSE_STRING_TAG_DESCRIPTION_END = "[/MELSE]";
const int MELSE_STRING_TAG_DESCRIPTION_START_LENGTH = 5;
const int MELSE_STRING_TAG_DESCRIPTION_END_LENGTH = 6;

string MELSE_STRING_TAG_DESCRIPTION_START_RGB = StringToRGBString(MELSE_STRING_TAG_DESCRIPTION_START, STRING_COLOR_BLACK);
string MELSE_STRING_TAG_DESCRIPTION_END_RGB = StringToRGBString(MELSE_STRING_TAG_DESCRIPTION_END, STRING_COLOR_BLACK);
int MELSE_STRING_TAG_DESCRIPTION_START_RGB_LENGTH = GetStringLength(MELSE_STRING_TAG_DESCRIPTION_START_RGB);
int MELSE_STRING_TAG_DESCRIPTION_END_RGB_LENGTH = GetStringLength(MELSE_STRING_TAG_DESCRIPTION_END);

string MELSE_GetText(int iKey, object oObject = OBJECT_INVALID, int iStackSize = 0, object oItem = OBJECT_INVALID)
{
    string sResult;

    if (iKey == MELSE_TEXT_ITEM_TAKEN)
        sResult = StringToRGBString(GetName(oObject) + " >> " +
                                        IntToString(iStackSize) + "x " + 
                                        (GetIdentified(oItem) ? GetName(oItem) : MELSE_GetLocalizedText(MELSE_STRREF_ITEM_NAME_UNIDENTIFIED)),
                                    STRING_COLOR_GREEN);
    else if (iKey == MELSE_TEXT_ITEM_IGNORED)
        sResult = StringToRGBString(GetName(oObject) + " || " +
                                        IntToString(iStackSize) + "x " + 
                                        (GetIdentified(oItem) ? GetName(oItem) : MELSE_GetLocalizedText(MELSE_STRREF_ITEM_NAME_UNIDENTIFIED)) + " " +
                                        MELSE_GetLocalizedText(MELSE_STRREF_ITEM_IGNORED),
                                    STRING_COLOR_RED);
    else if (iKey == MELSE_TEXT_ITEM_NOTIFY_PLOT)
        sResult = StringToRGBString(GetName(oObject) + " " +
                                        MELSE_GetLocalizedText(MELSE_STRREF_DROPPED_ITEM_PLOT),
                                    STRING_COLOR_RED);
    else if (iKey == MELSE_TEXT_ITEM_NOTIFY_SLOT)
        sResult = StringToRGBString(GetName(oObject) + " " +
                                        MELSE_GetLocalizedText(MELSE_STRREF_DROPPED_ITEM_SLOT),
                                    STRING_COLOR_RED);
    else if (iKey == MELSE_TEXT_GOLD_TAKEN)
        sResult = StringToRGBString(GetName(oObject) + " >> " +
                                        IntToString(iStackSize) + "x Gold",
                                    STRING_COLOR_GREEN);
    else if (iKey == MELSE_TEXT_ITEM_LOOTED_FROM)
        sResult = StringToRGBString(MELSE_GetLocalizedText(MELSE_STRREF_ITEM_LOOTED_FROM),
                                    STRING_COLOR_GREEN);
    else if (iKey == MELSE_TEXT_ITEM_LOOTED_FROM_AREA)
        sResult = StringToRGBString(MELSE_GetLocalizedText(MELSE_STRREF_ITEM_LOOTED_FROM_AREA),
                                    STRING_COLOR_GREEN);
    return sResult;
}

void MELSE_SetConfigInt(string sOption, int nValue)
{
    object oModule = GetModule();
    RAV_SetLocalInt(oModule, sOption, nValue);
}

int MELSE_GetConfigInt(string sOption)
{
    object oModule = GetModule();
    return RAV_GetLocalInt(oModule, sOption);
}

//::///////////////////////////////////////////////////////////////////////////
//:: LOOTABLE CORPSES  
//::///////////////////////////////////////////////////////////////////////////

int MELSE_GetHasAnyItem(object oObject)
{
    // Cleanup decisions must use the physical contents, not filtered loot state or local flags.
    if (!GetIsObjectValid(oObject))
        return FALSE;

    if (GetIsObjectValid(GetFirstItemInInventory(oObject)))
        return TRUE;

    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
    {
        if (GetGold(oObject) > 0)
            return TRUE;

        int nSlot;
        for (nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; nSlot++)
        {
            if (GetIsObjectValid(GetItemInSlot(nSlot, oObject)))
                return TRUE;
        }
    }

    return FALSE;
}

void MELSE_TrySetIsDestroyable(object oCorpse)
{
    if (!GetIsObjectValid(oCorpse) || MELSE_GetHasAnyItem(oCorpse))
        return;

    SetIsDestroyable(TRUE, TRUE, FALSE, oCorpse);
}

int MELSE_GetIsLootableExcluded(object oObject)
{
    int sResult;

    string sTag = GetTag(oObject);
    sResult = ( // Exclude NWN Chapter 1 Arena 
                sTag == "Map_M1S4C" ? TRUE 
              : sTag == "Map_M1S4D" ? TRUE 
              : sTag == "Map_M1S4E" ? TRUE 
              : sTag == "Map_M1S4F" ? TRUE 
              :                       FALSE );

    if (sResult) 
        RAV_PrintVariableBool("MELSE_GetIsLootableExcluded", TRUE, oObject);

    return sResult;
}

void MELSE_SetLootable(object oCreature)
{
    if (!GetLootable(oCreature))
    {
        if (!MELSE_GetIsLootableExcluded(oCreature) &&
            !MELSE_GetIsLootableExcluded(GetArea(oCreature)))
        {        
            SetLootable(oCreature, TRUE);
            RAV_SetLocalInt(oCreature, MELSE_LOCAL_MOD_LOOTABLE, TRUE);
        }
    }
}

void MELSE_SetIsDestroyable(int bSelectableWhenDead = TRUE)
{
    if (GetLootable(OBJECT_SELF))
    {
        int bDestroyable = MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED);
        if (MELSE_GetHasAnyItem(OBJECT_SELF))
        {
            bDestroyable = FALSE;
            bSelectableWhenDead = TRUE;
        }
        SetIsDestroyable(bDestroyable, MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_RAISEABLE), bSelectableWhenDead);

        if (!MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED))
        {
            if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_DECAYING_TIMED))
                DelayCommand(IntToFloat(MELSE_GetConfigInt(MELSE_LOCAL_PARAM_DELAY_CORPSE_DECAY)), MELSE_TrySetIsDestroyable(OBJECT_SELF));
        }

        if (!MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED) 
         || !MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_RAISEABLE) 
         || bSelectableWhenDead)
            RAV_SetLocalInt(OBJECT_SELF, MELSE_LOCAL_MOD_DESTROYABLE, TRUE);
    }
}

void MELSE_DestroyCorpse(object oCorpse)
{
    if (!GetIsObjectValid(oCorpse) || MELSE_GetHasAnyItem(oCorpse))
        return;

    RAV_PrintFunctionStrings("MELSE_DestroyCorpse", oCorpse);

    AssignCommand(oCorpse, SetIsDestroyable(TRUE));
    DestroyObject(oCorpse);
}

void MELSE_DestroyCorpses(object oModule, object oArea = OBJECT_INVALID)
{
    object oObject;
    if (GetIsObjectValid(oArea))
    {
        oObject = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oObject))
        {
            if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && GetIsDead(oObject) &&
                RAV_GetLocalInt(oObject, MELSE_LOCAL_MOD_LOOTABLE) && RAV_GetLocalInt(oObject, MELSE_LOCAL_MOD_DESTROYABLE))

            MELSE_DestroyCorpse(oObject);
            oObject = GetNextObjectInArea(oArea);
        }
    }
    else
    {
        oArea = GetFirstArea();
        while (GetIsObjectValid(oArea))
        {
            oObject = GetFirstObjectInArea(oArea);
            while (GetIsObjectValid(oObject))
            {
                if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && GetIsDead(oObject) &&
                    RAV_GetLocalInt(oObject, MELSE_LOCAL_MOD_LOOTABLE) && RAV_GetLocalInt(oObject, MELSE_LOCAL_MOD_DESTROYABLE))

                MELSE_DestroyCorpse(oObject);
                oObject = GetNextObjectInArea(oArea);
            }
            oArea = GetNextArea();
        }
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: CORPSE AND TREASURE LOOTING
//::///////////////////////////////////////////////////////////////////////////

int MELSE_GetIsItemLootingObligatory(object oItem)
{
    int bResult;
    int nBaseItemType = GetBaseItemType(oItem);

    bResult = nBaseItemType == BASE_ITEM_CRAFTMATERIALMED   ? TRUE
            : nBaseItemType == BASE_ITEM_CRAFTMATERIALSML   ? TRUE
            : nBaseItemType == BASE_ITEM_CREATUREITEM       ? TRUE
            : nBaseItemType == BASE_ITEM_GEM                ? TRUE
            : nBaseItemType == BASE_ITEM_GOLD               ? TRUE
            : nBaseItemType == BASE_ITEM_HEALERSKIT         ? TRUE
            : nBaseItemType == BASE_ITEM_INVALID            ? TRUE
            : nBaseItemType == BASE_ITEM_KEY                ? TRUE
            : nBaseItemType == BASE_ITEM_LARGEBOX           ? TRUE
            : nBaseItemType == BASE_ITEM_MISCLARGE          ? TRUE
            : nBaseItemType == BASE_ITEM_MISCMEDIUM         ? TRUE
            : nBaseItemType == BASE_ITEM_MISCSMALL          ? TRUE
            : nBaseItemType == BASE_ITEM_MISCTALL           ? TRUE
            : nBaseItemType == BASE_ITEM_MISCTHIN           ? TRUE
            : nBaseItemType == BASE_ITEM_MISCWIDE           ? TRUE
            : nBaseItemType == BASE_ITEM_POTIONS            ? TRUE
            : nBaseItemType == BASE_ITEM_RING               ? TRUE
            : nBaseItemType == BASE_ITEM_SPELLSCROLL        ? TRUE
            : nBaseItemType == BASE_ITEM_THIEVESTOOLS       ? TRUE
            : nBaseItemType == BASE_ITEM_TORCH              ? TRUE
            : nBaseItemType == BASE_ITEM_TRAPKIT            ? TRUE
            : nBaseItemType == BASE_ITEM_ARROW              ? TRUE
            : nBaseItemType == BASE_ITEM_BOLT               ? TRUE
            : nBaseItemType == BASE_ITEM_BULLET             ? TRUE
            :                                                 FALSE;

    if (!bResult) 
        RAV_PrintVariableBool("MELSE_GetIsItemLootingObligatory", FALSE, oItem);
        
    return bResult;
}

int MELSE_GetIsLootingExcluded(object oObject)
{
    int bResult;
    string sTag = GetTag(oObject);

    bResult = RAV_GetLocalInt(oObject, MELSE_LOCAL_NOLOOTING) ? TRUE
            : sTag == MELSE_TAG_BELLY                         ? TRUE 
            :                                                 FALSE ;

    if (!bResult)
    {
        int nObjectType = GetObjectType(oObject);
        if (nObjectType == OBJECT_TYPE_ITEM)
        {
            object oItem = oObject;
            if (GetIdentified(oItem) && !GetPlotFlag(oItem))
            {
                if (!MELSE_GetIsItemLootingObligatory(oItem))
                {
                    // Check item weight against configured threshold
                    float fItemWeight = IntToFloat(GetWeight(oItem)) / 10;
                    int nItemWeight = FloatToInt(fItemWeight); // Decimals of the weight will be truncated
                    RAV_PrintVariableInt("MELSE_GetIsLootingExcluded->nItemWeight", nItemWeight, oItem);
                    int nConfigMaxItemWeight = MELSE_GetConfigInt(MELSE_LOCAL_PARAM_THRESHOLD_ITEM_WEIGHT);
                    if (nConfigMaxItemWeight > 0)
                    {
                        if (nItemWeight > nConfigMaxItemWeight)
                            bResult = TRUE;
                    }
                    if (!bResult)
                    {
                        // Check item gold value against configured threshold
                        int nItemValue = GetGoldPieceValue(oItem);
                        RAV_PrintVariableInt("MELSE_GetIsLootingExcluded->nItemValue", nItemValue, oItem);
                        int nConfigMinItemValue = MELSE_GetConfigInt(MELSE_LOCAL_PARAM_THRESHOLD_ITEM_VALUE);
                        if (nConfigMinItemValue > 0)
                        {
                            if (nItemValue < nConfigMinItemValue)
                                bResult = TRUE;
                        }
                    }
                }
            }
        }
    }
    if (bResult) 
        RAV_PrintVariableBool("MELSE_GetIsLootingExcluded", TRUE, oObject);
        
    return bResult;
}

void MELSE_ConfirmItemTaken(object oItem, object oTakeFrom, object oGiveTo)
{
    if (GetItemPossessor(oItem) != oGiveTo)
        return;

    SetDroppableFlag(oItem, FALSE);
    RAV_SetLocalInt(oItem, MELSE_LOCAL_OBJECT_LOOTED, TRUE);

    int nBaseItemInvSoundType = StringToInt(Get2DAString("baseitems", "InvSoundType", GetBaseItemType(oItem)));
    string nBaseItemInventorySound = Get2DAString("inventorysnds", "InventorySound", nBaseItemInvSoundType);
    PlaySound(nBaseItemInventorySound);
    FloatingTextStringOnCreature(MELSE_GetText(MELSE_TEXT_ITEM_TAKEN, oTakeFrom, GetItemStackSize(oItem), oItem), oGiveTo);
}

void MELSE_ConfirmObjectLooted(object oObject)
{
    if (!MELSE_GetHasAnyItem(oObject))
        RAV_SetLocalInt(oObject, MELSE_LOCAL_OBJECT_LOOTED, TRUE);
}

int MELSE_TakeItem(object oItem, object oTakeFrom, object oGiveTo, int bIfNotExcludedByConfig = TRUE)
{
    if (!bIfNotExcludedByConfig || !MELSE_GetIsLootingExcluded(oItem))
    {
        ActionGiveItem(oItem, oGiveTo);
        ActionDoCommand(MELSE_ConfirmItemTaken(oItem, oTakeFrom, oGiveTo));

        return TRUE;
    }
    else
    {
        FloatingTextStringOnCreature(MELSE_GetText(MELSE_TEXT_ITEM_IGNORED, oTakeFrom, GetItemStackSize(oItem), oItem), oGiveTo);

        return FALSE;
    }
}

void MELSE_TakeGold(object oTakeFrom, object oGiveTo)
{
    int iGold = GetGold(oTakeFrom);
    if (iGold > 0)
    {
        TakeGoldFromCreature(iGold, oTakeFrom, TRUE);
        GiveGoldToCreature(oGiveTo, iGold);
        PlaySound(MELSE_SOUND_TAKE_GOLD);
        FloatingTextStringOnCreature(MELSE_GetText(MELSE_TEXT_GOLD_TAKEN, oTakeFrom, iGold), oGiveTo);
    }
}

void MELSE_LeaveItem(object oItem, object oTakeFrom, object oGiveTo)
{
    int iStackSize = GetItemStackSize(oItem);
    if (GetPlotFlag(oItem))
    {
        PlaySound(MELSE_SOUND_LEAVE_PLOT);
        FloatingTextStringOnCreature(MELSE_GetText(MELSE_TEXT_ITEM_NOTIFY_PLOT, oTakeFrom, iStackSize, oItem), oGiveTo);
        AssignCommand(oGiveTo, ActionSpeakString(MELSE_GetText(MELSE_TEXT_ITEM_NOTIFY_PLOT, oTakeFrom, iStackSize, oItem)));
    }
    else
    {
        PlaySound(MELSE_SOUND_LEAVE_ITEM);
        FloatingTextStringOnCreature(MELSE_GetText(MELSE_TEXT_ITEM_NOTIFY_SLOT, oTakeFrom, iStackSize, oItem), oGiveTo);
        AssignCommand(oGiveTo, ActionSpeakString(MELSE_GetText(MELSE_TEXT_ITEM_NOTIFY_SLOT, oTakeFrom, iStackSize, oItem)));
    }
}

int MELSE_GetHasItem(object oObject)
{
    return MELSE_GetHasAnyItem(oObject);
}

int MELSE_GetHasDroppable(object oObject)
{
    int bResult = FALSE;

    object oItem = GetFirstItemInInventory(oObject);
    while (GetIsObjectValid(oItem) && bResult == FALSE)
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE)
            bResult = TRUE;
        else if (GetDroppableFlag(oItem))
            bResult = TRUE;
        oItem = GetNextItemInInventory(oObject);
    }

    return bResult;
}

int MELSE_TakeDroppables(object oTakeFrom, object oGiveTo)
{
    int bResult = TRUE;
    int bItemTaken;
    object oItem;

    if (!MELSE_GetIsLootingExcluded(oTakeFrom))
    {
        // Check equipped items
        if (GetObjectType(oTakeFrom) == OBJECT_TYPE_CREATURE)
        {
            int nSlot; for (nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; nSlot++) 
            {
                bItemTaken = FALSE;
                oItem = GetItemInSlot(nSlot, oTakeFrom); 
                if (GetIsObjectValid(oItem))
                {
                    if (GetDroppableFlag(oItem))
                    {
                        bItemTaken = MELSE_TakeItem(oItem, oTakeFrom, oGiveTo);
                        if (!bItemTaken)
                            bResult = FALSE;
                    }
                }
            }
        }

        // Check inventory items
        oItem = GetFirstItemInInventory(oTakeFrom);
        while (GetIsObjectValid(oItem))
        {
            bItemTaken = FALSE;
            if (GetObjectType(oTakeFrom) == OBJECT_TYPE_PLACEABLE)
            {
                bItemTaken = MELSE_TakeItem(oItem, oTakeFrom, oGiveTo);
                if (!bItemTaken)
                    bResult = FALSE;
            }
            else if (!GetPlotFlag(oItem))
            {
                if (GetDroppableFlag(oItem))
                {
                    bItemTaken = MELSE_TakeItem(oItem, oTakeFrom, oGiveTo);
                    if (!bItemTaken)
                        bResult = FALSE;
                }
            }
            else
            {
                if (GetDroppableFlag(oItem))
                {
                    bItemTaken = MELSE_TakeItem(oItem, oTakeFrom, oGiveTo);
                    if (!bItemTaken)
                        bResult = FALSE;
                }
            }
            oItem = GetNextItemInInventory(oTakeFrom);
        }

        if (GetObjectType(oTakeFrom) == OBJECT_TYPE_CREATURE)
            MELSE_TakeGold(oTakeFrom, oGiveTo);

        ActionDoCommand(MELSE_ConfirmObjectLooted(oTakeFrom));
    }
    return bResult;
}

//::///////////////////////////////////////////////////////////////////////////
//:: TREASURE SCANNING
//::///////////////////////////////////////////////////////////////////////////

int MELSE_GetHasLootableItem(object oObject)
{
    int bResult = FALSE;
    if (!MELSE_GetIsLootingExcluded(oObject))
    {
        object oItem = GetFirstItemInInventory(oObject);
        while (RAV_IsItemValid(oItem, GetItemStackSize(oItem)) && bResult == FALSE)
        {
            if (!MELSE_GetIsLootingExcluded(oItem))
            {
                if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
                {
                    if (GetDroppableFlag(oItem))
                        bResult = TRUE;
                }
                else
                    bResult = TRUE;
            }
            oItem = GetNextItemInInventory(oObject);
        }
    }
    return bResult;
}

int MELSE_GetHasLoot(object oObject)
{
    int bResult; 
    
    if (GetUseableFlag(oObject) && GetHasInventory(oObject)) 
    {
        if (GetTag(oObject) == MELSE_TAG_BODYBAG)
        { 
            if  (!RAV_GetLocalInt(oObject, MELSE_LOCAL_OBJECT_LOOTED)
            &&  MELSE_GetHasLootableItem(oObject))
                bResult = TRUE;
        }
        else if (!RAV_GetLocalInt(oObject, MELSE_LOCAL_CONTAINER_EXAMINED) 
        ||      MELSE_GetHasLootableItem(oObject))
            bResult = TRUE;
    }
    
    if (bResult)
        RAV_PrintVariableBool("MELSE_GetHasLoot", TRUE, oObject);

    return bResult;
}

int MELSE_GetHasTreasure(object oArea)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetTag(oObject) != MELSE_TAG_IPBOX)
        {
            if (MELSE_GetHasLoot(oObject))
                return TRUE;
        }
        oObject = GetNextObjectInArea(oArea);
    }
    return FALSE;
}

void MELSE_NotifyTreasure(object oPC, object oArea, int bNotifyPositive = TRUE)
{
    if (GetIsObjectValid(oPC) && GetIsObjectValid(oArea))
    {
        string sAreaUUID = GetObjectUUID(oArea);
        RAV_SetLocalString(oPC, MELSE_LOCAL_AREA_SCANNED_LAST, sAreaUUID);

        if (MELSE_GetHasTreasure(oArea))
        {
            if (bNotifyPositive)
                AssignCommand(oPC, SpeakString(StringToRGBString(MELSE_GetLocalizedText(MELSE_STRREF_TREASURE_FOUND), STRING_COLOR_WHITE)));
        }
        else
        {
            AssignCommand(oPC, SpeakString(StringToRGBString(MELSE_GetLocalizedText(MELSE_STRREF_TREASURE_NOT_FOUND), STRING_COLOR_WHITE)));
        }
    }
}

void MELSE_ScanTreasure(object oPC, object oArea)
{
    string sAreaUUID = GetObjectUUID(oArea);
    if (sAreaUUID != STRING_EMPTY && RAV_GetLocalString(oPC, MELSE_LOCAL_AREA_SCANNED_LAST) != sAreaUUID)
        DelayCommand(MELSE_DELAY_TREASURE_NOTIFY, MELSE_NotifyTreasure(oPC, oArea));
}

//::///////////////////////////////////////////////////////////////////////////
//:: TREASURE TRACKING
//::///////////////////////////////////////////////////////////////////////////

void MELSE_SetIsUntracked(object oPlaceable, int bValue)
{
    RAV_SetLocalInt(oPlaceable, MELSE_LOCAL_CONTAINER_UNTRACKED, bValue);
}

void MELSE_SetIsUntrackedIfEmpty(object oPlaceable)
{
    if (!GetIsObjectValid(GetFirstItemInInventory(oPlaceable)))
        MELSE_SetIsUntracked(oPlaceable, TRUE);
}

int MELSE_GetIsUntracked(object oPlaceable)
{
    int bResult;
    string oTag = GetTag(oPlaceable);

    bResult = RAV_GetLocalInt(oPlaceable, MELSE_LOCAL_CONTAINER_UNTRACKED)                                    ? TRUE

            : oTag == MELSE_TAG_BODYBAG                                                                       ? TRUE
            : oTag == MELSE_TAG_IPBOX                                                                         ? TRUE

            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED)             != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DIALOGUE)            != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED)  != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK)          != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_LOCK)                != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED)       != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT)         != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USED)                != STRING_EMPTY     ? TRUE
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED_EVENT)  != STRING_EMPTY     ? TRUE

            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_CLOSED)              != STRING_EMPTY     &&
              ( FindSubString(GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_CLOSED), "esi_") == -1   ||
                RAV_GetLocalString(oPlaceable, 
                    ESI_GetLocalNameOriginalScript(EVENT_SCRIPT_PLACEABLE_ON_CLOSED))   != STRING_EMPTY   ) ? TRUE
              
            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DEATH)               != STRING_EMPTY     &&
              FindSubString(GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_DEATH), "_o2_")   == -1   ? TRUE

            : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_OPEN)                != STRING_EMPTY     &&
              FindSubString(GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_OPEN), "_o2_")    == -1    &&
              FindSubString(GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_OPEN), "esi_")    == -1    ? TRUE

            // : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT)           != STRING_EMPTY     ? TRUE
            // : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED)       != STRING_EMPTY     ? TRUE
            // : GetEventScript(oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK)              != STRING_EMPTY     ? TRUE
            
            :                                                                                                 FALSE;

    RAV_PrintVariableBool("MELSE_GetIsUntracked", bResult, oPlaceable);

    return bResult;
}

void MELSE_SetUnuseable(object oPlaceable)
{
    SetUseableFlag(oPlaceable, FALSE);
    RAV_SetLocalInt(oPlaceable, MELSE_LOCAL_MOD_USEABLE, TRUE);
}

void MELSE_TrackTreasure(object oPlaceable, object oPC)
{
    if (!MELSE_GetHasAnyItem(oPlaceable) && !MELSE_GetHasLoot(oPlaceable))
    {
        if (!MELSE_GetIsUntracked(oPlaceable))
            MELSE_SetUnuseable(oPlaceable);
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: ITEM DESCRIPTION ACQUIRED FROM
//::///////////////////////////////////////////////////////////////////////////

string MELSE_GetDescriptionExcludingAcquiredFromText(string sDescription)
{
    int nAdditionLength;
    int nStartTagOffset = FindSubString(sDescription, MELSE_STRING_TAG_DESCRIPTION_START_RGB);
    if (nStartTagOffset >= 0)
    {
        int nEndTagOffset = FindSubString(sDescription, MELSE_STRING_TAG_DESCRIPTION_END_RGB, nStartTagOffset+MELSE_STRING_TAG_DESCRIPTION_START_RGB_LENGTH);
        if (nEndTagOffset >= 0)
            nAdditionLength = nStartTagOffset + nEndTagOffset + MELSE_STRING_TAG_DESCRIPTION_END_RGB_LENGTH;
    }
    if (nAdditionLength > 0)
        return GetSubString(sDescription, 0, nStartTagOffset - 1);  // -1 to exclude line breaks
    else
        return sDescription;
}

string MELSE_TagAcquiredFromText(string sText)
{
    return MELSE_STRING_TAG_DESCRIPTION_START_RGB + "\n" + sText + "\n" + MELSE_STRING_TAG_DESCRIPTION_END_RGB;
}

string MELSE_GetAcquiredFromText(string sFrom, string sArea)
{
    return MELSE_GetText(MELSE_TEXT_ITEM_LOOTED_FROM) + sFrom + "\n" + MELSE_GetText(MELSE_TEXT_ITEM_LOOTED_FROM_AREA) + sArea;
}

void MELSE_AddAcquiredFromToDescription(object oItem)
{
    string sAcquiredFrom = RAV_GetLocalString(oItem, MELSE_LOCAL_ITEM_ACQUIRED_FROM_NAME);
    string sAcquiredFromArea = RAV_GetLocalString(oItem, MELSE_LOCAL_ITEM_ACQUIRED_FROM_AREA_NAME);
    if (sAcquiredFrom != STRING_EMPTY)
    {
        string sAcquiredFromText = MELSE_GetAcquiredFromText(sAcquiredFrom, sAcquiredFromArea);
        
        string sDescriptionOriginalIdentified = GetDescription(oItem, TRUE, TRUE);
        string sDescriptionIdentified = GetDescription(oItem, FALSE, TRUE);
        string sDescriptionOriginalUnidentified = GetDescription(oItem, TRUE, FALSE);
        string sDescriptionUnidentified = GetDescription(oItem, FALSE, FALSE);

        // Unidentifyable items normally use only one of the two descriptions
        // To maintain consistency, we have to copy one into the other
        int iBaseItemDescription = StringToInt(Get2DAString("baseitems", "Description", GetBaseItemType(oItem)));
        string sBaseItemDescription = GetStringByStrRef(iBaseItemDescription);
        int bCopyIdentifiedToUnidentified = (sDescriptionIdentified   != sBaseItemDescription &&
                                             sDescriptionUnidentified == sBaseItemDescription) ? TRUE : FALSE;
        int bCopyUnidentifiedToIdentified = (sDescriptionIdentified   == sBaseItemDescription &&
                                             sDescriptionUnidentified != sBaseItemDescription) ? TRUE : FALSE;
        if (bCopyIdentifiedToUnidentified)
            sDescriptionUnidentified = sDescriptionIdentified;
        if (bCopyUnidentifiedToIdentified)
            sDescriptionIdentified = sDescriptionUnidentified;

        // Perform final setting of description for identified and unidentified
        if (RAV_GetLocalInt(oItem, MELSE_LOCAL_MOD_DESCRIPTION))
            sDescriptionIdentified = MELSE_GetDescriptionExcludingAcquiredFromText(sDescriptionIdentified);
        SetDescription(oItem, sDescriptionIdentified + "\n" + MELSE_TagAcquiredFromText(sAcquiredFromText), TRUE);
        if (RAV_GetLocalInt(oItem, MELSE_LOCAL_MOD_DESCRIPTION))
            sDescriptionUnidentified = MELSE_GetDescriptionExcludingAcquiredFromText(sDescriptionUnidentified);
        SetDescription(oItem, sDescriptionUnidentified + "\n" + MELSE_TagAcquiredFromText(sAcquiredFromText), FALSE);

        RAV_SetLocalInt(oItem, MELSE_LOCAL_MOD_DESCRIPTION, TRUE);
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: MAINTENANCE
//::///////////////////////////////////////////////////////////////////////////

void MELSE_MAINTENANCE_SetDefaultConfig(object oModule)
{
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_TREASURE_SCANNING, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_TREASURE_TRACKING, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_TREASURE_LOOTING, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTABLE, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED, FALSE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_DECAYING_TIMED, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_RAISEABLE, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTING_EXAMINED, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_FEATURE_ITEM_DESCRIPTION_ACQUIRED, TRUE);
    MELSE_SetConfigInt(MELSE_LOCAL_PARAM_DELAY_CORPSE_DECAY, 600);  // 10 minutes decay time by default
    MELSE_SetConfigInt(MELSE_LOCAL_PARAM_THRESHOLD_ITEM_VALUE, 8);  // Exclude basic base game books by defaults
    MELSE_SetConfigInt(MELSE_LOCAL_PARAM_THRESHOLD_ITEM_WEIGHT, 9); // Exclude heavier armor/weapon items by default
}

void MELSE_MAINTENANCE_Build(object oModule, object oPC, string sNewBuild, string sOldBuild = STRING_EMPTY)
{
    // Perform maintenance actions needed to adjust the module to a new version of MELSE
    RAV_PrintFunctionStrings("MELSE_MAINTENANCE_Build", oModule, sNewBuild, sOldBuild);

    // Initialize default config after first install or update from initial release build
    if (sOldBuild == STRING_EMPTY || sOldBuild == "1001")
        MELSE_MAINTENANCE_SetDefaultConfig(oModule);

    if (sOldBuild == STRING_EMPTY)
        DelayCommand(8.0f, AssignCommand(oPC, ActionSpeakString(StringToRGBString(MELSE_GetLocalizedText(MELSE_STRREF_MAINTENANCE_INSTALL) + " " + 
                                                                                  MELSE_VERSION + " (Build " + sNewBuild + ")",
                                                                                  STRING_COLOR_GREEN))));
    else
        DelayCommand(8.0f, AssignCommand(oPC, ActionSpeakString(StringToRGBString(MELSE_GetLocalizedText(MELSE_STRREF_MAINTENANCE_UPDATE) + " " + 
                                                                                  MELSE_VERSION + " (Build " + sNewBuild + ")",
                                                                                  STRING_COLOR_GREEN))));

    RAV_SetLocalString(oModule, MELSE_LOCAL_VERSION_BUILD, sNewBuild);
}

//::///////////////////////////////////////////////////////////////////////////
//:: INITIALIZATION
//::///////////////////////////////////////////////////////////////////////////

void MELSE_InjectEventScripts(object oModule)
{
    if (RAV_GetLocalString(oModule, MELSE_LOCAL_EVENTS_BUILD) == MELSE_VERSION_BUILD)
        return;
    ESI_InjectToObject(oModule, MELSE_INJECT_KEY_MODULE_ACQUIRED_ITEM, EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM, MELSE_SCRIPT_EVENT_MODULE_ACQUIRED_ITEM, ESI_INJECTION_PLACEMENT_LAST);
    ESI_InjectToModuleObjects(oModule, MELSE_INJECT_KEY_AREA_ENTER, ESI_OBJECT_TYPE_AREA, EVENT_SCRIPT_AREA_ON_ENTER, MELSE_SCRIPT_EVENT_AREA_ENTER, ESI_INJECTION_PLACEMENT_LAST);
    RAV_SetLocalString(oModule, MELSE_LOCAL_EVENTS_BUILD, MELSE_VERSION_BUILD);
}

void MELSE_InjectAreaObjects(object oArea)
{
    if (!GetIsObjectValid(oArea) || RAV_GetLocalString(oArea, MELSE_LOCAL_AREA_EVENTS_BUILD) == MELSE_VERSION_BUILD)
        return;
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        int nObjectType = GetObjectType(oObject);
        if (nObjectType == OBJECT_TYPE_CREATURE && !GetIsPC(oObject))
        {
            ESI_InjectToObject(oObject, MELSE_INJECT_KEY_CREATURE_DEATH, EVENT_SCRIPT_CREATURE_ON_DEATH, MELSE_SCRIPT_EVENT_CREATURE_DEATH, ESI_INJECTION_PLACEMENT_LAST);
        }
        else if (nObjectType == OBJECT_TYPE_PLACEABLE)
        {
            ESI_InjectToObject(oObject, MELSE_INJECT_KEY_PLACEABLE_OPEN, EVENT_SCRIPT_PLACEABLE_ON_OPEN, MELSE_SCRIPT_EVENT_PLACEABLE_OPEN, ESI_INJECTION_PLACEMENT_LAST);
            ESI_InjectToObject(oObject, MELSE_INJECT_KEY_PLACEABLE_CLOSE, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, MELSE_SCRIPT_EVENT_PLACEABLE_CLOSE, ESI_INJECTION_PLACEMENT_FIRST);
            ESI_InjectToObject(oObject, MELSE_INJECT_KEY_PLACEABLE_UNLOCK, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, MELSE_SCRIPT_EVENT_PLACEABLE_UNLOCK, ESI_INJECTION_PLACEMENT_LAST);
        }
        oObject = GetNextObjectInArea(oArea);
    }
    RAV_SetLocalString(oArea, MELSE_LOCAL_AREA_EVENTS_BUILD, MELSE_VERSION_BUILD);
}

int MELSE_IsObjectInitialized(object oObject)
{
    return RAV_GetLocalInt(oObject, MELSE_LOCAL_INITIALIZED);
}

void MELSE_Initialize(object oModule, object oPC)
{
    string sVersionBuild = RAV_GetLocalString(oModule, MELSE_LOCAL_VERSION_BUILD);
    RAV_PrintVariableString("MELSE_LOCAL_VERSION_BUILD", sVersionBuild, oModule);
    RAV_PrintVariableString("MELSE_VERSION_BUILD", MELSE_VERSION_BUILD, oModule);
    if (StringToInt(sVersionBuild) != StringToInt(MELSE_VERSION_BUILD))
        MELSE_MAINTENANCE_Build(oModule, oPC, MELSE_VERSION_BUILD, sVersionBuild);

    MELSE_DetectLanguage(oPC);

    MELSE_InjectEventScripts(oModule);
    object oArea = GetArea(oPC);
    string sAreaUUID = GetObjectUUID(oArea);
    if (RAV_GetLocalString(oPC, MELSE_LOCAL_AREA_VISITED_LAST) != sAreaUUID)
    {
        RAV_SetLocalString(oPC, MELSE_LOCAL_AREA_VISITED_LAST, sAreaUUID);
        // Manually execute area scripts for startup area
        DelayCommand(6.0f, ESI_ExecuteEventScripts(oArea, EVENT_SCRIPT_AREA_ON_ENTER));
    }
}

void MELSE_InitializeCreature(object oCreature)
{
    if (!MELSE_IsObjectInitialized(oCreature))
    {
        RAV_SetLocalInt(oCreature, MELSE_LOCAL_INITIALIZED, TRUE);

        // Should have been already done for "static" creatures in areas OnEnter. This is to apply injection also for creatures created by script or encounter
        ESI_InjectToObject(oCreature, MELSE_INJECT_KEY_CREATURE_DEATH, EVENT_SCRIPT_CREATURE_ON_DEATH, MELSE_SCRIPT_EVENT_CREATURE_DEATH, ESI_INJECTION_PLACEMENT_LAST);

        if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTABLE))
            MELSE_SetLootable(oCreature);
    }
}

void MELSE_InitializeCorpse(object oCorpse)
{
    // Iterate all body bags near the corpse (within whole area to be exact) to inject OnClose event
    int nNext = 1;
    object oBodyBag = GetNearestObjectByTag(MELSE_TAG_BODYBAG, oCorpse, nNext);
    while (GetIsObjectValid(oBodyBag))
    {
        ESI_InjectToObject(oBodyBag, MELSE_INJECT_KEY_PLACEABLE_CLOSE, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, MELSE_SCRIPT_EVENT_PLACEABLE_CLOSE, ESI_INJECTION_PLACEMENT_FIRST);
        nNext++;
        oBodyBag = GetNearestObjectByTag(MELSE_TAG_BODYBAG, oCorpse, nNext);
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: EVENT HANDLING
//::///////////////////////////////////////////////////////////////////////////

void MELSE_OnHeartbeat(object oObject)
{
    if (GetIsPC(oObject))
    {
        object oPC = oObject;
        object oArea = GetArea(oPC);
        object oModule = GetModule();

        MELSE_Initialize(oModule, oPC);

        if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_TREASURE_SCANNING))
            MELSE_ScanTreasure(oPC, oArea);
    }
    else if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
    {
        MELSE_InitializeCreature(oObject);
    }
}

void MELSE_OnPhysicalAttacked(object oObject, object oAttacker, object oWeaponUsed, int iAttackType, int iAttackMode)
{
    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
        MELSE_InitializeCreature(oObject);
}

void MELSE_OnSpellCastAt(object oObject, int bSpellHarmful, object oSpellCaster, int iSpell)
{
    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
        MELSE_InitializeCreature(oObject);
}

void MELSE_OnDeath(object oObject, object oKiller)
{
    int bLootedAll;

    if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED) && GetIsPC(oKiller))
    {
        bLootedAll = MELSE_TakeDroppables(oObject, oKiller);
    }
    else if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH))
    {
        object oMaster = GetMaster(oKiller);
        object oSuperMaster = GetMaster(oMaster);
        if (GetIsPC(oMaster))
            bLootedAll = MELSE_TakeDroppables(oObject, oMaster);
        else if (GetIsPC(oSuperMaster))
            bLootedAll = MELSE_TakeDroppables(oObject, oSuperMaster);
    }

    int bSelectable;
    if (bLootedAll) 
        bSelectable = FALSE;
    else            
        bSelectable = TRUE;
    MELSE_SetIsDestroyable(bSelectable);
    ActionDoCommand(MELSE_SetIsDestroyable(bSelectable));

    if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_CORPSE_LOOTING_EXAMINED))
        DelayCommand(MELSE_DELAY_CORPSE_INITIALIZE, MELSE_InitializeCorpse(oObject));
}

void MELSE_OnAcquiredItem(object oModule, object oItem, object oBy, object oFrom, int nStackSize)
{
    if (GetIsObjectValid(oItem))    // Could be invalid in case of gold
    {
        if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_ITEM_DESCRIPTION_ACQUIRED))
        {
            if (GetIsObjectValid(oFrom) && GetIsPC(oBy) && !MELSE_GetIsUntracked(oFrom))
            {
                RAV_SetLocalString(oItem, MELSE_LOCAL_ITEM_ACQUIRED_FROM_UUID, GetObjectUUID(oFrom));
                RAV_SetLocalString(oItem, MELSE_LOCAL_ITEM_ACQUIRED_FROM_RESREF, GetResRef(oFrom));
                RAV_SetLocalString(oItem, MELSE_LOCAL_ITEM_ACQUIRED_FROM_NAME, GetName(oFrom, FALSE));
                RAV_SetLocalString(oItem, MELSE_LOCAL_ITEM_ACQUIRED_FROM_AREA_NAME, GetName(GetArea(oFrom)));
                MELSE_AddAcquiredFromToDescription(oItem);
            }
        }
    }
}

void MELSE_OnClose(object oObject, object oBy)
{
    if (GetHasInventory(oObject) && GetIsPC(oBy))
    {
        if (!RAV_GetLocalInt(oObject, MELSE_LOCAL_CONTAINER_EXAMINED))
        {
            int bLootedAll;
            RAV_SetLocalInt(oObject, MELSE_LOCAL_CONTAINER_EXAMINED, TRUE);
            if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_TREASURE_LOOTING))
                bLootedAll = MELSE_TakeDroppables(oObject, oBy);
            if (bLootedAll)
            {
                if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_TREASURE_TRACKING))
                    DelayCommand(MELSE_DELAY_TREASURE_TRACK, MELSE_TrackTreasure(oObject, oBy));
            }
            if (MELSE_GetConfigInt(MELSE_LOCAL_FEATURE_TREASURE_SCANNING))
                DelayCommand(MELSE_DELAY_TREASURE_NOTIFY, MELSE_NotifyTreasure(oBy, GetArea(oBy), FALSE));
        }
    }
}

void MELSE_OnOpen(object oObject, object oBy)
{
    if (GetHasInventory(oObject) && GetIsPC(oBy))
    {
        MELSE_SetIsUntrackedIfEmpty(oObject);
    }
}

void MELSE_OnEnter(object oObject, object oEntering)
{
    if (GetIsPC(oEntering) && oObject == GetArea(oEntering))
        MELSE_InjectAreaObjects(oObject);
}

void MELSE_OnUnlock(object oPlaceable, object oBy)
{
    if (GetHasInventory(oPlaceable) && GetIsPC(oBy))
        AssignCommand(oBy, ActionInteractObject(oPlaceable));
}
