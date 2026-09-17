#include "esi_lib"
#include "memoria_locale"
#include "memoria_loc"

const string MEDT_LOC_PREFIX = "medt";
const string MEDT_ESI_KEY_TARGET = "medt.module.target";
const string MEDT_LOCAL_LANGUAGE = "MEDT_LANGUAGE";
const string MEDT_LOCAL_TARGET_MODE = "MEDT_TARGET_MODE";
const string MEDT_LOCAL_DELETE_TARGET = "MEDT_DELETE_TARGET";
const string MEDT_CONFIRM_WINDOW_ID = "medt_confirm";
const int MEDT_TARGET_MODE_EXAMINE = 1;
const int MEDT_TARGET_MODE_DELETE = 2;

string MEDT_GetText(object oPC, string sKey)
{
    return MEMORIA_LOC_GetText(MEDT_LOC_PREFIX, MEMORIA_GetLanguage(oPC, MEDT_LOCAL_LANGUAGE), sKey);
}

string MEDT_ReplaceToken(string sText, string sToken, string sValue)
{
    int iPosition = FindSubString(sText, sToken);
    if (iPosition < 0) return sText;
    return GetSubString(sText, 0, iPosition) + sValue + GetSubString(sText, iPosition + GetStringLength(sToken), GetStringLength(sText));
}

string MEDT_FormatObjectText(object oPC, string sKey, object oTarget)
{
    string sText = MEDT_GetText(oPC, sKey);
    sText = MEDT_ReplaceToken(sText, "{name}", GetName(oTarget));
    return MEDT_ReplaceToken(sText, "{id}", ObjectToString(oTarget));
}

string MEDT_ObjectTypeName(int iType)
{
    if (iType == OBJECT_TYPE_CREATURE) return "creature";
    if (iType == OBJECT_TYPE_ITEM) return "item";
    if (iType == OBJECT_TYPE_TRIGGER) return "trigger";
    if (iType == OBJECT_TYPE_DOOR) return "door";
    if (iType == OBJECT_TYPE_AREA_OF_EFFECT) return "area_of_effect";
    if (iType == OBJECT_TYPE_WAYPOINT) return "waypoint";
    if (iType == OBJECT_TYPE_PLACEABLE) return "placeable";
    if (iType == OBJECT_TYPE_STORE) return "store";
    if (iType == OBJECT_TYPE_ENCOUNTER) return "encounter";
    return "unknown";
}

string MEDT_ObjectRef(object oObject)
{
    if (!GetIsObjectValid(oObject)) return "invalid";
    return "\"" + GetName(oObject) + "\" (" + ObjectToString(oObject) + ")";
}

void MEDT_Report(object oPC, string sLine)
{
    SendMessageToPC(oPC, "[MEDT] " + sLine);
}

void MEDT_ReportEffects(object oPC, object oTarget)
{
    int iIndex = 0;
    effect eEffect = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEffect))
    {
        iIndex++;
        MEDT_Report(oPC, "effect[" + IntToString(iIndex) + "]: type=" + IntToString(GetEffectType(eEffect, TRUE)) + " subtype=" + IntToString(GetEffectSubType(eEffect)) + " duration_type=" + IntToString(GetEffectDurationType(eEffect)) + " duration=" + IntToString(GetEffectDuration(eEffect)) + " remaining=" + IntToString(GetEffectDurationRemaining(eEffect)) + " spell=" + IntToString(GetEffectSpellId(eEffect)) + " caster_level=" + IntToString(GetEffectCasterLevel(eEffect)) + " creator=" + MEDT_ObjectRef(GetEffectCreator(eEffect)) + " tag=\"" + GetEffectTag(eEffect) + "\" link_id=\"" + GetEffectLinkId(eEffect) + "\".");
        eEffect = GetNextEffect(oTarget);
    }
    MEDT_Report(oPC, "effects.count=" + IntToString(iIndex) + ".");
}

void MEDT_ReportItem(object oPC, object oItem)
{
    int iBaseType = GetBaseItemType(oItem);
    object oPossessor = GetItemPossessor(oItem, TRUE);
    MEDT_Report(oPC, "item: base_type=" + IntToString(iBaseType) + " (" + Get2DAString("baseitems", "Label", iBaseType) + ") stack=" + IntToString(GetItemStackSize(oItem)) + " charges=" + IntToString(GetItemCharges(oItem)) + " value=" + IntToString(GetGoldPieceValue(oItem)) + " weight=" + IntToString(GetWeight(oItem)) + " ac=" + IntToString(GetItemACValue(oItem)) + ".");
    MEDT_Report(oPC, "item.flags: identified=" + IntToString(GetIdentified(oItem)) + " plot=" + IntToString(GetPlotFlag(oItem)) + " cursed=" + IntToString(GetItemCursedFlag(oItem)) + " droppable=" + IntToString(GetDroppableFlag(oItem)) + " stolen=" + IntToString(GetStolenFlag(oItem)) + " pickpocketable=" + IntToString(GetPickpocketableFlag(oItem)) + " infinite=" + IntToString(GetInfiniteFlag(oItem)) + ".");
    MEDT_Report(oPC, "item.possessor=" + MEDT_ObjectRef(oPossessor) + ".");
    int iIndex = 0;
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        iIndex++;
        MEDT_Report(oPC, "item_property[" + IntToString(iIndex) + "]: type=" + IntToString(GetItemPropertyType(ip)) + " subtype=" + IntToString(GetItemPropertySubType(ip)) + " cost_table=" + IntToString(GetItemPropertyCostTable(ip)) + " cost_value=" + IntToString(GetItemPropertyCostTableValue(ip)) + " param1=" + IntToString(GetItemPropertyParam1(ip)) + " param1_value=" + IntToString(GetItemPropertyParam1Value(ip)) + " duration_type=" + IntToString(GetItemPropertyDurationType(ip)) + " duration=" + IntToString(GetItemPropertyDuration(ip)) + " remaining=" + IntToString(GetItemPropertyDurationRemaining(ip)) + " uses_remaining=" + IntToString(GetItemPropertyUsesPerDayRemaining(oItem, ip)) + " tag=\"" + GetItemPropertyTag(ip) + "\".");
        ip = GetNextItemProperty(oItem);
    }
    MEDT_Report(oPC, "item_properties.count=" + IntToString(iIndex) + ".");
}

void MEDT_ReportCreature(object oPC, object oCreature)
{
    int iClass1 = GetClassByPosition(1, oCreature);
    int iClass2 = GetClassByPosition(2, oCreature);
    int iClass3 = GetClassByPosition(3, oCreature);
    MEDT_Report(oPC, "creature: pc=" + IntToString(GetIsPC(oCreature)) + " dm=" + IntToString(GetIsDM(oCreature)) + " dead=" + IntToString(GetIsDead(oCreature)) + " racial_type=" + IntToString(GetRacialType(oCreature)) + " gender=" + IntToString(GetGender(oCreature)) + " appearance=" + IntToString(GetAppearanceType(oCreature)) + " size=" + IntToString(GetCreatureSize(oCreature)) + " portrait=\"" + GetPortraitResRef(oCreature) + "\".");
    MEDT_Report(oPC, "creature.levels: hit_dice=" + IntToString(GetHitDice(oCreature)) + " class1=" + IntToString(iClass1) + ":" + IntToString(GetLevelByClass(iClass1, oCreature)) + " class2=" + IntToString(iClass2) + ":" + IntToString(GetLevelByClass(iClass2, oCreature)) + " class3=" + IntToString(iClass3) + ":" + IntToString(GetLevelByClass(iClass3, oCreature)) + " xp=" + IntToString(GetXP(oCreature)) + " challenge_rating=" + FloatToString(GetChallengeRating(oCreature), 0, 2) + ".");
    MEDT_Report(oPC, "creature.abilities: str=" + IntToString(GetAbilityScore(oCreature, ABILITY_STRENGTH)) + " dex=" + IntToString(GetAbilityScore(oCreature, ABILITY_DEXTERITY)) + " con=" + IntToString(GetAbilityScore(oCreature, ABILITY_CONSTITUTION)) + " int=" + IntToString(GetAbilityScore(oCreature, ABILITY_INTELLIGENCE)) + " wis=" + IntToString(GetAbilityScore(oCreature, ABILITY_WISDOM)) + " cha=" + IntToString(GetAbilityScore(oCreature, ABILITY_CHARISMA)) + ".");
    MEDT_Report(oPC, "creature.combat: ac=" + IntToString(GetAC(oCreature)) + " fortitude=" + IntToString(GetFortitudeSavingThrow(oCreature)) + " reflex=" + IntToString(GetReflexSavingThrow(oCreature)) + " will=" + IntToString(GetWillSavingThrow(oCreature)) + " spell_resistance=" + IntToString(GetSpellResistance(oCreature)) + " current_action=" + IntToString(GetCurrentAction(oCreature)) + ".");
    MEDT_Report(oPC, "creature.state: alignment_lc=" + IntToString(GetAlignmentLawChaos(oCreature)) + " alignment_ge=" + IntToString(GetAlignmentGoodEvil(oCreature)) + " commandable=" + IntToString(GetCommandable(oCreature)) + " lootable=" + IntToString(GetLootable(oCreature)) + " master=" + MEDT_ObjectRef(GetMaster(oCreature)) + ".");
}

void MEDT_ReportLockAndTrap(object oPC, object oTarget)
{
    MEDT_Report(oPC, "lock: locked=" + IntToString(GetLocked(oTarget)) + " lockable=" + IntToString(GetLockLockable(oTarget)) + " key_required=" + IntToString(GetLockKeyRequired(oTarget)) + " key_tag=\"" + GetLockKeyTag(oTarget) + "\" lock_dc=" + IntToString(GetLockLockDC(oTarget)) + " unlock_dc=" + IntToString(GetLockUnlockDC(oTarget)) + ".");
    MEDT_Report(oPC, "trap: trapped=" + IntToString(GetIsTrapped(oTarget)) + " active=" + IntToString(GetTrapActive(oTarget)) + " base_type=" + IntToString(GetTrapBaseType(oTarget)) + " detect_dc=" + IntToString(GetTrapDetectDC(oTarget)) + " disarm_dc=" + IntToString(GetTrapDisarmDC(oTarget)) + " detectable=" + IntToString(GetTrapDetectable(oTarget)) + " disarmable=" + IntToString(GetTrapDisarmable(oTarget)) + " recoverable=" + IntToString(GetTrapRecoverable(oTarget)) + " one_shot=" + IntToString(GetTrapOneShot(oTarget)) + " key_tag=\"" + GetTrapKeyTag(oTarget) + "\" creator=" + MEDT_ObjectRef(GetTrapCreator(oTarget)) + ".");
}

void MEDT_Examine(object oPC, object oTarget)
{
    int iType = GetObjectType(oTarget);
    vector vPosition = GetPosition(oTarget);
    object oArea = GetArea(oTarget);
    MEDT_Report(oPC, "BEGIN " + GetName(oTarget) + " (" + ObjectToString(oTarget) + ")");
    MEDT_Report(oPC, "identity: type=" + MEDT_ObjectTypeName(iType) + " (" + IntToString(iType) + ") tag=\"" + GetTag(oTarget) + "\" resref=\"" + GetResRef(oTarget) + "\" original_name=\"" + GetName(oTarget, TRUE) + "\".");
    MEDT_Report(oPC, "location: area=" + MEDT_ObjectRef(oArea) + " position=[" + FloatToString(vPosition.x, 0, 3) + "," + FloatToString(vPosition.y, 0, 3) + "," + FloatToString(vPosition.z, 0, 3) + "] facing=" + FloatToString(GetFacing(oTarget), 0, 2) + ".");
    MEDT_Report(oPC, "state: plot=" + IntToString(GetPlotFlag(oTarget)) + " usable=" + IntToString(GetUseableFlag(oTarget)) + " hp=" + IntToString(GetCurrentHitPoints(oTarget)) + "/" + IntToString(GetMaxHitPoints(oTarget)) + " hardness=" + IntToString(GetHardness(oTarget)) + ".");
    if (iType == OBJECT_TYPE_ITEM) MEDT_ReportItem(oPC, oTarget);
    else if (iType == OBJECT_TYPE_CREATURE) MEDT_ReportCreature(oPC, oTarget);
    else if (iType == OBJECT_TYPE_DOOR || iType == OBJECT_TYPE_PLACEABLE)
    {
        MEDT_Report(oPC, "container: has_inventory=" + IntToString(GetHasInventory(oTarget)) + " open=" + IntToString(GetIsOpen(oTarget)) + ".");
        MEDT_ReportLockAndTrap(oPC, oTarget);
    }
    else if (iType == OBJECT_TYPE_TRIGGER) MEDT_ReportLockAndTrap(oPC, oTarget);
    string sDescription = GetDescription(oTarget, FALSE, TRUE);
    if (sDescription != "") MEDT_Report(oPC, "description: " + sDescription);
    MEDT_ReportEffects(oPC, oTarget);
    MEDT_Report(oPC, "END " + GetName(oTarget) + " (" + ObjectToString(oTarget) + ")");
}

int MEDT_IsProtected(object oTarget)
{
    if (GetPlotFlag(oTarget) || GetIsPC(oTarget) || GetIsDM(oTarget)) return TRUE;
    if (GetObjectType(oTarget) != OBJECT_TYPE_ITEM) return FALSE;
    return GetItemCursedFlag(oTarget) || !GetDroppableFlag(oTarget);
}

json MEDT_BuildConfirmWindow(object oPC, object oTarget)
{
    json jColumn = JsonArray();
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiText(JsonString(MEDT_FormatObjectText(oPC, "confirm_question", oTarget)), FALSE, NUI_SCROLLBARS_NONE), 56.0f));
    if (MEDT_IsProtected(oTarget)) jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiStyleForegroundColor(NuiText(JsonString(MEDT_GetText(oPC, "protected_warning")), FALSE, NUI_SCROLLBARS_NONE), NuiColor(235, 70, 70)), 72.0f));
    json jButtons = JsonArray();
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MEDT_GetText(oPC, "confirm_delete"))), "delete"), 150.0f));
    jButtons = JsonArrayInsert(jButtons, NuiSpacer());
    jButtons = JsonArrayInsert(jButtons, NuiWidth(NuiId(NuiButton(JsonString(MEDT_GetText(oPC, "confirm_cancel"))), "cancel"), 150.0f));
    jColumn = JsonArrayInsert(jColumn, NuiHeight(NuiRow(jButtons), 36.0f));
    return NuiWindow(NuiCol(jColumn), JsonString(MEDT_GetText(oPC, "confirm_title")), NuiRect(-1.0f, -1.0f, 620.0f, MEDT_IsProtected(oTarget) ? 230.0f : 160.0f), JsonBool(FALSE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
}

void MEDT_OpenDeleteConfirmation(object oPC, object oTarget)
{
    int iOldToken = NuiFindWindow(oPC, MEDT_CONFIRM_WINDOW_ID);
    if (iOldToken > 0) NuiDestroy(oPC, iOldToken);
    SetLocalObject(oPC, MEDT_LOCAL_DELETE_TARGET, oTarget);
    NuiCreate(oPC, MEDT_BuildConfirmWindow(oPC, oTarget), MEDT_CONFIRM_WINDOW_ID, "medt_nuievt");
}

void MEDT_StartTargeting(object oPC, int iMode)
{
    SetLocalInt(oPC, MEDT_LOCAL_TARGET_MODE, iMode);
    SendMessageToPC(oPC, MEDT_GetText(oPC, iMode == MEDT_TARGET_MODE_EXAMINE ? "select_examine" : "select_delete"));
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);
}

void MEDT_InstallHook()
{
    ESI_InjectToObject(GetModule(), MEDT_ESI_KEY_TARGET, EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "medt_target", ESI_INJECTION_PLACEMENT_FIRST);
}
