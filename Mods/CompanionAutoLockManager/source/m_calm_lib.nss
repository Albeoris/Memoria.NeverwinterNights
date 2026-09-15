// Companion Auto-Lock Manager (M_CALM)
// Shared implementation. All resource names use the uncommon "m_calm_" prefix.

#include "esi_lib"
#include "memoria_core"
#include "memoria_group"
#include "memoria_locale"

const string M_CALM_VERSION = "1.2.7";
const string M_CALM_ITEM_RESREF = "m_calm_modeitem";
const string M_CALM_ITEM_TAG = "M_CALM_AUTO_UNLOCK_MODE_TOGGLE_9F31";
const string M_CALM_ACTIVATE_HANDLER = "m_calm_evact";
const string M_CALM_ESI_INJECTION_KEY = "9317";
const string M_CALM_LOCAL_INSTALLED = "M_CALM_INSTALLED";
const string M_CALM_LOCAL_ENABLED = "M_CALM_MODE_ENABLED";
const string M_CALM_LOCAL_PAUSED = "M_CALM_MODE_PAUSED";
const string M_CALM_LOCAL_TICK = "M_CALM_MANAGER_TICK";
const string M_CALM_LOCAL_TASK = "M_CALM_UNLOCK_TASK";
const string M_CALM_LOCAL_ASSIGNEE = "M_CALM_UNLOCK_ASSIGNEE";
const string M_CALM_LOCAL_OWNER = "M_CALM_UNLOCK_OWNER";
const string M_CALM_LOCAL_STALL = "M_CALM_PATH_STALL";
const string M_CALM_LOCAL_RETRIES = "M_CALM_PATH_RETRIES";
const string M_CALM_LOCAL_LAST_DISTANCE = "M_CALM_PATH_LAST_DISTANCE";
const string M_CALM_LOCAL_RETRY_AFTER = "M_CALM_RETRY_AFTER";
const string M_CALM_LOCAL_MANUAL_TICK = "M_CALM_MANUAL_TICK";
const string M_CALM_LOCAL_CHECK_TARGET = "M_CALM_CHECK_TARGET";
const string M_CALM_LOCAL_CHECK_RESULT = "M_CALM_CHECK_RESULT";
const string M_CALM_LOCAL_BLOCKING_DOOR = "M_CALM_BLOCKING_DOOR";
const string M_CALM_LOCAL_INITIAL_BLOCKING_DOOR = "M_CALM_INITIAL_BLOCKING_DOOR";
const string M_CALM_LOCAL_INITIAL_COMMAND = "M_CALM_INITIAL_COMMAND";
const string M_CALM_LOCAL_NEXT_ASSOCIATE = "M_CALM_NEXT_ASSOCIATE";
const string M_CALM_LOCAL_TEXT = "M_CALM_TEXT_RESULT";
const string M_CALM_LOCAL_IS_RUSSIAN = "M_CALM_LANGUAGE_IS_RUSSIAN";
const string M_CALM_LOCAL_ITEM_LANGUAGE = "M_CALM_ITEM_LANGUAGE";
const string M_CALM_LOCAL_ITEM_SCHEMA = "M_CALM_ITEM_SCHEMA";
const string M_CALM_LOCAL_LANGUAGE = "M_CALM_LANGUAGE";
const string M_CALM_LOCAL_GROUP_COUNT = "M_CALM_GROUP_COUNT";
const string M_CALM_LOCAL_GROUP_MEMBER = "M_CALM_GROUP_MEMBER_";
const string M_CALM_LOCAL_LOCK_COUNT = "M_CALM_LOCK_COUNT";
const string M_CALM_LOCAL_LOCK_MEMBER = "M_CALM_LOCK_MEMBER_";
const string M_CALM_LOCAL_LOCKSMITH_COUNT = "M_CALM_LOCKSMITH_COUNT";
const string M_CALM_LOCAL_LOCKSMITH_MEMBER = "M_CALM_LOCKSMITH_MEMBER_";
const string M_CALM_LOCAL_REPORT_PENDING = "M_CALM_REPORT_PENDING";
const string M_CALM_LOCAL_ESI_INSTALLED = "M_CALM_ESI_INSTALLED";
const string M_CALM_LOCAL_SETTINGS_INITIALIZED = "M_CALM_SETTINGS_INITIALIZED";
const string M_CALM_LOCAL_SEARCH_RADIUS = "M_CALM_CFG_SEARCH_RADIUS";
const string M_CALM_LOCAL_LOCK_INTERVAL = "M_CALM_CFG_LOCK_INTERVAL";
const string M_CALM_LOCAL_REQUIRE_LOS = "M_CALM_CFG_REQUIRE_LOS";
const string M_CALM_LOCAL_ATTACK_SAFETY = "M_CALM_CFG_ATTACK_SAFETY";
const string M_CALM_LOCAL_HIGHLIGHT = "M_CALM_CFG_HIGHLIGHT";
const string M_CALM_LOCAL_OVERHEAD_MESSAGES = "M_CALM_CFG_OVERHEAD_MESSAGES";
const string M_CALM_LOCAL_DEBUG = "M_CALM_CFG_DEBUG";
const string M_CALM_LOCAL_AUTO_DETECT = "M_CALM_CFG_AUTO_DETECT";
const string M_CALM_LOCAL_DETECT_ACTOR = "M_CALM_DETECT_ACTOR";
const string M_CALM_LOCAL_DETECT_COUNT = "M_CALM_DETECT_COUNT";
const string M_CALM_LOCAL_DETECT_MEMBER = "M_CALM_DETECT_MEMBER_";
const string M_CALM_LOCAL_DETECT_OWNER = "M_CALM_DETECT_OWNER";
const string M_CALM_LOCAL_DETECT_LAST_LOCATION = "M_CALM_DETECT_LAST_LOCATION";
const string M_CALM_LOCAL_DETECT_STILL_TIME = "M_CALM_DETECT_STILL_TIME";
const string M_CALM_LOCAL_DETECT_OWNED = "M_CALM_DETECT_OWNED";
const string M_CALM_LOCAL_DETECT_REMOVED = "M_CALM_DETECT_REMOVED";
const string M_CALM_LOCAL_HIGHLIGHTED = "M_CALM_HIGHLIGHTED";
const string M_CALM_PARAM_TEXT_KEY = "M_CALM_TEXT_KEY";
const string M_CALM_ASSOCIATE_STATE = "NW_ASSOCIATE_MASTER";
const string M_CALM_ASSOCIATE_MOVEMENT_MODE = "NW_COM_MODE_MOVEMENT";
const string M_CALM_HIGHLIGHT_EFFECT_TAG = "M_CALM_LOCK_GLOW_9F31";

const float M_CALM_BASE_HEARTBEAT_SECONDS = 6.0f;
const float M_CALM_DEFAULT_SEARCH_RADIUS = 15.0f;
const float M_CALM_DEFAULT_LOCK_INTERVAL = 1.0f;
const int M_CALM_MAX_ASSIGNMENTS = 32;
const float M_CALM_STALL_SECONDS = 3.0f;
const int M_CALM_MAX_PATH_RETRIES = 2;
const int M_CALM_MAX_GROUP_MEMBERS = 32;
const int M_CALM_MAX_VISIBLE_LOCKS = 64;
const int M_CALM_ITEM_SCHEMA = 4;

const int M_CALM_TEXT_ITEM_NAME = 1;
const int M_CALM_TEXT_ITEM_DESCRIPTION = 2;
const int M_CALM_TEXT_MODE_ENABLED = 3;
const int M_CALM_TEXT_MODE_DISABLED = 4;
const int M_CALM_TEXT_MODE_PAUSED = 5;
const int M_CALM_TEXT_PATH_FAILED = 6;
const int M_CALM_TEXT_INSTALLED = 7;
const int M_CALM_TEXT_SCAN_LOCKS = 8;
const int M_CALM_TEXT_SCAN_LOCKSMITHS = 9;
const int M_CALM_TEXT_STATE_ON = 10;
const int M_CALM_TEXT_STATE_OFF = 11;
const int M_CALM_TEXT_LOCK_CLAIM = 12;
const int M_CALM_TEXT_SETTINGS_TITLE = 13;
const int M_CALM_TEXT_AUTO_LOCK = 14;
const int M_CALM_TEXT_ENABLED = 15;
const int M_CALM_TEXT_SEARCH_RADIUS = 16;
const int M_CALM_TEXT_LOCK_INTERVAL = 17;
const int M_CALM_TEXT_REQUIRE_LOS = 18;
const int M_CALM_TEXT_ATTACK_SAFETY = 19;
const int M_CALM_TEXT_HIGHLIGHT = 20;
const int M_CALM_TEXT_OVERHEAD_MESSAGES = 21;
const int M_CALM_TEXT_DEBUG = 22;
const int M_CALM_TEXT_AUTO_DETECT = 23;
const int M_CALM_TEXT_DETECT_INTERVAL = 24;
const int M_CALM_TEXT_DETECT_DELAY = 25;
const int M_CALM_TEXT_SAVE = 26;
const int M_CALM_TEXT_CANCEL = 27;
const int M_CALM_TEXT_INVALID_SETTINGS = 28;
const int M_CALM_TEXT_SETTINGS_SAVED = 29;

object M_CALM_GetRootMaster(object oCreature)
{
    return MEMORIA_GetRootPlayer(oCreature);
}

int M_CALM_IsRootPlayer(object oCreature)
{
    return MEMORIA_IsRootPlayerCharacter(oCreature);
}

int M_CALM_IsGroupCreature(object oCreature, object oPC)
{
    return MEMORIA_IsPartyCreature(oCreature, oPC);
}

int M_CALM_IsManagedAssociate(object oCreature, object oPC)
{
    return M_CALM_IsGroupCreature(oCreature, oPC) && oCreature != oPC && !GetIsPC(oCreature) && !GetIsDead(oCreature) && GetArea(oCreature) == GetArea(oPC);
}

int M_CALM_IsPossessingFamiliar(object oPC)
{
    return MEMORIA_IsPossessingFamiliar(oPC);
}

void M_CALM_InitializeSettings(object oPC)
{
    if (GetLocalInt(oPC, M_CALM_LOCAL_SETTINGS_INITIALIZED))
        return;
    SetLocalInt(oPC, M_CALM_LOCAL_SETTINGS_INITIALIZED, TRUE);
    SetLocalFloat(oPC, M_CALM_LOCAL_SEARCH_RADIUS, M_CALM_DEFAULT_SEARCH_RADIUS);
    SetLocalFloat(oPC, M_CALM_LOCAL_LOCK_INTERVAL, M_CALM_DEFAULT_LOCK_INTERVAL);
    SetLocalInt(oPC, M_CALM_LOCAL_REQUIRE_LOS, TRUE);
    SetLocalInt(oPC, M_CALM_LOCAL_ATTACK_SAFETY, TRUE);
    SetLocalInt(oPC, M_CALM_LOCAL_HIGHLIGHT, TRUE);
    SetLocalInt(oPC, M_CALM_LOCAL_OVERHEAD_MESSAGES, TRUE);
    SetLocalInt(oPC, M_CALM_LOCAL_DEBUG, FALSE);
    SetLocalInt(oPC, M_CALM_LOCAL_AUTO_DETECT, FALSE);
}

float M_CALM_GetSearchRadius(object oPC)
{
    M_CALM_InitializeSettings(oPC);
    return GetLocalFloat(oPC, M_CALM_LOCAL_SEARCH_RADIUS);
}

float M_CALM_GetLockInterval(object oPC)
{
    M_CALM_InitializeSettings(oPC);
    return GetLocalFloat(oPC, M_CALM_LOCAL_LOCK_INTERVAL);
}

object M_CALM_GetGroupMember(object oPC, int iIndex)
{
    return MEMORIA_GetGroupMember(oPC, M_CALM_LOCAL_GROUP_MEMBER, iIndex);
}

int M_CALM_GetGroupCount(object oPC)
{
    return MEMORIA_GetGroupCount(oPC, M_CALM_LOCAL_GROUP_COUNT);
}

int M_CALM_IsGroupMemberCached(object oPC, object oCreature)
{
    return MEMORIA_IsGroupMemberCached(oPC, oCreature, M_CALM_LOCAL_GROUP_COUNT, M_CALM_LOCAL_GROUP_MEMBER);
}

void M_CALM_AddGroupMember(object oPC, object oCreature)
{
    MEMORIA_AddGroupMember(oPC, oCreature, M_CALM_LOCAL_GROUP_COUNT, M_CALM_LOCAL_GROUP_MEMBER, M_CALM_MAX_GROUP_MEMBERS);
}

void M_CALM_BuildGroupCache(object oPC)
{
    MEMORIA_BuildGroupCache(oPC, M_CALM_LOCAL_GROUP_COUNT, M_CALM_LOCAL_GROUP_MEMBER, M_CALM_MAX_GROUP_MEMBERS);
}

string M_CALM_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, M_CALM_LOCAL_LANGUAGE, "m_calm_is_ru", M_CALM_LOCAL_IS_RUSSIAN);
}

string M_CALM_GetText(int iKey, object oPC, string sLang = "")
{
    if (sLang == "") sLang = M_CALM_GetLanguage(oPC);
    return MEMORIA_GetText(iKey, oPC, sLang, "m_calm_txt_", M_CALM_LOCAL_TEXT, M_CALM_PARAM_TEXT_KEY);
}

void M_CALM_LocalizeItem(object oItem, object oPC)
{
    string sLang = M_CALM_GetLanguage(oPC);
    string sDescription = M_CALM_GetText(M_CALM_TEXT_ITEM_DESCRIPTION, oPC, sLang);
    string sState = M_CALM_GetText(GetLocalInt(oPC, M_CALM_LOCAL_ENABLED) ? M_CALM_TEXT_STATE_ON : M_CALM_TEXT_STATE_OFF, oPC, sLang);
    SetName(oItem, M_CALM_GetText(M_CALM_TEXT_ITEM_NAME, oPC, sLang) + " [" + sState + "]");
    SetDescription(oItem, sDescription, TRUE);
    SetDescription(oItem, sDescription, FALSE);
    SetLocalString(oItem, M_CALM_LOCAL_ITEM_LANGUAGE, sLang);
}

void M_CALM_EnsureModeItem(object oPC)
{
    object oItem = GetItemPossessedBy(oPC, M_CALM_ITEM_TAG);
    if (GetIsObjectValid(oItem) && GetLocalInt(oItem, M_CALM_LOCAL_ITEM_SCHEMA) != M_CALM_ITEM_SCHEMA)
    {
        DestroyObject(oItem);
        oItem = OBJECT_INVALID;
    }
    if (!GetIsObjectValid(oItem))
        oItem = CreateItemOnObject(M_CALM_ITEM_RESREF, oPC, 1, M_CALM_ITEM_TAG);
    if (GetIsObjectValid(oItem))
    {
        SetLocalInt(oItem, M_CALM_LOCAL_ITEM_SCHEMA, M_CALM_ITEM_SCHEMA);
        SetPlotFlag(oItem, TRUE);
        SetItemCursedFlag(oItem, TRUE);
        if (GetLocalString(oItem, M_CALM_LOCAL_ITEM_LANGUAGE) != M_CALM_GetLanguage(oPC))
            M_CALM_LocalizeItem(oItem, oPC);
    }
}

void M_CALM_InstallActivateHook()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, M_CALM_LOCAL_ESI_INSTALLED))
        return;
    if (ESI_InjectToObject(oModule, M_CALM_ESI_INJECTION_KEY, EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, M_CALM_ACTIVATE_HANDLER, ESI_INJECTION_PLACEMENT_FIRST))
        SetLocalInt(oModule, M_CALM_LOCAL_ESI_INSTALLED, TRUE);
}

int M_CALM_IsPartyInCombat(object oPC)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetGroupMember(oPC, iIndex);
        if (M_CALM_IsGroupCreature(oCreature, oPC) && GetArea(oCreature) == GetArea(oPC) && GetIsInCombat(oCreature))
            return TRUE;
    }
    return FALSE;
}

int M_CALM_GroupHasAction(object oPC, int iAction)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetGroupMember(oPC, iIndex);
        if (M_CALM_IsGroupCreature(oCreature, oPC) && GetArea(oCreature) == GetArea(oPC) && GetCurrentAction(oCreature) == iAction)
            return TRUE;
    }
    return FALSE;
}

int M_CALM_HasLineOfSightToLock(object oTarget, object oPC)
{
    if (LineOfSightObject(oPC, oTarget))
        return TRUE;
    if (GetArea(OBJECT_SELF) != GetArea(oPC))
        return FALSE;
    vector vSource = GetPositionFromLocation(GetLocation(oPC));
    vector vTarget = GetPositionFromLocation(GetLocation(oTarget));
    vSource.z += 1.0f;
    vTarget.z += 1.0f;
    vector vTowardPlayer = vSource - vTarget;
    vTowardPlayer.z = 0.0f;
    if (VectorMagnitude(vTowardPlayer) <= 0.01f)
        return FALSE;
    vTowardPlayer = VectorNormalize(vTowardPlayer);
    return LineOfSightVector(vSource, vTarget + vTowardPlayer * 0.50f) || LineOfSightVector(vSource, vTarget + vTowardPlayer);
}

int M_CALM_IsVisibleFromPlayer(object oTarget, object oPC)
{
    if (!GetIsObjectValid(oTarget) || !GetIsObjectValid(oPC))
        return FALSE;
    if (GetArea(oTarget) != GetArea(oPC) || GetDistanceBetween(oTarget, oPC) > M_CALM_GetSearchRadius(oPC))
        return FALSE;
    return !GetLocalInt(oPC, M_CALM_LOCAL_REQUIRE_LOS) || M_CALM_HasLineOfSightToLock(oTarget, oPC);
}

int M_CALM_IsDetectedActiveTrap(object oTarget, object oPC)
{
    if (!GetIsTrapped(oTarget) || !GetTrapActive(oTarget))
        return FALSE;
    if (GetTrapFlagged(oTarget))
        return TRUE;

    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetTrapDetectedBy(oTarget, oCreature))
            return TRUE;
    }
    return FALSE;
}

int M_CALM_IsLockObject(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    int iType = GetObjectType(oTarget);
    if (iType != OBJECT_TYPE_DOOR && iType != OBJECT_TYPE_PLACEABLE)
        return FALSE;
    if (iType == OBJECT_TYPE_PLACEABLE && !GetHasInventory(oTarget))
        return FALSE;
    if (!GetLocked(oTarget) || (iType == OBJECT_TYPE_PLACEABLE && !GetUseableFlag(oTarget)) || GetIsOpen(oTarget))
        return FALSE;
    return TRUE;
}

int M_CALM_IsLockCandidate(object oTarget, object oPC, int iTick)
{
    return M_CALM_IsLockObject(oTarget) && GetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER) <= iTick;
}

int M_CALM_CanUnlock(object oAssociate, object oTarget)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget))
        return FALSE;
    string sKeyTag = GetLockKeyTag(oTarget);
    if (sKeyTag != "" && GetIsObjectValid(GetItemPossessedBy(oAssociate, sKeyTag)))
        return TRUE;
    if (GetLockKeyRequired(oTarget))
        return FALSE;

    int iSkill = GetSkillRank(SKILL_OPEN_LOCK, oAssociate);
    int iBaseSkill = GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE);
    if (iSkill < 0 || iBaseSkill <= 0 || iSkill + 20 < GetLockUnlockDC(oTarget))
        return FALSE;
    return TRUE;
}

int M_CALM_IsRouteSafe(object oAssociate, object oTarget, object oPC)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget) || GetArea(oAssociate) != GetArea(oTarget))
        return FALSE;
    float fDistance = GetDistanceBetween(oAssociate, oTarget);
    if (fDistance <= 1.5f)
        return TRUE;
    location lTarget = GetLocation(oTarget);
    vector vOrigin = GetPositionFromLocation(GetLocation(oAssociate));
    object oObstacle = GetFirstObjectInShape(SHAPE_SPELLCYLINDER, fDistance, lTarget, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);
    while (GetIsObjectValid(oObstacle))
    {
        if (oObstacle != oTarget)
        {
            int iType = GetObjectType(oObstacle);
            if (iType == OBJECT_TYPE_DOOR && !GetIsOpen(oObstacle))
                return FALSE;
            if (M_CALM_IsDetectedActiveTrap(oObstacle, oPC))
                return FALSE;
        }
        oObstacle = GetNextObjectInShape(SHAPE_SPELLCYLINDER, fDistance, lTarget, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);
    }
    return TRUE;
}

void M_CALM_AbandonTask(object oAssociate);

int M_CALM_IsReservationValid(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    object oAssignee = GetLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE);
    if (!GetIsObjectValid(oAssignee) || GetIsDead(oAssignee) || GetArea(oAssignee) != GetArea(oTarget))
    {
        DeleteLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE);
        if (GetIsObjectValid(oAssignee))
            M_CALM_AbandonTask(oAssignee);
        return FALSE;
    }
    object oOwner = GetLocalObject(oAssignee, M_CALM_LOCAL_OWNER);
    if (!GetIsObjectValid(oOwner) || !M_CALM_IsManagedAssociate(oAssignee, oOwner))
    {
        DeleteLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE);
        M_CALM_AbandonTask(oAssignee);
        return FALSE;
    }
    if (GetLocalObject(oAssignee, M_CALM_LOCAL_TASK) != oTarget)
    {
        DeleteLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE);
        return FALSE;
    }
    return TRUE;
}

object M_CALM_GetLikelyManualLock(object oActor)
{
    if (!GetIsObjectValid(oActor))
        return OBJECT_INVALID;
    if (GetCurrentAction(oActor) != ACTION_OPENLOCK)
        return OBJECT_INVALID;

    int iNth = 1;
    object oTarget = GetNearestObject(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, oActor, iNth);
    while (GetIsObjectValid(oTarget) && iNth <= 16)
    {
        if (GetLocked(oTarget))
            return oTarget;
        iNth++;
        oTarget = GetNearestObject(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, oActor, iNth);
    }
    return OBJECT_INVALID;
}

void M_CALM_MarkManualReservations(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oTarget = M_CALM_GetLikelyManualLock(M_CALM_GetGroupMember(oPC, iIndex));
        if (GetIsObjectValid(oTarget))
            SetLocalInt(oTarget, M_CALM_LOCAL_MANUAL_TICK, iTick);
    }
}

int M_CALM_CanTakeTask(object oAssociate, object oPC)
{
    if (!M_CALM_IsManagedAssociate(oAssociate, oPC) || GetIsObjectValid(GetLocalObject(oAssociate, M_CALM_LOCAL_TASK)))
        return FALSE;
    if (!GetCommandable(oAssociate) || GetIsResting(oAssociate) || IsInConversation(oAssociate))
        return FALSE;

    int iAction = GetCurrentAction(oAssociate);
    return iAction == ACTION_INVALID || iAction == ACTION_FOLLOW || iAction == ACTION_WAIT || iAction == ACTION_RANDOMWALK;
}

object M_CALM_GetVisibleLock(object oPC, int iIndex)
{
    return GetLocalObject(oPC, M_CALM_LOCAL_LOCK_MEMBER + IntToString(iIndex));
}

int M_CALM_GetVisibleLockCount(object oPC)
{
    return GetLocalInt(oPC, M_CALM_LOCAL_LOCK_COUNT);
}

int M_CALM_CountEligibleVisibleLocks(object oPC, int iTick)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = M_CALM_GetVisibleLock(oPC, iIndex);
        if (M_CALM_IsLockCandidate(oTarget, oPC, iTick) && M_CALM_IsVisibleFromPlayer(oTarget, oPC))
            iCount++;
    }
    return iCount;
}

object M_CALM_GetLocksmith(object oPC, int iIndex)
{
    return GetLocalObject(oPC, M_CALM_LOCAL_LOCKSMITH_MEMBER + IntToString(iIndex));
}

int M_CALM_GetLocksmithCount(object oPC)
{
    return GetLocalInt(oPC, M_CALM_LOCAL_LOCKSMITH_COUNT);
}

void M_CALM_BuildLocksmithCache(object oPC)
{
    int iIndex;
    int iOldCount = M_CALM_GetLocksmithCount(oPC);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
        DeleteLocalObject(oPC, M_CALM_LOCAL_LOCKSMITH_MEMBER + IntToString(iIndex));
    SetLocalInt(oPC, M_CALM_LOCAL_LOCKSMITH_COUNT, 0);
    for (iIndex = 2; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oAssociate = M_CALM_GetGroupMember(oPC, iIndex);
        if (M_CALM_IsManagedAssociate(oAssociate, oPC) && GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) > 0)
        {
            int iCount = M_CALM_GetLocksmithCount(oPC) + 1;
            SetLocalInt(oPC, M_CALM_LOCAL_LOCKSMITH_COUNT, iCount);
            SetLocalObject(oPC, M_CALM_LOCAL_LOCKSMITH_MEMBER + IntToString(iCount), oAssociate);
        }
    }
}

void M_CALM_ClearHighlight(object oTarget)
{
    if (!GetIsObjectValid(oTarget) || !GetLocalInt(oTarget, M_CALM_LOCAL_HIGHLIGHTED))
        return;
    effect eEffect = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEffect))
    {
        effect eNext = GetNextEffect(oTarget);
        if (GetEffectTag(eEffect) == M_CALM_HIGHLIGHT_EFFECT_TAG)
            RemoveEffect(oTarget, eEffect);
        eEffect = eNext;
    }
    DeleteLocalInt(oTarget, M_CALM_LOCAL_HIGHLIGHTED);
}

void M_CALM_SetHighlight(object oTarget)
{
    if (!GetIsObjectValid(oTarget) || GetLocalInt(oTarget, M_CALM_LOCAL_HIGHLIGHTED))
        return;
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, TagEffect(EffectVisualEffect(VFX_DUR_GLOW_GREY), M_CALM_HIGHLIGHT_EFFECT_TAG), oTarget);
    SetLocalInt(oTarget, M_CALM_LOCAL_HIGHLIGHTED, TRUE);
}

void M_CALM_ClearCachedHighlights(object oPC)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetVisibleLockCount(oPC); iIndex++)
        M_CALM_ClearHighlight(M_CALM_GetVisibleLock(oPC, iIndex));
}

void M_CALM_BuildVisibleLockCache(object oPC, int iTick)
{
    int iIndex;
    int iOldCount = M_CALM_GetVisibleLockCount(oPC);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
    {
        object oOldTarget = M_CALM_GetVisibleLock(oPC, iIndex);
        if (!GetLocalInt(oPC, M_CALM_LOCAL_HIGHLIGHT) || !M_CALM_IsLockObject(oOldTarget) || GetArea(oOldTarget) != GetArea(oPC) || GetDistanceBetween(oOldTarget, oPC) > M_CALM_GetSearchRadius(oPC))
            M_CALM_ClearHighlight(oOldTarget);
        DeleteLocalObject(oPC, M_CALM_LOCAL_LOCK_MEMBER + IntToString(iIndex));
    }
    SetLocalInt(oPC, M_CALM_LOCAL_LOCK_COUNT, 0);

    float fRadius = M_CALM_GetSearchRadius(oPC);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(oPC), FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while (GetIsObjectValid(oTarget) && M_CALM_GetVisibleLockCount(oPC) < M_CALM_MAX_VISIBLE_LOCKS)
    {
        if (M_CALM_IsLockObject(oTarget))
        {
            int iCount = M_CALM_GetVisibleLockCount(oPC) + 1;
            SetLocalInt(oPC, M_CALM_LOCAL_LOCK_COUNT, iCount);
            SetLocalObject(oPC, M_CALM_LOCAL_LOCK_MEMBER + IntToString(iCount), oTarget);
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(oPC), FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}

void M_CALM_UpdateCachedHighlights(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = M_CALM_GetVisibleLock(oPC, iIndex);
        if (GetLocalInt(oPC, M_CALM_LOCAL_HIGHLIGHT) && M_CALM_IsLockCandidate(oTarget, oPC, iTick) && M_CALM_IsVisibleFromPlayer(oTarget, oPC))
            M_CALM_SetHighlight(oTarget);
        else
            M_CALM_ClearHighlight(oTarget);
    }
}

object M_CALM_FindBestTarget(object oAssociate, object oPC, int iTick)
{
    object oBest = OBJECT_INVALID;
    float fBestDistance = 1000000.0f;
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = M_CALM_GetVisibleLock(oPC, iIndex);
        if (M_CALM_IsLockCandidate(oTarget, oPC, iTick) && M_CALM_IsVisibleFromPlayer(oTarget, oPC) && !M_CALM_IsReservationValid(oTarget) && GetLocalInt(oTarget, M_CALM_LOCAL_MANUAL_TICK) != iTick)
        {
            float fDistance = GetDistanceBetween(oAssociate, oTarget);
            if (fDistance < fBestDistance && M_CALM_CanUnlock(oAssociate, oTarget) && M_CALM_IsRouteSafe(oAssociate, oTarget, oPC))
            {
                oBest = oTarget;
                fBestDistance = fDistance;
            }
        }
    }
    return oBest;
}

object M_CALM_FindNearestAvailableTarget(object oPC, int iTick)
{
    object oBestTarget = OBJECT_INVALID;
    object oBestAssociate = OBJECT_INVALID;
    float fBestDistance = 1000000.0f;
    int iBestSkill = 1000000;
    int iTargetIndex;
    for (iTargetIndex = 1; iTargetIndex <= M_CALM_GetVisibleLockCount(oPC); iTargetIndex++)
    {
        object oTarget = M_CALM_GetVisibleLock(oPC, iTargetIndex);
        if (M_CALM_IsLockCandidate(oTarget, oPC, iTick) && M_CALM_IsVisibleFromPlayer(oTarget, oPC) && !M_CALM_IsReservationValid(oTarget) && GetLocalInt(oTarget, M_CALM_LOCAL_MANUAL_TICK) != iTick)
        {
            int iAssociateIndex;
            for (iAssociateIndex = 1; iAssociateIndex <= M_CALM_GetLocksmithCount(oPC); iAssociateIndex++)
            {
                object oAssociate = M_CALM_GetLocksmith(oPC, iAssociateIndex);
                if (M_CALM_CanTakeTask(oAssociate, oPC))
                {
                    float fDistance = GetDistanceBetween(oAssociate, oTarget);
                    int iSkill = GetSkillRank(SKILL_OPEN_LOCK, oAssociate);
                    if ((fDistance < fBestDistance || (fDistance == fBestDistance && iSkill < iBestSkill)) && M_CALM_CanUnlock(oAssociate, oTarget) && M_CALM_IsRouteSafe(oAssociate, oTarget, oPC))
                    {
                        oBestTarget = oTarget;
                        oBestAssociate = oAssociate;
                        fBestDistance = fDistance;
                        iBestSkill = iSkill;
                    }
                }
            }
        }
    }
    DeleteLocalObject(oPC, M_CALM_LOCAL_NEXT_ASSOCIATE);
    if (GetIsObjectValid(oBestAssociate))
        SetLocalObject(oPC, M_CALM_LOCAL_NEXT_ASSOCIATE, oBestAssociate);
    return oBestTarget;
}

int M_CALM_CountAvailableLocksmiths(object oPC)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetLocksmithCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetLocksmith(oPC, iIndex);
        if (M_CALM_CanTakeTask(oCreature, oPC))
            iCount++;
    }
    return iCount;
}

int M_CALM_CountAssignableLocksmiths(object oPC, int iTick)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetLocksmithCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetLocksmith(oPC, iIndex);
        if (M_CALM_CanTakeTask(oCreature, oPC) && GetIsObjectValid(M_CALM_FindBestTarget(oCreature, oPC, iTick)))
            iCount++;
    }
    return iCount;
}

string M_CALM_AppendDiagnosticReason(string sReasons, string sReason)
{
    if (sReasons == "")
        return sReason;
    return sReasons + "," + sReason;
}

string M_CALM_GetLocksmithRejectionReasons(object oAssociate, object oPC)
{
    string sReasons = "";
    if (!GetIsObjectValid(oAssociate))
        return "invalid_object";
    if (GetObjectType(oAssociate) != OBJECT_TYPE_CREATURE)
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "not_creature");
    if (M_CALM_GetRootMaster(oAssociate) != oPC)
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "different_root_master");
    if (oAssociate == oPC)
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "player_character");
    if (GetIsPC(oAssociate))
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "player_controlled");
    if (GetIsDead(oAssociate))
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "dead");
    if (GetArea(oAssociate) != GetArea(oPC))
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "different_area");
    if (GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) <= 0)
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "open_lock_untrained");
    if (GetIsObjectValid(GetLocalObject(oAssociate, M_CALM_LOCAL_TASK)))
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "has_m_calm_task");
    if (!GetCommandable(oAssociate))
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "not_commandable");
    if (GetIsResting(oAssociate))
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "resting");
    if (IsInConversation(oAssociate))
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "in_conversation");
    int iAction = GetCurrentAction(oAssociate);
    if (iAction != ACTION_INVALID && iAction != ACTION_FOLLOW && iAction != ACTION_WAIT && iAction != ACTION_RANDOMWALK)
        sReasons = M_CALM_AppendDiagnosticReason(sReasons, "busy_action=" + IntToString(iAction));
    if (sReasons == "")
        return "none";
    return sReasons;
}

void M_CALM_ReportTargetRejections(object oAssociate, object oPC, int iTick, int iAllyIndex)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = M_CALM_GetVisibleLock(oPC, iIndex);
        int bValid = GetIsObjectValid(oTarget);
        int bLock = bValid && M_CALM_IsLockObject(oTarget);
        int bRetryReady = bValid && GetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER) <= iTick;
        int bSameArea = bValid && GetArea(oTarget) == GetArea(oPC);
        float fDistance = bSameArea ? GetDistanceBetween(oTarget, oPC) : -1.0f;
        int bInRange = bSameArea && fDistance <= M_CALM_GetSearchRadius(oPC);
        int bObjectLOS = bSameArea && LineOfSightObject(oPC, oTarget);
        int bLockLOS = bSameArea && M_CALM_HasLineOfSightToLock(oTarget, oPC);
        int bVisible = bInRange && (!GetLocalInt(oPC, M_CALM_LOCAL_REQUIRE_LOS) || bLockLOS);
        int bReserved = bValid && M_CALM_IsReservationValid(oTarget);
        int bManual = bValid && GetLocalInt(oTarget, M_CALM_LOCAL_MANUAL_TICK) == iTick;
        int bCanUnlock = bValid && M_CALM_CanUnlock(oAssociate, oTarget);
        int bRouteSafe = bValid && M_CALM_IsRouteSafe(oAssociate, oTarget, oPC);
        int bAssignable = bLock && bRetryReady && bVisible && !bReserved && !bManual && bCanUnlock && bRouteSafe;
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "]: id=" + ObjectToString(oTarget) + " name=\"" + GetName(oTarget) + "\" valid=" + IntToString(bValid) + " lock=" + IntToString(bLock) + " retry_ready=" + IntToString(bRetryReady) + " retry_after=" + IntToString(GetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER)) + ".");
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "].visibility: same_area=" + IntToString(bSameArea) + " distance=" + FloatToString(fDistance, 0, 2) + " radius=" + FloatToString(M_CALM_GetSearchRadius(oPC), 0, 2) + " require_los=" + IntToString(GetLocalInt(oPC, M_CALM_LOCAL_REQUIRE_LOS)) + " object_los=" + IntToString(bObjectLOS) + " lock_los=" + IntToString(bLockLOS) + " visible=" + IntToString(bVisible) + ".");
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "].pair: reserved=" + IntToString(bReserved) + " manual=" + IntToString(bManual) + " can_unlock=" + IntToString(bCanUnlock) + " route_safe=" + IntToString(bRouteSafe) + " assignable=" + IntToString(bAssignable) + ".");
    }
}

void M_CALM_ReportAssignmentFailure(object oPC, int iTick, int iAvailable, int iAssignable)
{
    SendMessageToPC(oPC, "M_CALM assignment diagnostics: group=" + IntToString(M_CALM_GetGroupCount(oPC)) + " trained=" + IntToString(M_CALM_GetLocksmithCount(oPC)) + " available=" + IntToString(iAvailable) + " assignable=" + IntToString(iAssignable) + " cached_locks=" + IntToString(M_CALM_GetVisibleLockCount(oPC)) + " tick=" + IntToString(iTick) + ".");
    if (M_CALM_GetGroupCount(oPC) <= 1)
    {
        SendMessageToPC(oPC, "ally.none: associate discovery returned no same-area companions.");
        return;
    }
    int iIndex;
    for (iIndex = 2; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oAssociate = M_CALM_GetGroupMember(oPC, iIndex);
        if (!GetIsObjectValid(oAssociate))
            SendMessageToPC(oPC, "ally[" + IntToString(iIndex) + "]: invalid_object.");
        else
        {
            int bTrained = GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) > 0;
            int bAvailable = bTrained && M_CALM_CanTakeTask(oAssociate, oPC);
            string sReasons = M_CALM_GetLocksmithRejectionReasons(oAssociate, oPC);
            SendMessageToPC(oPC, "ally[" + IntToString(iIndex) + "].id=" + ObjectToString(oAssociate) + " name=\"" + GetName(oAssociate) + "\" open_lock=" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oAssociate)) + "/" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE)) + " trained=" + IntToString(bTrained) + " available=" + IntToString(bAvailable) + " action=" + IntToString(GetCurrentAction(oAssociate)) + " reasons=" + sReasons + ".");
            if (bAvailable)
                M_CALM_ReportTargetRejections(oAssociate, oPC, iTick, iIndex);
        }
    }
}

void M_CALM_ReleaseTask(object oAssociate)
{
    object oTarget = GetLocalObject(oAssociate, M_CALM_LOCAL_TASK);
    if (GetIsObjectValid(oTarget) && GetLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE) == oAssociate)
        DeleteLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE);
    DeleteLocalObject(oAssociate, M_CALM_LOCAL_TASK);
    DeleteLocalObject(oAssociate, M_CALM_LOCAL_OWNER);
    DeleteLocalInt(oAssociate, M_CALM_LOCAL_STALL);
    DeleteLocalFloat(oAssociate, M_CALM_LOCAL_STALL);
    DeleteLocalInt(oAssociate, M_CALM_LOCAL_RETRIES);
    DeleteLocalInt(oAssociate, M_CALM_LOCAL_LAST_DISTANCE);
    DeleteLocalObject(oAssociate, M_CALM_LOCAL_BLOCKING_DOOR);
    DeleteLocalObject(oAssociate, M_CALM_LOCAL_INITIAL_BLOCKING_DOOR);
    DeleteLocalInt(oAssociate, M_CALM_LOCAL_INITIAL_COMMAND);
}

void M_CALM_AbandonTask(object oAssociate)
{
    if (!GetIsObjectValid(oAssociate))
        return;
    ClearAllActions(FALSE, oAssociate);
    M_CALM_ReleaseTask(oAssociate);
}

float M_CALM_GetFollowDistance(object oAssociate)
{
    int iState = GetLocalInt(oAssociate, M_CALM_ASSOCIATE_STATE);
    if (iState & 0x00000001)
        return 2.0f;
    if (iState & 0x00000004)
        return 6.0f;
    return 4.0f;
}

void M_CALM_RestoreNaturalState(object oAssociate, object oOwner)
{
    if (!GetIsObjectValid(oAssociate) || GetIsDead(oAssociate))
        return;
    ClearAllActions(FALSE, oAssociate);
    if (GetIsInCombat(oAssociate) || GetLocalInt(oAssociate, M_CALM_ASSOCIATE_MOVEMENT_MODE) == ASSOCIATE_COMMAND_STANDGROUND)
        return;
    object oMaster = GetMaster(oAssociate);
    if (!GetIsObjectValid(oMaster))
        oMaster = oOwner;
    if (GetIsObjectValid(oMaster) && GetArea(oMaster) == GetArea(oAssociate))
        AssignCommand(oAssociate, ActionForceFollowObject(oMaster, M_CALM_GetFollowDistance(oAssociate)));
}

void M_CALM_CancelTask(object oAssociate)
{
    object oOwner = GetLocalObject(oAssociate, M_CALM_LOCAL_OWNER);
    M_CALM_ReleaseTask(oAssociate);
    M_CALM_RestoreNaturalState(oAssociate, oOwner);
}

void M_CALM_CancelAllTasks(object oPC)
{
    int iIndex;
    for (iIndex = 2; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetLocalObject(oCreature, M_CALM_LOCAL_OWNER) == oPC)
        {
            if (M_CALM_IsManagedAssociate(oCreature, oPC))
                M_CALM_CancelTask(oCreature);
            else
                M_CALM_AbandonTask(oCreature);
        }
    }
    for (iIndex = 1; iIndex <= M_CALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = M_CALM_GetVisibleLock(oPC, iIndex);
        object oAssignee = GetLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE);
        if (GetIsObjectValid(oAssignee) && GetLocalObject(oAssignee, M_CALM_LOCAL_OWNER) == oPC)
            M_CALM_AbandonTask(oAssignee);
    }
}

void M_CALM_AssignTask(object oAssociate, object oTarget, object oPC)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget) || !GetIsObjectValid(oPC) || GetArea(oAssociate) != GetArea(oTarget) || GetArea(oTarget) != GetArea(oPC) || !GetLocked(oTarget) || !M_CALM_IsRouteSafe(oAssociate, oTarget, oPC))
        return;
    if (GetCurrentAction(oAssociate) == ACTION_FOLLOW || GetCurrentAction(oAssociate) == ACTION_WAIT || GetCurrentAction(oAssociate) == ACTION_RANDOMWALK)
        ClearAllActions(FALSE, oAssociate);
    SetLocalObject(oAssociate, M_CALM_LOCAL_TASK, oTarget);
    SetLocalObject(oAssociate, M_CALM_LOCAL_OWNER, oPC);
    SetLocalObject(oTarget, M_CALM_LOCAL_ASSIGNEE, oAssociate);
    SetLocalInt(oAssociate, M_CALM_LOCAL_LAST_DISTANCE, FloatToInt(GetDistanceBetween(oAssociate, oTarget) * 100.0f));
    SetLocalInt(oAssociate, M_CALM_LOCAL_INITIAL_COMMAND, GetLastAssociateCommand(oAssociate));
    ExecuteScript("m_calm_pathcheck", oAssociate);
    object oBlockingDoor = GetLocalObject(oAssociate, M_CALM_LOCAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor))
        SetLocalObject(oAssociate, M_CALM_LOCAL_INITIAL_BLOCKING_DOOR, oBlockingDoor);
    if (GetLocalInt(oPC, M_CALM_LOCAL_OVERHEAD_MESSAGES))
        FloatingTextStringOnCreature(M_CALM_GetText(M_CALM_TEXT_LOCK_CLAIM, oPC), oAssociate, TRUE, FALSE);
    AssignCommand(oAssociate, ActionUnlockObject(oTarget));
    AssignCommand(oAssociate, ActionDoCommand(ExecuteScript("m_calm_done", oAssociate)));
}

void M_CALM_RetryTask(object oAssociate, object oTarget, int iRetry)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget) || GetArea(oAssociate) != GetArea(oTarget) || !GetLocked(oTarget))
        return;
    ClearAllActions(FALSE, oAssociate);
    if (iRetry == 1)
        AssignCommand(oAssociate, ActionMoveToObject(oTarget, TRUE, 1.5f));
    else
        AssignCommand(oAssociate, ActionForceMoveToObject(oTarget, TRUE, 1.5f, 12.0f));
    AssignCommand(oAssociate, ActionUnlockObject(oTarget));
    AssignCommand(oAssociate, ActionDoCommand(ExecuteScript("m_calm_done", oAssociate)));
}

void M_CALM_UpdateTask(object oAssociate, object oPC, int iTick)
{
    object oTarget = GetLocalObject(oAssociate, M_CALM_LOCAL_TASK);
    if (GetIsPossessedFamiliar(oAssociate) || GetIsPC(oAssociate))
    {
        M_CALM_AbandonTask(oAssociate);
        return;
    }
    if (!GetIsObjectValid(oTarget) || GetArea(oTarget) != GetArea(oAssociate) || !GetLocked(oTarget))
    {
        M_CALM_CancelTask(oAssociate);
        return;
    }

    if (!M_CALM_IsVisibleFromPlayer(oTarget, oPC) || !M_CALM_IsRouteSafe(oAssociate, oTarget, oPC))
    {
        SetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER, iTick + 1);
        M_CALM_CancelTask(oAssociate);
        return;
    }

    if (GetLastAssociateCommand(oAssociate) != GetLocalInt(oAssociate, M_CALM_LOCAL_INITIAL_COMMAND))
    {
        SetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER, iTick + 1);
        M_CALM_ReleaseTask(oAssociate);
        return;
    }

    int iAction = GetCurrentAction(oAssociate);
    if (iAction != ACTION_MOVETOPOINT && iAction != ACTION_OPENDOOR && iAction != ACTION_DISABLETRAP && iAction != ACTION_RECOVERTRAP && iAction != ACTION_OPENLOCK)
    {
        SetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER, iTick + 1);
        M_CALM_ReleaseTask(oAssociate);
        return;
    }

    ExecuteScript("m_calm_pathcheck", oAssociate);
    object oBlockingDoor = GetLocalObject(oAssociate, M_CALM_LOCAL_BLOCKING_DOOR);
    object oInitialBlockingDoor = GetLocalObject(oAssociate, M_CALM_LOCAL_INITIAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor) && oBlockingDoor != oInitialBlockingDoor && oBlockingDoor != oTarget && GetArea(oBlockingDoor) == GetArea(oAssociate) && !GetIsOpen(oBlockingDoor))
    {
        SetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER, iTick + 1);
        M_CALM_CancelTask(oAssociate);
        return;
    }

    int iDistance = FloatToInt(GetDistanceBetween(oAssociate, oTarget) * 100.0f);
    int iLastDistance = GetLocalInt(oAssociate, M_CALM_LOCAL_LAST_DISTANCE);
    float fStall = GetLocalFloat(oAssociate, M_CALM_LOCAL_STALL);
    if (iLastDistance == 0 || iDistance < iLastDistance - 25 || (GetCurrentAction(oAssociate) == ACTION_OPENLOCK && iDistance < 300))
        fStall = 0.0f;
    else
        fStall += M_CALM_GetLockInterval(oPC);
    SetLocalInt(oAssociate, M_CALM_LOCAL_LAST_DISTANCE, iDistance);
    SetLocalFloat(oAssociate, M_CALM_LOCAL_STALL, fStall);

    if (fStall < M_CALM_STALL_SECONDS)
        return;

    int iRetry = GetLocalInt(oAssociate, M_CALM_LOCAL_RETRIES) + 1;
    if (iRetry <= M_CALM_MAX_PATH_RETRIES)
    {
        SetLocalInt(oAssociate, M_CALM_LOCAL_RETRIES, iRetry);
        SetLocalFloat(oAssociate, M_CALM_LOCAL_STALL, 0.0f);
        M_CALM_RetryTask(oAssociate, oTarget, iRetry);
        return;
    }

    SendMessageToPC(oPC, M_CALM_GetText(M_CALM_TEXT_PATH_FAILED, oPC) + " " + GetName(oTarget));
    SetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER, iTick + 1);
    M_CALM_CancelTask(oAssociate);
}

void M_CALM_UpdateAllTasks(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 2; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetLocalObject(oCreature, M_CALM_LOCAL_OWNER) == oPC)
        {
            if (M_CALM_IsManagedAssociate(oCreature, oPC))
                M_CALM_UpdateTask(oCreature, oPC, iTick);
            else
                M_CALM_AbandonTask(oCreature);
        }
    }
}

void M_CALM_AssignAvailableTasks(object oPC, int iTick)
{
    int iAssignment;
    for (iAssignment = 0; iAssignment < M_CALM_MAX_ASSIGNMENTS; iAssignment++)
    {
        object oTarget = M_CALM_FindNearestAvailableTarget(oPC, iTick);
        if (!GetIsObjectValid(oTarget))
            return;
        object oAssociate = GetLocalObject(oPC, M_CALM_LOCAL_NEXT_ASSOCIATE);
        if (!GetIsObjectValid(oAssociate))
            return;
        M_CALM_AssignTask(oAssociate, oTarget, oPC);
    }
}

int M_CALM_ShouldProtectTarget(object oTarget, object oPC)
{
    if (!GetLocalInt(oPC, M_CALM_LOCAL_ATTACK_SAFETY))
        return FALSE;
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    int iType = GetObjectType(oTarget);
    if (iType != OBJECT_TYPE_DOOR && iType != OBJECT_TYPE_PLACEABLE)
        return FALSE;
    if (M_CALM_IsReservationValid(oTarget))
        return TRUE;
    if (GetLocked(oTarget) && M_CALM_GroupHasAction(oPC, ACTION_OPENLOCK))
        return TRUE;
    if (GetIsTrapped(oTarget) && GetTrapActive(oTarget) && M_CALM_GroupHasAction(oPC, ACTION_DISABLETRAP))
        return TRUE;
    return GetLocalInt(oPC, M_CALM_LOCAL_ENABLED) && GetLocked(oTarget) && M_CALM_IsVisibleFromPlayer(oTarget, oPC);
}

void M_CALM_RunSafetyManager(object oPC)
{
    if (!GetLocalInt(oPC, M_CALM_LOCAL_ATTACK_SAFETY))
        return;
    int iIndex;
    for (iIndex = 2; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = M_CALM_GetGroupMember(oPC, iIndex);
        if (M_CALM_IsManagedAssociate(oCreature, oPC))
            ExecuteScript("m_calm_guard", oCreature);
    }
}

void M_CALM_ClearLegacyAutoDetectActor(object oActor, object oPC)
{
    if (!GetIsObjectValid(oActor) || GetLocalObject(oActor, M_CALM_LOCAL_DETECT_OWNER) != oPC)
        return;
    if (GetLocalInt(oActor, M_CALM_LOCAL_DETECT_OWNED) && GetActionMode(oActor, ACTION_MODE_DETECT))
        SetActionMode(oActor, ACTION_MODE_DETECT, FALSE);
    DeleteLocalObject(oActor, M_CALM_LOCAL_DETECT_OWNER);
    DeleteLocalInt(oActor, M_CALM_LOCAL_DETECT_OWNED);
    DeleteLocalFloat(oActor, M_CALM_LOCAL_DETECT_STILL_TIME);
    DeleteLocalLocation(oActor, M_CALM_LOCAL_DETECT_LAST_LOCATION);
}

void M_CALM_RemoveLegacyAutoDetect(object oPC)
{
    if (GetLocalInt(oPC, M_CALM_LOCAL_DETECT_REMOVED))
        return;
    object oLegacyActor = GetLocalObject(oPC, M_CALM_LOCAL_DETECT_ACTOR);
    if (GetIsObjectValid(oLegacyActor) && GetLocalInt(oPC, M_CALM_LOCAL_DETECT_OWNED) && GetActionMode(oLegacyActor, ACTION_MODE_DETECT))
        SetActionMode(oLegacyActor, ACTION_MODE_DETECT, FALSE);
    DeleteLocalObject(oPC, M_CALM_LOCAL_DETECT_ACTOR);
    int iIndex;
    int iOldCount = GetLocalInt(oPC, M_CALM_LOCAL_DETECT_COUNT);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
    {
        M_CALM_ClearLegacyAutoDetectActor(GetLocalObject(oPC, M_CALM_LOCAL_DETECT_MEMBER + IntToString(iIndex)), oPC);
        DeleteLocalObject(oPC, M_CALM_LOCAL_DETECT_MEMBER + IntToString(iIndex));
    }
    SetLocalInt(oPC, M_CALM_LOCAL_DETECT_COUNT, 0);
    for (iIndex = 1; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
        M_CALM_ClearLegacyAutoDetectActor(M_CALM_GetGroupMember(oPC, iIndex), oPC);
    DeleteLocalInt(oPC, M_CALM_LOCAL_DETECT_OWNED);
    DeleteLocalFloat(oPC, M_CALM_LOCAL_DETECT_STILL_TIME);
    DeleteLocalLocation(oPC, M_CALM_LOCAL_DETECT_LAST_LOCATION);
    SetLocalInt(oPC, M_CALM_LOCAL_AUTO_DETECT, FALSE);
    SetLocalInt(oPC, M_CALM_LOCAL_DETECT_REMOVED, TRUE);
}

void M_CALM_RunLockRegistryDispatcher(object oPC)
{
    M_CALM_BuildGroupCache(oPC);
    M_CALM_BuildLocksmithCache(oPC);
    int iTick = GetLocalInt(oPC, M_CALM_LOCAL_TICK);
    if (GetLocalInt(oPC, M_CALM_LOCAL_ENABLED))
        M_CALM_BuildVisibleLockCache(oPC, iTick);
    else
    {
        M_CALM_ClearCachedHighlights(oPC);
        SetLocalInt(oPC, M_CALM_LOCAL_LOCK_COUNT, 0);
    }
    if (GetLocalInt(oPC, M_CALM_LOCAL_DEBUG))
        SetLocalInt(oPC, M_CALM_LOCAL_REPORT_PENDING, TRUE);
    M_CALM_RemoveLegacyAutoDetect(oPC);
}

void M_CALM_RunLockDispatcher(object oPC)
{
    if (!M_CALM_IsRootPlayer(oPC))
        return;
    int iTick = GetLocalInt(oPC, M_CALM_LOCAL_TICK) + 1;
    SetLocalInt(oPC, M_CALM_LOCAL_TICK, iTick);
    M_CALM_UpdateCachedHighlights(oPC, iTick);
    M_CALM_RunSafetyManager(oPC);
    if (!GetLocalInt(oPC, M_CALM_LOCAL_ENABLED))
    {
        M_CALM_CancelAllTasks(oPC);
        return;
    }
    if (M_CALM_IsPossessingFamiliar(oPC))
    {
        if (!GetLocalInt(oPC, M_CALM_LOCAL_PAUSED))
            SendMessageToPC(oPC, M_CALM_GetText(M_CALM_TEXT_MODE_PAUSED, oPC));
        SetLocalInt(oPC, M_CALM_LOCAL_PAUSED, TRUE);
        M_CALM_CancelAllTasks(oPC);
        return;
    }
    DeleteLocalInt(oPC, M_CALM_LOCAL_PAUSED);
    if (M_CALM_IsPartyInCombat(oPC))
    {
        M_CALM_CancelAllTasks(oPC);
        return;
    }
    M_CALM_UpdateAllTasks(oPC, iTick);
    M_CALM_MarkManualReservations(oPC, iTick);
    if (GetLocalInt(oPC, M_CALM_LOCAL_DEBUG) && GetLocalInt(oPC, M_CALM_LOCAL_REPORT_PENDING))
    {
        int iAvailable = M_CALM_CountAvailableLocksmiths(oPC);
        int iAssignable = M_CALM_CountAssignableLocksmiths(oPC, iTick);
        SendMessageToPC(oPC, M_CALM_GetText(M_CALM_TEXT_SCAN_LOCKS, oPC) + IntToString(M_CALM_CountEligibleVisibleLocks(oPC, iTick)) + M_CALM_GetText(M_CALM_TEXT_SCAN_LOCKSMITHS, oPC) + IntToString(iAvailable) + ", assignable = " + IntToString(iAssignable) + ".");
        if (iAssignable == 0)
            M_CALM_ReportAssignmentFailure(oPC, iTick, iAvailable, iAssignable);
    }
    DeleteLocalInt(oPC, M_CALM_LOCAL_REPORT_PENDING);
    M_CALM_AssignAvailableTasks(oPC, iTick);
}

string M_CALM_GetDiagnosticObjectType(int iType)
{
    if (iType == OBJECT_TYPE_DOOR)
        return "door";
    if (iType == OBJECT_TYPE_PLACEABLE)
        return "placeable";
    if (iType == OBJECT_TYPE_TRIGGER)
        return "trigger";
    if (iType == OBJECT_TYPE_CREATURE)
        return "creature";
    return "other";
}

int M_CALM_IsCachedLock(object oPC, object oTarget)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetVisibleLockCount(oPC); iIndex++)
    {
        if (M_CALM_GetVisibleLock(oPC, iIndex) == oTarget)
            return TRUE;
    }
    return FALSE;
}

int M_CALM_GetDiagnosticActionPossible(object oActor, object oTarget)
{
    SetLocalObject(oActor, M_CALM_LOCAL_CHECK_TARGET, oTarget);
    DeleteLocalInt(oActor, M_CALM_LOCAL_CHECK_RESULT);
    ExecuteScript("m_calm_diagact", oActor);
    int bResult = GetLocalInt(oActor, M_CALM_LOCAL_CHECK_RESULT);
    DeleteLocalObject(oActor, M_CALM_LOCAL_CHECK_TARGET);
    DeleteLocalInt(oActor, M_CALM_LOCAL_CHECK_RESULT);
    return bResult;
}

void M_CALM_ReportLOSProbes(object oPC, object oTarget)
{
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oTarget) || GetArea(oPC) != GetArea(oTarget))
        return;
    vector vSource = GetPositionFromLocation(GetLocation(oPC));
    vector vTarget = GetPositionFromLocation(GetLocation(oTarget));
    vSource.z += 1.0f;
    vTarget.z += 1.0f;
    vector vTowardPlayer = vSource - vTarget;
    vTowardPlayer.z = 0.0f;
    if (VectorMagnitude(vTowardPlayer) <= 0.01f)
        return;
    vTowardPlayer = VectorNormalize(vTowardPlayer);
    vector vProbe025 = vTarget + vTowardPlayer * 0.25f;
    vector vProbe050 = vTarget + vTowardPlayer * 0.50f;
    vector vProbe100 = vTarget + vTowardPlayer;
    SendMessageToPC(oPC, "los.probes object=" + IntToString(LineOfSightObject(oPC, oTarget)) + " center=" + IntToString(LineOfSightVector(vSource, vTarget)) + " toward_025=" + IntToString(LineOfSightVector(vSource, vProbe025)) + " toward_050=" + IntToString(LineOfSightVector(vSource, vProbe050)) + " toward_100=" + IntToString(LineOfSightVector(vSource, vProbe100)) + " lock_los=" + IntToString(M_CALM_HasLineOfSightToLock(oTarget, oPC)) + " facing=" + FloatToString(GetFacingFromLocation(GetLocation(oTarget)), 0, 2));
    SendMessageToPC(oPC, "los.vectors source=[" + FloatToString(vSource.x, 0, 2) + "," + FloatToString(vSource.y, 0, 2) + "," + FloatToString(vSource.z, 0, 2) + "] target=[" + FloatToString(vTarget.x, 0, 2) + "," + FloatToString(vTarget.y, 0, 2) + "," + FloatToString(vTarget.z, 0, 2) + "]");
}

void M_CALM_ReportObject(object oPC, object oTarget)
{
    if (!M_CALM_IsRootPlayer(oPC) || !GetIsObjectValid(oTarget))
        return;
    M_CALM_BuildGroupCache(oPC);
    M_CALM_BuildLocksmithCache(oPC);
    int iType = GetObjectType(oTarget);
    int iTick = GetLocalInt(oPC, M_CALM_LOCAL_TICK);
    SendMessageToPC(oPC, "=== M_CALM object diagnostics " + M_CALM_VERSION + " ===");
    SendMessageToPC(oPC, "object.id=" + ObjectToString(oTarget) + " uuid=" + GetObjectUUID(oTarget) + " type=" + IntToString(iType) + "/" + M_CALM_GetDiagnosticObjectType(iType));
    SendMessageToPC(oPC, "name=\"" + GetName(oTarget) + "\" tag=\"" + GetTag(oTarget) + "\" resref=\"" + GetResRef(oTarget) + "\"");
    SendMessageToPC(oPC, "area.same=" + IntToString(GetArea(oTarget) == GetArea(oPC)) + " distance=" + FloatToString(GetDistanceBetween(oPC, oTarget), 0, 2) + " radius=" + FloatToString(M_CALM_GetSearchRadius(oPC), 0, 2) + " direct_los=" + IntToString(LineOfSightObject(oPC, oTarget)) + " require_los=" + IntToString(GetLocalInt(oPC, M_CALM_LOCAL_REQUIRE_LOS)));
    if (iType == OBJECT_TYPE_DOOR || iType == OBJECT_TYPE_PLACEABLE)
    {
        M_CALM_ReportLOSProbes(oPC, oTarget);
        SendMessageToPC(oPC, "state.locked=" + IntToString(GetLocked(oTarget)) + " open=" + IntToString(GetIsOpen(oTarget)) + " usable=" + IntToString(GetUseableFlag(oTarget)) + " plot=" + IntToString(GetPlotFlag(oTarget)) + " inventory=" + IntToString(GetHasInventory(oTarget)));
        SendMessageToPC(oPC, "lock.key_required=" + IntToString(GetLockKeyRequired(oTarget)) + " key_tag=\"" + GetLockKeyTag(oTarget) + "\" unlock_dc=" + IntToString(GetLockUnlockDC(oTarget)) + " lockable=" + IntToString(GetLockLockable(oTarget)));
        SendMessageToPC(oPC, "filter.candidate=" + IntToString(M_CALM_IsLockCandidate(oTarget, oPC, iTick)) + " visible=" + IntToString(M_CALM_IsVisibleFromPlayer(oTarget, oPC)) + " cached=" + IntToString(M_CALM_IsCachedLock(oPC, oTarget)) + " reserved=" + IntToString(M_CALM_IsReservationValid(oTarget)) + " manual_tick=" + IntToString(GetLocalInt(oTarget, M_CALM_LOCAL_MANUAL_TICK)) + " retry_after=" + IntToString(GetLocalInt(oTarget, M_CALM_LOCAL_RETRY_AFTER)) + " current_tick=" + IntToString(iTick));
        SendMessageToPC(oPC, "trap.present=" + IntToString(GetIsTrapped(oTarget)) + " active=" + IntToString(GetTrapActive(oTarget)) + " detected=" + IntToString(M_CALM_IsDetectedActiveTrap(oTarget, oPC)) + " flagged=" + IntToString(GetTrapFlagged(oTarget)) + " detectable=" + IntToString(GetTrapDetectable(oTarget)) + " disarmable=" + IntToString(GetTrapDisarmable(oTarget)));
    }
    int iIndex;
    for (iIndex = 1; iIndex <= M_CALM_GetGroupCount(oPC); iIndex++)
    {
        object oActor = M_CALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oActor))
            SendMessageToPC(oPC, "actor[" + IntToString(iIndex) + "].id=" + ObjectToString(oActor) + " name=\"" + GetName(oActor) + "\" pc=" + IntToString(GetIsPC(oActor)) + " commandable=" + IntToString(GetCommandable(oActor)) + " action=" + IntToString(GetCurrentAction(oActor)) + " open_lock=" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oActor)) + "/" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oActor, TRUE)) + " can_take=" + IntToString(M_CALM_CanTakeTask(oActor, oPC)) + " can_unlock=" + IntToString(M_CALM_CanUnlock(oActor, oTarget)) + " route_safe=" + IntToString(M_CALM_IsRouteSafe(oActor, oTarget, oPC)) + " engine_action=" + IntToString(M_CALM_GetDiagnosticActionPossible(oActor, oTarget)));
    }
    SendMessageToPC(oPC, "=== end M_CALM diagnostics ===");
}

void M_CALM_ScheduleDispatcherBurst(object oPC, string sScript, float fInterval)
{
    float fDelay = fInterval;
    int iCount = 0;
    while (fDelay < M_CALM_BASE_HEARTBEAT_SECONDS && iCount < 60)
    {
        DelayCommand(fDelay, ExecuteScript(sScript, oPC));
        fDelay += fInterval;
        iCount++;
    }
}

void M_CALM_RunSchedulerDispatcher(object oPC)
{
    if (GetLocalInt(oPC, M_CALM_LOCAL_ENABLED) || GetLocalInt(oPC, M_CALM_LOCAL_ATTACK_SAFETY))
        M_CALM_ScheduleDispatcherBurst(oPC, "m_calm_lock", M_CALM_GetLockInterval(oPC));
}

void M_CALM_Heartbeat(object oPC)
{
    if (!M_CALM_IsRootPlayer(oPC))
        return;
    M_CALM_InitializeSettings(oPC);
    M_CALM_InstallActivateHook();
    M_CALM_EnsureModeItem(oPC);
    ExecuteScript("m_calm_registry", oPC);
    ExecuteScript("m_calm_lock", oPC);
    ExecuteScript("m_calm_schedule", oPC);
    if (!GetLocalInt(oPC, M_CALM_LOCAL_INSTALLED))
    {
        SetLocalInt(oPC, M_CALM_LOCAL_INSTALLED, TRUE);
        SendMessageToPC(oPC, M_CALM_GetText(M_CALM_TEXT_INSTALLED, oPC) + " " + M_CALM_VERSION);
    }
}

void M_CALM_UnlockActionCompleted(object oAssociate)
{
    object oTarget = GetLocalObject(oAssociate, M_CALM_LOCAL_TASK);
    if (GetIsObjectValid(oTarget) && GetLocked(oTarget))
        return;
    object oOwner = GetLocalObject(oAssociate, M_CALM_LOCAL_OWNER);
    M_CALM_ClearHighlight(oTarget);
    ClearAllActions(FALSE, oAssociate);
    M_CALM_ReleaseTask(oAssociate);
    if (M_CALM_IsRootPlayer(oOwner))
        ExecuteScript("m_calm_lock", oOwner);
    if (!GetIsObjectValid(GetLocalObject(oAssociate, M_CALM_LOCAL_TASK)))
        M_CALM_RestoreNaturalState(oAssociate, oOwner);
}
