// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

//::///////////////////////////////////////////////////////////////////////////
//:: m_lse_lib
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
#include "m_lse_sin_lib"

const string M_LSE_VERSION = "1.1";
const string M_LSE_VERSION_BUILD = "1010";

const string M_LSE_SOUND_TAKE_GOLD = "it_coins";
const string M_LSE_SOUND_TAKE_ITEM = "it_generictiny";
const string M_LSE_SOUND_LEAVE_PLOT = "as_sw_x2gong1";
const string M_LSE_SOUND_LEAVE_ITEM = "as_sw_x2gong2";

const string M_LSE_LOCAL_FEATURE_TREASURE_SCANNING = "M_LSE_FEATURE_TREASURE_SCANNING";
const string M_LSE_LOCAL_FEATURE_TREASURE_TRACKING = "M_LSE_FEATURE_TREASURE_TRACKING";
const string M_LSE_LOCAL_FEATURE_TREASURE_LOOTING = "M_LSE_FEATURE_TREASURE_LOOTING";
const string M_LSE_LOCAL_FEATURE_CORPSE_LOOTABLE = "M_LSE_FEATURE_CORPSE_LOOTABLE";
const string M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED = "M_LSE_FEATURE_CORPSE_DECAYING_LOOTED";
const string M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_TIMED = "M_LSE_FEATURE_CORPSE_DECAYING_TIMED";
const string M_LSE_LOCAL_FEATURE_CORPSE_RAISEABLE = "M_LSE_FEATURE_CORPSE_RAISEABLE";
const string M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_EXAMINED = "M_LSE_FEATURE_CORPSE_LOOTING_EXAMINED";
const string M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED = "M_LSE_FEATURE_CORPSE_LOOTING_KILLED";
const string M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH = "M_LSE_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH";
const string M_LSE_LOCAL_FEATURE_ITEM_DESCRIPTION_ACQUIRED = "M_LSE_FEATURE_ITEM_DESCRIPTION_ACQUIRED";
const string M_LSE_LOCAL_PARAM_DELAY_CORPSE_DECAY = "M_LSE_PARAM_DELAY_CORPSE_DECAY";
const string M_LSE_LOCAL_PARAM_THRESHOLD_ITEM_VALUE = "M_LSE_PARAM_THRESHOLD_ITEM_PRICE";
const string M_LSE_LOCAL_PARAM_THRESHOLD_ITEM_WEIGHT = "M_LSE_PARAM_THRESHOLD_ITEM_WEIGHT";
const string M_LSE_LOCAL_INITIALIZED = "M_LSE_INITIALIZED";
const string M_LSE_LOCAL_MOD_LOOTABLE = "M_LSE_MOD_LOOTABLE";
const string M_LSE_LOCAL_MOD_DESTROYABLE = "M_LSE_MOD_DESTROYABLE";
const string M_LSE_LOCAL_MOD_USEABLE = "M_LSE_MOD_USEABLE";
const string M_LSE_LOCAL_MOD_DESCRIPTION = "M_LSE_MOD_DESCRIPTION";
const string M_LSE_LOCAL_AREA_SCANNED_LAST = "M_LSE_AREA_SCANNED_LAST";
const string M_LSE_LOCAL_AREA_VISITED_LAST = "M_LSE_AREA_VISITED_LAST";
const string M_LSE_LOCAL_CONTAINER_EXAMINED = "M_LSE_EXAMINED";
const string M_LSE_LOCAL_CONTAINER_UNTRACKED = "M_LSE_UNTRACKED";
const string M_LSE_LOCAL_OBJECT_LOOTED = "M_LSE_LOOTED";
const string M_LSE_LOCAL_ITEM_ACQUIRED_FROM_UUID = "M_LSE_ACQUIRED_FROM_UUID";
const string M_LSE_LOCAL_ITEM_ACQUIRED_FROM_RESREF = "M_LSE_ACQUIRED_FROM_RESREF";
const string M_LSE_LOCAL_ITEM_ACQUIRED_FROM_NAME = "M_LSE_ACQUIRED_FROM_NAME";
const string M_LSE_LOCAL_ITEM_ACQUIRED_FROM_AREA_NAME = "M_LSE_ACQUIRED_FROM_AREA_NAME";
const string M_LSE_LOCAL_NOLOOTING = "M_LSE_NOLOOTING";
const string M_LSE_LOCAL_CORPSE = "M_LSE_CORPSE";
const string M_LSE_LOCAL_VERSION_BUILD = "M_LSE_VERSION_BUILD";
const string M_LSE_LOCAL_EVENTS_BUILD = "M_LSE_EVENTS_BUILD";
const string M_LSE_LOCAL_AREA_EVENTS_BUILD = "M_LSE_AREA_EVENTS_BUILD";

const string M_LSE_TAG_BODYBAG = "BodyBag";
const string M_LSE_TAG_GOLD = "NW_IT_GOLD001";
const string M_LSE_TAG_IPBOX = "x2_plc_ipbox";
const string M_LSE_TAG_BELLY = "NW_IT_MSMLMISC08";

const float M_LSE_DELAY_TREASURE_NOTIFY = 0.1f;
const float M_LSE_DELAY_TREASURE_TRACK = 0.1f;
const float M_LSE_DELAY_CORPSE_INITIALIZE = 1.0f;

const string M_LSE_TEXT_INDEX = "m_lse_text";

const int M_LSE_TEXT_ITEM_TAKEN = 1;
const int M_LSE_TEXT_ITEM_NOTIFY_PLOT = 2;
const int M_LSE_TEXT_ITEM_NOTIFY_SLOT = 3;
const int M_LSE_TEXT_GOLD_TAKEN = 4;
const int M_LSE_TEXT_ITEM_LOOTED_FROM = 5;
const int M_LSE_TEXT_ITEM_LOOTED_FROM_AREA = 6;
const int M_LSE_TEXT_ITEM_IGNORED = 7;

const int M_LSE_STRREF_MAINTENANCE_INSTALL = 501;
const int M_LSE_STRREF_MAINTENANCE_UPDATE = 502;

const int M_LSE_STRREF_TREASURE_FOUND = 1;
const int M_LSE_STRREF_TREASURE_NOT_FOUND = 2;
const int M_LSE_STRREF_ACQUIRED_ITEM = 3;
const int M_LSE_STRREF_ACQUIRED_GOLD = 6;
const int M_LSE_STRREF_ACQUIRED_FROM = 4;
const int M_LSE_STRREF_DROPPED_ITEM_PLOT = 5;
const int M_LSE_STRREF_DROPPED_ITEM_SLOT = 7;
const int M_LSE_STRREF_ITEM_LOOTED_FROM = 8;
const int M_LSE_STRREF_ITEM_LOOTED_FROM_AREA = 9;
const int M_LSE_STRREF_ITEM_NAME_UNIDENTIFIED = 10;
const int M_LSE_STRREF_ITEM_IGNORED = 11;

const string M_LSE_SCRIPT_EVENT_MODULE_ACQUIRED_ITEM = "m_lse_modacqit";
const string M_LSE_SCRIPT_EVENT_CREATURE_DEATH = "m_lse_crtdeath";
const string M_LSE_SCRIPT_EVENT_PLACEABLE_CLOSE = "m_lse_plcclose";
const string M_LSE_SCRIPT_EVENT_PLACEABLE_OPEN = "m_lse_plcopen";
const string M_LSE_SCRIPT_EVENT_PLACEABLE_UNLOCK = "m_lse_plcunlck";
const string M_LSE_SCRIPT_EVENT_AREA_ENTER = "m_lse_areenter";

const string M_LSE_INJECT_KEY_MODULE_ACQUIRED_ITEM = "100";
const string M_LSE_INJECT_KEY_AREA_ENTER = "200";
const string M_LSE_INJECT_KEY_CREATURE_DEATH = "300";
const string M_LSE_INJECT_KEY_PLACEABLE_CLOSE = "400";
const string M_LSE_INJECT_KEY_PLACEABLE_OPEN = "410";
const string M_LSE_INJECT_KEY_PLACEABLE_UNLOCK = "500";

const string M_LSE_STRING_TAG_DESCRIPTION_START = "[M_LSE]";
const string M_LSE_STRING_TAG_DESCRIPTION_END = "[/M_LSE]";
const int M_LSE_STRING_TAG_DESCRIPTION_START_LENGTH = 5;
const int M_LSE_STRING_TAG_DESCRIPTION_END_LENGTH = 6;

string M_LSE_STRING_TAG_DESCRIPTION_START_RGB = StringToRGBString(M_LSE_STRING_TAG_DESCRIPTION_START, STRING_COLOR_BLACK);
string M_LSE_STRING_TAG_DESCRIPTION_END_RGB = StringToRGBString(M_LSE_STRING_TAG_DESCRIPTION_END, STRING_COLOR_BLACK);
int M_LSE_STRING_TAG_DESCRIPTION_START_RGB_LENGTH = GetStringLength(M_LSE_STRING_TAG_DESCRIPTION_START_RGB);
int M_LSE_STRING_TAG_DESCRIPTION_END_RGB_LENGTH = GetStringLength(M_LSE_STRING_TAG_DESCRIPTION_END);

string M_LSE_GetText(int iKey, object oObject = OBJECT_INVALID, int iStackSize = 0, object oItem = OBJECT_INVALID)
{
    string sResult;

    if (iKey == M_LSE_TEXT_ITEM_TAKEN)
        sResult = StringToRGBString(GetName(oObject) + " >> " +
                                        IntToString(iStackSize) + "x " + 
                                        (GetIdentified(oItem) ? GetName(oItem) : M_LSE_SIN_GetText(M_LSE_STRREF_ITEM_NAME_UNIDENTIFIED)),
                                    STRING_COLOR_GREEN);
    else if (iKey == M_LSE_TEXT_ITEM_IGNORED)
        sResult = StringToRGBString(GetName(oObject) + " || " +
                                        IntToString(iStackSize) + "x " + 
                                        (GetIdentified(oItem) ? GetName(oItem) : M_LSE_SIN_GetText(M_LSE_STRREF_ITEM_NAME_UNIDENTIFIED)) + " " +
                                        M_LSE_SIN_GetText(M_LSE_STRREF_ITEM_IGNORED),
                                    STRING_COLOR_RED);
    else if (iKey == M_LSE_TEXT_ITEM_NOTIFY_PLOT)
        sResult = StringToRGBString(GetName(oObject) + " " +
                                        M_LSE_SIN_GetText(M_LSE_STRREF_DROPPED_ITEM_PLOT),
                                    STRING_COLOR_RED);
    else if (iKey == M_LSE_TEXT_ITEM_NOTIFY_SLOT)
        sResult = StringToRGBString(GetName(oObject) + " " +
                                        M_LSE_SIN_GetText(M_LSE_STRREF_DROPPED_ITEM_SLOT),
                                    STRING_COLOR_RED);
    else if (iKey == M_LSE_TEXT_GOLD_TAKEN)
        sResult = StringToRGBString(GetName(oObject) + " >> " +
                                        IntToString(iStackSize) + "x Gold",
                                    STRING_COLOR_GREEN);
    else if (iKey == M_LSE_TEXT_ITEM_LOOTED_FROM)
        sResult = StringToRGBString(M_LSE_SIN_GetText(M_LSE_STRREF_ITEM_LOOTED_FROM),
                                    STRING_COLOR_GREEN);
    else if (iKey == M_LSE_TEXT_ITEM_LOOTED_FROM_AREA)
        sResult = StringToRGBString(M_LSE_SIN_GetText(M_LSE_STRREF_ITEM_LOOTED_FROM_AREA),
                                    STRING_COLOR_GREEN);
    return sResult;
}

void M_LSE_SetConfigInt(string sOption, int nValue)
{
    object oModule = GetModule();
    RAV_SetLocalInt(oModule, sOption, nValue);
}

int M_LSE_GetConfigInt(string sOption)
{
    object oModule = GetModule();
    return RAV_GetLocalInt(oModule, sOption);
}

//::///////////////////////////////////////////////////////////////////////////
//:: LOOTABLE CORPSES  
//::///////////////////////////////////////////////////////////////////////////

int M_LSE_GetHasAnyItem(object oObject)
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

void M_LSE_TrySetIsDestroyable(object oCorpse)
{
    if (!GetIsObjectValid(oCorpse) || M_LSE_GetHasAnyItem(oCorpse))
        return;

    SetIsDestroyable(TRUE, TRUE, FALSE, oCorpse);
}

int M_LSE_GetIsLootableExcluded(object oObject)
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
        RAV_PrintVariableBool("M_LSE_GetIsLootableExcluded", TRUE, oObject);

    return sResult;
}

void M_LSE_SetLootable(object oCreature)
{
    if (!GetLootable(oCreature))
    {
        if (!M_LSE_GetIsLootableExcluded(oCreature) &&
            !M_LSE_GetIsLootableExcluded(GetArea(oCreature)))
        {        
            SetLootable(oCreature, TRUE);
            RAV_SetLocalInt(oCreature, M_LSE_LOCAL_MOD_LOOTABLE, TRUE);
        }
    }
}

void M_LSE_SetIsDestroyable(int bSelectableWhenDead = TRUE)
{
    if (GetLootable(OBJECT_SELF))
    {
        int bDestroyable = M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED);
        if (M_LSE_GetHasAnyItem(OBJECT_SELF))
        {
            bDestroyable = FALSE;
            bSelectableWhenDead = TRUE;
        }
        SetIsDestroyable(bDestroyable, M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_RAISEABLE), bSelectableWhenDead);

        if (!M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED))
        {
            if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_TIMED))
                DelayCommand(IntToFloat(M_LSE_GetConfigInt(M_LSE_LOCAL_PARAM_DELAY_CORPSE_DECAY)), M_LSE_TrySetIsDestroyable(OBJECT_SELF));
        }

        if (!M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED) 
         || !M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_RAISEABLE) 
         || bSelectableWhenDead)
            RAV_SetLocalInt(OBJECT_SELF, M_LSE_LOCAL_MOD_DESTROYABLE, TRUE);
    }
}

void M_LSE_DestroyCorpse(object oCorpse)
{
    if (!GetIsObjectValid(oCorpse) || M_LSE_GetHasAnyItem(oCorpse))
        return;

    RAV_PrintFunctionStrings("M_LSE_DestroyCorpse", oCorpse);

    AssignCommand(oCorpse, SetIsDestroyable(TRUE));
    DestroyObject(oCorpse);
}

void M_LSE_DestroyCorpses(object oModule, object oArea = OBJECT_INVALID)
{
    object oObject;
    if (GetIsObjectValid(oArea))
    {
        oObject = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oObject))
        {
            if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && GetIsDead(oObject) &&
                RAV_GetLocalInt(oObject, M_LSE_LOCAL_MOD_LOOTABLE) && RAV_GetLocalInt(oObject, M_LSE_LOCAL_MOD_DESTROYABLE))

            M_LSE_DestroyCorpse(oObject);
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
                    RAV_GetLocalInt(oObject, M_LSE_LOCAL_MOD_LOOTABLE) && RAV_GetLocalInt(oObject, M_LSE_LOCAL_MOD_DESTROYABLE))

                M_LSE_DestroyCorpse(oObject);
                oObject = GetNextObjectInArea(oArea);
            }
            oArea = GetNextArea();
        }
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: CORPSE AND TREASURE LOOTING
//::///////////////////////////////////////////////////////////////////////////

int M_LSE_GetIsItemLootingObligatory(object oItem)
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
        RAV_PrintVariableBool("M_LSE_GetIsItemLootingObligatory", FALSE, oItem);
        
    return bResult;
}

int M_LSE_GetIsLootingExcluded(object oObject)
{
    int bResult;
    string sTag = GetTag(oObject);

    bResult = RAV_GetLocalInt(oObject, M_LSE_LOCAL_NOLOOTING) ? TRUE
            : sTag == M_LSE_TAG_BELLY                         ? TRUE 
            :                                                 FALSE ;

    if (!bResult)
    {
        int nObjectType = GetObjectType(oObject);
        if (nObjectType == OBJECT_TYPE_ITEM)
        {
            object oItem = oObject;
            if (GetIdentified(oItem) && !GetPlotFlag(oItem))
            {
                if (!M_LSE_GetIsItemLootingObligatory(oItem))
                {
                    // Check item weight against configured threshold
                    float fItemWeight = IntToFloat(GetWeight(oItem)) / 10;
                    int nItemWeight = FloatToInt(fItemWeight); // Decimals of the weight will be truncated
                    RAV_PrintVariableInt("M_LSE_GetIsLootingExcluded->nItemWeight", nItemWeight, oItem);
                    int nConfigMaxItemWeight = M_LSE_GetConfigInt(M_LSE_LOCAL_PARAM_THRESHOLD_ITEM_WEIGHT);
                    if (nConfigMaxItemWeight > 0)
                    {
                        if (nItemWeight > nConfigMaxItemWeight)
                            bResult = TRUE;
                    }
                    if (!bResult)
                    {
                        // Check item gold value against configured threshold
                        int nItemValue = GetGoldPieceValue(oItem);
                        RAV_PrintVariableInt("M_LSE_GetIsLootingExcluded->nItemValue", nItemValue, oItem);
                        int nConfigMinItemValue = M_LSE_GetConfigInt(M_LSE_LOCAL_PARAM_THRESHOLD_ITEM_VALUE);
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
        RAV_PrintVariableBool("M_LSE_GetIsLootingExcluded", TRUE, oObject);
        
    return bResult;
}

void M_LSE_ConfirmItemTaken(object oItem, object oTakeFrom, object oGiveTo)
{
    if (GetItemPossessor(oItem) != oGiveTo)
        return;

    SetDroppableFlag(oItem, FALSE);
    RAV_SetLocalInt(oItem, M_LSE_LOCAL_OBJECT_LOOTED, TRUE);

    int nBaseItemInvSoundType = StringToInt(Get2DAString("baseitems", "InvSoundType", GetBaseItemType(oItem)));
    string nBaseItemInventorySound = Get2DAString("inventorysnds", "InventorySound", nBaseItemInvSoundType);
    PlaySound(nBaseItemInventorySound);
    FloatingTextStringOnCreature(M_LSE_GetText(M_LSE_TEXT_ITEM_TAKEN, oTakeFrom, GetItemStackSize(oItem), oItem), oGiveTo);
}

void M_LSE_ConfirmObjectLooted(object oObject)
{
    if (!M_LSE_GetHasAnyItem(oObject))
        RAV_SetLocalInt(oObject, M_LSE_LOCAL_OBJECT_LOOTED, TRUE);
}

int M_LSE_TakeItem(object oItem, object oTakeFrom, object oGiveTo, int bIfNotExcludedByConfig = TRUE)
{
    if (!bIfNotExcludedByConfig || !M_LSE_GetIsLootingExcluded(oItem))
    {
        ActionGiveItem(oItem, oGiveTo);
        ActionDoCommand(M_LSE_ConfirmItemTaken(oItem, oTakeFrom, oGiveTo));

        return TRUE;
    }
    else
    {
        FloatingTextStringOnCreature(M_LSE_GetText(M_LSE_TEXT_ITEM_IGNORED, oTakeFrom, GetItemStackSize(oItem), oItem), oGiveTo);

        return FALSE;
    }
}

void M_LSE_TakeGold(object oTakeFrom, object oGiveTo)
{
    int iGold = GetGold(oTakeFrom);
    if (iGold > 0)
    {
        TakeGoldFromCreature(iGold, oTakeFrom, TRUE);
        GiveGoldToCreature(oGiveTo, iGold);
        PlaySound(M_LSE_SOUND_TAKE_GOLD);
        FloatingTextStringOnCreature(M_LSE_GetText(M_LSE_TEXT_GOLD_TAKEN, oTakeFrom, iGold), oGiveTo);
    }
}

void M_LSE_LeaveItem(object oItem, object oTakeFrom, object oGiveTo)
{
    int iStackSize = GetItemStackSize(oItem);
    if (GetPlotFlag(oItem))
    {
        PlaySound(M_LSE_SOUND_LEAVE_PLOT);
        FloatingTextStringOnCreature(M_LSE_GetText(M_LSE_TEXT_ITEM_NOTIFY_PLOT, oTakeFrom, iStackSize, oItem), oGiveTo);
        AssignCommand(oGiveTo, ActionSpeakString(M_LSE_GetText(M_LSE_TEXT_ITEM_NOTIFY_PLOT, oTakeFrom, iStackSize, oItem)));
    }
    else
    {
        PlaySound(M_LSE_SOUND_LEAVE_ITEM);
        FloatingTextStringOnCreature(M_LSE_GetText(M_LSE_TEXT_ITEM_NOTIFY_SLOT, oTakeFrom, iStackSize, oItem), oGiveTo);
        AssignCommand(oGiveTo, ActionSpeakString(M_LSE_GetText(M_LSE_TEXT_ITEM_NOTIFY_SLOT, oTakeFrom, iStackSize, oItem)));
    }
}

int M_LSE_GetHasItem(object oObject)
{
    return M_LSE_GetHasAnyItem(oObject);
}

int M_LSE_GetHasDroppable(object oObject)
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

int M_LSE_TakeDroppables(object oTakeFrom, object oGiveTo)
{
    int bResult = TRUE;
    int bItemTaken;
    object oItem;

    if (!M_LSE_GetIsLootingExcluded(oTakeFrom))
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
                        bItemTaken = M_LSE_TakeItem(oItem, oTakeFrom, oGiveTo);
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
                bItemTaken = M_LSE_TakeItem(oItem, oTakeFrom, oGiveTo);
                if (!bItemTaken)
                    bResult = FALSE;
            }
            else if (!GetPlotFlag(oItem))
            {
                if (GetDroppableFlag(oItem))
                {
                    bItemTaken = M_LSE_TakeItem(oItem, oTakeFrom, oGiveTo);
                    if (!bItemTaken)
                        bResult = FALSE;
                }
            }
            else
            {
                if (GetDroppableFlag(oItem))
                {
                    bItemTaken = M_LSE_TakeItem(oItem, oTakeFrom, oGiveTo);
                    if (!bItemTaken)
                        bResult = FALSE;
                }
            }
            oItem = GetNextItemInInventory(oTakeFrom);
        }

        if (GetObjectType(oTakeFrom) == OBJECT_TYPE_CREATURE)
            M_LSE_TakeGold(oTakeFrom, oGiveTo);

        ActionDoCommand(M_LSE_ConfirmObjectLooted(oTakeFrom));
    }
    return bResult;
}

//::///////////////////////////////////////////////////////////////////////////
//:: TREASURE SCANNING
//::///////////////////////////////////////////////////////////////////////////

int M_LSE_GetHasLootableItem(object oObject)
{
    int bResult = FALSE;
    if (!M_LSE_GetIsLootingExcluded(oObject))
    {
        object oItem = GetFirstItemInInventory(oObject);
        while (RAV_IsItemValid(oItem, GetItemStackSize(oItem)) && bResult == FALSE)
        {
            if (!M_LSE_GetIsLootingExcluded(oItem))
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

int M_LSE_GetHasLoot(object oObject)
{
    int bResult; 
    
    if (GetUseableFlag(oObject) && GetHasInventory(oObject)) 
    {
        if (GetTag(oObject) == M_LSE_TAG_BODYBAG)
        { 
            if  (!RAV_GetLocalInt(oObject, M_LSE_LOCAL_OBJECT_LOOTED)
            &&  M_LSE_GetHasLootableItem(oObject))
                bResult = TRUE;
        }
        else if (!RAV_GetLocalInt(oObject, M_LSE_LOCAL_CONTAINER_EXAMINED) 
        ||      M_LSE_GetHasLootableItem(oObject))
            bResult = TRUE;
    }
    
    if (bResult)
        RAV_PrintVariableBool("M_LSE_GetHasLoot", TRUE, oObject);

    return bResult;
}

int M_LSE_GetHasTreasure(object oArea)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetTag(oObject) != M_LSE_TAG_IPBOX)
        {
            if (M_LSE_GetHasLoot(oObject))
                return TRUE;
        }
        oObject = GetNextObjectInArea(oArea);
    }
    return FALSE;
}

void M_LSE_NotifyTreasure(object oPC, object oArea, int bNotifyPositive = TRUE)
{
    if (GetIsObjectValid(oPC) && GetIsObjectValid(oArea))
    {
        string sAreaUUID = GetObjectUUID(oArea);
        RAV_SetLocalString(oPC, M_LSE_LOCAL_AREA_SCANNED_LAST, sAreaUUID);

        if (M_LSE_GetHasTreasure(oArea))
        {
            if (bNotifyPositive)
                AssignCommand(oPC, SpeakString(StringToRGBString(M_LSE_SIN_GetText(M_LSE_STRREF_TREASURE_FOUND), STRING_COLOR_WHITE)));
        }
        else
        {
            AssignCommand(oPC, SpeakString(StringToRGBString(M_LSE_SIN_GetText(M_LSE_STRREF_TREASURE_NOT_FOUND), STRING_COLOR_WHITE)));
        }
    }
}

void M_LSE_ScanTreasure(object oPC, object oArea)
{
    string sAreaUUID = GetObjectUUID(oArea);
    if (sAreaUUID != STRING_EMPTY && RAV_GetLocalString(oPC, M_LSE_LOCAL_AREA_SCANNED_LAST) != sAreaUUID)
        DelayCommand(M_LSE_DELAY_TREASURE_NOTIFY, M_LSE_NotifyTreasure(oPC, oArea));
}

//::///////////////////////////////////////////////////////////////////////////
//:: TREASURE TRACKING
//::///////////////////////////////////////////////////////////////////////////

void M_LSE_SetIsUntracked(object oPlaceable, int bValue)
{
    RAV_SetLocalInt(oPlaceable, M_LSE_LOCAL_CONTAINER_UNTRACKED, bValue);
}

void M_LSE_SetIsUntrackedIfEmpty(object oPlaceable)
{
    if (!GetIsObjectValid(GetFirstItemInInventory(oPlaceable)))
        M_LSE_SetIsUntracked(oPlaceable, TRUE);
}

int M_LSE_GetIsUntracked(object oPlaceable)
{
    int bResult;
    string oTag = GetTag(oPlaceable);

    bResult = RAV_GetLocalInt(oPlaceable, M_LSE_LOCAL_CONTAINER_UNTRACKED)                                    ? TRUE

            : oTag == M_LSE_TAG_BODYBAG                                                                       ? TRUE
            : oTag == M_LSE_TAG_IPBOX                                                                         ? TRUE

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

    RAV_PrintVariableBool("M_LSE_GetIsUntracked", bResult, oPlaceable);

    return bResult;
}

void M_LSE_SetUnuseable(object oPlaceable)
{
    SetUseableFlag(oPlaceable, FALSE);
    RAV_SetLocalInt(oPlaceable, M_LSE_LOCAL_MOD_USEABLE, TRUE);
}

void M_LSE_TrackTreasure(object oPlaceable, object oPC)
{
    if (!M_LSE_GetHasAnyItem(oPlaceable) && !M_LSE_GetHasLoot(oPlaceable))
    {
        if (!M_LSE_GetIsUntracked(oPlaceable))
            M_LSE_SetUnuseable(oPlaceable);
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: ITEM DESCRIPTION ACQUIRED FROM
//::///////////////////////////////////////////////////////////////////////////

string M_LSE_GetDescriptionExcludingAcquiredFromText(string sDescription)
{
    int nAdditionLength;
    int nStartTagOffset = FindSubString(sDescription, M_LSE_STRING_TAG_DESCRIPTION_START_RGB);
    if (nStartTagOffset >= 0)
    {
        int nEndTagOffset = FindSubString(sDescription, M_LSE_STRING_TAG_DESCRIPTION_END_RGB, nStartTagOffset+M_LSE_STRING_TAG_DESCRIPTION_START_RGB_LENGTH);
        if (nEndTagOffset >= 0)
            nAdditionLength = nStartTagOffset + nEndTagOffset + M_LSE_STRING_TAG_DESCRIPTION_END_RGB_LENGTH;
    }
    if (nAdditionLength > 0)
        return GetSubString(sDescription, 0, nStartTagOffset - 1);  // -1 to exclude line breaks
    else
        return sDescription;
}

string M_LSE_TagAcquiredFromText(string sText)
{
    return M_LSE_STRING_TAG_DESCRIPTION_START_RGB + "\n" + sText + "\n" + M_LSE_STRING_TAG_DESCRIPTION_END_RGB;
}

string M_LSE_GetAcquiredFromText(string sFrom, string sArea)
{
    return M_LSE_GetText(M_LSE_TEXT_ITEM_LOOTED_FROM) + sFrom + "\n" + M_LSE_GetText(M_LSE_TEXT_ITEM_LOOTED_FROM_AREA) + sArea;
}

void M_LSE_AddAcquiredFromToDescription(object oItem)
{
    string sAcquiredFrom = RAV_GetLocalString(oItem, M_LSE_LOCAL_ITEM_ACQUIRED_FROM_NAME);
    string sAcquiredFromArea = RAV_GetLocalString(oItem, M_LSE_LOCAL_ITEM_ACQUIRED_FROM_AREA_NAME);
    if (sAcquiredFrom != STRING_EMPTY)
    {
        string sAcquiredFromText = M_LSE_GetAcquiredFromText(sAcquiredFrom, sAcquiredFromArea);
        
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
        if (RAV_GetLocalInt(oItem, M_LSE_LOCAL_MOD_DESCRIPTION))
            sDescriptionIdentified = M_LSE_GetDescriptionExcludingAcquiredFromText(sDescriptionIdentified);
        SetDescription(oItem, sDescriptionIdentified + "\n" + M_LSE_TagAcquiredFromText(sAcquiredFromText), TRUE);
        if (RAV_GetLocalInt(oItem, M_LSE_LOCAL_MOD_DESCRIPTION))
            sDescriptionUnidentified = M_LSE_GetDescriptionExcludingAcquiredFromText(sDescriptionUnidentified);
        SetDescription(oItem, sDescriptionUnidentified + "\n" + M_LSE_TagAcquiredFromText(sAcquiredFromText), FALSE);

        RAV_SetLocalInt(oItem, M_LSE_LOCAL_MOD_DESCRIPTION, TRUE);
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: MAINTENANCE
//::///////////////////////////////////////////////////////////////////////////

void M_LSE_MAINTENANCE_SetDefaultConfig(object oModule)
{
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_TREASURE_SCANNING, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_TREASURE_TRACKING, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_TREASURE_LOOTING, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTABLE, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_LOOTED, FALSE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_DECAYING_TIMED, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_RAISEABLE, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_EXAMINED, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_FEATURE_ITEM_DESCRIPTION_ACQUIRED, TRUE);
    M_LSE_SetConfigInt(M_LSE_LOCAL_PARAM_DELAY_CORPSE_DECAY, 600);  // 10 minutes decay time by default
    M_LSE_SetConfigInt(M_LSE_LOCAL_PARAM_THRESHOLD_ITEM_VALUE, 8);  // Exclude basic base game books by defaults
    M_LSE_SetConfigInt(M_LSE_LOCAL_PARAM_THRESHOLD_ITEM_WEIGHT, 9); // Exclude heavier armor/weapon items by default
}

void M_LSE_MAINTENANCE_Build(object oModule, object oPC, string sNewBuild, string sOldBuild = STRING_EMPTY)
{
    // Perform maintenance actions needed to adjust the module to a new version of M_LSE
    RAV_PrintFunctionStrings("M_LSE_MAINTENANCE_Build", oModule, sNewBuild, sOldBuild);

    // Initialize default config after first install or update from initial release build
    if (sOldBuild == STRING_EMPTY || sOldBuild == "1001")
        M_LSE_MAINTENANCE_SetDefaultConfig(oModule);
    
    // SIN: Clear text index buffers to apply changed strings
    M_LSE_SIN_ClearBuffer();

    if (sOldBuild == STRING_EMPTY)
        DelayCommand(8.0f, AssignCommand(oPC, ActionSpeakString(StringToRGBString(M_LSE_SIN_GetText(M_LSE_STRREF_MAINTENANCE_INSTALL) + " " + 
                                                                                  M_LSE_VERSION + " (Build " + sNewBuild + ")",
                                                                                  STRING_COLOR_GREEN))));
    else
        DelayCommand(8.0f, AssignCommand(oPC, ActionSpeakString(StringToRGBString(M_LSE_SIN_GetText(M_LSE_STRREF_MAINTENANCE_UPDATE) + " " + 
                                                                                  M_LSE_VERSION + " (Build " + sNewBuild + ")",
                                                                                  STRING_COLOR_GREEN))));

    RAV_SetLocalString(oModule, M_LSE_LOCAL_VERSION_BUILD, sNewBuild);
}

//::///////////////////////////////////////////////////////////////////////////
//:: INITIALIZATION
//::///////////////////////////////////////////////////////////////////////////

void M_LSE_InjectEventScripts(object oModule)
{
    if (RAV_GetLocalString(oModule, M_LSE_LOCAL_EVENTS_BUILD) == M_LSE_VERSION_BUILD)
        return;
    ESI_InjectToObject(oModule, M_LSE_INJECT_KEY_MODULE_ACQUIRED_ITEM, EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM, M_LSE_SCRIPT_EVENT_MODULE_ACQUIRED_ITEM, ESI_INJECTION_PLACEMENT_LAST);
    ESI_InjectToModuleObjects(oModule, M_LSE_INJECT_KEY_AREA_ENTER, ESI_OBJECT_TYPE_AREA, EVENT_SCRIPT_AREA_ON_ENTER, M_LSE_SCRIPT_EVENT_AREA_ENTER, ESI_INJECTION_PLACEMENT_LAST);
    RAV_SetLocalString(oModule, M_LSE_LOCAL_EVENTS_BUILD, M_LSE_VERSION_BUILD);
}

void M_LSE_InjectAreaObjects(object oArea)
{
    if (!GetIsObjectValid(oArea) || RAV_GetLocalString(oArea, M_LSE_LOCAL_AREA_EVENTS_BUILD) == M_LSE_VERSION_BUILD)
        return;
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        int nObjectType = GetObjectType(oObject);
        if (nObjectType == OBJECT_TYPE_CREATURE && !GetIsPC(oObject))
        {
            ESI_InjectToObject(oObject, M_LSE_INJECT_KEY_CREATURE_DEATH, EVENT_SCRIPT_CREATURE_ON_DEATH, M_LSE_SCRIPT_EVENT_CREATURE_DEATH, ESI_INJECTION_PLACEMENT_LAST);
        }
        else if (nObjectType == OBJECT_TYPE_PLACEABLE)
        {
            ESI_InjectToObject(oObject, M_LSE_INJECT_KEY_PLACEABLE_OPEN, EVENT_SCRIPT_PLACEABLE_ON_OPEN, M_LSE_SCRIPT_EVENT_PLACEABLE_OPEN, ESI_INJECTION_PLACEMENT_LAST);
            ESI_InjectToObject(oObject, M_LSE_INJECT_KEY_PLACEABLE_CLOSE, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, M_LSE_SCRIPT_EVENT_PLACEABLE_CLOSE, ESI_INJECTION_PLACEMENT_FIRST);
            ESI_InjectToObject(oObject, M_LSE_INJECT_KEY_PLACEABLE_UNLOCK, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, M_LSE_SCRIPT_EVENT_PLACEABLE_UNLOCK, ESI_INJECTION_PLACEMENT_LAST);
        }
        oObject = GetNextObjectInArea(oArea);
    }
    RAV_SetLocalString(oArea, M_LSE_LOCAL_AREA_EVENTS_BUILD, M_LSE_VERSION_BUILD);
}

int M_LSE_IsObjectInitialized(object oObject)
{
    return RAV_GetLocalInt(oObject, M_LSE_LOCAL_INITIALIZED);
}

void M_LSE_Initialize(object oModule, object oPC)
{
    string sVersionBuild = RAV_GetLocalString(oModule, M_LSE_LOCAL_VERSION_BUILD);
    RAV_PrintVariableString("M_LSE_LOCAL_VERSION_BUILD", sVersionBuild, oModule);
    RAV_PrintVariableString("M_LSE_VERSION_BUILD", M_LSE_VERSION_BUILD, oModule);
    if (StringToInt(sVersionBuild) != StringToInt(M_LSE_VERSION_BUILD))
        M_LSE_MAINTENANCE_Build(oModule, oPC, M_LSE_VERSION_BUILD, sVersionBuild);

    if (M_LSE_SIN_GetIndex() != M_LSE_TEXT_INDEX)
        M_LSE_SIN_SetIndex(M_LSE_TEXT_INDEX);
    if (M_LSE_SIN_GetLanguage() != "de" && M_LSE_SIN_GetLanguage() != "en")
        M_LSE_SIN_SetLanguage("en");

    M_LSE_InjectEventScripts(oModule);
    object oArea = GetArea(oPC);
    string sAreaUUID = GetObjectUUID(oArea);
    if (RAV_GetLocalString(oPC, M_LSE_LOCAL_AREA_VISITED_LAST) != sAreaUUID)
    {
        RAV_SetLocalString(oPC, M_LSE_LOCAL_AREA_VISITED_LAST, sAreaUUID);
        // Manually execute area scripts for startup area
        DelayCommand(6.0f, ESI_ExecuteEventScripts(oArea, EVENT_SCRIPT_AREA_ON_ENTER));
    }
}

void M_LSE_InitializeCreature(object oCreature)
{
    if (!M_LSE_IsObjectInitialized(oCreature))
    {
        RAV_SetLocalInt(oCreature, M_LSE_LOCAL_INITIALIZED, TRUE);

        // Should have been already done for "static" creatures in areas OnEnter. This is to apply injection also for creatures created by script or encounter
        ESI_InjectToObject(oCreature, M_LSE_INJECT_KEY_CREATURE_DEATH, EVENT_SCRIPT_CREATURE_ON_DEATH, M_LSE_SCRIPT_EVENT_CREATURE_DEATH, ESI_INJECTION_PLACEMENT_LAST);

        if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTABLE))
            M_LSE_SetLootable(oCreature);
    }
}

void M_LSE_InitializeCorpse(object oCorpse)
{
    // Iterate all body bags near the corpse (within whole area to be exact) to inject OnClose event
    int nNext = 1;
    object oBodyBag = GetNearestObjectByTag(M_LSE_TAG_BODYBAG, oCorpse, nNext);
    while (GetIsObjectValid(oBodyBag))
    {
        ESI_InjectToObject(oBodyBag, M_LSE_INJECT_KEY_PLACEABLE_CLOSE, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, M_LSE_SCRIPT_EVENT_PLACEABLE_CLOSE, ESI_INJECTION_PLACEMENT_FIRST);
        nNext++;
        oBodyBag = GetNearestObjectByTag(M_LSE_TAG_BODYBAG, oCorpse, nNext);
    }
}

//::///////////////////////////////////////////////////////////////////////////
//:: EVENT HANDLING
//::///////////////////////////////////////////////////////////////////////////

void M_LSE_OnHeartbeat(object oObject)
{
    if (GetIsPC(oObject))
    {
        object oPC = oObject;
        object oArea = GetArea(oPC);
        object oModule = GetModule();

        M_LSE_Initialize(oModule, oPC);

        if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_TREASURE_SCANNING))
            M_LSE_ScanTreasure(oPC, oArea);
    }
    else if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
    {
        M_LSE_InitializeCreature(oObject);
    }
}

void M_LSE_OnPhysicalAttacked(object oObject, object oAttacker, object oWeaponUsed, int iAttackType, int iAttackMode)
{
    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
        M_LSE_InitializeCreature(oObject);
}

void M_LSE_OnSpellCastAt(object oObject, int bSpellHarmful, object oSpellCaster, int iSpell)
{
    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE)
        M_LSE_InitializeCreature(oObject);
}

void M_LSE_OnDeath(object oObject, object oKiller)
{
    int bLootedAll;

    if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED) && GetIsPC(oKiller))
    {
        bLootedAll = M_LSE_TakeDroppables(oObject, oKiller);
    }
    else if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_KILLED_BY_HENCH))
    {
        object oMaster = GetMaster(oKiller);
        object oSuperMaster = GetMaster(oMaster);
        if (GetIsPC(oMaster))
            bLootedAll = M_LSE_TakeDroppables(oObject, oMaster);
        else if (GetIsPC(oSuperMaster))
            bLootedAll = M_LSE_TakeDroppables(oObject, oSuperMaster);
    }

    int bSelectable;
    if (bLootedAll) 
        bSelectable = FALSE;
    else            
        bSelectable = TRUE;
    M_LSE_SetIsDestroyable(bSelectable);
    ActionDoCommand(M_LSE_SetIsDestroyable(bSelectable));

    if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_CORPSE_LOOTING_EXAMINED))
        DelayCommand(M_LSE_DELAY_CORPSE_INITIALIZE, M_LSE_InitializeCorpse(oObject));
}

void M_LSE_OnAcquiredItem(object oModule, object oItem, object oBy, object oFrom, int nStackSize)
{
    if (GetIsObjectValid(oItem))    // Could be invalid in case of gold
    {
        if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_ITEM_DESCRIPTION_ACQUIRED))
        {
            if (GetIsObjectValid(oFrom) && GetIsPC(oBy) && !M_LSE_GetIsUntracked(oFrom))
            {
                RAV_SetLocalString(oItem, M_LSE_LOCAL_ITEM_ACQUIRED_FROM_UUID, GetObjectUUID(oFrom));
                RAV_SetLocalString(oItem, M_LSE_LOCAL_ITEM_ACQUIRED_FROM_RESREF, GetResRef(oFrom));
                RAV_SetLocalString(oItem, M_LSE_LOCAL_ITEM_ACQUIRED_FROM_NAME, GetName(oFrom, FALSE));
                RAV_SetLocalString(oItem, M_LSE_LOCAL_ITEM_ACQUIRED_FROM_AREA_NAME, GetName(GetArea(oFrom)));
                M_LSE_AddAcquiredFromToDescription(oItem);
            }
        }
    }
}

void M_LSE_OnClose(object oObject, object oBy)
{
    if (GetHasInventory(oObject) && GetIsPC(oBy))
    {
        if (!RAV_GetLocalInt(oObject, M_LSE_LOCAL_CONTAINER_EXAMINED))
        {
            int bLootedAll;
            RAV_SetLocalInt(oObject, M_LSE_LOCAL_CONTAINER_EXAMINED, TRUE);
            if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_TREASURE_LOOTING))
                bLootedAll = M_LSE_TakeDroppables(oObject, oBy);
            if (bLootedAll)
            {
                if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_TREASURE_TRACKING))
                    DelayCommand(M_LSE_DELAY_TREASURE_TRACK, M_LSE_TrackTreasure(oObject, oBy));
            }
            if (M_LSE_GetConfigInt(M_LSE_LOCAL_FEATURE_TREASURE_SCANNING))
                DelayCommand(M_LSE_DELAY_TREASURE_NOTIFY, M_LSE_NotifyTreasure(oBy, GetArea(oBy), FALSE));
        }
    }
}

void M_LSE_OnOpen(object oObject, object oBy)
{
    if (GetHasInventory(oObject) && GetIsPC(oBy))
    {
        M_LSE_SetIsUntrackedIfEmpty(oObject);
    }
}

void M_LSE_OnEnter(object oObject, object oEntering)
{
    if (GetIsPC(oEntering) && oObject == GetArea(oEntering))
        M_LSE_InjectAreaObjects(oObject);
}

void M_LSE_OnUnlock(object oPlaceable, object oBy)
{
    if (GetHasInventory(oPlaceable) && GetIsPC(oBy))
        AssignCommand(oBy, ActionInteractObject(oPlaceable));
}
