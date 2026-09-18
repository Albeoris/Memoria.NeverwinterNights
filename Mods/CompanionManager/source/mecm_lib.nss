// Companion Manager (MECM)
// Shared implementation. All resource names use the uncommon "mecm_" prefix.

#include "memoria_core"
#include "memoria_group"
#include "memoria_locale"
#include "memoria_loc"

const string MECM_VERSION = "1.2.9";
const string MECM_LOC_PREFIX = "mecm";
const string MECM_LOCAL_INSTALLED = "MECM_INSTALLED";
const string MECM_LOCAL_ENABLED = "MECM_MODE_ENABLED";
const string MECM_LOCAL_PAUSED = "MECM_MODE_PAUSED";
const string MECM_LOCAL_TICK = "MECM_MANAGER_TICK";
const string MECM_LOCAL_TASK = "MECM_UNLOCK_TASK";
const string MECM_LOCAL_ASSIGNEE = "MECM_UNLOCK_ASSIGNEE";
const string MECM_LOCAL_OWNER = "MECM_UNLOCK_OWNER";
const string MECM_LOCAL_STALL = "MECM_PATH_STALL";
const string MECM_LOCAL_RETRIES = "MECM_PATH_RETRIES";
const string MECM_LOCAL_LAST_DISTANCE = "MECM_PATH_LAST_DISTANCE";
const string MECM_LOCAL_RETRY_AFTER = "MECM_RETRY_AFTER";
const string MECM_LOCAL_MANUAL_TICK = "MECM_MANUAL_TICK";
const string MECM_LOCAL_CHECK_TARGET = "MECM_CHECK_TARGET";
const string MECM_LOCAL_CHECK_RESULT = "MECM_CHECK_RESULT";
const string MECM_LOCAL_BLOCKING_DOOR = "MECM_BLOCKING_DOOR";
const string MECM_LOCAL_INITIAL_BLOCKING_DOOR = "MECM_INITIAL_BLOCKING_DOOR";
const string MECM_LOCAL_INITIAL_COMMAND = "MECM_INITIAL_COMMAND";
const string MECM_LOCAL_NEXT_ASSOCIATE = "MECM_NEXT_ASSOCIATE";
const string MECM_LOCAL_LANGUAGE = "MECM_LANGUAGE";
const string MECM_LOCAL_GROUP_COUNT = "MECM_GROUP_COUNT";
const string MECM_LOCAL_GROUP_MEMBER = "MECM_GROUP_MEMBER_";
const string MECM_LOCAL_LOCK_COUNT = "MECM_LOCK_COUNT";
const string MECM_LOCAL_LOCK_MEMBER = "MECM_LOCK_MEMBER_";
const string MECM_LOCAL_LOCKSMITH_COUNT = "MECM_LOCKSMITH_COUNT";
const string MECM_LOCAL_LOCKSMITH_MEMBER = "MECM_LOCKSMITH_MEMBER_";
const string MECM_LOCAL_REPORT_PENDING = "MECM_REPORT_PENDING";
const string MECM_LOCAL_SETTINGS_INITIALIZED = "MECM_SETTINGS_INITIALIZED";
const string MECM_LOCAL_SEARCH_RADIUS = "MECM_CFG_SEARCH_RADIUS";
const string MECM_LOCAL_LOCK_INTERVAL = "MECM_CFG_LOCK_INTERVAL";
const string MECM_LOCAL_REQUIRE_LOS = "MECM_CFG_REQUIRE_LOS";
const string MECM_LOCAL_ATTACK_SAFETY = "MECM_CFG_ATTACK_SAFETY";
const string MECM_LOCAL_HIGHLIGHT = "MECM_CFG_HIGHLIGHT";
const string MECM_LOCAL_OVERHEAD_MESSAGES = "MECM_CFG_OVERHEAD_MESSAGES";
const string MECM_LOCAL_DEBUG = "MECM_CFG_DEBUG";
const string MECM_LOCAL_AUTO_DETECT = "MECM_CFG_AUTO_DETECT";
const string MECM_LOCAL_DETECT_ACTOR = "MECM_DETECT_ACTOR";
const string MECM_LOCAL_DETECT_COUNT = "MECM_DETECT_COUNT";
const string MECM_LOCAL_DETECT_MEMBER = "MECM_DETECT_MEMBER_";
const string MECM_LOCAL_DETECT_OWNER = "MECM_DETECT_OWNER";
const string MECM_LOCAL_DETECT_LAST_LOCATION = "MECM_DETECT_LAST_LOCATION";
const string MECM_LOCAL_DETECT_STILL_TIME = "MECM_DETECT_STILL_TIME";
const string MECM_LOCAL_DETECT_OWNED = "MECM_DETECT_OWNED";
const string MECM_LOCAL_DETECT_REMOVED = "MECM_DETECT_REMOVED";
const string MECM_LOCAL_HIGHLIGHTED = "MECM_HIGHLIGHTED";
const string MECM_ASSOCIATE_STATE = "NW_ASSOCIATE_MASTER";
const string MECM_ASSOCIATE_MOVEMENT_MODE = "NW_COM_MODE_MOVEMENT";
const string MECM_HIGHLIGHT_EFFECT_TAG = "MECM_LOCK_GLOW_9F31";

const float MECM_BASE_HEARTBEAT_SECONDS = 6.0f;
const float MECM_DEFAULT_SEARCH_RADIUS = 15.0f;
const float MECM_DEFAULT_LOCK_INTERVAL = 1.0f;
const int MECM_MAX_ASSIGNMENTS = 32;
const float MECM_STALL_SECONDS = 3.0f;
const int MECM_MAX_PATH_RETRIES = 2;
const int MECM_MAX_GROUP_MEMBERS = 32;
const int MECM_MAX_VISIBLE_LOCKS = 64;
const string MECM_TEXT_MODE_PAUSED = "familiar_pause_message";
const string MECM_TEXT_PATH_FAILED = "task_released_message";
const string MECM_TEXT_INSTALLED = "installed_message";
const string MECM_TEXT_SCAN_LOCKS = "scan_locks_message";
const string MECM_TEXT_SCAN_LOCKSMITHS = "scan_locksmiths_message";
const string MECM_TEXT_LOCK_CLAIM = "lock_claim_message";

object MECM_GetRootMaster(object oCreature)
{
    return MEMORIA_GetRootPlayer(oCreature);
}

int MECM_IsRootPlayer(object oCreature)
{
    return MEMORIA_IsRootPlayerCharacter(oCreature);
}

int MECM_IsGroupCreature(object oCreature, object oPC)
{
    return MEMORIA_IsPartyCreature(oCreature, oPC);
}

int MECM_IsManagedAssociate(object oCreature, object oPC)
{
    return MECM_IsGroupCreature(oCreature, oPC) && oCreature != oPC && !GetIsPC(oCreature) && !GetIsDead(oCreature) && GetArea(oCreature) == GetArea(oPC);
}

int MECM_IsPossessingFamiliar(object oPC)
{
    return MEMORIA_IsPossessingFamiliar(oPC);
}

void MECM_InitializeSettings(object oPC)
{
    if (GetLocalInt(oPC, MECM_LOCAL_SETTINGS_INITIALIZED))
        return;
    SetLocalInt(oPC, MECM_LOCAL_SETTINGS_INITIALIZED, TRUE);
    SetLocalInt(oPC, MECM_LOCAL_ENABLED, TRUE);
    SetLocalFloat(oPC, MECM_LOCAL_SEARCH_RADIUS, MECM_DEFAULT_SEARCH_RADIUS);
    SetLocalFloat(oPC, MECM_LOCAL_LOCK_INTERVAL, MECM_DEFAULT_LOCK_INTERVAL);
    SetLocalInt(oPC, MECM_LOCAL_REQUIRE_LOS, TRUE);
    SetLocalInt(oPC, MECM_LOCAL_ATTACK_SAFETY, TRUE);
    SetLocalInt(oPC, MECM_LOCAL_HIGHLIGHT, TRUE);
    SetLocalInt(oPC, MECM_LOCAL_OVERHEAD_MESSAGES, TRUE);
    SetLocalInt(oPC, MECM_LOCAL_DEBUG, FALSE);
    SetLocalInt(oPC, MECM_LOCAL_AUTO_DETECT, FALSE);
}

float MECM_GetSearchRadius(object oPC)
{
    MECM_InitializeSettings(oPC);
    return GetLocalFloat(oPC, MECM_LOCAL_SEARCH_RADIUS);
}

float MECM_GetLockInterval(object oPC)
{
    MECM_InitializeSettings(oPC);
    return GetLocalFloat(oPC, MECM_LOCAL_LOCK_INTERVAL);
}

object MECM_GetGroupMember(object oPC, int iIndex)
{
    return MEMORIA_GetGroupMember(oPC, MECM_LOCAL_GROUP_MEMBER, iIndex);
}

int MECM_GetGroupCount(object oPC)
{
    return MEMORIA_GetGroupCount(oPC, MECM_LOCAL_GROUP_COUNT);
}

int MECM_IsGroupMemberCached(object oPC, object oCreature)
{
    return MEMORIA_IsGroupMemberCached(oPC, oCreature, MECM_LOCAL_GROUP_COUNT, MECM_LOCAL_GROUP_MEMBER);
}

void MECM_AddGroupMember(object oPC, object oCreature)
{
    MEMORIA_AddGroupMember(oPC, oCreature, MECM_LOCAL_GROUP_COUNT, MECM_LOCAL_GROUP_MEMBER, MECM_MAX_GROUP_MEMBERS);
}

void MECM_BuildGroupCache(object oPC)
{
    MEMORIA_BuildGroupCache(oPC, MECM_LOCAL_GROUP_COUNT, MECM_LOCAL_GROUP_MEMBER, MECM_MAX_GROUP_MEMBERS);
}

string MECM_GetLanguage(object oPC)
{
    return MEMORIA_GetLanguage(oPC, MECM_LOCAL_LANGUAGE);
}

string MECM_GetText(string sKey, object oPC)
{
    return MEMORIA_LOC_GetText(MECM_LOC_PREFIX, MECM_GetLanguage(oPC), sKey);
}

int MECM_IsPartyInCombat(object oPC)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetGroupMember(oPC, iIndex);
        if (MECM_IsGroupCreature(oCreature, oPC) && GetArea(oCreature) == GetArea(oPC) && GetIsInCombat(oCreature))
            return TRUE;
    }
    return FALSE;
}

int MECM_GroupHasAction(object oPC, int iAction)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetGroupMember(oPC, iIndex);
        if (MECM_IsGroupCreature(oCreature, oPC) && GetArea(oCreature) == GetArea(oPC) && GetCurrentAction(oCreature) == iAction)
            return TRUE;
    }
    return FALSE;
}

int MECM_HasLineOfSightToLock(object oTarget, object oPC)
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

int MECM_IsVisibleFromPlayer(object oTarget, object oPC)
{
    if (!GetIsObjectValid(oTarget) || !GetIsObjectValid(oPC))
        return FALSE;
    if (GetArea(oTarget) != GetArea(oPC) || GetDistanceBetween(oTarget, oPC) > MECM_GetSearchRadius(oPC))
        return FALSE;
    return !GetLocalInt(oPC, MECM_LOCAL_REQUIRE_LOS) || MECM_HasLineOfSightToLock(oTarget, oPC);
}

int MECM_IsDetectedActiveTrap(object oTarget, object oPC)
{
    if (!GetIsTrapped(oTarget) || !GetTrapActive(oTarget))
        return FALSE;
    if (GetTrapFlagged(oTarget))
        return TRUE;

    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetTrapDetectedBy(oTarget, oCreature))
            return TRUE;
    }
    return FALSE;
}

int MECM_IsLockObject(object oTarget)
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

int MECM_IsLockCandidate(object oTarget, object oPC, int iTick)
{
    return MECM_IsLockObject(oTarget) && GetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER) <= iTick;
}

int MECM_CanUnlock(object oAssociate, object oTarget)
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

int MECM_IsRouteSafe(object oAssociate, object oTarget, object oPC)
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
            if (MECM_IsDetectedActiveTrap(oObstacle, oPC))
                return FALSE;
        }
        oObstacle = GetNextObjectInShape(SHAPE_SPELLCYLINDER, fDistance, lTarget, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, vOrigin);
    }
    return TRUE;
}

void MECM_AbandonTask(object oAssociate);

int MECM_IsReservationValid(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    object oAssignee = GetLocalObject(oTarget, MECM_LOCAL_ASSIGNEE);
    if (!GetIsObjectValid(oAssignee) || GetIsDead(oAssignee) || GetArea(oAssignee) != GetArea(oTarget))
    {
        DeleteLocalObject(oTarget, MECM_LOCAL_ASSIGNEE);
        if (GetIsObjectValid(oAssignee))
            MECM_AbandonTask(oAssignee);
        return FALSE;
    }
    object oOwner = GetLocalObject(oAssignee, MECM_LOCAL_OWNER);
    if (!GetIsObjectValid(oOwner) || !MECM_IsManagedAssociate(oAssignee, oOwner))
    {
        DeleteLocalObject(oTarget, MECM_LOCAL_ASSIGNEE);
        MECM_AbandonTask(oAssignee);
        return FALSE;
    }
    if (GetLocalObject(oAssignee, MECM_LOCAL_TASK) != oTarget)
    {
        DeleteLocalObject(oTarget, MECM_LOCAL_ASSIGNEE);
        return FALSE;
    }
    return TRUE;
}

object MECM_GetLikelyManualLock(object oActor)
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

void MECM_MarkManualReservations(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oTarget = MECM_GetLikelyManualLock(MECM_GetGroupMember(oPC, iIndex));
        if (GetIsObjectValid(oTarget))
            SetLocalInt(oTarget, MECM_LOCAL_MANUAL_TICK, iTick);
    }
}

int MECM_CanTakeTask(object oAssociate, object oPC)
{
    if (!MECM_IsManagedAssociate(oAssociate, oPC) || GetIsObjectValid(GetLocalObject(oAssociate, MECM_LOCAL_TASK)))
        return FALSE;
    if (!GetCommandable(oAssociate) || GetIsResting(oAssociate) || IsInConversation(oAssociate))
        return FALSE;

    int iAction = GetCurrentAction(oAssociate);
    return iAction == ACTION_INVALID || iAction == ACTION_FOLLOW || iAction == ACTION_WAIT || iAction == ACTION_RANDOMWALK;
}

object MECM_GetVisibleLock(object oPC, int iIndex)
{
    return GetLocalObject(oPC, MECM_LOCAL_LOCK_MEMBER + IntToString(iIndex));
}

int MECM_GetVisibleLockCount(object oPC)
{
    return GetLocalInt(oPC, MECM_LOCAL_LOCK_COUNT);
}

int MECM_CountEligibleVisibleLocks(object oPC, int iTick)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECM_GetVisibleLock(oPC, iIndex);
        if (MECM_IsLockCandidate(oTarget, oPC, iTick) && MECM_IsVisibleFromPlayer(oTarget, oPC))
            iCount++;
    }
    return iCount;
}

object MECM_GetLocksmith(object oPC, int iIndex)
{
    return GetLocalObject(oPC, MECM_LOCAL_LOCKSMITH_MEMBER + IntToString(iIndex));
}

int MECM_GetLocksmithCount(object oPC)
{
    return GetLocalInt(oPC, MECM_LOCAL_LOCKSMITH_COUNT);
}

void MECM_BuildLocksmithCache(object oPC)
{
    int iIndex;
    int iOldCount = MECM_GetLocksmithCount(oPC);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
        DeleteLocalObject(oPC, MECM_LOCAL_LOCKSMITH_MEMBER + IntToString(iIndex));
    SetLocalInt(oPC, MECM_LOCAL_LOCKSMITH_COUNT, 0);
    for (iIndex = 2; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oAssociate = MECM_GetGroupMember(oPC, iIndex);
        if (MECM_IsManagedAssociate(oAssociate, oPC) && GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) > 0)
        {
            int iCount = MECM_GetLocksmithCount(oPC) + 1;
            SetLocalInt(oPC, MECM_LOCAL_LOCKSMITH_COUNT, iCount);
            SetLocalObject(oPC, MECM_LOCAL_LOCKSMITH_MEMBER + IntToString(iCount), oAssociate);
        }
    }
}

void MECM_ClearHighlight(object oTarget)
{
    if (!GetIsObjectValid(oTarget) || !GetLocalInt(oTarget, MECM_LOCAL_HIGHLIGHTED))
        return;
    effect eEffect = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEffect))
    {
        effect eNext = GetNextEffect(oTarget);
        if (GetEffectTag(eEffect) == MECM_HIGHLIGHT_EFFECT_TAG)
            RemoveEffect(oTarget, eEffect);
        eEffect = eNext;
    }
    DeleteLocalInt(oTarget, MECM_LOCAL_HIGHLIGHTED);
}

void MECM_SetHighlight(object oTarget)
{
    if (!GetIsObjectValid(oTarget) || GetLocalInt(oTarget, MECM_LOCAL_HIGHLIGHTED))
        return;
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, TagEffect(EffectVisualEffect(VFX_DUR_GLOW_GREY), MECM_HIGHLIGHT_EFFECT_TAG), oTarget);
    SetLocalInt(oTarget, MECM_LOCAL_HIGHLIGHTED, TRUE);
}

void MECM_ClearCachedHighlights(object oPC)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetVisibleLockCount(oPC); iIndex++)
        MECM_ClearHighlight(MECM_GetVisibleLock(oPC, iIndex));
}

void MECM_BuildVisibleLockCache(object oPC, int iTick)
{
    int iIndex;
    int iOldCount = MECM_GetVisibleLockCount(oPC);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
    {
        object oOldTarget = MECM_GetVisibleLock(oPC, iIndex);
        if (!GetLocalInt(oPC, MECM_LOCAL_HIGHLIGHT) || !MECM_IsLockObject(oOldTarget) || GetArea(oOldTarget) != GetArea(oPC) || GetDistanceBetween(oOldTarget, oPC) > MECM_GetSearchRadius(oPC))
            MECM_ClearHighlight(oOldTarget);
        DeleteLocalObject(oPC, MECM_LOCAL_LOCK_MEMBER + IntToString(iIndex));
    }
    SetLocalInt(oPC, MECM_LOCAL_LOCK_COUNT, 0);

    float fRadius = MECM_GetSearchRadius(oPC);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(oPC), FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while (GetIsObjectValid(oTarget) && MECM_GetVisibleLockCount(oPC) < MECM_MAX_VISIBLE_LOCKS)
    {
        if (MECM_IsLockObject(oTarget))
        {
            int iCount = MECM_GetVisibleLockCount(oPC) + 1;
            SetLocalInt(oPC, MECM_LOCAL_LOCK_COUNT, iCount);
            SetLocalObject(oPC, MECM_LOCAL_LOCK_MEMBER + IntToString(iCount), oTarget);
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, GetLocation(oPC), FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}

void MECM_UpdateCachedHighlights(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECM_GetVisibleLock(oPC, iIndex);
        if (GetLocalInt(oPC, MECM_LOCAL_HIGHLIGHT) && MECM_IsLockCandidate(oTarget, oPC, iTick) && MECM_IsVisibleFromPlayer(oTarget, oPC))
            MECM_SetHighlight(oTarget);
        else
            MECM_ClearHighlight(oTarget);
    }
}

object MECM_FindBestTarget(object oAssociate, object oPC, int iTick)
{
    object oBest = OBJECT_INVALID;
    float fBestDistance = 1000000.0f;
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECM_GetVisibleLock(oPC, iIndex);
        if (MECM_IsLockCandidate(oTarget, oPC, iTick) && MECM_IsVisibleFromPlayer(oTarget, oPC) && !MECM_IsReservationValid(oTarget) && GetLocalInt(oTarget, MECM_LOCAL_MANUAL_TICK) != iTick)
        {
            float fDistance = GetDistanceBetween(oAssociate, oTarget);
            if (fDistance < fBestDistance && MECM_CanUnlock(oAssociate, oTarget) && MECM_IsRouteSafe(oAssociate, oTarget, oPC))
            {
                oBest = oTarget;
                fBestDistance = fDistance;
            }
        }
    }
    return oBest;
}

object MECM_FindNearestAvailableTarget(object oPC, int iTick)
{
    object oBestTarget = OBJECT_INVALID;
    object oBestAssociate = OBJECT_INVALID;
    float fBestDistance = 1000000.0f;
    int iBestSkill = 1000000;
    int iTargetIndex;
    for (iTargetIndex = 1; iTargetIndex <= MECM_GetVisibleLockCount(oPC); iTargetIndex++)
    {
        object oTarget = MECM_GetVisibleLock(oPC, iTargetIndex);
        if (MECM_IsLockCandidate(oTarget, oPC, iTick) && MECM_IsVisibleFromPlayer(oTarget, oPC) && !MECM_IsReservationValid(oTarget) && GetLocalInt(oTarget, MECM_LOCAL_MANUAL_TICK) != iTick)
        {
            int iAssociateIndex;
            for (iAssociateIndex = 1; iAssociateIndex <= MECM_GetLocksmithCount(oPC); iAssociateIndex++)
            {
                object oAssociate = MECM_GetLocksmith(oPC, iAssociateIndex);
                if (MECM_CanTakeTask(oAssociate, oPC))
                {
                    float fDistance = GetDistanceBetween(oAssociate, oTarget);
                    int iSkill = GetSkillRank(SKILL_OPEN_LOCK, oAssociate);
                    if ((fDistance < fBestDistance || (fDistance == fBestDistance && iSkill < iBestSkill)) && MECM_CanUnlock(oAssociate, oTarget) && MECM_IsRouteSafe(oAssociate, oTarget, oPC))
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
    DeleteLocalObject(oPC, MECM_LOCAL_NEXT_ASSOCIATE);
    if (GetIsObjectValid(oBestAssociate))
        SetLocalObject(oPC, MECM_LOCAL_NEXT_ASSOCIATE, oBestAssociate);
    return oBestTarget;
}

int MECM_CountAvailableLocksmiths(object oPC)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetLocksmithCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetLocksmith(oPC, iIndex);
        if (MECM_CanTakeTask(oCreature, oPC))
            iCount++;
    }
    return iCount;
}

int MECM_CountAssignableLocksmiths(object oPC, int iTick)
{
    int iCount = 0;
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetLocksmithCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetLocksmith(oPC, iIndex);
        if (MECM_CanTakeTask(oCreature, oPC) && GetIsObjectValid(MECM_FindBestTarget(oCreature, oPC, iTick)))
            iCount++;
    }
    return iCount;
}

string MECM_AppendDiagnosticReason(string sReasons, string sReason)
{
    if (sReasons == "")
        return sReason;
    return sReasons + "," + sReason;
}

string MECM_GetLocksmithRejectionReasons(object oAssociate, object oPC)
{
    string sReasons = "";
    if (!GetIsObjectValid(oAssociate))
        return "invalid_object";
    if (GetObjectType(oAssociate) != OBJECT_TYPE_CREATURE)
        sReasons = MECM_AppendDiagnosticReason(sReasons, "not_creature");
    if (MECM_GetRootMaster(oAssociate) != oPC)
        sReasons = MECM_AppendDiagnosticReason(sReasons, "different_root_master");
    if (oAssociate == oPC)
        sReasons = MECM_AppendDiagnosticReason(sReasons, "player_character");
    if (GetIsPC(oAssociate))
        sReasons = MECM_AppendDiagnosticReason(sReasons, "player_controlled");
    if (GetIsDead(oAssociate))
        sReasons = MECM_AppendDiagnosticReason(sReasons, "dead");
    if (GetArea(oAssociate) != GetArea(oPC))
        sReasons = MECM_AppendDiagnosticReason(sReasons, "different_area");
    if (GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) <= 0)
        sReasons = MECM_AppendDiagnosticReason(sReasons, "open_lock_untrained");
    if (GetIsObjectValid(GetLocalObject(oAssociate, MECM_LOCAL_TASK)))
        sReasons = MECM_AppendDiagnosticReason(sReasons, "has_mecm_task");
    if (!GetCommandable(oAssociate))
        sReasons = MECM_AppendDiagnosticReason(sReasons, "not_commandable");
    if (GetIsResting(oAssociate))
        sReasons = MECM_AppendDiagnosticReason(sReasons, "resting");
    if (IsInConversation(oAssociate))
        sReasons = MECM_AppendDiagnosticReason(sReasons, "in_conversation");
    int iAction = GetCurrentAction(oAssociate);
    if (iAction != ACTION_INVALID && iAction != ACTION_FOLLOW && iAction != ACTION_WAIT && iAction != ACTION_RANDOMWALK)
        sReasons = MECM_AppendDiagnosticReason(sReasons, "busy_action=" + IntToString(iAction));
    if (sReasons == "")
        return "none";
    return sReasons;
}

void MECM_ReportTargetRejections(object oAssociate, object oPC, int iTick, int iAllyIndex)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECM_GetVisibleLock(oPC, iIndex);
        int bValid = GetIsObjectValid(oTarget);
        int bLock = bValid && MECM_IsLockObject(oTarget);
        int bRetryReady = bValid && GetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER) <= iTick;
        int bSameArea = bValid && GetArea(oTarget) == GetArea(oPC);
        float fDistance = bSameArea ? GetDistanceBetween(oTarget, oPC) : -1.0f;
        int bInRange = bSameArea && fDistance <= MECM_GetSearchRadius(oPC);
        int bObjectLOS = bSameArea && LineOfSightObject(oPC, oTarget);
        int bLockLOS = bSameArea && MECM_HasLineOfSightToLock(oTarget, oPC);
        int bVisible = bInRange && (!GetLocalInt(oPC, MECM_LOCAL_REQUIRE_LOS) || bLockLOS);
        int bReserved = bValid && MECM_IsReservationValid(oTarget);
        int bManual = bValid && GetLocalInt(oTarget, MECM_LOCAL_MANUAL_TICK) == iTick;
        int bCanUnlock = bValid && MECM_CanUnlock(oAssociate, oTarget);
        int bRouteSafe = bValid && MECM_IsRouteSafe(oAssociate, oTarget, oPC);
        int bAssignable = bLock && bRetryReady && bVisible && !bReserved && !bManual && bCanUnlock && bRouteSafe;
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "]: id=" + ObjectToString(oTarget) + " name=\"" + GetName(oTarget) + "\" valid=" + IntToString(bValid) + " lock=" + IntToString(bLock) + " retry_ready=" + IntToString(bRetryReady) + " retry_after=" + IntToString(GetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER)) + ".");
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "].visibility: same_area=" + IntToString(bSameArea) + " distance=" + FloatToString(fDistance, 0, 2) + " radius=" + FloatToString(MECM_GetSearchRadius(oPC), 0, 2) + " require_los=" + IntToString(GetLocalInt(oPC, MECM_LOCAL_REQUIRE_LOS)) + " object_los=" + IntToString(bObjectLOS) + " lock_los=" + IntToString(bLockLOS) + " visible=" + IntToString(bVisible) + ".");
        SendMessageToPC(oPC, "ally[" + IntToString(iAllyIndex) + "].target[" + IntToString(iIndex) + "].pair: reserved=" + IntToString(bReserved) + " manual=" + IntToString(bManual) + " can_unlock=" + IntToString(bCanUnlock) + " route_safe=" + IntToString(bRouteSafe) + " assignable=" + IntToString(bAssignable) + ".");
    }
}

void MECM_ReportAssignmentFailure(object oPC, int iTick, int iAvailable, int iAssignable)
{
    SendMessageToPC(oPC, "MECM assignment diagnostics: group=" + IntToString(MECM_GetGroupCount(oPC)) + " trained=" + IntToString(MECM_GetLocksmithCount(oPC)) + " available=" + IntToString(iAvailable) + " assignable=" + IntToString(iAssignable) + " cached_locks=" + IntToString(MECM_GetVisibleLockCount(oPC)) + " tick=" + IntToString(iTick) + ".");
    if (MECM_GetGroupCount(oPC) <= 1)
    {
        SendMessageToPC(oPC, "ally.none: associate discovery returned no same-area companions.");
        return;
    }
    int iIndex;
    for (iIndex = 2; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oAssociate = MECM_GetGroupMember(oPC, iIndex);
        if (!GetIsObjectValid(oAssociate))
            SendMessageToPC(oPC, "ally[" + IntToString(iIndex) + "]: invalid_object.");
        else
        {
            int bTrained = GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE) > 0;
            int bAvailable = bTrained && MECM_CanTakeTask(oAssociate, oPC);
            string sReasons = MECM_GetLocksmithRejectionReasons(oAssociate, oPC);
            SendMessageToPC(oPC, "ally[" + IntToString(iIndex) + "].id=" + ObjectToString(oAssociate) + " name=\"" + GetName(oAssociate) + "\" open_lock=" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oAssociate)) + "/" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oAssociate, TRUE)) + " trained=" + IntToString(bTrained) + " available=" + IntToString(bAvailable) + " action=" + IntToString(GetCurrentAction(oAssociate)) + " reasons=" + sReasons + ".");
            if (bAvailable)
                MECM_ReportTargetRejections(oAssociate, oPC, iTick, iIndex);
        }
    }
}

void MECM_ReleaseTask(object oAssociate)
{
    object oTarget = GetLocalObject(oAssociate, MECM_LOCAL_TASK);
    if (GetIsObjectValid(oTarget) && GetLocalObject(oTarget, MECM_LOCAL_ASSIGNEE) == oAssociate)
        DeleteLocalObject(oTarget, MECM_LOCAL_ASSIGNEE);
    DeleteLocalObject(oAssociate, MECM_LOCAL_TASK);
    DeleteLocalObject(oAssociate, MECM_LOCAL_OWNER);
    DeleteLocalInt(oAssociate, MECM_LOCAL_STALL);
    DeleteLocalFloat(oAssociate, MECM_LOCAL_STALL);
    DeleteLocalInt(oAssociate, MECM_LOCAL_RETRIES);
    DeleteLocalInt(oAssociate, MECM_LOCAL_LAST_DISTANCE);
    DeleteLocalObject(oAssociate, MECM_LOCAL_BLOCKING_DOOR);
    DeleteLocalObject(oAssociate, MECM_LOCAL_INITIAL_BLOCKING_DOOR);
    DeleteLocalInt(oAssociate, MECM_LOCAL_INITIAL_COMMAND);
}

void MECM_AbandonTask(object oAssociate)
{
    if (!GetIsObjectValid(oAssociate))
        return;
    ClearAllActions(FALSE, oAssociate);
    MECM_ReleaseTask(oAssociate);
}

float MECM_GetFollowDistance(object oAssociate)
{
    int iState = GetLocalInt(oAssociate, MECM_ASSOCIATE_STATE);
    if (iState & 0x00000001)
        return 2.0f;
    if (iState & 0x00000004)
        return 6.0f;
    return 4.0f;
}

void MECM_RestoreNaturalState(object oAssociate, object oOwner)
{
    if (!GetIsObjectValid(oAssociate) || GetIsDead(oAssociate))
        return;
    ClearAllActions(FALSE, oAssociate);
    if (GetIsInCombat(oAssociate) || GetLocalInt(oAssociate, MECM_ASSOCIATE_MOVEMENT_MODE) == ASSOCIATE_COMMAND_STANDGROUND)
        return;
    object oMaster = GetMaster(oAssociate);
    if (!GetIsObjectValid(oMaster))
        oMaster = oOwner;
    if (GetIsObjectValid(oMaster) && GetArea(oMaster) == GetArea(oAssociate))
        AssignCommand(oAssociate, ActionForceFollowObject(oMaster, MECM_GetFollowDistance(oAssociate)));
}

void MECM_CancelTask(object oAssociate)
{
    object oOwner = GetLocalObject(oAssociate, MECM_LOCAL_OWNER);
    MECM_ReleaseTask(oAssociate);
    MECM_RestoreNaturalState(oAssociate, oOwner);
}

void MECM_CancelAllTasks(object oPC)
{
    int iIndex;
    for (iIndex = 2; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetLocalObject(oCreature, MECM_LOCAL_OWNER) == oPC)
        {
            if (MECM_IsManagedAssociate(oCreature, oPC))
                MECM_CancelTask(oCreature);
            else
                MECM_AbandonTask(oCreature);
        }
    }
    for (iIndex = 1; iIndex <= MECM_GetVisibleLockCount(oPC); iIndex++)
    {
        object oTarget = MECM_GetVisibleLock(oPC, iIndex);
        object oAssignee = GetLocalObject(oTarget, MECM_LOCAL_ASSIGNEE);
        if (GetIsObjectValid(oAssignee) && GetLocalObject(oAssignee, MECM_LOCAL_OWNER) == oPC)
            MECM_AbandonTask(oAssignee);
    }
}

void MECM_AssignTask(object oAssociate, object oTarget, object oPC)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget) || !GetIsObjectValid(oPC) || GetArea(oAssociate) != GetArea(oTarget) || GetArea(oTarget) != GetArea(oPC) || !GetLocked(oTarget) || !MECM_IsRouteSafe(oAssociate, oTarget, oPC))
        return;
    if (GetCurrentAction(oAssociate) == ACTION_FOLLOW || GetCurrentAction(oAssociate) == ACTION_WAIT || GetCurrentAction(oAssociate) == ACTION_RANDOMWALK)
        ClearAllActions(FALSE, oAssociate);
    SetLocalObject(oAssociate, MECM_LOCAL_TASK, oTarget);
    SetLocalObject(oAssociate, MECM_LOCAL_OWNER, oPC);
    SetLocalObject(oTarget, MECM_LOCAL_ASSIGNEE, oAssociate);
    SetLocalInt(oAssociate, MECM_LOCAL_LAST_DISTANCE, FloatToInt(GetDistanceBetween(oAssociate, oTarget) * 100.0f));
    SetLocalInt(oAssociate, MECM_LOCAL_INITIAL_COMMAND, GetLastAssociateCommand(oAssociate));
    ExecuteScript("mecm_pathcheck", oAssociate);
    object oBlockingDoor = GetLocalObject(oAssociate, MECM_LOCAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor))
        SetLocalObject(oAssociate, MECM_LOCAL_INITIAL_BLOCKING_DOOR, oBlockingDoor);
    if (GetLocalInt(oPC, MECM_LOCAL_OVERHEAD_MESSAGES))
        FloatingTextStringOnCreature(MECM_GetText(MECM_TEXT_LOCK_CLAIM, oPC), oAssociate, TRUE, FALSE);
    AssignCommand(oAssociate, ActionUnlockObject(oTarget));
    AssignCommand(oAssociate, ActionDoCommand(ExecuteScript("mecm_done", oAssociate)));
}

void MECM_RetryTask(object oAssociate, object oTarget, int iRetry)
{
    if (!GetIsObjectValid(oAssociate) || !GetIsObjectValid(oTarget) || GetArea(oAssociate) != GetArea(oTarget) || !GetLocked(oTarget))
        return;
    ClearAllActions(FALSE, oAssociate);
    if (iRetry == 1)
        AssignCommand(oAssociate, ActionMoveToObject(oTarget, TRUE, 1.5f));
    else
        AssignCommand(oAssociate, ActionForceMoveToObject(oTarget, TRUE, 1.5f, 12.0f));
    AssignCommand(oAssociate, ActionUnlockObject(oTarget));
    AssignCommand(oAssociate, ActionDoCommand(ExecuteScript("mecm_done", oAssociate)));
}

void MECM_UpdateTask(object oAssociate, object oPC, int iTick)
{
    object oTarget = GetLocalObject(oAssociate, MECM_LOCAL_TASK);
    if (GetIsPossessedFamiliar(oAssociate) || GetIsPC(oAssociate))
    {
        MECM_AbandonTask(oAssociate);
        return;
    }
    if (!GetIsObjectValid(oTarget) || GetArea(oTarget) != GetArea(oAssociate) || !GetLocked(oTarget))
    {
        MECM_CancelTask(oAssociate);
        return;
    }

    if (!MECM_IsVisibleFromPlayer(oTarget, oPC) || !MECM_IsRouteSafe(oAssociate, oTarget, oPC))
    {
        SetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER, iTick + 1);
        MECM_CancelTask(oAssociate);
        return;
    }

    if (GetLastAssociateCommand(oAssociate) != GetLocalInt(oAssociate, MECM_LOCAL_INITIAL_COMMAND))
    {
        SetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER, iTick + 1);
        MECM_ReleaseTask(oAssociate);
        return;
    }

    int iAction = GetCurrentAction(oAssociate);
    if (iAction != ACTION_MOVETOPOINT && iAction != ACTION_OPENDOOR && iAction != ACTION_DISABLETRAP && iAction != ACTION_RECOVERTRAP && iAction != ACTION_OPENLOCK)
    {
        SetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER, iTick + 1);
        MECM_ReleaseTask(oAssociate);
        return;
    }

    ExecuteScript("mecm_pathcheck", oAssociate);
    object oBlockingDoor = GetLocalObject(oAssociate, MECM_LOCAL_BLOCKING_DOOR);
    object oInitialBlockingDoor = GetLocalObject(oAssociate, MECM_LOCAL_INITIAL_BLOCKING_DOOR);
    if (GetIsObjectValid(oBlockingDoor) && oBlockingDoor != oInitialBlockingDoor && oBlockingDoor != oTarget && GetArea(oBlockingDoor) == GetArea(oAssociate) && !GetIsOpen(oBlockingDoor))
    {
        SetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER, iTick + 1);
        MECM_CancelTask(oAssociate);
        return;
    }

    int iDistance = FloatToInt(GetDistanceBetween(oAssociate, oTarget) * 100.0f);
    int iLastDistance = GetLocalInt(oAssociate, MECM_LOCAL_LAST_DISTANCE);
    float fStall = GetLocalFloat(oAssociate, MECM_LOCAL_STALL);
    if (iLastDistance == 0 || iDistance < iLastDistance - 25 || (GetCurrentAction(oAssociate) == ACTION_OPENLOCK && iDistance < 300))
        fStall = 0.0f;
    else
        fStall += MECM_GetLockInterval(oPC);
    SetLocalInt(oAssociate, MECM_LOCAL_LAST_DISTANCE, iDistance);
    SetLocalFloat(oAssociate, MECM_LOCAL_STALL, fStall);

    if (fStall < MECM_STALL_SECONDS)
        return;

    int iRetry = GetLocalInt(oAssociate, MECM_LOCAL_RETRIES) + 1;
    if (iRetry <= MECM_MAX_PATH_RETRIES)
    {
        SetLocalInt(oAssociate, MECM_LOCAL_RETRIES, iRetry);
        SetLocalFloat(oAssociate, MECM_LOCAL_STALL, 0.0f);
        MECM_RetryTask(oAssociate, oTarget, iRetry);
        return;
    }

    SendMessageToPC(oPC, MECM_GetText(MECM_TEXT_PATH_FAILED, oPC) + " " + GetName(oTarget));
    SetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER, iTick + 1);
    MECM_CancelTask(oAssociate);
}

void MECM_UpdateAllTasks(object oPC, int iTick)
{
    int iIndex;
    for (iIndex = 2; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oCreature) && GetLocalObject(oCreature, MECM_LOCAL_OWNER) == oPC)
        {
            if (MECM_IsManagedAssociate(oCreature, oPC))
                MECM_UpdateTask(oCreature, oPC, iTick);
            else
                MECM_AbandonTask(oCreature);
        }
    }
}

void MECM_AssignAvailableTasks(object oPC, int iTick)
{
    int iAssignment;
    for (iAssignment = 0; iAssignment < MECM_MAX_ASSIGNMENTS; iAssignment++)
    {
        object oTarget = MECM_FindNearestAvailableTarget(oPC, iTick);
        if (!GetIsObjectValid(oTarget))
            return;
        object oAssociate = GetLocalObject(oPC, MECM_LOCAL_NEXT_ASSOCIATE);
        if (!GetIsObjectValid(oAssociate))
            return;
        MECM_AssignTask(oAssociate, oTarget, oPC);
    }
}

int MECM_ShouldProtectTarget(object oTarget, object oPC)
{
    if (!GetLocalInt(oPC, MECM_LOCAL_ATTACK_SAFETY))
        return FALSE;
    if (!GetIsObjectValid(oTarget))
        return FALSE;
    int iType = GetObjectType(oTarget);
    if (iType != OBJECT_TYPE_DOOR && iType != OBJECT_TYPE_PLACEABLE)
        return FALSE;
    if (MECM_IsReservationValid(oTarget))
        return TRUE;
    if (GetLocked(oTarget) && MECM_GroupHasAction(oPC, ACTION_OPENLOCK))
        return TRUE;
    if (GetIsTrapped(oTarget) && GetTrapActive(oTarget) && MECM_GroupHasAction(oPC, ACTION_DISABLETRAP))
        return TRUE;
    return GetLocalInt(oPC, MECM_LOCAL_ENABLED) && GetLocked(oTarget) && MECM_IsVisibleFromPlayer(oTarget, oPC);
}

void MECM_RunSafetyManager(object oPC)
{
    if (!GetLocalInt(oPC, MECM_LOCAL_ATTACK_SAFETY))
        return;
    int iIndex;
    for (iIndex = 2; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oCreature = MECM_GetGroupMember(oPC, iIndex);
        if (MECM_IsManagedAssociate(oCreature, oPC))
            ExecuteScript("mecm_guard", oCreature);
    }
}

void MECM_ClearLegacyAutoDetectActor(object oActor, object oPC)
{
    if (!GetIsObjectValid(oActor) || GetLocalObject(oActor, MECM_LOCAL_DETECT_OWNER) != oPC)
        return;
    if (GetLocalInt(oActor, MECM_LOCAL_DETECT_OWNED) && GetActionMode(oActor, ACTION_MODE_DETECT))
        SetActionMode(oActor, ACTION_MODE_DETECT, FALSE);
    DeleteLocalObject(oActor, MECM_LOCAL_DETECT_OWNER);
    DeleteLocalInt(oActor, MECM_LOCAL_DETECT_OWNED);
    DeleteLocalFloat(oActor, MECM_LOCAL_DETECT_STILL_TIME);
    DeleteLocalLocation(oActor, MECM_LOCAL_DETECT_LAST_LOCATION);
}

void MECM_RemoveLegacyAutoDetect(object oPC)
{
    if (GetLocalInt(oPC, MECM_LOCAL_DETECT_REMOVED))
        return;
    object oLegacyActor = GetLocalObject(oPC, MECM_LOCAL_DETECT_ACTOR);
    if (GetIsObjectValid(oLegacyActor) && GetLocalInt(oPC, MECM_LOCAL_DETECT_OWNED) && GetActionMode(oLegacyActor, ACTION_MODE_DETECT))
        SetActionMode(oLegacyActor, ACTION_MODE_DETECT, FALSE);
    DeleteLocalObject(oPC, MECM_LOCAL_DETECT_ACTOR);
    int iIndex;
    int iOldCount = GetLocalInt(oPC, MECM_LOCAL_DETECT_COUNT);
    for (iIndex = 1; iIndex <= iOldCount; iIndex++)
    {
        MECM_ClearLegacyAutoDetectActor(GetLocalObject(oPC, MECM_LOCAL_DETECT_MEMBER + IntToString(iIndex)), oPC);
        DeleteLocalObject(oPC, MECM_LOCAL_DETECT_MEMBER + IntToString(iIndex));
    }
    SetLocalInt(oPC, MECM_LOCAL_DETECT_COUNT, 0);
    for (iIndex = 1; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
        MECM_ClearLegacyAutoDetectActor(MECM_GetGroupMember(oPC, iIndex), oPC);
    DeleteLocalInt(oPC, MECM_LOCAL_DETECT_OWNED);
    DeleteLocalFloat(oPC, MECM_LOCAL_DETECT_STILL_TIME);
    DeleteLocalLocation(oPC, MECM_LOCAL_DETECT_LAST_LOCATION);
    SetLocalInt(oPC, MECM_LOCAL_AUTO_DETECT, FALSE);
    SetLocalInt(oPC, MECM_LOCAL_DETECT_REMOVED, TRUE);
}

void MECM_RunLockRegistryDispatcher(object oPC)
{
    MECM_BuildGroupCache(oPC);
    MECM_BuildLocksmithCache(oPC);
    int iTick = GetLocalInt(oPC, MECM_LOCAL_TICK);
    if (GetLocalInt(oPC, MECM_LOCAL_ENABLED))
        MECM_BuildVisibleLockCache(oPC, iTick);
    else
    {
        MECM_ClearCachedHighlights(oPC);
        SetLocalInt(oPC, MECM_LOCAL_LOCK_COUNT, 0);
    }
    if (GetLocalInt(oPC, MECM_LOCAL_DEBUG))
        SetLocalInt(oPC, MECM_LOCAL_REPORT_PENDING, TRUE);
    MECM_RemoveLegacyAutoDetect(oPC);
}

void MECM_RunLockDispatcher(object oPC)
{
    if (!MECM_IsRootPlayer(oPC))
        return;
    int iTick = GetLocalInt(oPC, MECM_LOCAL_TICK) + 1;
    SetLocalInt(oPC, MECM_LOCAL_TICK, iTick);
    MECM_UpdateCachedHighlights(oPC, iTick);
    MECM_RunSafetyManager(oPC);
    if (!GetLocalInt(oPC, MECM_LOCAL_ENABLED))
    {
        MECM_CancelAllTasks(oPC);
        return;
    }
    if (MECM_IsPossessingFamiliar(oPC))
    {
        if (!GetLocalInt(oPC, MECM_LOCAL_PAUSED))
            SendMessageToPC(oPC, MECM_GetText(MECM_TEXT_MODE_PAUSED, oPC));
        SetLocalInt(oPC, MECM_LOCAL_PAUSED, TRUE);
        MECM_CancelAllTasks(oPC);
        return;
    }
    DeleteLocalInt(oPC, MECM_LOCAL_PAUSED);
    if (MECM_IsPartyInCombat(oPC))
    {
        MECM_CancelAllTasks(oPC);
        return;
    }
    MECM_UpdateAllTasks(oPC, iTick);
    MECM_MarkManualReservations(oPC, iTick);
    if (GetLocalInt(oPC, MECM_LOCAL_DEBUG) && GetLocalInt(oPC, MECM_LOCAL_REPORT_PENDING))
    {
        int iAvailable = MECM_CountAvailableLocksmiths(oPC);
        int iAssignable = MECM_CountAssignableLocksmiths(oPC, iTick);
        SendMessageToPC(oPC, MECM_GetText(MECM_TEXT_SCAN_LOCKS, oPC) + IntToString(MECM_CountEligibleVisibleLocks(oPC, iTick)) + MECM_GetText(MECM_TEXT_SCAN_LOCKSMITHS, oPC) + IntToString(iAvailable) + ", assignable = " + IntToString(iAssignable) + ".");
        if (iAssignable == 0)
            MECM_ReportAssignmentFailure(oPC, iTick, iAvailable, iAssignable);
    }
    DeleteLocalInt(oPC, MECM_LOCAL_REPORT_PENDING);
    MECM_AssignAvailableTasks(oPC, iTick);
}

string MECM_GetDiagnosticObjectType(int iType)
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

int MECM_IsCachedLock(object oPC, object oTarget)
{
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetVisibleLockCount(oPC); iIndex++)
    {
        if (MECM_GetVisibleLock(oPC, iIndex) == oTarget)
            return TRUE;
    }
    return FALSE;
}

int MECM_GetDiagnosticActionPossible(object oActor, object oTarget)
{
    SetLocalObject(oActor, MECM_LOCAL_CHECK_TARGET, oTarget);
    DeleteLocalInt(oActor, MECM_LOCAL_CHECK_RESULT);
    ExecuteScript("mecm_diagact", oActor);
    int bResult = GetLocalInt(oActor, MECM_LOCAL_CHECK_RESULT);
    DeleteLocalObject(oActor, MECM_LOCAL_CHECK_TARGET);
    DeleteLocalInt(oActor, MECM_LOCAL_CHECK_RESULT);
    return bResult;
}

void MECM_ReportLOSProbes(object oPC, object oTarget)
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
    SendMessageToPC(oPC, "los.probes object=" + IntToString(LineOfSightObject(oPC, oTarget)) + " center=" + IntToString(LineOfSightVector(vSource, vTarget)) + " toward_025=" + IntToString(LineOfSightVector(vSource, vProbe025)) + " toward_050=" + IntToString(LineOfSightVector(vSource, vProbe050)) + " toward_100=" + IntToString(LineOfSightVector(vSource, vProbe100)) + " lock_los=" + IntToString(MECM_HasLineOfSightToLock(oTarget, oPC)) + " facing=" + FloatToString(GetFacingFromLocation(GetLocation(oTarget)), 0, 2));
    SendMessageToPC(oPC, "los.vectors source=[" + FloatToString(vSource.x, 0, 2) + "," + FloatToString(vSource.y, 0, 2) + "," + FloatToString(vSource.z, 0, 2) + "] target=[" + FloatToString(vTarget.x, 0, 2) + "," + FloatToString(vTarget.y, 0, 2) + "," + FloatToString(vTarget.z, 0, 2) + "]");
}

void MECM_ReportObject(object oPC, object oTarget)
{
    if (!MECM_IsRootPlayer(oPC) || !GetIsObjectValid(oTarget))
        return;
    MECM_BuildGroupCache(oPC);
    MECM_BuildLocksmithCache(oPC);
    int iType = GetObjectType(oTarget);
    int iTick = GetLocalInt(oPC, MECM_LOCAL_TICK);
    SendMessageToPC(oPC, "=== MECM object diagnostics " + MECM_VERSION + " ===");
    SendMessageToPC(oPC, "object.id=" + ObjectToString(oTarget) + " uuid=" + GetObjectUUID(oTarget) + " type=" + IntToString(iType) + "/" + MECM_GetDiagnosticObjectType(iType));
    SendMessageToPC(oPC, "name=\"" + GetName(oTarget) + "\" tag=\"" + GetTag(oTarget) + "\" resref=\"" + GetResRef(oTarget) + "\"");
    SendMessageToPC(oPC, "area.same=" + IntToString(GetArea(oTarget) == GetArea(oPC)) + " distance=" + FloatToString(GetDistanceBetween(oPC, oTarget), 0, 2) + " radius=" + FloatToString(MECM_GetSearchRadius(oPC), 0, 2) + " direct_los=" + IntToString(LineOfSightObject(oPC, oTarget)) + " require_los=" + IntToString(GetLocalInt(oPC, MECM_LOCAL_REQUIRE_LOS)));
    if (iType == OBJECT_TYPE_DOOR || iType == OBJECT_TYPE_PLACEABLE)
    {
        MECM_ReportLOSProbes(oPC, oTarget);
        SendMessageToPC(oPC, "state.locked=" + IntToString(GetLocked(oTarget)) + " open=" + IntToString(GetIsOpen(oTarget)) + " usable=" + IntToString(GetUseableFlag(oTarget)) + " plot=" + IntToString(GetPlotFlag(oTarget)) + " inventory=" + IntToString(GetHasInventory(oTarget)));
        SendMessageToPC(oPC, "lock.key_required=" + IntToString(GetLockKeyRequired(oTarget)) + " key_tag=\"" + GetLockKeyTag(oTarget) + "\" unlock_dc=" + IntToString(GetLockUnlockDC(oTarget)) + " lockable=" + IntToString(GetLockLockable(oTarget)));
        SendMessageToPC(oPC, "filter.candidate=" + IntToString(MECM_IsLockCandidate(oTarget, oPC, iTick)) + " visible=" + IntToString(MECM_IsVisibleFromPlayer(oTarget, oPC)) + " cached=" + IntToString(MECM_IsCachedLock(oPC, oTarget)) + " reserved=" + IntToString(MECM_IsReservationValid(oTarget)) + " manual_tick=" + IntToString(GetLocalInt(oTarget, MECM_LOCAL_MANUAL_TICK)) + " retry_after=" + IntToString(GetLocalInt(oTarget, MECM_LOCAL_RETRY_AFTER)) + " current_tick=" + IntToString(iTick));
        SendMessageToPC(oPC, "trap.present=" + IntToString(GetIsTrapped(oTarget)) + " active=" + IntToString(GetTrapActive(oTarget)) + " detected=" + IntToString(MECM_IsDetectedActiveTrap(oTarget, oPC)) + " flagged=" + IntToString(GetTrapFlagged(oTarget)) + " detectable=" + IntToString(GetTrapDetectable(oTarget)) + " disarmable=" + IntToString(GetTrapDisarmable(oTarget)));
    }
    int iIndex;
    for (iIndex = 1; iIndex <= MECM_GetGroupCount(oPC); iIndex++)
    {
        object oActor = MECM_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oActor))
            SendMessageToPC(oPC, "actor[" + IntToString(iIndex) + "].id=" + ObjectToString(oActor) + " name=\"" + GetName(oActor) + "\" pc=" + IntToString(GetIsPC(oActor)) + " commandable=" + IntToString(GetCommandable(oActor)) + " action=" + IntToString(GetCurrentAction(oActor)) + " open_lock=" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oActor)) + "/" + IntToString(GetSkillRank(SKILL_OPEN_LOCK, oActor, TRUE)) + " can_take=" + IntToString(MECM_CanTakeTask(oActor, oPC)) + " can_unlock=" + IntToString(MECM_CanUnlock(oActor, oTarget)) + " route_safe=" + IntToString(MECM_IsRouteSafe(oActor, oTarget, oPC)) + " engine_action=" + IntToString(MECM_GetDiagnosticActionPossible(oActor, oTarget)));
    }
    SendMessageToPC(oPC, "=== end MECM diagnostics ===");
}

void MECM_ScheduleDispatcherBurst(object oPC, string sScript, float fInterval)
{
    float fDelay = fInterval;
    int iCount = 0;
    while (fDelay < MECM_BASE_HEARTBEAT_SECONDS && iCount < 60)
    {
        DelayCommand(fDelay, ExecuteScript(sScript, oPC));
        fDelay += fInterval;
        iCount++;
    }
}

void MECM_RunSchedulerDispatcher(object oPC)
{
    if (GetLocalInt(oPC, MECM_LOCAL_ENABLED) || GetLocalInt(oPC, MECM_LOCAL_ATTACK_SAFETY))
        MECM_ScheduleDispatcherBurst(oPC, "mecm_lock", MECM_GetLockInterval(oPC));
}

void MECM_Heartbeat(object oPC)
{
    if (!MECM_IsRootPlayer(oPC))
        return;
    MECM_InitializeSettings(oPC);
    ExecuteScript("mecm_registry", oPC);
    ExecuteScript("mecm_lock", oPC);
    ExecuteScript("mecm_schedule", oPC);
    if (!GetLocalInt(oPC, MECM_LOCAL_INSTALLED))
    {
        SetLocalInt(oPC, MECM_LOCAL_INSTALLED, TRUE);
        SendMessageToPC(oPC, MECM_GetText(MECM_TEXT_INSTALLED, oPC) + " " + MECM_VERSION);
    }
}

void MECM_UnlockActionCompleted(object oAssociate)
{
    object oTarget = GetLocalObject(oAssociate, MECM_LOCAL_TASK);
    if (GetIsObjectValid(oTarget) && GetLocked(oTarget))
        return;
    object oOwner = GetLocalObject(oAssociate, MECM_LOCAL_OWNER);
    MECM_ClearHighlight(oTarget);
    ClearAllActions(FALSE, oAssociate);
    MECM_ReleaseTask(oAssociate);
    if (MECM_IsRootPlayer(oOwner))
        ExecuteScript("mecm_lock", oOwner);
    if (!GetIsObjectValid(GetLocalObject(oAssociate, MECM_LOCAL_TASK)))
        MECM_RestoreNaturalState(oAssociate, oOwner);
}
