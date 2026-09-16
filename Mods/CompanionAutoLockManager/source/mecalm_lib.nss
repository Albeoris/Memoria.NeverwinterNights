// Companion Auto-Lock Manager (MECALM)
// Shared implementation. All resource names use the uncommon "mecalm_" prefix.

#include "memoria_core"
#include "memoria_group"
#include "memoria_locale"
#include "memoria_i18n"

const string MECALM_VERSION = "1.2.7";
const string MECALM_I18N_PREFIX = "mecalm";
const string MECALM_LOCAL_INSTALLED = "MECALM_INSTALLED";
const string MECALM_LOCAL_ENABLED = "MECALM_MODE_ENABLED";
const string MECALM_LOCAL_PAUSED = "MECALM_MODE_PAUSED";
const string MECALM_LOCAL_TICK = "MECALM_MANAGER_TICK";
const string MECALM_LOCAL_TASK = "MECALM_UNLOCK_TASK";
const string MECALM_LOCAL_ASSIGNEE = "MECALM_UNLOCK_ASSIGNEE";
const string MECALM_LOCAL_OWNER = "MECALM_UNLOCK_OWNER";
const string MECALM_LOCAL_STALL = "MECALM_PATH_STALL";
const string MECALM_LOCAL_RETRIES = "MECALM_PATH_RETRIES";
const string MECALM_LOCAL_LAST_DISTANCE = "MECALM_PATH_LAST_DISTANCE";
const string MECALM_LOCAL_RETRY_AFTER = "MECALM_RETRY_AFTER";
const string MECALM_LOCAL_MANUAL_TICK = "MECALM_MANUAL_TICK";
const string MECALM_LOCAL_CHECK_TARGET = "MECALM_CHECK_TARGET";
const string MECALM_LOCAL_CHECK_RESULT = "MECALM_CHECK_RESULT";
const string MECALM_LOCAL_BLOCKING_DOOR = "MECALM_BLOCKING_DOOR";
const string MECALM_LOCAL_INITIAL_BLOCKING_DOOR = "MECALM_INITIAL_BLOCKING_DOOR";
const string MECALM_LOCAL_INITIAL_COMMAND = "MECALM_INITIAL_COMMAND";
const string MECALM_LOCAL_NEXT_ASSOCIATE = "MECALM_NEXT_ASSOCIATE";
const string MECALM_LOCAL_LANGUAGE = "MECALM_LANGUAGE";
const string MECALM_LOCAL_GROUP_COUNT = "MECALM_GROUP_COUNT";
const string MECALM_LOCAL_GROUP_MEMBER = "MECALM_GROUP_MEMBER_";
const string MECALM_LOCAL_LOCK_COUNT = "MECALM_LOCK_COUNT";
const string MECALM_LOCAL_LOCK_MEMBER = "MECALM_LOCK_MEMBER_";
const string MECALM_LOCAL_LOCKSMITH_COUNT = "MECALM_LOCKSMITH_COUNT";
const string MECALM_LOCAL_LOCKSMITH_MEMBER = "MECALM_LOCKSMITH_MEMBER_";
const string MECALM_LOCAL_REPORT_PENDING = "MECALM_REPORT_PENDING";
const string MECALM_LOCAL_SETTINGS_INITIALIZED = "MECALM_SETTINGS_INITIALIZED";
const string MECALM_LOCAL_SEARCH_RADIUS = "MECALM_CFG_SEARCH_RADIUS";
const string MECALM_LOCAL_LOCK_INTERVAL = "MECALM_CFG_LOCK_INTERVAL";
const string MECALM_LOCAL_REQUIRE_LOS = "MECALM_CFG_REQUIRE_LOS";
const string MECALM_LOCAL_ATTACK_SAFETY = "MECALM_CFG_ATTACK_SAFETY";
const string MECALM_LOCAL_HIGHLIGHT = "MECALM_CFG_HIGHLIGHT";
const string MECALM_LOCAL_OVERHEAD_MESSAGES = "MECALM_CFG_OVERHEAD_MESSAGES";
const string MECALM_LOCAL_DEBUG = "MECALM_CFG_DEBUG";
const string MECALM_LOCAL_AUTO_DETECT = "MECALM_CFG_AUTO_DETECT";
const string MECALM_LOCAL_DETECT_ACTOR = "MECALM_DETECT_ACTOR";
const string MECALM_LOCAL_DETECT_COUNT = "MECALM_DETECT_COUNT";
const string MECALM_LOCAL_DETECT_MEMBER = "MECALM_DETECT_MEMBER_";
const string MECALM_LOCAL_DETECT_OWNER = "MECALM_DETECT_OWNER";
const string MECALM_LOCAL_DETECT_LAST_LOCATION = "MECALM_DETECT_LAST_LOCATION";
const string MECALM_LOCAL_DETECT_STILL_TIME = "MECALM_DETECT_STILL_TIME";
const string MECALM_LOCAL_DETECT_OWNED = "MECALM_DETECT_OWNED";
const string MECALM_LOCAL_DETECT_REMOVED = "MECALM_DETECT_REMOVED";
const string MECALM_LOCAL_HIGHLIGHTED = "MECALM_HIGHLIGHTED";
const string MECALM_ASSOCIATE_STATE = "NW_ASSOCIATE_MASTER";
const string MECALM_ASSOCIATE_MOVEMENT_MODE = "NW_COM_MODE_MOVEMENT";
const string MECALM_HIGHLIGHT_EFFECT_TAG = "MECALM_LOCK_GLOW_9F31";

const float MECALM_BASE_HEARTBEAT_SECONDS = 6.0f;
const float MECALM_DEFAULT_SEARCH_RADIUS = 15.0f;
const float MECALM_DEFAULT_LOCK_INTERVAL = 1.0f;
const int MECALM_MAX_ASSIGNMENTS = 32;
const float MECALM_STALL_SECONDS = 3.0f;
const int MECALM_MAX_PATH_RETRIES = 2;
const int MECALM_MAX_GROUP_MEMBERS = 32;
const int MECALM_MAX_VISIBLE_LOCKS = 64;
const string MECALM_TEXT_MODE_PAUSED = "familiar_pause_message";
const string MECALM_TEXT_PATH_FAILED = "task_released_message";
const string MECALM_TEXT_INSTALLED = "installed_message";
const string MECALM_TEXT_SCAN_LOCKS = "scan_locks_message";
const string MECALM_TEXT_SCAN_LOCKSMITHS = "scan_locksmiths_message";
const string MECALM_TEXT_LOCK_CLAIM = "lock_claim_message";

object MECALM_GetRootMaster(object oCreature)
{
    return MEMORIA_GetRootPlayer(oCreature);
}

int MECALM_IsRootPlayer(object oCreature)
{
    return MEMORIA_IsRootPlayerCharacter(oCreature);
}

int MECALM_IsGroupCreature(object oCreature, object oPC)
{
    return MEMORIA_IsPartyCreature(oCreature, oPC);
}

int MECALM_IsManagedAssociate(object oCreature, object oPC)
{
    return MECALM_IsGroupCreature(oCreature, oPC) && oCreature != oPC && !GetIsPC(oCreature) && !GetIsDead(oCreature) && GetArea(oCreature) == GetArea(oPC);
}

int MECALM_IsPossessingFamiliar(object oPC)
{
    return MEMORIA_IsPossessingFamiliar(oPC);
}

void MECALM_InitializeSettings(object oPC)
{
    if (GetLocalInt(oPC, MECALM_LOCAL_SETTINGS_INITIALIZED))
        return;
    SetLocalInt(oPC, MECALM_LOCAL_SETTINGS_INITIALIZED, TRUE);
    SetLocalFloat(oPC, MECALM_LOCAL_SEARCH_RADIUS, MECALM_DEFAULT_SEARCH_RADIUS);
    SetLocalFloat(oPC, MECALM_LOCAL_LOCK_INTERVAL, MECALM_DEFAULT_LOCK_INTERVAL);
    SetLocalInt(oPC, MECALM_LOCAL_REQUIRE_LOS, TRUE);
    SetLocalInt(oPC, MECALM_LOCAL_ATTACK_SAFETY, TRUE);
    SetLocalInt(oPC, MECALM_LOCAL_HIGHLIGHT, TRUE);
    SetLocalInt(oPC, MECALM_LOCAL_OVERHEAD_MESSAGES, TRUE);
    SetLocalInt(oPC, MECALM_LOCAL_DEBUG, FALSE);
    SetLocalInt(oPC, MECALM_LOCAL_AUTO_DETECT, FALSE);
}

float MECALM_GetSearchRadius(object oPC)
{
    MECALM_InitializeSettings(oPC);
    return GetLocalFloat(oPC, MECALM_LOCAL_SEARCH_RADIUS);
}

float MECALM_GetLockInterval(object oPC)
{
    MECALM_InitializeSettings(oPC);
    return GetLocalFloat(oPC, MECALM_LOCAL_LOCK_INTERVAL);
}

object MECALM_GetGroupMember(object oPC, int iIndex)
{
    return MEMORIA_GetGroupMember(oPC, MECALM_LOCAL_GROUP_MEMBER, iIndex);
}

int MECALM_GetGroupCount(object oPC)
{
    return MEMORIA_GetGroupCount(oPC, MECALM_LOCAL_GROUP_COUNT);
}

int MECALM_IsGroupMemberCached(object oPC, object oCreature)
{
    return MEMORIA_IsGroupMemberCached(oPC, oCreature, MECALM_LOCAL_GROUP_COUNT, MECALM_LOCAL_GROUP_MEMBER);
}

void MECALM_AddGroupMember(object oPC, object oCreature)
{
    MEMORIA_AddGroupMember(oPC, oCreature, MECALM_LOCAL_GROUP_COUNT, MECALM_LOCAL_GROUP_MEMBER, MECALM_MAX_GROUP_MEMBERS);
}

void MECALM_BuildGroupCache(object oPC)
{
    MEMORIA_BuildGroupCache(oPC, MECALM_LOCAL_GROUP_COUNT, MECALM_LOCAL_GROUP_MEMBER, MECALM_MAX_GROUP_MEMBERS);
}

string MECALM_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, MECALM_LOCAL_LANGUAGE);
}

string MECALM_GetText(string sKey, object oPC)
{
    return MEMORIA_I18N_GetText(MECALM_I18N_PREFIX, MECALM_GetLanguage(oPC), sKey);
}

int MECALM_IsPartyInCombat(object oPC)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetGroupMember(oPC, iIndex);
        if (MECALM_IsGroupCreature(oCreature, oPC) && GetArea(oCreature) == GetArea(oPC) && GetIsInCombat(oCreature))
            return TRUE;
    }
    return FALSE;
}

int MECALM_GroupHasAction(object oPC, int iAction)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetGroupMember(oPC, iIndex);
        if (MECALM_IsGroupCreature(oCreature, oPC) && GetArea(oCreature) == GetArea(oPC) && GetCurrentAction(oCreature) == iAction)
            return TRUE;
    }
    return FALSE;
}

int MECALM_HasLineOfSightToLock(object oTarget, object oPC)
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

int MECALM_IsVisibleFromPlayer(object oTarget, object oPC)
{
    if (!GetIsObjectValid(oTarget) || !GetIsObjectValid(oPC))
        return FALSE;
    if (GetArea(oTarget) != GetArea(oPC) || GetDistanceBetween(oTarget, oPC) > MECALM_GetSearchRadius(oPC))
        return FALSE;
    return !GetLocalInt(oPC, MECALM_LOCAL_REQUIRE_LOS) || MECALM_HasLineOfSightToLock(oTarget, oPC);
}

int MECALM_IsDetectedActiveTrap(object oTarget, object oPC)
{
    if (!GetIsTrapped(oTarget) || !GetTrapActive(oTarget))
        return FALSE;
    if (GetTrapFlagged(oTarget))
        return TRUE;

    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetTrapDetectedBy(oTarget, oCreature))
            return TRUE;
    }
    return FALSE;
}

int MECALM_IsLockObject(object oTarget)
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

int MECALM_IsLockCandidate(object oTarget, object oPC, int iTick)
{
    return MECALM_IsLockObject(oTarget) && GetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER) <= iTick;
}

int MECALM_CanUnlock(object oAssociate, object oTarget)
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

int MECALM_IsRouteSafe(object oAssociate, object oTarget, object oPC)
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
            if (MECALM_IsDetectedActiveTrap(oObstacle, oPC))
                return FALSE;
        }
        oObstacle = GetNextObjectInShape(SHAPE_SPELLCYLINDER, fDistance, lTarget, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);
    }
    return TRUE;
}

void MECALM_AbandonTask(object oAssociate);

int MECALM_IsReservationValid(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    object oAssignee = GetLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE);
    if (!GetIsObjectValid(oAssignee) || GetIsDead(oAssignee) || GetArea(oAssignee) != GetArea(oTarget))
    {
        DeleteLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE);
        if (GetIsObjectValid(oAssignee))
            MECALM_AbandonTask(oAssignee);
        return FALSE;
    }
    object oOwner = GetLocalObject(oAssignee, MECALM_LOCAL_OWNER);
    if (!GetIsObjectValid(oOwner) || !MECALM_IsManagedAssociate(oAssignee, oOwner))
    {
        DeleteLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE);
        MECALM_AbandonTask(oAssignee);
        return FALSE;
    }
    if (GetLocalObject(oAssignee, MECALM_LOCAL_TASK) != oTarget)
    {
        DeleteLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE);
        return FALSE;
    }
    return TRUE;
}

object MECALM_GetLikelyManualLock(object oActor)
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

void MECALM_MarkManualReservations(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oTarget = MECALM_GetLikelyManualLock(MECALM_GetGroupMember(oPC, iIndex));
        if (GetIsObjectValid(oTarget))
            SetLocalInt(oTarget, MECALM_LOCAL_MANUAL_TICK, iTick);
    }
}

int MECALM_CanTakeTask(object oAssociate, object oPC)
{
    if (!MECALM_IsManagedAssociate(oAssociate, oPC) || GetIsObjectValid(GetLocalObject(oAssociate, MECALM_LOCAL_TASK)))
        return FALSE;
    if (!GetCommandable(oAssociate) || GetIsResting(oAssociate) || IsInConversation(oAssociate))
        return FALSE;

    int iAction = GetCurrentAction(oAssociate);
    return iAction == ACTION_INVALID || iAction == ACTION_FOLLOW || iAction == ACTION_WAIT || iAction == ACTION_RANDOMWALK;
}

object MECALM_GetVisibleLock(object oPC, int iIndex)
{
    return GetLocalObject(oPC, MECALM_LOCAL_LOCK_MEMBER + IntToString(iIndex));
}

int MECALM_GetVisibleLockCount(object oPC)
{
    return GetLocalInt(oPC, MECALM_LOCAL_LOCK_COUNT);
}

int MECALM_CountEligibleVisibleLocks(object oPC, int iTick)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECALM_GetVisibleLock(oPC, iIndex);
        if (MECALM_IsLockCandidate(oTarget, oPC, iTick) && MECALM_IsVisibleFromPlayer(oTarget, oPC))
            iCount++;
    }
    return iCount;
}

object MECALM_GetLocksmith(object oPC, int iIndex)
{
    return GetLocalObject(oPC, MECALM_LOCAL_LOCKSMITH_MEMBER + IntToString(iIndex));
}

int MECALM_GetLocksmithCount(object oPC)
{
    return GetLocalInt(oPC, MECALM_LOCAL_LOCKSMITH_COUNT);
}

void MECALM_BuildLocksmithCache(object oPC)
{
    int iIndex;
    int iOldCount = MECALM_GetLocksmithCount(oPC);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
        DeleteLocalObject(oPC, MECALM_LOCAL_LOCKSMITH_MEMBER + IntToString(iIndex));
    SetLocalInt(oPC, MECALM_LOCAL_LOCKSMITH_COUNT, 0);
    for (iIndex = 2; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oAssociate = MECALM_GetGroupMember(oPC, iIndex);
        if (MECALM_IsManagedAssociate(oAssociate, oPC) && GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) > 0)
        {
            int iCount = MECALM_GetLocksmithCount(oPC) + 1;
            SetLocalInt(oPC, MECALM_LOCAL_LOCKSMITH_COUNT, iCount);
            SetLocalObject(oPC, MECALM_LOCAL_LOCKSMITH_MEMBER + IntToString(iCount), oAssociate);
        }
    }
}

void MECALM_ClearHighlight(object oTarget)
{
    if (!GetIsObjectValid(oTarget) || !GetLocalInt(oTarget, MECALM_LOCAL_HIGHLIGHTED))
        return;
    effect eEffect = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEffect))
    {
        effect eNext = GetNextEffect(oTarget);
        if (GetEffectTag(eEffect) == MECALM_HIGHLIGHT_EFFECT_TAG)
            RemoveEffect(oTarget, eEffect);
        eEffect = eNext;
    }
    DeleteLocalInt(oTarget, MECALM_LOCAL_HIGHLIGHTED);
}

void MECALM_SetHighlight(object oTarget)
{
    if (!GetIsObjectValid(oTarget) || GetLocalInt(oTarget, MECALM_LOCAL_HIGHLIGHTED))
        return;
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, TagEffect(EffectVisualEffect(VFX_DUR_GLOW_GREY), MECALM_HIGHLIGHT_EFFECT_TAG), oTarget);
    SetLocalInt(oTarget, MECALM_LOCAL_HIGHLIGHTED, TRUE);
}

void MECALM_ClearCachedHighlights(object oPC)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetVisibleLockCount(oPC); iIndex++)
        MECALM_ClearHighlight(MECALM_GetVisibleLock(oPC, iIndex));
}

void MECALM_BuildVisibleLockCache(object oPC, int iTick)
{
    int iIndex;
    int iOldCount = MECALM_GetVisibleLockCount(oPC);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
    {
        object oOldTarget = MECALM_GetVisibleLock(oPC, iIndex);
        if (!GetLocalInt(oPC, MECALM_LOCAL_HIGHLIGHT) || !MECALM_IsLockObject(oOldTarget) || GetArea(oOldTarget) != GetArea(oPC) || GetDistanceBetween(oOldTarget, oPC) > MECALM_GetSearchRadius(oPC))
            MECALM_ClearHighlight(oOldTarget);
        DeleteLocalObject(oPC, MECALM_LOCAL_LOCK_MEMBER + IntToString(iIndex));
    }
    SetLocalInt(oPC, MECALM_LOCAL_LOCK_COUNT, 0);

    float fRadius = MECALM_GetSearchRadius(oPC);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(oPC), FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while (GetIsObjectValid(oTarget) && MECALM_GetVisibleLockCount(oPC) < MECALM_MAX_VISIBLE_LOCKS)
    {
        if (MECALM_IsLockObject(oTarget))
        {
            int iCount = MECALM_GetVisibleLockCount(oPC) + 1;
            SetLocalInt(oPC, MECALM_LOCAL_LOCK_COUNT, iCount);
            SetLocalObject(oPC, MECALM_LOCAL_LOCK_MEMBER + IntToString(iCount), oTarget);
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(oPC), FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}

void MECALM_UpdateCachedHighlights(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECALM_GetVisibleLock(oPC, iIndex);
        if (GetLocalInt(oPC, MECALM_LOCAL_HIGHLIGHT) && MECALM_IsLockCandidate(oTarget, oPC, iTick) && MECALM_IsVisibleFromPlayer(oTarget, oPC))
            MECALM_SetHighlight(oTarget);
        else
            MECALM_ClearHighlight(oTarget);
    }
}

object MECALM_FindBestTarget(object oAssociate, object oPC, int iTick)
{
    object oBest = OBJECT_INVALID;
    float fBestDistance = 1000000.0f;
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECALM_GetVisibleLock(oPC, iIndex);
        if (MECALM_IsLockCandidate(oTarget, oPC, iTick) && MECALM_IsVisibleFromPlayer(oTarget, oPC) && !MECALM_IsReservationValid(oTarget) && GetLocalInt(oTarget, MECALM_LOCAL_MANUAL_TICK) != iTick)
        {
            float fDistance = GetDistanceBetween(oAssociate, oTarget);
            if (fDistance < fBestDistance && MECALM_CanUnlock(oAssociate, oTarget) && MECALM_IsRouteSafe(oAssociate, oTarget, oPC))
            {
                oBest = oTarget;
                fBestDistance = fDistance;
            }
        }
    }
    return oBest;
}

object MECALM_FindNearestAvailableTarget(object oPC, int iTick)
{
    object oBestTarget = OBJECT_INVALID;
    object oBestAssociate = OBJECT_INVALID;
    float fBestDistance = 1000000.0f;
    int iBestSkill = 1000000;
    int iTargetIndex;
    for (iTargetIndex = 1; iTargetIndex <= MECALM_GetVisibleLockCount(oPC); iTargetIndex++)
    {
        object oTarget = MECALM_GetVisibleLock(oPC, iTargetIndex);
        if (MECALM_IsLockCandidate(oTarget, oPC, iTick) && MECALM_IsVisibleFromPlayer(oTarget, oPC) && !MECALM_IsReservationValid(oTarget) && GetLocalInt(oTarget, MECALM_LOCAL_MANUAL_TICK) != iTick)
        {
            int iAssociateIndex;
            for (iAssociateIndex = 1; iAssociateIndex <= MECALM_GetLocksmithCount(oPC); iAssociateIndex++)
            {
                object oAssociate = MECALM_GetLocksmith(oPC, iAssociateIndex);
                if (MECALM_CanTakeTask(oAssociate, oPC))
                {
                    float fDistance = GetDistanceBetween(oAssociate, oTarget);
                    int iSkill = GetSkillRank(SKILL_OPEN_LOCK, oAssociate);
                    if ((fDistance < fBestDistance || (fDistance == fBestDistance && iSkill < iBestSkill)) && MECALM_CanUnlock(oAssociate, oTarget) && MECALM_IsRouteSafe(oAssociate, oTarget, oPC))
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
    DeleteLocalObject(oPC, MECALM_LOCAL_NEXT_ASSOCIATE);
    if (GetIsObjectValid(oBestAssociate))
        SetLocalObject(oPC, MECALM_LOCAL_NEXT_ASSOCIATE, oBestAssociate);
    return oBestTarget;
}

int MECALM_CountAvailableLocksmiths(object oPC)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetLocksmithCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetLocksmith(oPC, iIndex);
        if (MECALM_CanTakeTask(oCreature, oPC))
            iCount++;
    }
    return iCount;
}

int MECALM_CountAssignableLocksmiths(object oPC, int iTick)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetLocksmithCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetLocksmith(oPC, iIndex);
        if (MECALM_CanTakeTask(oCreature, oPC) && GetIsObjectValid(MECALM_FindBestTarget(oCreature, oPC, iTick)))
            iCount++;
    }
    return iCount;
}

string MECALM_AppendDiagnosticReason(string sReasons, string sReason)
{
    if (sReasons == "")
        return sReason;
    return sReasons + "," + sReason;
}

string MECALM_GetLocksmithRejectionReasons(object oAssociate, object oPC)
{
    string sReasons = "";
    if (!GetIsObjectValid(oAssociate))
        return "invalid_object";
    if (GetObjectType(oAssociate) != OBJECT_TYPE_CREATURE)
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "not_creature");
    if (MECALM_GetRootMaster(oAssociate) != oPC)
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "different_root_master");
    if (oAssociate == oPC)
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "player_character");
    if (GetIsPC(oAssociate))
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "player_controlled");
    if (GetIsDead(oAssociate))
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "dead");
    if (GetArea(oAssociate) != GetArea(oPC))
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "different_area");
    if (GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) <= 0)
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "open_lock_untrained");
    if (GetIsObjectValid(GetLocalObject(oAssociate, MECALM_LOCAL_TASK)))
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "has_mecalm_task");
    if (!GetCommandable(oAssociate))
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "not_commandable");
    if (GetIsResting(oAssociate))
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "resting");
    if (IsInConversation(oAssociate))
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "in_conversation");
    int iAction = GetCurrentAction(oAssociate);
    if (iAction != ACTION_INVALID && iAction != ACTION_FOLLOW && iAction != ACTION_WAIT && iAction != ACTION_RANDOMWALK)
        sReasons = MECALM_AppendDiagnosticReason(sReasons, "busy_action=" + IntToString(iAction));
    if (sReasons == "")
        return "none";
    return sReasons;
}

void MECALM_ReportTargetRejections(object oAssociate, object oPC, int iTick, int iAllyIndex)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECALM_GetVisibleLock(oPC, iIndex);
        int bValid = GetIsObjectValid(oTarget);
        int bLock = bValid && MECALM_IsLockObject(oTarget);
        int bRetryReady = bValid && GetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER) <= iTick;
        int bSameArea = bValid && GetArea(oTarget) == GetArea(oPC);
        float fDistance = bSameArea ? GetDistanceBetween(oTarget, oPC) : -1.0f;
        int bInRange = bSameArea && fDistance <= MECALM_GetSearchRadius(oPC);
        int bObjectLOS = bSameArea && LineOfSightObject(oPC, oTarget);
        int bLockLOS = bSameArea && MECALM_HasLineOfSightToLock(oTarget, oPC);
        int bVisible = bInRange && (!GetLocalInt(oPC, MECALM_LOCAL_REQUIRE_LOS) || bLockLOS);
        int bReserved = bValid && MECALM_IsReservationValid(oTarget);
        int bManual = bValid && GetLocalInt(oTarget, MECALM_LOCAL_MANUAL_TICK) == iTick;
        int bCanUnlock = bValid && MECALM_CanUnlock(oAssociate, oTarget);
        int bRouteSafe = bValid && MECALM_IsRouteSafe(oAssociate, oTarget, oPC);
        int bAssignable = bLock && bRetryReady && bVisible && !bReserved && !bManual && bCanUnlock && bRouteSafe;
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "]: id=" + ObjectToString(oTarget) + " name=\"" + GetName(oTarget) + "\" valid=" + IntToString(bValid) + " lock=" + IntToString(bLock) + " retry_ready=" + IntToString(bRetryReady) + " retry_after=" + IntToString(GetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER)) + ".");
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "].visibility: same_area=" + IntToString(bSameArea) + " distance=" + FloatToString(fDistance, 0, 2) + " radius=" + FloatToString(MECALM_GetSearchRadius(oPC), 0, 2) + " require_los=" + IntToString(GetLocalInt(oPC, MECALM_LOCAL_REQUIRE_LOS)) + " object_los=" + IntToString(bObjectLOS) + " lock_los=" + IntToString(bLockLOS) + " visible=" + IntToString(bVisible) + ".");
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "].pair: reserved=" + IntToString(bReserved) + " manual=" + IntToString(bManual) + " can_unlock=" + IntToString(bCanUnlock) + " route_safe=" + IntToString(bRouteSafe) + " assignable=" + IntToString(bAssignable) + ".");
    }
}

void MECALM_ReportAssignmentFailure(object oPC, int iTick, int iAvailable, int iAssignable)
{
    SendMessageToPC(oPC, "MECALM assignment diagnostics: group=" + IntToString(MECALM_GetGroupCount(oPC)) + " trained=" + IntToString(MECALM_GetLocksmithCount(oPC)) + " available=" + IntToString(iAvailable) + " assignable=" + IntToString(iAssignable) + " cached_locks=" + IntToString(MECALM_GetVisibleLockCount(oPC)) + " tick=" + IntToString(iTick) + ".");
    if (MECALM_GetGroupCount(oPC) <= 1)
    {
        SendMessageToPC(oPC, "ally.none: associate discovery returned no same-area companions.");
        return;
    }
    int iIndex;
    for (iIndex = 2; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oAssociate = MECALM_GetGroupMember(oPC, iIndex);
        if (!GetIsObjectValid(oAssociate))
            SendMessageToPC(oPC, "ally[" + IntToString(iIndex) + "]: invalid_object.");
        else
        {
            int bTrained = GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) > 0;
            int bAvailable = bTrained && MECALM_CanTakeTask(oAssociate, oPC);
            string sReasons = MECALM_GetLocksmithRejectionReasons(oAssociate, oPC);
            SendMessageToPC(oPC, "ally[" + IntToString(iIndex) + "].id=" + ObjectToString(oAssociate) + " name=\"" + GetName(oAssociate) + "\" open_lock=" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oAssociate)) + "/" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE)) + " trained=" + IntToString(bTrained) + " available=" + IntToString(bAvailable) + " action=" + IntToString(GetCurrentAction(oAssociate)) + " reasons=" + sReasons + ".");
            if (bAvailable)
                MECALM_ReportTargetRejections(oAssociate, oPC, iTick, iIndex);
        }
    }
}

void MECALM_ReleaseTask(object oAssociate)
{
    object oTarget = GetLocalObject(oAssociate, MECALM_LOCAL_TASK);
    if (GetIsObjectValid(oTarget) && GetLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE) == oAssociate)
        DeleteLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE);
    DeleteLocalObject(oAssociate, MECALM_LOCAL_TASK);
    DeleteLocalObject(oAssociate, MECALM_LOCAL_OWNER);
    DeleteLocalInt(oAssociate, MECALM_LOCAL_STALL);
    DeleteLocalFloat(oAssociate, MECALM_LOCAL_STALL);
    DeleteLocalInt(oAssociate, MECALM_LOCAL_RETRIES);
    DeleteLocalInt(oAssociate, MECALM_LOCAL_LAST_DISTANCE);
    DeleteLocalObject(oAssociate, MECALM_LOCAL_BLOCKING_DOOR);
    DeleteLocalObject(oAssociate, MECALM_LOCAL_INITIAL_BLOCKING_DOOR);
    DeleteLocalInt(oAssociate, MECALM_LOCAL_INITIAL_COMMAND);
}

void MECALM_AbandonTask(object oAssociate)
{
    if (!GetIsObjectValid(oAssociate))
        return;
    ClearAllActions(FALSE, oAssociate);
    MECALM_ReleaseTask(oAssociate);
}

float MECALM_GetFollowDistance(object oAssociate)
{
    int iState = GetLocalInt(oAssociate, MECALM_ASSOCIATE_STATE);
    if (iState & 0x00000001)
        return 2.0f;
    if (iState & 0x00000004)
        return 6.0f;
    return 4.0f;
}

void MECALM_RestoreNaturalState(object oAssociate, object oOwner)
{
    if (!GetIsObjectValid(oAssociate) || GetIsDead(oAssociate))
        return;
    ClearAllActions(FALSE, oAssociate);
    if (GetIsInCombat(oAssociate) || GetLocalInt(oAssociate, MECALM_ASSOCIATE_MOVEMENT_MODE) == ASSOCIATE_COMMAND_STANDGROUND)
        return;
    object oMaster = GetMaster(oAssociate);
    if (!GetIsObjectValid(oMaster))
        oMaster = oOwner;
    if (GetIsObjectValid(oMaster) && GetArea(oMaster) == GetArea(oAssociate))
        AssignCommand(oAssociate, ActionForceFollowObject(oMaster, MECALM_GetFollowDistance(oAssociate)));
}

void MECALM_CancelTask(object oAssociate)
{
    object oOwner = GetLocalObject(oAssociate, MECALM_LOCAL_OWNER);
    MECALM_ReleaseTask(oAssociate);
    MECALM_RestoreNaturalState(oAssociate, oOwner);
}

void MECALM_CancelAllTasks(object oPC)
{
    int iIndex;
    for (iIndex = 2; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetLocalObject(oCreature, MECALM_LOCAL_OWNER) == oPC)
        {
            if (MECALM_IsManagedAssociate(oCreature, oPC))
                MECALM_CancelTask(oCreature);
            else
                MECALM_AbandonTask(oCreature);
        }
    }
    for (iIndex = 1; iIndex <= MECALM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECALM_GetVisibleLock(oPC, iIndex);
        object oAssignee = GetLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE);
        if (GetIsObjectValid(oAssignee) && GetLocalObject(oAssignee, MECALM_LOCAL_OWNER) == oPC)
            MECALM_AbandonTask(oAssignee);
    }
}

void MECALM_AssignTask(object oAssociate, object oTarget, object oPC)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget) || !GetIsObjectValid(oPC) || GetArea(oAssociate) != GetArea(oTarget) || GetArea(oTarget) != GetArea(oPC) || !GetLocked(oTarget) || !MECALM_IsRouteSafe(oAssociate, oTarget, oPC))
        return;
    if (GetCurrentAction(oAssociate) == ACTION_FOLLOW || GetCurrentAction(oAssociate) == ACTION_WAIT || GetCurrentAction(oAssociate) == ACTION_RANDOMWALK)
        ClearAllActions(FALSE, oAssociate);
    SetLocalObject(oAssociate, MECALM_LOCAL_TASK, oTarget);
    SetLocalObject(oAssociate, MECALM_LOCAL_OWNER, oPC);
    SetLocalObject(oTarget, MECALM_LOCAL_ASSIGNEE, oAssociate);
    SetLocalInt(oAssociate, MECALM_LOCAL_LAST_DISTANCE, FloatToInt(GetDistanceBetween(oAssociate, oTarget) * 100.0f));
    SetLocalInt(oAssociate, MECALM_LOCAL_INITIAL_COMMAND, GetLastAssociateCommand(oAssociate));
    ExecuteScript("mecalm_pathcheck", oAssociate);
    object oBlockingDoor = GetLocalObject(oAssociate, MECALM_LOCAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor))
        SetLocalObject(oAssociate, MECALM_LOCAL_INITIAL_BLOCKING_DOOR, oBlockingDoor);
    if (GetLocalInt(oPC, MECALM_LOCAL_OVERHEAD_MESSAGES))
        FloatingTextStringOnCreature(MECALM_GetText(MECALM_TEXT_LOCK_CLAIM, oPC), oAssociate, TRUE, FALSE);
    AssignCommand(oAssociate, ActionUnlockObject(oTarget));
    AssignCommand(oAssociate, ActionDoCommand(ExecuteScript("mecalm_done", oAssociate)));
}

void MECALM_RetryTask(object oAssociate, object oTarget, int iRetry)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget) || GetArea(oAssociate) != GetArea(oTarget) || !GetLocked(oTarget))
        return;
    ClearAllActions(FALSE, oAssociate);
    if (iRetry == 1)
        AssignCommand(oAssociate, ActionMoveToObject(oTarget, TRUE, 1.5f));
    else
        AssignCommand(oAssociate, ActionForceMoveToObject(oTarget, TRUE, 1.5f, 12.0f));
    AssignCommand(oAssociate, ActionUnlockObject(oTarget));
    AssignCommand(oAssociate, ActionDoCommand(ExecuteScript("mecalm_done", oAssociate)));
}

void MECALM_UpdateTask(object oAssociate, object oPC, int iTick)
{
    object oTarget = GetLocalObject(oAssociate, MECALM_LOCAL_TASK);
    if (GetIsPossessedFamiliar(oAssociate) || GetIsPC(oAssociate))
    {
        MECALM_AbandonTask(oAssociate);
        return;
    }
    if (!GetIsObjectValid(oTarget) || GetArea(oTarget) != GetArea(oAssociate) || !GetLocked(oTarget))
    {
        MECALM_CancelTask(oAssociate);
        return;
    }

    if (!MECALM_IsVisibleFromPlayer(oTarget, oPC) || !MECALM_IsRouteSafe(oAssociate, oTarget, oPC))
    {
        SetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER, iTick + 1);
        MECALM_CancelTask(oAssociate);
        return;
    }

    if (GetLastAssociateCommand(oAssociate) != GetLocalInt(oAssociate, MECALM_LOCAL_INITIAL_COMMAND))
    {
        SetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER, iTick + 1);
        MECALM_ReleaseTask(oAssociate);
        return;
    }

    int iAction = GetCurrentAction(oAssociate);
    if (iAction != ACTION_MOVETOPOINT && iAction != ACTION_OPENDOOR && iAction != ACTION_DISABLETRAP && iAction != ACTION_RECOVERTRAP && iAction != ACTION_OPENLOCK)
    {
        SetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER, iTick + 1);
        MECALM_ReleaseTask(oAssociate);
        return;
    }

    ExecuteScript("mecalm_pathcheck", oAssociate);
    object oBlockingDoor = GetLocalObject(oAssociate, MECALM_LOCAL_BLOCKING_DOOR);
    object oInitialBlockingDoor = GetLocalObject(oAssociate, MECALM_LOCAL_INITIAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor) && oBlockingDoor != oInitialBlockingDoor && oBlockingDoor != oTarget && GetArea(oBlockingDoor) == GetArea(oAssociate) && !GetIsOpen(oBlockingDoor))
    {
        SetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER, iTick + 1);
        MECALM_CancelTask(oAssociate);
        return;
    }

    int iDistance = FloatToInt(GetDistanceBetween(oAssociate, oTarget) * 100.0f);
    int iLastDistance = GetLocalInt(oAssociate, MECALM_LOCAL_LAST_DISTANCE);
    float fStall = GetLocalFloat(oAssociate, MECALM_LOCAL_STALL);
    if (iLastDistance == 0 || iDistance < iLastDistance - 25 || (GetCurrentAction(oAssociate) == ACTION_OPENLOCK && iDistance < 300))
        fStall = 0.0f;
    else
        fStall += MECALM_GetLockInterval(oPC);
    SetLocalInt(oAssociate, MECALM_LOCAL_LAST_DISTANCE, iDistance);
    SetLocalFloat(oAssociate, MECALM_LOCAL_STALL, fStall);

    if (fStall < MECALM_STALL_SECONDS)
        return;

    int iRetry = GetLocalInt(oAssociate, MECALM_LOCAL_RETRIES) + 1;
    if (iRetry <= MECALM_MAX_PATH_RETRIES)
    {
        SetLocalInt(oAssociate, MECALM_LOCAL_RETRIES, iRetry);
        SetLocalFloat(oAssociate, MECALM_LOCAL_STALL, 0.0f);
        MECALM_RetryTask(oAssociate, oTarget, iRetry);
        return;
    }

    SendMessageToPC(oPC, MECALM_GetText(MECALM_TEXT_PATH_FAILED, oPC) + " " + GetName(oTarget));
    SetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER, iTick + 1);
    MECALM_CancelTask(oAssociate);
}

void MECALM_UpdateAllTasks(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 2; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetLocalObject(oCreature, MECALM_LOCAL_OWNER) == oPC)
        {
            if (MECALM_IsManagedAssociate(oCreature, oPC))
                MECALM_UpdateTask(oCreature, oPC, iTick);
            else
                MECALM_AbandonTask(oCreature);
        }
    }
}

void MECALM_AssignAvailableTasks(object oPC, int iTick)
{
    int iAssignment;
    for (iAssignment = 0; iAssignment < MECALM_MAX_ASSIGNMENTS; iAssignment++)
    {
        object oTarget = MECALM_FindNearestAvailableTarget(oPC, iTick);
        if (!GetIsObjectValid(oTarget))
            return;
        object oAssociate = GetLocalObject(oPC, MECALM_LOCAL_NEXT_ASSOCIATE);
        if (!GetIsObjectValid(oAssociate))
            return;
        MECALM_AssignTask(oAssociate, oTarget, oPC);
    }
}

int MECALM_ShouldProtectTarget(object oTarget, object oPC)
{
    if (!GetLocalInt(oPC, MECALM_LOCAL_ATTACK_SAFETY))
        return FALSE;
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    int iType = GetObjectType(oTarget);
    if (iType != OBJECT_TYPE_DOOR && iType != OBJECT_TYPE_PLACEABLE)
        return FALSE;
    if (MECALM_IsReservationValid(oTarget))
        return TRUE;
    if (GetLocked(oTarget) && MECALM_GroupHasAction(oPC, ACTION_OPENLOCK))
        return TRUE;
    if (GetIsTrapped(oTarget) && GetTrapActive(oTarget) && MECALM_GroupHasAction(oPC, ACTION_DISABLETRAP))
        return TRUE;
    return GetLocalInt(oPC, MECALM_LOCAL_ENABLED) && GetLocked(oTarget) && MECALM_IsVisibleFromPlayer(oTarget, oPC);
}

void MECALM_RunSafetyManager(object oPC)
{
    if (!GetLocalInt(oPC, MECALM_LOCAL_ATTACK_SAFETY))
        return;
    int iIndex;
    for (iIndex = 2; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECALM_GetGroupMember(oPC, iIndex);
        if (MECALM_IsManagedAssociate(oCreature, oPC))
            ExecuteScript("mecalm_guard", oCreature);
    }
}

void MECALM_ClearLegacyAutoDetectActor(object oActor, object oPC)
{
    if (!GetIsObjectValid(oActor) || GetLocalObject(oActor, MECALM_LOCAL_DETECT_OWNER) != oPC)
        return;
    if (GetLocalInt(oActor, MECALM_LOCAL_DETECT_OWNED) && GetActionMode(oActor, ACTION_MODE_DETECT))
        SetActionMode(oActor, ACTION_MODE_DETECT, FALSE);
    DeleteLocalObject(oActor, MECALM_LOCAL_DETECT_OWNER);
    DeleteLocalInt(oActor, MECALM_LOCAL_DETECT_OWNED);
    DeleteLocalFloat(oActor, MECALM_LOCAL_DETECT_STILL_TIME);
    DeleteLocalLocation(oActor, MECALM_LOCAL_DETECT_LAST_LOCATION);
}

void MECALM_RemoveLegacyAutoDetect(object oPC)
{
    if (GetLocalInt(oPC, MECALM_LOCAL_DETECT_REMOVED))
        return;
    object oLegacyActor = GetLocalObject(oPC, MECALM_LOCAL_DETECT_ACTOR);
    if (GetIsObjectValid(oLegacyActor) && GetLocalInt(oPC, MECALM_LOCAL_DETECT_OWNED) && GetActionMode(oLegacyActor, ACTION_MODE_DETECT))
        SetActionMode(oLegacyActor, ACTION_MODE_DETECT, FALSE);
    DeleteLocalObject(oPC, MECALM_LOCAL_DETECT_ACTOR);
    int iIndex;
    int iOldCount = GetLocalInt(oPC, MECALM_LOCAL_DETECT_COUNT);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
    {
        MECALM_ClearLegacyAutoDetectActor(GetLocalObject(oPC, MECALM_LOCAL_DETECT_MEMBER + IntToString(iIndex)), oPC);
        DeleteLocalObject(oPC, MECALM_LOCAL_DETECT_MEMBER + IntToString(iIndex));
    }
    SetLocalInt(oPC, MECALM_LOCAL_DETECT_COUNT, 0);
    for (iIndex = 1; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
        MECALM_ClearLegacyAutoDetectActor(MECALM_GetGroupMember(oPC, iIndex), oPC);
    DeleteLocalInt(oPC, MECALM_LOCAL_DETECT_OWNED);
    DeleteLocalFloat(oPC, MECALM_LOCAL_DETECT_STILL_TIME);
    DeleteLocalLocation(oPC, MECALM_LOCAL_DETECT_LAST_LOCATION);
    SetLocalInt(oPC, MECALM_LOCAL_AUTO_DETECT, FALSE);
    SetLocalInt(oPC, MECALM_LOCAL_DETECT_REMOVED, TRUE);
}

void MECALM_RunLockRegistryDispatcher(object oPC)
{
    MECALM_BuildGroupCache(oPC);
    MECALM_BuildLocksmithCache(oPC);
    int iTick = GetLocalInt(oPC, MECALM_LOCAL_TICK);
    if (GetLocalInt(oPC, MECALM_LOCAL_ENABLED))
        MECALM_BuildVisibleLockCache(oPC, iTick);
    else
    {
        MECALM_ClearCachedHighlights(oPC);
        SetLocalInt(oPC, MECALM_LOCAL_LOCK_COUNT, 0);
    }
    if (GetLocalInt(oPC, MECALM_LOCAL_DEBUG))
        SetLocalInt(oPC, MECALM_LOCAL_REPORT_PENDING, TRUE);
    MECALM_RemoveLegacyAutoDetect(oPC);
}

void MECALM_RunLockDispatcher(object oPC)
{
    if (!MECALM_IsRootPlayer(oPC))
        return;
    int iTick = GetLocalInt(oPC, MECALM_LOCAL_TICK) + 1;
    SetLocalInt(oPC, MECALM_LOCAL_TICK, iTick);
    MECALM_UpdateCachedHighlights(oPC, iTick);
    MECALM_RunSafetyManager(oPC);
    if (!GetLocalInt(oPC, MECALM_LOCAL_ENABLED))
    {
        MECALM_CancelAllTasks(oPC);
        return;
    }
    if (MECALM_IsPossessingFamiliar(oPC))
    {
        if (!GetLocalInt(oPC, MECALM_LOCAL_PAUSED))
            SendMessageToPC(oPC, MECALM_GetText(MECALM_TEXT_MODE_PAUSED, oPC));
        SetLocalInt(oPC, MECALM_LOCAL_PAUSED, TRUE);
        MECALM_CancelAllTasks(oPC);
        return;
    }
    DeleteLocalInt(oPC, MECALM_LOCAL_PAUSED);
    if (MECALM_IsPartyInCombat(oPC))
    {
        MECALM_CancelAllTasks(oPC);
        return;
    }
    MECALM_UpdateAllTasks(oPC, iTick);
    MECALM_MarkManualReservations(oPC, iTick);
    if (GetLocalInt(oPC, MECALM_LOCAL_DEBUG) && GetLocalInt(oPC, MECALM_LOCAL_REPORT_PENDING))
    {
        int iAvailable = MECALM_CountAvailableLocksmiths(oPC);
        int iAssignable = MECALM_CountAssignableLocksmiths(oPC, iTick);
        SendMessageToPC(oPC, MECALM_GetText(MECALM_TEXT_SCAN_LOCKS, oPC) + IntToString(MECALM_CountEligibleVisibleLocks(oPC, iTick)) + MECALM_GetText(MECALM_TEXT_SCAN_LOCKSMITHS, oPC) + IntToString(iAvailable) + ", assignable = " + IntToString(iAssignable) + ".");
        if (iAssignable == 0)
            MECALM_ReportAssignmentFailure(oPC, iTick, iAvailable, iAssignable);
    }
    DeleteLocalInt(oPC, MECALM_LOCAL_REPORT_PENDING);
    MECALM_AssignAvailableTasks(oPC, iTick);
}

string MECALM_GetDiagnosticObjectType(int iType)
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

int MECALM_IsCachedLock(object oPC, object oTarget)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetVisibleLockCount(oPC); iIndex++)
    {
        if (MECALM_GetVisibleLock(oPC, iIndex) == oTarget)
            return TRUE;
    }
    return FALSE;
}

int MECALM_GetDiagnosticActionPossible(object oActor, object oTarget)
{
    SetLocalObject(oActor, MECALM_LOCAL_CHECK_TARGET, oTarget);
    DeleteLocalInt(oActor, MECALM_LOCAL_CHECK_RESULT);
    ExecuteScript("mecalm_diagact", oActor);
    int bResult = GetLocalInt(oActor, MECALM_LOCAL_CHECK_RESULT);
    DeleteLocalObject(oActor, MECALM_LOCAL_CHECK_TARGET);
    DeleteLocalInt(oActor, MECALM_LOCAL_CHECK_RESULT);
    return bResult;
}

void MECALM_ReportLOSProbes(object oPC, object oTarget)
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
    SendMessageToPC(oPC, "los.probes object=" + IntToString(LineOfSightObject(oPC, oTarget)) + " center=" + IntToString(LineOfSightVector(vSource, vTarget)) + " toward_025=" + IntToString(LineOfSightVector(vSource, vProbe025)) + " toward_050=" + IntToString(LineOfSightVector(vSource, vProbe050)) + " toward_100=" + IntToString(LineOfSightVector(vSource, vProbe100)) + " lock_los=" + IntToString(MECALM_HasLineOfSightToLock(oTarget, oPC)) + " facing=" + FloatToString(GetFacingFromLocation(GetLocation(oTarget)), 0, 2));
    SendMessageToPC(oPC, "los.vectors source=[" + FloatToString(vSource.x, 0, 2) + "," + FloatToString(vSource.y, 0, 2) + "," + FloatToString(vSource.z, 0, 2) + "] target=[" + FloatToString(vTarget.x, 0, 2) + "," + FloatToString(vTarget.y, 0, 2) + "," + FloatToString(vTarget.z, 0, 2) + "]");
}

void MECALM_ReportObject(object oPC, object oTarget)
{
    if (!MECALM_IsRootPlayer(oPC) || !GetIsObjectValid(oTarget))
        return;
    MECALM_BuildGroupCache(oPC);
    MECALM_BuildLocksmithCache(oPC);
    int iType = GetObjectType(oTarget);
    int iTick = GetLocalInt(oPC, MECALM_LOCAL_TICK);
    SendMessageToPC(oPC, "=== MECALM object diagnostics " + MECALM_VERSION + " ===");
    SendMessageToPC(oPC, "object.id=" + ObjectToString(oTarget) + " uuid=" + GetObjectUUID(oTarget) + " type=" + IntToString(iType) + "/" + MECALM_GetDiagnosticObjectType(iType));
    SendMessageToPC(oPC, "name=\"" + GetName(oTarget) + "\" tag=\"" + GetTag(oTarget) + "\" resref=\"" + GetResRef(oTarget) + "\"");
    SendMessageToPC(oPC, "area.same=" + IntToString(GetArea(oTarget) == GetArea(oPC)) + " distance=" + FloatToString(GetDistanceBetween(oPC, oTarget), 0, 2) + " radius=" + FloatToString(MECALM_GetSearchRadius(oPC), 0, 2) + " direct_los=" + IntToString(LineOfSightObject(oPC, oTarget)) + " require_los=" + IntToString(GetLocalInt(oPC, MECALM_LOCAL_REQUIRE_LOS)));
    if (iType == OBJECT_TYPE_DOOR || iType == OBJECT_TYPE_PLACEABLE)
    {
        MECALM_ReportLOSProbes(oPC, oTarget);
        SendMessageToPC(oPC, "state.locked=" + IntToString(GetLocked(oTarget)) + " open=" + IntToString(GetIsOpen(oTarget)) + " usable=" + IntToString(GetUseableFlag(oTarget)) + " plot=" + IntToString(GetPlotFlag(oTarget)) + " inventory=" + IntToString(GetHasInventory(oTarget)));
        SendMessageToPC(oPC, "lock.key_required=" + IntToString(GetLockKeyRequired(oTarget)) + " key_tag=\"" + GetLockKeyTag(oTarget) + "\" unlock_dc=" + IntToString(GetLockUnlockDC(oTarget)) + " lockable=" + IntToString(GetLockLockable(oTarget)));
        SendMessageToPC(oPC, "filter.candidate=" + IntToString(MECALM_IsLockCandidate(oTarget, oPC, iTick)) + " visible=" + IntToString(MECALM_IsVisibleFromPlayer(oTarget, oPC)) + " cached=" + IntToString(MECALM_IsCachedLock(oPC, oTarget)) + " reserved=" + IntToString(MECALM_IsReservationValid(oTarget)) + " manual_tick=" + IntToString(GetLocalInt(oTarget, MECALM_LOCAL_MANUAL_TICK)) + " retry_after=" + IntToString(GetLocalInt(oTarget, MECALM_LOCAL_RETRY_AFTER)) + " current_tick=" + IntToString(iTick));
        SendMessageToPC(oPC, "trap.present=" + IntToString(GetIsTrapped(oTarget)) + " active=" + IntToString(GetTrapActive(oTarget)) + " detected=" + IntToString(MECALM_IsDetectedActiveTrap(oTarget, oPC)) + " flagged=" + IntToString(GetTrapFlagged(oTarget)) + " detectable=" + IntToString(GetTrapDetectable(oTarget)) + " disarmable=" + IntToString(GetTrapDisarmable(oTarget)));
    }
    int iIndex;
    for (iIndex = 1; iIndex <= MECALM_GetGroupCount(oPC); iIndex++)
    {
        object oActor = MECALM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oActor))
            SendMessageToPC(oPC, "actor[" + IntToString(iIndex) + "].id=" + ObjectToString(oActor) + " name=\"" + GetName(oActor) + "\" pc=" + IntToString(GetIsPC(oActor)) + " commandable=" + IntToString(GetCommandable(oActor)) + " action=" + IntToString(GetCurrentAction(oActor)) + " open_lock=" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oActor)) + "/" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oActor, TRUE)) + " can_take=" + IntToString(MECALM_CanTakeTask(oActor, oPC)) + " can_unlock=" + IntToString(MECALM_CanUnlock(oActor, oTarget)) + " route_safe=" + IntToString(MECALM_IsRouteSafe(oActor, oTarget, oPC)) + " engine_action=" + IntToString(MECALM_GetDiagnosticActionPossible(oActor, oTarget)));
    }
    SendMessageToPC(oPC, "=== end MECALM diagnostics ===");
}

void MECALM_ScheduleDispatcherBurst(object oPC, string sScript, float fInterval)
{
    float fDelay = fInterval;
    int iCount = 0;
    while (fDelay < MECALM_BASE_HEARTBEAT_SECONDS && iCount < 60)
    {
        DelayCommand(fDelay, ExecuteScript(sScript, oPC));
        fDelay += fInterval;
        iCount++;
    }
}

void MECALM_RunSchedulerDispatcher(object oPC)
{
    if (GetLocalInt(oPC, MECALM_LOCAL_ENABLED) || GetLocalInt(oPC, MECALM_LOCAL_ATTACK_SAFETY))
        MECALM_ScheduleDispatcherBurst(oPC, "mecalm_lock", MECALM_GetLockInterval(oPC));
}

void MECALM_Heartbeat(object oPC)
{
    if (!MECALM_IsRootPlayer(oPC))
        return;
    MECALM_InitializeSettings(oPC);
    ExecuteScript("mecalm_registry", oPC);
    ExecuteScript("mecalm_lock", oPC);
    ExecuteScript("mecalm_schedule", oPC);
    if (!GetLocalInt(oPC, MECALM_LOCAL_INSTALLED))
    {
        SetLocalInt(oPC, MECALM_LOCAL_INSTALLED, TRUE);
        SendMessageToPC(oPC, MECALM_GetText(MECALM_TEXT_INSTALLED, oPC) + " " + MECALM_VERSION);
    }
}

void MECALM_UnlockActionCompleted(object oAssociate)
{
    object oTarget = GetLocalObject(oAssociate, MECALM_LOCAL_TASK);
    if (GetIsObjectValid(oTarget) && GetLocked(oTarget))
        return;
    object oOwner = GetLocalObject(oAssociate, MECALM_LOCAL_OWNER);
    MECALM_ClearHighlight(oTarget);
    ClearAllActions(FALSE, oAssociate);
    MECALM_ReleaseTask(oAssociate);
    if (MECALM_IsRootPlayer(oOwner))
        ExecuteScript("mecalm_lock", oOwner);
    if (!GetIsObjectValid(GetLocalObject(oAssociate, MECALM_LOCAL_TASK)))
        MECALM_RestoreNaturalState(oAssociate, oOwner);
}
