// Transactional extraction, targeting, item use, and cleanup.

#include "meio_index"

void MEIO_ReleaseSuppression(object oPC, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_GENERATION) == iGeneration)
    {
        DeleteLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT);
        MEIO_Debug(oPC, "Suppression released generation=" + IntToString(iGeneration));
    }
    else
    {
        MEIO_Debug(oPC, "Suppression release skipped staleGeneration=" + IntToString(iGeneration) + " currentGeneration=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_GENERATION)));
    }
}

void MEIO_BeginSuppression(object oPC)
{
    int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_GENERATION) + 1;
    SetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_GENERATION, iGeneration);
    SetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_SORT, TRUE);
    MEIO_Debug(oPC, "Suppression enabled generation=" + IntToString(iGeneration));
}

void MEIO_ScheduleSuppressionRelease(object oPC)
{
    int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_SUPPRESS_GENERATION);
    MEIO_Debug(oPC, "Suppression release scheduled delay=2.0 generation=" + IntToString(iGeneration));
    DelayCommand(2.0f, MEIO_ReleaseSuppression(oPC, iGeneration));
}

void MEIO_ClearReservation(object oPC)
{
    MEIO_Debug(oPC, "Reservation clearing reserved=" + ObjectToString(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)) + " issued=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED)));
    DeleteLocalObject(oPC, MEIO_LOCAL_RESERVED);
    DeleteLocalString(oPC, MEIO_LOCAL_RESERVED_KEY);
    DeleteLocalString(oPC, MEIO_LOCAL_RESERVED_TAG);
    DeleteLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED);
    MEIO_ScheduleSuppressionRelease(oPC);
}

void MEIO_ReturnReservation(object oPC)
{
    object oReserved = GetLocalObject(oPC, MEIO_LOCAL_RESERVED);
    MEIO_Debug(oPC, "Reservation return entered " + MEIO_DebugItemState(oPC, oReserved));
    if (!GetIsObjectValid(oReserved))
    {
        MEIO_Debug(oPC, "Reservation return decision=clear reason=reserved-invalid");
        MEIO_ClearReservation(oPC);
        return;
    }
    if (!MEIO_IsDirectlyIn(oReserved, oPC))
    {
        MEIO_Debug(oPC, "Reservation return decision=clear reason=not-in-player-inventory " + MEIO_DebugItemState(oPC, oReserved));
        MEIO_ClearReservation(oPC);
        return;
    }
    MEIO_NormalizeExtractedTag(oReserved);
    DeleteLocalInt(oReserved, MEIO_LOCAL_KEEP_OUT);
    MEIO_Debug(oPC, "Reservation return decision=explicit-store " + MEIO_DebugItemState(oPC, oReserved));
    int iMoved = MEIO_StoreAmountExplicit(oPC, oReserved, 1);
    MEIO_Debug(oPC, "Reservation return store-finished moved=" + IntToString(iMoved) + " " + MEIO_DebugItemState(oPC, oReserved));
    MEIO_ClearReservation(oPC);
}

void MEIO_CleanupReservation(object oPC, int iGeneration)
{
    if (GetLocalInt(oPC, MEIO_LOCAL_CLEANUP_GENERATION) != iGeneration)
    {
        return;
    }
    MEIO_ReturnReservation(oPC);
}

void MEIO_CopyRuntimeFlags(object oSource, object oCopy)
{
    SetIdentified(oCopy, GetIdentified(oSource));
    SetPlotFlag(oCopy, GetPlotFlag(oSource));
    SetItemCursedFlag(oCopy, GetItemCursedFlag(oSource));
    SetDroppableFlag(oCopy, GetDroppableFlag(oSource));
    SetStolenFlag(oCopy, GetStolenFlag(oSource));
    SetPickpocketableFlag(oCopy, GetPickpocketableFlag(oSource));
    SetInfiniteFlag(oCopy, GetInfiniteFlag(oSource));
}

object MEIO_ExtractStoredItem(object oPC, object oStorage, object oSource, int iBaseItem)
{
    MEIO_Debug(oPC, "ExtractOne entered storage=" + ObjectToString(oStorage) + " " + MEIO_DebugItemState(oPC, oSource));
    if (!MEIO_IsInScriptorium(oStorage, oSource) || !GetBaseItemFitsInInventory(iBaseItem, oPC))
    {
        MEIO_Debug(oPC, "ExtractOne decision=fail inStorage=" + IntToString(MEIO_IsInScriptorium(oStorage, oSource)) + " fits=" + IntToString(GetBaseItemFitsInInventory(iBaseItem, oPC)));
        return OBJECT_INVALID;
    }
    int iSourceSize = GetItemStackSize(oSource);
    string sTag = GetTag(oSource);
    string sReservedTag = "MEIO_CAST_" + ObjectToString(oSource);
    DeleteLocalObject(oPC, MEIO_LOCAL_RESERVED);
    DeleteLocalString(oPC, MEIO_LOCAL_RESERVED_KEY);
    DeleteLocalString(oPC, MEIO_LOCAL_RESERVED_TAG);
    DeleteLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED);
    MEIO_BeginSuppression(oPC);
    SetLocalString(oSource, MEIO_LOCAL_ORIGINAL_TAG, sTag);
    SetLocalInt(oSource, MEIO_LOCAL_HAS_ORIGINAL_TAG, TRUE);
    SetTag(oSource, sReservedTag);
    SetLocalInt(oSource, MEIO_LOCAL_KEEP_OUT, TRUE);
    MEIO_Debug(oPC, "ExtractOne source-prepared-before-copy reservedTag=\"" + sReservedTag + "\" " + MEIO_DebugItemState(oPC, oSource));
    if (iSourceSize > 1)
    {
        SetItemStackSize(oSource, 1);
    }
    object oReserved = CopyItem(oSource, oPC, TRUE);
    MEIO_Debug(oPC, "ExtractOne CopyItem returned " + MEIO_DebugItemState(oPC, oReserved));
    if (iSourceSize > 1)
    {
        SetItemStackSize(oSource, iSourceSize);
    }
    SetTag(oSource, sTag);
    DeleteLocalInt(oSource, MEIO_LOCAL_KEEP_OUT);
    DeleteLocalString(oSource, MEIO_LOCAL_ORIGINAL_TAG);
    DeleteLocalInt(oSource, MEIO_LOCAL_HAS_ORIGINAL_TAG);
    if (!MEIO_IsDirectlyIn(oReserved, oPC))
    {
        MEIO_Debug(oPC, "ExtractOne decision=fail reason=copy-not-in-player-inventory " + MEIO_DebugItemState(oPC, oReserved));
        if (GetIsObjectValid(oReserved))
        {
            DestroyObject(oReserved);
        }
        MEIO_ScheduleSuppressionRelease(oPC);
        return OBJECT_INVALID;
    }
    SetTag(oReserved, sReservedTag);
    MEIO_MarkKeepOut(oPC, oReserved);
    MEIO_Debug(oPC, "ExtractOne copy-tagged-and-registered " + MEIO_DebugItemState(oPC, oReserved));
    MEIO_CopyRuntimeFlags(oSource, oReserved);
    if (iSourceSize == 1)
    {
        DestroyObject(oSource);
    }
    else
    {
        SetItemStackSize(oSource, iSourceSize - 1);
    }
    SetLocalObject(oPC, MEIO_LOCAL_RESERVED, oReserved);
    SetLocalString(oPC, MEIO_LOCAL_RESERVED_TAG, sTag);
    MEIO_Debug(oPC, "ExtractOne completed reserved=" + ObjectToString(oReserved) + " originalTag=\"" + sTag + "\" " + MEIO_DebugItemState(oPC, oReserved));
    MEIO_ScheduleStorageSave(oPC);
    return oReserved;
}

object MEIO_ExtractOne(object oPC, object oStorage, object oSource)
{
    return MEIO_ExtractStoredItem(oPC, oStorage, oSource, BASE_ITEM_SPELLSCROLL);
}

object MEIO_ExtractPotionOne(object oPC, object oStorage, object oSource)
{
    return MEIO_ExtractStoredItem(oPC, oStorage, oSource, BASE_ITEM_POTIONS);
}

int MEIO_WithdrawOne(object oPC, json jSelected)
{
    MEIO_Debug(oPC, "WithdrawOne entered selection=" + JsonDump(jSelected));
    if (GetIsObjectValid(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)))
    {
        MEIO_Debug(oPC, "WithdrawOne decision=fail reason=reservation-already-active reserved=" + ObjectToString(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)));
        return FALSE;
    }
    object oStorage = MEIO_EnsureStorage(oPC);
    string sKey = JsonGetString(JsonObjectGet(jSelected, "key"));
    int iSubtype = JsonGetInt(JsonObjectGet(jSelected, "subtype"));
    object oSource = MEIO_ResolveScroll(oStorage, sKey, iSubtype);
    if (!GetIsObjectValid(oSource))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "stale_entry"));
        return FALSE;
    }
    if (!GetBaseItemFitsInInventory(BASE_ITEM_SPELLSCROLL, oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "no_space"));
        return FALSE;
    }
    object oWithdrawn = MEIO_ExtractOne(oPC, oStorage, oSource);
    if (!GetIsObjectValid(oWithdrawn))
    {
        MEIO_Debug(oPC, "WithdrawOne decision=fail reason=extraction-failed");
        return FALSE;
    }
    MEIO_ClearReservation(oPC);
    MEIO_Debug(oPC, "WithdrawOne completed and left item in inventory " + MEIO_DebugItemState(oPC, oWithdrawn));
    SendMessageToPC(oPC, MEIO_GetText(oPC, "withdrawn"));
    return TRUE;
}

int MEIO_WithdrawPotionOne(object oPC, json jSelected)
{
    MEIO_Debug(oPC, "WithdrawPotionOne entered selection=" + JsonDump(jSelected));
    if (GetIsObjectValid(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)))
    {
        return FALSE;
    }
    object oStorage = MEIO_EnsurePotionStorage(oPC);
    string sKey = JsonGetString(JsonObjectGet(jSelected, "key"));
    int iSubtype = JsonGetInt(JsonObjectGet(jSelected, "subtype"));
    object oSource = MEIO_ResolvePotion(oStorage, sKey, iSubtype);
    if (!GetIsObjectValid(oSource))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "stale_entry"));
        return FALSE;
    }
    if (!GetBaseItemFitsInInventory(BASE_ITEM_POTIONS, oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "no_space"));
        return FALSE;
    }
    object oWithdrawn = MEIO_ExtractPotionOne(oPC, oStorage, oSource);
    if (!GetIsObjectValid(oWithdrawn))
    {
        return FALSE;
    }
    MEIO_ClearReservation(oPC);
    SendMessageToPC(oPC, MEIO_GetText(oPC, "potion_withdrawn"));
    return TRUE;
}

float MEIO_GetRange(int iSpell)
{
    string sRange = Get2DAString("spells", "Range", iSpell);
    if (sRange == "P")
    {
        return 0.1f;
    }
    if (sRange == "T")
    {
        return 2.5f;
    }
    if (sRange == "S")
    {
        return 8.0f;
    }
    if (sRange == "M")
    {
        return 20.0f;
    }
    return 40.0f;
}

int MEIO_GetTargetShape(int iSpell)
{
    string sShape = Get2DAString("spells", "TargetShape", iSpell);
    if (sShape == "S" || sShape == "Sphere")
    {
        return SPELL_TARGETING_SHAPE_SPHERE;
    }
    if (sShape == "R" || sShape == "Rect")
    {
        return SPELL_TARGETING_SHAPE_RECT;
    }
    if (sShape == "C" || sShape == "Cone")
    {
        return SPELL_TARGETING_SHAPE_CONE;
    }
    if (sShape == "H" || sShape == "HSphere")
    {
        return SPELL_TARGETING_SHAPE_HSPHERE;
    }
    int iShape = StringToInt(sShape);
    return iShape >= SPELL_TARGETING_SHAPE_NONE && iShape <= SPELL_TARGETING_SHAPE_HSPHERE ? iShape : SPELL_TARGETING_SHAPE_NONE;
}

void MEIO_IssueUseOnObject(object oPC, object oTarget)
{
    object oReserved = GetLocalObject(oPC, MEIO_LOCAL_RESERVED);
    int iSubtype = StringToInt(GetLocalString(oPC, MEIO_LOCAL_RESERVED_KEY));
    itemproperty ip = MEIO_FindCastProperty(oReserved, iSubtype);
    if (!MEIO_IsDirectlyIn(oReserved, oPC) || !GetIsItemPropertyValid(ip))
    {
        MEIO_Debug(oPC, "IssueUseOnObject decision=return-reservation validProperty=" + IntToString(GetIsItemPropertyValid(ip)) + " target=" + ObjectToString(oTarget) + " " + MEIO_DebugItemState(oPC, oReserved));
        MEIO_ReturnReservation(oPC);
        return;
    }
    SetLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED, TRUE);
    MEIO_Debug(oPC, "IssueUseOnObject decision=queue-use subtype=" + IntToString(iSubtype) + " target=" + ObjectToString(oTarget) + " " + MEIO_DebugItemState(oPC, oReserved));
    AssignCommand(oPC, ActionUseItemOnObject(oReserved, ip, oTarget, 0, TRUE));
    int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_CLEANUP_GENERATION) + 1;
    SetLocalInt(oPC, MEIO_LOCAL_CLEANUP_GENERATION, iGeneration);
    DelayCommand(30.0f, MEIO_CleanupReservation(oPC, iGeneration));
}

void MEIO_IssueUseAtLocation(object oPC, location lTarget)
{
    object oReserved = GetLocalObject(oPC, MEIO_LOCAL_RESERVED);
    int iSubtype = StringToInt(GetLocalString(oPC, MEIO_LOCAL_RESERVED_KEY));
    itemproperty ip = MEIO_FindCastProperty(oReserved, iSubtype);
    if (!MEIO_IsDirectlyIn(oReserved, oPC) || !GetIsItemPropertyValid(ip))
    {
        MEIO_Debug(oPC, "IssueUseAtLocation decision=return-reservation validProperty=" + IntToString(GetIsItemPropertyValid(ip)) + " " + MEIO_DebugItemState(oPC, oReserved));
        MEIO_ReturnReservation(oPC);
        return;
    }
    SetLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED, TRUE);
    MEIO_Debug(oPC, "IssueUseAtLocation decision=queue-use subtype=" + IntToString(iSubtype) + " " + MEIO_DebugItemState(oPC, oReserved));
    AssignCommand(oPC, ActionUseItemAtLocation(oReserved, ip, lTarget, 0, TRUE));
    int iGeneration = GetLocalInt(oPC, MEIO_LOCAL_CLEANUP_GENERATION) + 1;
    SetLocalInt(oPC, MEIO_LOCAL_CLEANUP_GENERATION, iGeneration);
    DelayCommand(30.0f, MEIO_CleanupReservation(oPC, iGeneration));
}

int MEIO_BeginCast(object oPC, json jSelected)
{
    MEIO_Debug(oPC, "BeginCast entered selection=" + JsonDump(jSelected));
    if (GetIsObjectValid(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)))
    {
        MEIO_Debug(oPC, "BeginCast decision=fail reason=reservation-already-active reserved=" + ObjectToString(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)));
        return FALSE;
    }
    object oStorage = MEIO_EnsureStorage(oPC);
    string sKey = JsonGetString(JsonObjectGet(jSelected, "key"));
    int iSubtype = JsonGetInt(JsonObjectGet(jSelected, "subtype"));
    int iSpell = JsonGetInt(JsonObjectGet(jSelected, "spell"));
    object oSource = MEIO_ResolveScroll(oStorage, sKey, iSubtype);
    if (!GetIsObjectValid(oSource))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "stale_entry"));
        return FALSE;
    }
    if (!GetBaseItemFitsInInventory(BASE_ITEM_SPELLSCROLL, oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "no_space"));
        return FALSE;
    }
    object oReserved = MEIO_ExtractOne(oPC, oStorage, oSource);
    if (!GetIsObjectValid(oReserved))
    {
        MEIO_Debug(oPC, "BeginCast decision=fail reason=extraction-failed");
        return FALSE;
    }
    SetLocalString(oPC, MEIO_LOCAL_RESERVED_KEY, IntToString(iSubtype));
    MEIO_Debug(oPC, "BeginCast extracted subtype=" + IntToString(iSubtype) + " spell=" + IntToString(iSpell) + " " + MEIO_DebugItemState(oPC, oReserved));
    int iWindow = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iWindow > 0) NuiDestroy(oPC, iWindow);
    if (Get2DAString("spells", "Range", iSpell) == "P")
    {
        MEIO_Debug(oPC, "BeginCast decision=personal-target");
        MEIO_IssueUseOnObject(oPC, oPC);
        return TRUE;
    }
    int iShape = MEIO_GetTargetShape(iSpell);
    float fSizeX = StringToFloat(Get2DAString("spells", "TargetSizeX", iSpell));
    float fSizeY = StringToFloat(Get2DAString("spells", "TargetSizeY", iSpell));
    int iFlags = StringToInt(Get2DAString("spells", "TargetFlags", iSpell));
    SetEnterTargetingModeData(oPC, iShape, fSizeX, fSizeY, iFlags, MEIO_GetRange(iSpell), iSpell);
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
    MEIO_Debug(oPC, "BeginCast decision=enter-targeting shape=" + IntToString(iShape) + " flags=" + IntToString(iFlags));
    return TRUE;
}

int MEIO_BeginPotionUse(object oPC, json jSelected)
{
    MEIO_Debug(oPC, "BeginPotionUse entered selection=" + JsonDump(jSelected));
    if (GetIsObjectValid(GetLocalObject(oPC, MEIO_LOCAL_RESERVED)))
    {
        return FALSE;
    }
    object oStorage = MEIO_EnsurePotionStorage(oPC);
    string sKey = JsonGetString(JsonObjectGet(jSelected, "key"));
    int iSubtype = JsonGetInt(JsonObjectGet(jSelected, "subtype"));
    object oSource = MEIO_ResolvePotion(oStorage, sKey, iSubtype);
    if (!GetIsObjectValid(oSource))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "stale_entry"));
        return FALSE;
    }
    if (!GetBaseItemFitsInInventory(BASE_ITEM_POTIONS, oPC))
    {
        SendMessageToPC(oPC, MEIO_GetText(oPC, "no_space"));
        return FALSE;
    }
    object oReserved = MEIO_ExtractPotionOne(oPC, oStorage, oSource);
    if (!GetIsObjectValid(oReserved))
    {
        return FALSE;
    }
    SetLocalString(oPC, MEIO_LOCAL_RESERVED_KEY, IntToString(iSubtype));
    int iWindow = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iWindow > 0)
    {
        NuiDestroy(oPC, iWindow);
    }
    MEIO_IssueUseOnObject(oPC, oPC);
    return TRUE;
}
