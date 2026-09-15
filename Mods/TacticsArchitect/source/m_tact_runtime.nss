#include "m_tact_meta"
#include "memoria_math"
#include "x0_i0_assoc"

const string M_TACT_LOCAL_EXPECTED_ACTION = "M_TACT_EXPECTED_ACTION";
const string M_TACT_LOCAL_EVAL_TARGET = "M_TACT_EVAL_TARGET";
const string M_TACT_LOCAL_EVAL_LOCATION = "M_TACT_EVAL_LOCATION";
const string M_TACT_LOCAL_EVAL_IS_LOCATION = "M_TACT_EVAL_IS_LOCATION";
const string M_TACT_LOCAL_EVAL_CLASS = "M_TACT_EVAL_CLASS";
const string M_TACT_LOCAL_EVAL_METAMAGIC = "M_TACT_EVAL_METAMAGIC";
const string M_TACT_LOCAL_EVAL_DOMAIN = "M_TACT_EVAL_DOMAIN";
const string M_TACT_LOCAL_ACTIVE_TARGET = "M_TACT_ACTIVE_TARGET";
const string M_TACT_LOCAL_ACTIVE_TARGET_SET = "M_TACT_ACTIVE_TARGET_SET";
const string M_TACT_LOCAL_PENDING_EQUIP_ITEM = "M_TACT_PENDING_EQUIP_ITEM";
const string M_TACT_LOCAL_PENDING_EQUIP_SLOT = "M_TACT_PENDING_EQUIP_SLOT";
const string M_TACT_LOCAL_PENDING_EQUIP_ACTION = "M_TACT_PENDING_EQUIP_ACTION";
const string M_TACT_LOCAL_PENDING_EQUIP_CAST = "M_TACT_PENDING_EQUIP_CAST";
const int M_TACT_MAX_TARGETS = 32;

int M_TACT_Fail(object oActor, string sReason)
{
    SetLocalString(oActor, M_TACT_LOCAL_FAILURE, sReason);
    return FALSE;
}

int M_TACT_GetHealthPercent(object oCreature)
{
    return MEMORIA_GetHealthPercent(oCreature);
}

object M_TACT_GetEnemy(object oActor, int iNth)
{
    return GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oActor, iNth, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
}

int M_TACT_CountEnemies(object oActor, float fRadius)
{
    int iCount;
    int iNth = 1;
    object oEnemy = M_TACT_GetEnemy(oActor, iNth);
    while (GetIsObjectValid(oEnemy) && iNth <= M_TACT_MAX_TARGETS)
    {
        if (!GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor) && GetDistanceBetween(oActor, oEnemy) <= fRadius)
            iCount++;
        iNth++;
        oEnemy = M_TACT_GetEnemy(oActor, iNth);
    }
    return iCount;
}

object M_TACT_GetLowestHealthAlly(object oActor, object oPC, float fRadius)
{
    object oBest = OBJECT_INVALID;
    int iBestHealth = 101;
    int iIndex;
    for (iIndex = 1; iIndex <= M_TACT_GetGroupCount(oPC); iIndex++)
    {
        object oAlly = M_TACT_GetGroupMember(oPC, iIndex);
        if (GetIsObjectValid(oAlly) && !GetIsDead(oAlly) && GetArea(oAlly) == GetArea(oActor) && GetDistanceBetween(oActor, oAlly) <= fRadius)
        {
            int iHealth = M_TACT_GetHealthPercent(oAlly);
            if (iHealth < iBestHealth)
            {
                oBest = oAlly;
                iBestHealth = iHealth;
            }
        }
    }
    return oBest;
}

int M_TACT_EnemyMatchesTargetCondition(object oActor, object oEnemy, json jCondition)
{
    if (JsonGetString(JsonObjectGet(jCondition, "kind")) != "enemy_rating") return TRUE;
    int iRating = M_TACT_GetRelativeEnemyRating(oActor, oEnemy);
    int iThreshold = JsonGetInt(JsonObjectGet(jCondition, "value"));
    return JsonGetString(JsonObjectGet(jCondition, "comparison")) == "max" ? iRating <= iThreshold : iRating >= iThreshold;
}

int M_TACT_CountMatchingEnemies(object oActor, json jCondition)
{
    int iCount;
    int iNth = 1;
    object oEnemy = M_TACT_GetEnemy(oActor, iNth);
    while (GetIsObjectValid(oEnemy) && iNth <= M_TACT_MAX_TARGETS)
    {
        if (!GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor) && M_TACT_EnemyMatchesTargetCondition(oActor, oEnemy, jCondition)) iCount++;
        iNth++;
        oEnemy = M_TACT_GetEnemy(oActor, iNth);
    }
    return iCount;
}

object M_TACT_GetHealthEnemy(object oActor, int iSpell, int iSpellLevel, int bLowest, json jCondition)
{
    object oBest = OBJECT_INVALID;
    int iBestHealth = bLowest ? 2147483647 : -2147483647;
    int iNth = 1;
    object oEnemy = M_TACT_GetEnemy(oActor, iNth);
    while (GetIsObjectValid(oEnemy) && iNth <= M_TACT_MAX_TARGETS)
    {
        int iHealth = GetCurrentHitPoints(oEnemy);
        if (!GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor) && M_TACT_EnemyMatchesTargetCondition(oActor, oEnemy, jCondition) && (iSpell < 0 || M_TACT_IsSpellSensible(oActor, oEnemy, iSpell, iSpellLevel)) && ((bLowest && iHealth < iBestHealth) || (!bLowest && iHealth > iBestHealth)))
        {
            oBest = oEnemy;
            iBestHealth = iHealth;
        }
        iNth++;
        oEnemy = M_TACT_GetEnemy(oActor, iNth);
    }
    return oBest;
}

int M_TACT_IsEnemySpellcaster(object oEnemy)
{
    if (GetSpellAbilityCount(oEnemy) > 0) return TRUE;
    int iPosition;
    for (iPosition = 1; iPosition <= 8; iPosition++)
    {
        int iClass = GetClassByPosition(iPosition, oEnemy);
        if (iClass != CLASS_TYPE_INVALID && GetLevelByClass(iClass, oEnemy) > 0 && Get2DAString("classes", "SpellCaster", iClass) == "1") return TRUE;
    }
    return FALSE;
}

int M_TACT_CompareEnemyPriority(object oActor, object oCandidate, object oCurrent, json jPriorities)
{
    if (!GetIsObjectValid(oCurrent)) return 1;
    if (JsonGetType(jPriorities) != JSON_TYPE_ARRAY) return 0;
    int iPriority;
    for (iPriority = 0; iPriority < JsonGetLength(jPriorities); iPriority++)
    {
        json jPriority = JsonArrayGet(jPriorities, iPriority);
        if (!JsonGetInt(JsonObjectGet(jPriority, "enabled"))) continue;
        string sKind = JsonGetString(JsonObjectGet(jPriority, "kind"));
        int iCandidate;
        int iCurrent;
        int bLowerIsBetter;
        if (sKind == "caster")
        {
            iCandidate = M_TACT_IsEnemySpellcaster(oCandidate);
            iCurrent = M_TACT_IsEnemySpellcaster(oCurrent);
        }
        else if (sKind == "rating_high" || sKind == "rating_low")
        {
            iCandidate = M_TACT_GetRelativeEnemyRating(oActor, oCandidate);
            iCurrent = M_TACT_GetRelativeEnemyRating(oActor, oCurrent);
            bLowerIsBetter = sKind == "rating_low";
        }
        else if (sKind == "health_low" || sKind == "health_high")
        {
            iCandidate = GetCurrentHitPoints(oCandidate);
            iCurrent = GetCurrentHitPoints(oCurrent);
            bLowerIsBetter = sKind == "health_low";
        }
        else continue;
        if (iCandidate != iCurrent) return bLowerIsBetter ? (iCandidate < iCurrent ? 1 : -1) : (iCandidate > iCurrent ? 1 : -1);
    }
    return 0;
}

object M_TACT_GetPrioritizedEnemy(object oActor, int iSpell, int iSpellLevel, json jPriorities, json jCondition)
{
    object oBest = OBJECT_INVALID;
    int iNth = 1;
    object oEnemy = M_TACT_GetEnemy(oActor, iNth);
    while (GetIsObjectValid(oEnemy) && iNth <= M_TACT_MAX_TARGETS)
    {
        if (!GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor) && M_TACT_EnemyMatchesTargetCondition(oActor, oEnemy, jCondition) && (iSpell < 0 || M_TACT_IsSpellSensible(oActor, oEnemy, iSpell, iSpellLevel)) && M_TACT_CompareEnemyPriority(oActor, oEnemy, oBest, jPriorities) > 0) oBest = oEnemy;
        iNth++;
        oEnemy = M_TACT_GetEnemy(oActor, iNth);
    }
    return oBest;
}

json M_TACT_AppendTargetPriorities(json jCombined, json jPriorities)
{
    if (JsonGetType(jCombined) != JSON_TYPE_ARRAY) jCombined = JsonArray();
    if (JsonGetType(jPriorities) != JSON_TYPE_ARRAY) return jCombined;
    int iPriority;
    for (iPriority = 0; iPriority < JsonGetLength(jPriorities); iPriority++) jCombined = JsonArrayInsert(jCombined, JsonArrayGet(jPriorities, iPriority));
    return jCombined;
}

json M_TACT_GetEffectiveTargetPriorities(json jAction, json jRule, json jTactic)
{
    json jPriorities = M_TACT_AppendTargetPriorities(JsonArray(), JsonObjectGet(jAction, "target_priorities"));
    jPriorities = M_TACT_AppendTargetPriorities(jPriorities, JsonObjectGet(jRule, "target_priorities"));
    return M_TACT_AppendTargetPriorities(jPriorities, JsonObjectGet(jTactic, "target_priorities"));
}

void M_TACT_UpdateMotion(object oCreature, int iTick)
{
    if (!GetIsObjectValid(oCreature) || GetIsDead(oCreature) || GetLocalInt(oCreature, M_TACT_LOCAL_MOTION_TICK) == iTick) return;
    vector vPosition = GetPosition(oCreature);
    object oArea = GetArea(oCreature);
    int iPreviousTick = GetLocalInt(oCreature, M_TACT_LOCAL_MOTION_TICK);
    if (iPreviousTick > 0 && iPreviousTick < iTick && GetLocalObject(oCreature, M_TACT_LOCAL_MOTION_AREA) == oArea)
    {
        float fElapsed = IntToFloat(iTick - iPreviousTick) * M_TACT_INTERVAL;
        float fDeltaX = vPosition.x - GetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_X);
        float fDeltaY = vPosition.y - GetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_Y);
        float fDistance = sqrt(fDeltaX * fDeltaX + fDeltaY * fDeltaY);
        float fVelocityX;
        float fVelocityY;
        if (fElapsed > 0.0f && fDistance <= 10.0f)
        {
            fVelocityX = fDeltaX / fElapsed;
            fVelocityY = fDeltaY / fElapsed;
            float fSpeed = sqrt(fVelocityX * fVelocityX + fVelocityY * fVelocityY);
            if (fSpeed > 8.0f) { fVelocityX = fVelocityX * 8.0f / fSpeed; fVelocityY = fVelocityY * 8.0f / fSpeed; }
            SetLocalInt(oCreature, M_TACT_LOCAL_MOTION_READY, TRUE);
        }
        else DeleteLocalInt(oCreature, M_TACT_LOCAL_MOTION_READY);
        SetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_VX, fVelocityX);
        SetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_VY, fVelocityY);
    }
    else
    {
        SetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_VX, 0.0f);
        SetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_VY, 0.0f);
        DeleteLocalInt(oCreature, M_TACT_LOCAL_MOTION_READY);
    }
    SetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_X, vPosition.x);
    SetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_Y, vPosition.y);
    SetLocalObject(oCreature, M_TACT_LOCAL_MOTION_AREA, oArea);
    SetLocalInt(oCreature, M_TACT_LOCAL_MOTION_TICK, iTick);
}

vector M_TACT_PredictPosition(object oCreature, float fSeconds)
{
    vector vPosition = GetPosition(oCreature);
    if (fSeconds < 0.0f) fSeconds = 0.0f;
    if (fSeconds > 6.0f) fSeconds = 6.0f;
    return Vector(vPosition.x + GetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_VX) * fSeconds, vPosition.y + GetLocalFloat(oCreature, M_TACT_LOCAL_MOTION_VY) * fSeconds, vPosition.z);
}

float M_TACT_Distance2D(vector vLeft, vector vRight)
{
    return MEMORIA_Distance2D(vLeft, vRight);
}

vector M_TACT_ClosestPointOnSegment2D(vector vPoint, vector vStart, vector vEnd)
{
    return MEMORIA_ClosestPointOnSegment2D(vPoint, vStart, vEnd);
}

float M_TACT_DistanceToSegment2D(vector vPoint, vector vStart, vector vEnd)
{
    return MEMORIA_DistanceToSegment2D(vPoint, vStart, vEnd);
}

float M_TACT_GetSpellImpactDelay(object oActor, int iSpell, int iMetaMagic, vector vCenter)
{
    float fConjure = StringToFloat(Get2DAString("spells", "ConjTime", iSpell)) / 1000.0f;
    float fCast = StringToFloat(Get2DAString("spells", "CastTime", iSpell)) / 1000.0f;
    float fDelay = fConjure + fCast;
    if (iMetaMagic == METAMAGIC_QUICKEN) fDelay = M_TACT_INTERVAL;
    if (Get2DAString("spells", "HasProjectile", iSpell) == "1") fDelay += M_TACT_Distance2D(GetPosition(oActor), vCenter) / M_TACT_AOE_PROJECTILE_SPEED;
    if (fDelay < M_TACT_INTERVAL) fDelay = M_TACT_INTERVAL;
    if (fDelay > 6.0f) fDelay = 6.0f;
    return fDelay;
}

int M_TACT_GetAoeSafetyMode(json jAction)
{
    int iMode = JsonGetInt(JsonObjectGet(jAction, "aoe_safety"));
    return iMode >= M_TACT_AOE_SAFETY_SAFE && iMode <= M_TACT_AOE_SAFETY_STATIONARY ? iMode : M_TACT_AOE_SAFETY_SAFE;
}

int M_TACT_AreRelevantAlliesStationary(object oPC, object oActor)
{
    int iIndex;
    for (iIndex = 1; iIndex <= M_TACT_GetGroupCount(oPC); iIndex++)
    {
        object oAlly = M_TACT_GetGroupMember(oPC, iIndex);
        if (!GetIsObjectValid(oAlly) || oAlly == oActor || GetIsDead(oAlly) || GetArea(oAlly) != GetArea(oActor) || GetDistanceBetween(oActor, oAlly) > 40.0f) continue;
        if (!GetLocalInt(oAlly, M_TACT_LOCAL_MOTION_READY)) return FALSE;
        float fVelocityX = GetLocalFloat(oAlly, M_TACT_LOCAL_MOTION_VX);
        float fVelocityY = GetLocalFloat(oAlly, M_TACT_LOCAL_MOTION_VY);
        if (fVelocityX * fVelocityX + fVelocityY * fVelocityY > M_TACT_AOE_STATIONARY_SPEED * M_TACT_AOE_STATIONARY_SPEED) return FALSE;
    }
    return TRUE;
}

vector M_TACT_PredictFriendlyEndpoint(object oPC, object oActor, object oAlly, float fDelay)
{
    vector vStart = GetPosition(oAlly);
    if (oAlly == oActor) return vStart;
    float fVelocityX = GetLocalFloat(oAlly, M_TACT_LOCAL_MOTION_VX);
    float fVelocityY = GetLocalFloat(oAlly, M_TACT_LOCAL_MOTION_VY);
    float fVelocitySquared = fVelocityX * fVelocityX + fVelocityY * fVelocityY;
    if (fVelocitySquared <= 0.01f) return vStart;
    float fStopTime = fDelay;
    int iTick = GetLocalInt(oPC, M_TACT_LOCAL_DISPATCH_TICK);
    int iEnemyIndex = 1;
    object oEnemy = M_TACT_GetEnemy(oActor, iEnemyIndex);
    while (GetIsObjectValid(oEnemy) && iEnemyIndex <= M_TACT_MAX_AOE_TARGETS)
    {
        if (!GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor))
        {
            M_TACT_UpdateMotion(oEnemy, iTick);
            vector vEnemy = GetPosition(oEnemy);
            float fRelativePositionX = vStart.x - vEnemy.x;
            float fRelativePositionY = vStart.y - vEnemy.y;
            float fRelativeVelocityX = fVelocityX - GetLocalFloat(oEnemy, M_TACT_LOCAL_MOTION_VX);
            float fRelativeVelocityY = fVelocityY - GetLocalFloat(oEnemy, M_TACT_LOCAL_MOTION_VY);
            float fA = fRelativeVelocityX * fRelativeVelocityX + fRelativeVelocityY * fRelativeVelocityY;
            float fB = 2.0f * (fRelativePositionX * fRelativeVelocityX + fRelativePositionY * fRelativeVelocityY);
            float fC = fRelativePositionX * fRelativePositionX + fRelativePositionY * fRelativePositionY - M_TACT_AOE_ENGAGEMENT_DISTANCE * M_TACT_AOE_ENGAGEMENT_DISTANCE;
            if (fC <= 0.0f) fStopTime = 0.0f;
            else if (fA > 0.0001f)
            {
                float fDiscriminant = fB * fB - 4.0f * fA * fC;
                if (fDiscriminant >= 0.0f)
                {
                    float fContactTime = (-fB - sqrt(fDiscriminant)) / (2.0f * fA);
                    if (fContactTime >= 0.0f && fContactTime < fStopTime) fStopTime = fContactTime;
                }
            }
        }
        iEnemyIndex++;
        oEnemy = M_TACT_GetEnemy(oActor, iEnemyIndex);
    }
    return Vector(vStart.x + fVelocityX * fStopTime, vStart.y + fVelocityY * fStopTime, vStart.z);
}

int M_TACT_IsFriendlyTrajectorySafe(object oPC, object oActor, vector vCenter, float fRadius, float fDelay)
{
    float fMinimumClearance = 1000.0f;
    int iIndex;
    for (iIndex = 1; iIndex <= M_TACT_GetGroupCount(oPC); iIndex++)
    {
        object oAlly = M_TACT_GetGroupMember(oPC, iIndex);
        if (!GetIsObjectValid(oAlly) || GetIsDead(oAlly) || GetArea(oAlly) != GetArea(oActor)) continue;
        vector vStart = GetPosition(oAlly);
        vector vEnd = M_TACT_PredictFriendlyEndpoint(oPC, oActor, oAlly, fDelay);
        float fClearance = M_TACT_DistanceToSegment2D(vCenter, vStart, vEnd) - fRadius - M_TACT_AOE_ALLY_MARGIN;
        if (fClearance < fMinimumClearance) fMinimumClearance = fClearance;
        if (fClearance <= 0.0f)
        {
            SetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON, "ally_trajectory:" + GetName(oAlly));
            return FALSE;
        }
    }
    SetLocalFloat(oActor, M_TACT_LOCAL_AOE_CLEARANCE, fMinimumClearance);
    return TRUE;
}

json M_TACT_AddClusterCandidate(json jCandidates, vector vCenter, int iSeedIndex)
{
    json jCandidate = JsonObject();
    jCandidate = JsonObjectSet(jCandidate, "x", JsonFloat(vCenter.x));
    jCandidate = JsonObjectSet(jCandidate, "y", JsonFloat(vCenter.y));
    jCandidate = JsonObjectSet(jCandidate, "z", JsonFloat(vCenter.z));
    jCandidate = JsonObjectSet(jCandidate, "seed", JsonInt(iSeedIndex));
    return JsonArrayInsert(jCandidates, jCandidate);
}

vector M_TACT_GetClusterCandidatePosition(json jCandidate)
{
    return Vector(JsonGetFloat(JsonObjectGet(jCandidate, "x")), JsonGetFloat(JsonObjectGet(jCandidate, "y")), JsonGetFloat(JsonObjectGet(jCandidate, "z")));
}

int M_TACT_CountClusterCandidateEnemies(object oActor, json jEnemyIndices, vector vCenter, float fRadius, float fDelay)
{
    int iCount;
    int iIndex;
    for (iIndex = 0; iIndex < JsonGetLength(jEnemyIndices); iIndex++)
    {
        object oEnemy = M_TACT_GetEnemy(oActor, JsonGetInt(JsonArrayGet(jEnemyIndices, iIndex)));
        if (GetIsObjectValid(oEnemy) && !GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor) && M_TACT_Distance2D(M_TACT_PredictPosition(oEnemy, fDelay), vCenter) <= fRadius) iCount++;
    }
    return iCount;
}

int M_TACT_CountPredictedSensibleEnemies(object oActor, object oPC, int iSpell, int iSpellLevel, vector vCenter, float fRadius, float fDelay)
{
    int iCount;
    int iTick = GetLocalInt(oPC, M_TACT_LOCAL_DISPATCH_TICK);
    int iEnemyIndex = 1;
    object oEnemy = M_TACT_GetEnemy(oActor, iEnemyIndex);
    while (GetIsObjectValid(oEnemy) && iEnemyIndex <= M_TACT_MAX_AOE_TARGETS)
    {
        M_TACT_UpdateMotion(oEnemy, iTick);
        if (!GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor) && M_TACT_Distance2D(M_TACT_PredictPosition(oEnemy, fDelay), vCenter) <= fRadius && M_TACT_IsSpellSensible(oActor, oEnemy, iSpell, iSpellLevel)) iCount++;
        iEnemyIndex++;
        oEnemy = M_TACT_GetEnemy(oActor, iEnemyIndex);
    }
    return iCount;
}

location M_TACT_FindBestCluster(object oActor, object oPC, int iSpell, int iSpellLevel, int iMetaMagic, int bFriendlyFire, int iMinimum, json jPriorities, json jCondition)
{
    location lBest;
    object oBestSeed = OBJECT_INVALID;
    int iBestCount = iMinimum - 1;
    float fBestClearance = -1000.0f;
    int bEnoughPredictedEnemies;
    int bUnsafeAllyTrajectory;
    string sUnsafeAlly;
    float fRadius = M_TACT_GetSpellAreaRadius(oActor, iSpell, iSpellLevel, iMetaMagic);
    int iTick = GetLocalInt(oPC, M_TACT_LOCAL_DISPATCH_TICK);
    json jEnemyIndices = JsonArray();
    int iEnemyIndex = 1;
    object oEnemy = M_TACT_GetEnemy(oActor, iEnemyIndex);
    while (GetIsObjectValid(oEnemy) && iEnemyIndex <= M_TACT_MAX_AOE_TARGETS)
    {
        M_TACT_UpdateMotion(oEnemy, iTick);
        if (!GetIsDead(oEnemy) && GetArea(oEnemy) == GetArea(oActor) && M_TACT_EnemyMatchesTargetCondition(oActor, oEnemy, jCondition) && M_TACT_IsSpellSensible(oActor, oEnemy, iSpell, iSpellLevel)) jEnemyIndices = JsonArrayInsert(jEnemyIndices, JsonInt(iEnemyIndex));
        iEnemyIndex++;
        oEnemy = M_TACT_GetEnemy(oActor, iEnemyIndex);
    }
    json jCandidates = JsonArray();
    int iCandidateEnemyCount = JsonGetLength(jEnemyIndices);
    if (iCandidateEnemyCount > M_TACT_MAX_AOE_CANDIDATE_ENEMIES) iCandidateEnemyCount = M_TACT_MAX_AOE_CANDIDATE_ENEMIES;
    int iLeft;
    for (iLeft = 0; iLeft < iCandidateEnemyCount; iLeft++)
    {
        int iSeedIndex = JsonGetInt(JsonArrayGet(jEnemyIndices, iLeft));
        object oSeed = M_TACT_GetEnemy(oActor, iSeedIndex);
        if (!GetIsObjectValid(oSeed) || GetIsDead(oSeed) || GetArea(oSeed) != GetArea(oActor)) continue;
        float fSeedDelay = M_TACT_GetSpellImpactDelay(oActor, iSpell, iMetaMagic, GetPosition(oSeed));
        vector vSeed = M_TACT_PredictPosition(oSeed, fSeedDelay);
        jCandidates = M_TACT_AddClusterCandidate(jCandidates, vSeed, iSeedIndex);
        float fNearestAlly = 1000.0f;
        vector vNearestAllyPoint;
        int bNearestAlly;
        int iAllyIndex;
        for (iAllyIndex = 1; iAllyIndex <= M_TACT_GetGroupCount(oPC); iAllyIndex++)
        {
            object oAlly = M_TACT_GetGroupMember(oPC, iAllyIndex);
            if (!GetIsObjectValid(oAlly) || GetIsDead(oAlly) || GetArea(oAlly) != GetArea(oActor)) continue;
            vector vAllyStart = GetPosition(oAlly);
            vector vAllyEnd = M_TACT_PredictFriendlyEndpoint(oPC, oActor, oAlly, fSeedDelay);
            vector vClosestAlly = M_TACT_ClosestPointOnSegment2D(vSeed, vAllyStart, vAllyEnd);
            float fAllyDistance = M_TACT_Distance2D(vSeed, vClosestAlly);
            if (fAllyDistance < fNearestAlly)
            {
                fNearestAlly = fAllyDistance;
                vNearestAllyPoint = vClosestAlly;
                bNearestAlly = TRUE;
            }
        }
        if (bNearestAlly && fNearestAlly > 0.01f)
        {
            float fShift = fRadius * 0.98f / fNearestAlly;
            jCandidates = M_TACT_AddClusterCandidate(jCandidates, Vector(vSeed.x + (vSeed.x - vNearestAllyPoint.x) * fShift, vSeed.y + (vSeed.y - vNearestAllyPoint.y) * fShift, vSeed.z), iSeedIndex);
        }
        int iRight;
        for (iRight = iLeft + 1; iRight < iCandidateEnemyCount; iRight++)
        {
            int iPartnerIndex = JsonGetInt(JsonArrayGet(jEnemyIndices, iRight));
            object oPartner = M_TACT_GetEnemy(oActor, iPartnerIndex);
            if (!GetIsObjectValid(oPartner) || GetIsDead(oPartner) || GetArea(oPartner) != GetArea(oActor)) continue;
            vector vCurrentMidpoint = Vector((GetPosition(oSeed).x + GetPosition(oPartner).x) / 2.0f, (GetPosition(oSeed).y + GetPosition(oPartner).y) / 2.0f, (GetPosition(oSeed).z + GetPosition(oPartner).z) / 2.0f);
            float fPairDelay = M_TACT_GetSpellImpactDelay(oActor, iSpell, iMetaMagic, vCurrentMidpoint);
            vector vLeft = M_TACT_PredictPosition(oSeed, fPairDelay);
            vector vRight = M_TACT_PredictPosition(oPartner, fPairDelay);
            float fDeltaX = vRight.x - vLeft.x;
            float fDeltaY = vRight.y - vLeft.y;
            float fDistance = sqrt(fDeltaX * fDeltaX + fDeltaY * fDeltaY);
            if (fDistance > fRadius * 2.0f || fDistance <= 0.01f) continue;
            vector vMidpoint = Vector((vLeft.x + vRight.x) / 2.0f, (vLeft.y + vRight.y) / 2.0f, (vLeft.z + vRight.z) / 2.0f);
            float fHalfDistance = fDistance / 2.0f;
            float fHeight = sqrt(fRadius * fRadius - fHalfDistance * fHalfDistance);
            float fPerpendicularX = -fDeltaY / fDistance;
            float fPerpendicularY = fDeltaX / fDistance;
            jCandidates = M_TACT_AddClusterCandidate(jCandidates, vMidpoint, iSeedIndex);
            jCandidates = M_TACT_AddClusterCandidate(jCandidates, Vector(vMidpoint.x + fPerpendicularX * fHeight, vMidpoint.y + fPerpendicularY * fHeight, vMidpoint.z), iSeedIndex);
            jCandidates = M_TACT_AddClusterCandidate(jCandidates, Vector(vMidpoint.x - fPerpendicularX * fHeight, vMidpoint.y - fPerpendicularY * fHeight, vMidpoint.z), iSeedIndex);
        }
    }
    int iCandidateIndex;
    for (iCandidateIndex = 0; iCandidateIndex < JsonGetLength(jCandidates); iCandidateIndex++)
    {
        json jCandidate = JsonArrayGet(jCandidates, iCandidateIndex);
        vector vCenter = M_TACT_GetClusterCandidatePosition(jCandidate);
        float fFinalDelay = M_TACT_GetSpellImpactDelay(oActor, iSpell, iMetaMagic, vCenter);
        int iCount = M_TACT_CountClusterCandidateEnemies(oActor, jEnemyIndices, vCenter, fRadius, fFinalDelay);
        if (iCount >= iMinimum)
        {
            bEnoughPredictedEnemies = TRUE;
            int bSafe = bFriendlyFire || M_TACT_IsFriendlyTrajectorySafe(oPC, oActor, vCenter, fRadius, fFinalDelay);
            float fClearance = bFriendlyFire ? 0.0f : GetLocalFloat(oActor, M_TACT_LOCAL_AOE_CLEARANCE);
            if (!bSafe)
            {
                bUnsafeAllyTrajectory = TRUE;
                sUnsafeAlly = GetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON);
            }
            object oSeed = M_TACT_GetEnemy(oActor, JsonGetInt(JsonObjectGet(jCandidate, "seed")));
            int bBetter = iCount > iBestCount || iCount == iBestCount && fClearance > fBestClearance + 0.05f || iCount == iBestCount && fClearance >= fBestClearance - 0.05f && M_TACT_CompareEnemyPriority(oActor, oSeed, oBestSeed, jPriorities) > 0;
            if (bSafe && bBetter)
            {
                lBest = Location(GetArea(oActor), vCenter, 0.0f);
                oBestSeed = oSeed;
                iBestCount = iCount;
                fBestClearance = fClearance;
            }
        }
    }
    if (GetAreaFromLocation(lBest) != GetArea(oActor)) SetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON, bUnsafeAllyTrajectory ? sUnsafeAlly : bEnoughPredictedEnemies ? "no_reachable_predicted_cluster" : "not_enough_predicted_enemies");
    return lBest;
}

int M_TACT_MatchesCondition(object oActor, object oPC, json jCondition)
{
    string sKind = JsonGetString(JsonObjectGet(jCondition, "kind"));
    int iValue = JsonGetInt(JsonObjectGet(jCondition, "value"));
    float fRadius = JsonGetFloat(JsonObjectGet(jCondition, "radius"));
    if (fRadius <= 0.0f)
        fRadius = 20.0f;
    if (sKind == "" || sKind == "always") return TRUE;
    if (sKind == "enemies") return M_TACT_CountEnemies(oActor, fRadius) >= iValue;
    if (sKind == "cluster") return TRUE;
    if (sKind == "health")
    {
        if (JsonGetString(JsonObjectGet(jCondition, "subject")) != "ally") return M_TACT_GetHealthPercent(oActor) <= iValue;
        object oAlly = M_TACT_GetLowestHealthAlly(oActor, oPC, fRadius);
        return GetIsObjectValid(oAlly) && M_TACT_GetHealthPercent(oAlly) <= iValue;
    }
    if (sKind == "enemy_rating") return M_TACT_CountMatchingEnemies(oActor, jCondition) > 0;
    if (sKind == "no_summon") return !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED, oActor));
    if (sKind == "no_familiar") return !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oActor));
    return FALSE;
}

int M_TACT_ResolveTarget(object oActor, object oPC, json jAction, int iSpell, int iSpellLevel, int iMetaMagic, int iClusterMinimum, json jPriorities, json jCondition)
{
    DeleteLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET);
    DeleteLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION);
    DeleteLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION);
    string sTarget = JsonGetString(JsonObjectGet(jAction, "target"));
    int bHostile = iSpell >= 0 ? M_TACT_IsSpellHostile(iSpell) : TRUE;
    int bArea = iSpell >= 0 && M_TACT_IsSpellArea(iSpell);
    int bCanHitAllies = bHostile && bArea && M_TACT_CanSpellHitAllies(iSpell);
    if (bCanHitAllies && !JsonGetInt(JsonObjectGet(jAction, "friendly_fire")) && M_TACT_GetAoeSafetyMode(jAction) == M_TACT_AOE_SAFETY_STATIONARY && !M_TACT_AreRelevantAlliesStationary(oPC, oActor)) return M_TACT_Fail(oActor, "allies_moving");
    if (iSpell >= 0 && M_TACT_GetSpellRole(iSpell) == M_TACT_ROLE_SUMMON)
    {
        if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED, oActor))) return M_TACT_Fail(oActor, "summon_already_present");
        SetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION, GetLocation(oActor));
        SetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION, TRUE);
        return TRUE;
    }
    if (sTarget == "self" || (sTarget == "auto" && !bHostile))
    {
        if (iSpell >= 0 && !M_TACT_IsSpellSensible(oActor, oActor, iSpell, iSpellLevel)) return M_TACT_Fail(oActor, GetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON));
        SetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET, oActor);
        return TRUE;
    }
    if (sTarget == "ally")
    {
        object oAlly = M_TACT_GetLowestHealthAlly(oActor, oPC, 40.0f);
        if (!GetIsObjectValid(oAlly)) return M_TACT_Fail(oActor, "no_ally_target");
        if (iSpell >= 0 && !M_TACT_IsSpellSensible(oActor, oAlly, iSpell, iSpellLevel)) return M_TACT_Fail(oActor, GetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON));
        SetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET, oAlly);
        return TRUE;
    }
    if (sTarget == "cluster" || (bHostile && bArea && sTarget == "auto"))
    {
        location lCluster = M_TACT_FindBestCluster(oActor, oPC, iSpell, iSpellLevel, iMetaMagic, !bCanHitAllies || JsonGetInt(JsonObjectGet(jAction, "friendly_fire")), iClusterMinimum, jPriorities, jCondition);
        if (GetAreaFromLocation(lCluster) != GetArea(oActor))
        {
            string sReason = GetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON);
            return M_TACT_Fail(oActor, sReason == "" ? "no_sensible_cluster" : sReason);
        }
        SetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION, lCluster);
        SetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION, TRUE);
        return TRUE;
    }
    if (sTarget == "enemy_low" || sTarget == "enemy_high")
    {
        object oHealthEnemy = M_TACT_GetHealthEnemy(oActor, iSpell, iSpellLevel, sTarget == "enemy_low", jCondition);
        if (!GetIsObjectValid(oHealthEnemy)) return M_TACT_Fail(oActor, "no_sensible_enemy:" + GetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON));
        if (bArea)
        {
            SetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION, GetLocation(oHealthEnemy));
            SetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION, TRUE);
        }
        else SetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET, oHealthEnemy);
        return TRUE;
    }
    object oEnemy = M_TACT_GetPrioritizedEnemy(oActor, iSpell, iSpellLevel, jPriorities, jCondition);
    if (!GetIsObjectValid(oEnemy)) return M_TACT_Fail(oActor, "no_sensible_enemy:" + GetLocalString(oActor, M_TACT_LOCAL_REJECT_REASON));
    if (bArea)
    {
        SetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION, GetLocation(oEnemy));
        SetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION, TRUE);
    }
    else SetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET, oEnemy);
    return TRUE;
}

int M_TACT_IsResolvedTargetValid(object oActor)
{
    if (GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION))
        return GetAreaFromLocation(GetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION)) == GetArea(oActor);
    object oTarget = GetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET);
    return GetIsObjectValid(oTarget) && !GetIsDead(oTarget) && GetArea(oTarget) == GetArea(oActor);
}

int M_TACT_IsTargetInRange(object oActor, json jAction, int iSpell)
{
    if (!M_TACT_IsResolvedTargetValid(oActor))
        return FALSE;
    if (JsonGetInt(JsonObjectGet(jAction, "move")) && !GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION))
        return TRUE;
    float fRange = iSpell >= 0 ? M_TACT_GetSpellRange(iSpell) : 2.0f;
    if (GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION))
    {
        vector vActor = GetPosition(oActor);
        vector vTarget = GetPositionFromLocation(GetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION));
        return M_TACT_Distance2D(vActor, vTarget) <= fRange && LineOfSightVector(vActor, vTarget);
    }
    object oTarget = GetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET);
    return GetIsObjectValid(oTarget) && GetDistanceBetween(oActor, oTarget) <= fRange && LineOfSightObject(oActor, oTarget);
}

itemproperty M_TACT_FindCastProperty(object oItem, int iSubtype, int iSpell)
{
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL && (iSubtype < 0 || GetItemPropertySubType(ip) == iSubtype) && MEMORIA_IsCastPropertyAvailable(oItem, ip))
        {
            int iItemSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", GetItemPropertySubType(ip)));
            if (iSpell < 0 || iItemSpell == iSpell)
                return ip;
        }
        ip = GetNextItemProperty(oItem);
    }
    return GetFirstItemProperty(OBJECT_INVALID);
}

object M_TACT_FindCastItem(object oActor, json jAction, int iSpell)
{
    string sResRef = JsonGetString(JsonObjectGet(jAction, "item_resref"));
    int iSubtype = JsonGetInt(JsonObjectGet(jAction, "item_property"));
    object oItem = GetFirstItemInInventory(oActor);
    while (GetIsObjectValid(oItem))
    {
        itemproperty ip = M_TACT_FindCastProperty(oItem, iSubtype, iSpell);
        if (GetIsItemPropertyValid(ip) && (sResRef == "" || GetResRef(oItem) == sResRef) && !(GetLocalObject(oActor, M_TACT_LOCAL_BLOCKED_ITEM) == oItem && GetLocalInt(oActor, M_TACT_LOCAL_BLOCKED_ITEM_UNTIL) >= GetLocalInt(oActor, M_TACT_LOCAL_ACTOR_TICK)))
            return oItem;
        oItem = GetNextItemInInventory(oActor);
    }
    int iSlot;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
    {
        oItem = GetItemInSlot(iSlot, oActor);
        if (!GetIsObjectValid(oItem)) continue;
        itemproperty ipEquipped = M_TACT_FindCastProperty(oItem, iSubtype, iSpell);
        if (GetIsItemPropertyValid(ipEquipped) && (sResRef == "" || GetResRef(oItem) == sResRef)) return oItem;
    }
    return OBJECT_INVALID;
}

int M_TACT_ItemMatchesEquipAction(object oItem, json jAction)
{
    if (!GetIsObjectValid(oItem)) return FALSE;
    string sUUID = JsonGetString(JsonObjectGet(jAction, "item_uuid"));
    if (sUUID != "" && GetObjectUUID(oItem) == sUUID) return TRUE;
    return sUUID == "" && GetResRef(oItem) == JsonGetString(JsonObjectGet(jAction, "item_resref"));
}

object M_TACT_FindEquipItem(object oActor, json jAction)
{
    object oBlocked = GetLocalObject(oActor, M_TACT_LOCAL_BLOCKED_ITEM);
    int bBlocked = GetIsObjectValid(oBlocked) && GetLocalInt(oActor, M_TACT_LOCAL_BLOCKED_ITEM_UNTIL) >= GetLocalInt(oActor, M_TACT_LOCAL_ACTOR_TICK);
    object oItem = GetFirstItemInInventory(oActor);
    while (GetIsObjectValid(oItem))
    {
        if (M_TACT_ItemMatchesEquipAction(oItem, jAction) && (!bBlocked || oItem != oBlocked)) return oItem;
        oItem = GetNextItemInInventory(oActor);
    }
    int iSlot;
    for (iSlot = INVENTORY_SLOT_HEAD; iSlot <= INVENTORY_SLOT_CARMOUR; iSlot++)
    {
        oItem = GetItemInSlot(iSlot, oActor);
        if (M_TACT_ItemMatchesEquipAction(oItem, jAction)) return oItem;
    }
    return OBJECT_INVALID;
}

int M_TACT_FindCastingClass(object oActor, int iSpell, int iPreferredClass, int iMetaMagic, int iDomainLevel)
{
    if (iPreferredClass != CLASS_TYPE_INVALID)
        return GetSpellUsesLeft(oActor, iPreferredClass, iSpell, iMetaMagic, iDomainLevel) > 0 ? iPreferredClass : CLASS_TYPE_INVALID;
    int iPosition;
    for (iPosition = 1; iPosition <= 8; iPosition++)
    {
        int iClass = GetClassByPosition(iPosition, oActor);
        if (iClass != CLASS_TYPE_INVALID && GetSpellUsesLeft(oActor, iClass, iSpell, iMetaMagic, iDomainLevel) > 0)
            return iClass;
    }
    return CLASS_TYPE_INVALID;
}

int M_TACT_FindAnyCastingVariant(object oActor, int iSpell)
{
    int iPosition;
    for (iPosition = 1; iPosition <= 8; iPosition++)
    {
        int iClass = GetClassByPosition(iPosition, oActor);
        if (iClass != CLASS_TYPE_INVALID)
        {
            int iMetaIndex;
            for (iMetaIndex = 0; iMetaIndex <= 6; iMetaIndex++)
            {
                int iMetaMagic = iMetaIndex == 0 ? METAMAGIC_NONE : iMetaIndex == 1 ? METAMAGIC_EMPOWER : iMetaIndex == 2 ? METAMAGIC_EXTEND : iMetaIndex == 3 ? METAMAGIC_MAXIMIZE : iMetaIndex == 4 ? METAMAGIC_QUICKEN : iMetaIndex == 5 ? METAMAGIC_SILENT : METAMAGIC_STILL;
                int iDomain;
                for (iDomain = 0; iDomain <= 9; iDomain++)
                {
                    if (GetSpellUsesLeft(oActor, iClass, iSpell, iMetaMagic, iDomain) > 0)
                    {
                        SetLocalInt(oActor, M_TACT_LOCAL_EVAL_CLASS, iClass);
                        SetLocalInt(oActor, M_TACT_LOCAL_EVAL_METAMAGIC, iMetaMagic);
                        SetLocalInt(oActor, M_TACT_LOCAL_EVAL_DOMAIN, iDomain);
                        return TRUE;
                    }
                }
            }
        }
    }
    return FALSE;
}

void M_TACT_BeginOwnedAction(object oActor, object oPC, int iExpectedAction)
{
    int iCurrent = GetCurrentAction(oActor);
    if (iCurrent != ACTION_INVALID)
        ClearAllActions(FALSE, oActor);
    SetLocalObject(oActor, M_TACT_LOCAL_OWNER, oPC);
    SetLocalInt(oActor, M_TACT_LOCAL_OWNED, TRUE);
    SetLocalInt(oActor, M_TACT_LOCAL_OWNED_TICKS, 0);
    SetLocalInt(oActor, M_TACT_LOCAL_EXPECTED_ACTION, iExpectedAction);
    DeleteLocalObject(oActor, M_TACT_LOCAL_ACTIVE_TARGET);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_TARGET_SET);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE);
    DeleteLocalLocation(oActor, M_TACT_LOCAL_ACTIVE_AOE_LOCATION);
    DeleteLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_RADIUS);
    DeleteLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_DELAY);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_SPELL);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_LEVEL);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_MINIMUM);
    if (oActor != oPC)
        SetAssociateState(NW_ASC_IS_BUSY, TRUE, oActor);
}

void M_TACT_SetActiveAoe(object oActor, object oPC, json jAction, int iSpell, int iSpellLevel, int iMetaMagic, int iMinimum)
{
    if (!GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION) || JsonGetInt(JsonObjectGet(jAction, "friendly_fire")) || !M_TACT_IsSpellHostile(iSpell) || !M_TACT_IsSpellArea(iSpell) || !M_TACT_CanSpellHitAllies(iSpell) || M_TACT_GetAoeSafetyMode(jAction) != M_TACT_AOE_SAFETY_VERY_SAFE) return;
    location lCenter = GetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION);
    SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE, TRUE);
    SetLocalLocation(oActor, M_TACT_LOCAL_ACTIVE_AOE_LOCATION, lCenter);
    SetLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_RADIUS, M_TACT_GetSpellAreaRadius(oActor, iSpell, iSpellLevel, iMetaMagic));
    SetLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_DELAY, M_TACT_GetSpellImpactDelay(oActor, iSpell, iMetaMagic, GetPositionFromLocation(lCenter)));
    SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_SPELL, iSpell);
    SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_LEVEL, iSpellLevel);
    SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_MINIMUM, iMinimum);
}

void M_TACT_EndOwnedAction(object oActor)
{
    object oPC = GetLocalObject(oActor, M_TACT_LOCAL_OWNER);
    DeleteLocalObject(oActor, M_TACT_LOCAL_OWNER);
    DeleteLocalInt(oActor, M_TACT_LOCAL_OWNED);
    DeleteLocalInt(oActor, M_TACT_LOCAL_EXPECTED_ACTION);
    DeleteLocalInt(oActor, M_TACT_LOCAL_OWNED_TICKS);
    DeleteLocalObject(oActor, M_TACT_LOCAL_ACTIVE_TARGET);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_TARGET_SET);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE);
    DeleteLocalLocation(oActor, M_TACT_LOCAL_ACTIVE_AOE_LOCATION);
    DeleteLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_RADIUS);
    DeleteLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_DELAY);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_SPELL);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_LEVEL);
    DeleteLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_MINIMUM);
    DeleteLocalObject(oActor, M_TACT_LOCAL_PENDING_EQUIP_ITEM);
    DeleteLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_SLOT);
    DeleteLocalJson(oActor, M_TACT_LOCAL_PENDING_EQUIP_ACTION);
    DeleteLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_CAST);
    if (GetIsObjectValid(oActor) && oActor != oPC)
        SetAssociateState(NW_ASC_IS_BUSY, FALSE, oActor);
}

void M_TACT_BlockEquipItem(object oActor, object oItem)
{
    SetLocalObject(oActor, M_TACT_LOCAL_BLOCKED_ITEM, oItem);
    SetLocalInt(oActor, M_TACT_LOCAL_BLOCKED_ITEM_UNTIL, GetLocalInt(oActor, M_TACT_LOCAL_ACTOR_TICK) + 10);
}

void M_TACT_QueueEquip(object oActor, object oItem, int iSlot, json jAction, int bCastAfter)
{
    SetLocalObject(oActor, M_TACT_LOCAL_PENDING_EQUIP_ITEM, oItem);
    SetLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_SLOT, iSlot);
    SetLocalJson(oActor, M_TACT_LOCAL_PENDING_EQUIP_ACTION, jAction);
    SetLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_CAST, bCastAfter);
    AssignCommand(oActor, ActionEquipItem(oItem, iSlot));
    AssignCommand(oActor, ActionDoCommand(ExecuteScript("m_tact_equip", oActor)));
    DelayCommand(3.0f, ExecuteScript("m_tact_equip", oActor));
}

void M_TACT_ContinueEquippedItem(object oActor)
{
    object oItem = GetLocalObject(oActor, M_TACT_LOCAL_PENDING_EQUIP_ITEM);
    if (!GetIsObjectValid(oItem)) return;
    int iSlot = GetLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_SLOT);
    json jAction = GetLocalJson(oActor, M_TACT_LOCAL_PENDING_EQUIP_ACTION);
    int bCastAfter = GetLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_CAST);
    if (GetItemInSlot(iSlot, oActor) != oItem)
    {
        M_TACT_BlockEquipItem(oActor, oItem);
        SetLocalString(oActor, M_TACT_LOCAL_FAILURE, "item_cannot_be_equipped");
        M_TACT_EndOwnedAction(oActor);
        return;
    }
    DeleteLocalObject(oActor, M_TACT_LOCAL_PENDING_EQUIP_ITEM);
    DeleteLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_SLOT);
    DeleteLocalJson(oActor, M_TACT_LOCAL_PENDING_EQUIP_ACTION);
    DeleteLocalInt(oActor, M_TACT_LOCAL_PENDING_EQUIP_CAST);
    if (!bCastAfter)
    {
        M_TACT_EndOwnedAction(oActor);
        return;
    }
    int iSpell = JsonGetInt(JsonObjectGet(jAction, "spell"));
    itemproperty ip = M_TACT_FindCastProperty(oItem, JsonGetInt(JsonObjectGet(jAction, "item_property")), iSpell);
    if (!GetIsItemPropertyValid(ip))
    {
        M_TACT_EndOwnedAction(oActor);
        return;
    }
    if (GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION)) AssignCommand(oActor, ActionUseItemAtLocation(oItem, ip, GetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION)));
    else AssignCommand(oActor, ActionUseItemOnObject(oItem, ip, GetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET)));
    AssignCommand(oActor, ActionDoCommand(ExecuteScript("m_tact_done", oActor)));
}

int M_TACT_CanTakeAction(object oActor, object oPC)
{
    if (!GetIsObjectValid(oActor) || GetIsDead(oActor) || GetArea(oActor) != GetArea(oPC) || !GetCommandable(oActor) || GetIsPossessedFamiliar(oActor) || IsInConversation(oPC) || IsInConversation(oActor))
        return FALSE;
    int iCurrent = GetCurrentAction(oActor);
    if (GetLocalInt(oActor, M_TACT_LOCAL_OWNED))
    {
        if (GetLocalInt(oActor, M_TACT_LOCAL_MANUAL))
        {
            M_TACT_EndOwnedAction(oActor);
            return FALSE;
        }
        if (GetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_TARGET_SET))
        {
            object oActiveTarget = GetLocalObject(oActor, M_TACT_LOCAL_ACTIVE_TARGET);
            if (!GetIsObjectValid(oActiveTarget) || GetIsDead(oActiveTarget))
            {
                ClearAllActions(FALSE, oActor);
                M_TACT_EndOwnedAction(oActor);
                return TRUE;
            }
        }
        if (GetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE))
        {
            float fRemaining = GetLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_DELAY) - IntToFloat(GetLocalInt(oActor, M_TACT_LOCAL_OWNED_TICKS)) * M_TACT_INTERVAL;
            if (fRemaining < M_TACT_INTERVAL) fRemaining = M_TACT_INTERVAL;
            location lCenter = GetLocalLocation(oActor, M_TACT_LOCAL_ACTIVE_AOE_LOCATION);
            object oOwner = GetLocalObject(oActor, M_TACT_LOCAL_OWNER);
            if (!GetIsObjectValid(oOwner) || GetAreaFromLocation(lCenter) != GetArea(oActor))
            {
                ClearAllActions(FALSE, oActor);
                M_TACT_EndOwnedAction(oActor);
                return TRUE;
            }
            vector vCenter = GetPositionFromLocation(lCenter);
            float fRadius = GetLocalFloat(oActor, M_TACT_LOCAL_ACTIVE_AOE_RADIUS);
            int iRemainingTargets = M_TACT_CountPredictedSensibleEnemies(oActor, oOwner, GetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_SPELL), GetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_LEVEL), vCenter, fRadius, fRemaining);
            if (!M_TACT_IsFriendlyTrajectorySafe(oOwner, oActor, vCenter, fRadius, fRemaining) || iRemainingTargets < GetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_AOE_MINIMUM))
            {
                ClearAllActions(FALSE, oActor);
                M_TACT_EndOwnedAction(oActor);
                return TRUE;
            }
        }
        int iExpected = GetLocalInt(oActor, M_TACT_LOCAL_EXPECTED_ACTION);
        int iTicks = GetLocalInt(oActor, M_TACT_LOCAL_OWNED_TICKS) + 1;
        SetLocalInt(oActor, M_TACT_LOCAL_OWNED_TICKS, iTicks);
        if (iTicks > 60)
        {
            ClearAllActions(FALSE, oActor);
            M_TACT_EndOwnedAction(oActor);
            return FALSE;
        }
        if (GetIsObjectValid(GetLocalObject(oActor, M_TACT_LOCAL_PENDING_EQUIP_ITEM))) return FALSE;
        if (iCurrent == iExpected || iCurrent == ACTION_MOVETOPOINT || iCurrent == ACTION_CASTSPELL || iCurrent == ACTION_ITEMCASTSPELL)
            return FALSE;
        M_TACT_EndOwnedAction(oActor);
        return FALSE;
    }
    if (GetLocalInt(oActor, M_TACT_LOCAL_MANUAL))
    {
        if (iCurrent != ACTION_INVALID && iCurrent != ACTION_FOLLOW && iCurrent != ACTION_WAIT && iCurrent != ACTION_RANDOMWALK)
            return FALSE;
        DeleteLocalInt(oActor, M_TACT_LOCAL_MANUAL);
    }
    if (oActor == oPC)
        return iCurrent == ACTION_INVALID || iCurrent == ACTION_FOLLOW || iCurrent == ACTION_WAIT || iCurrent == ACTION_RANDOMWALK;
    return TRUE;
}

int M_TACT_ExecuteSpellAction(object oActor, object oPC, json jAction, json jCondition, json jPriorities)
{
    DeleteLocalString(oActor, M_TACT_LOCAL_FAILURE);
    int iSpell = JsonGetInt(JsonObjectGet(jAction, "spell"));
    int iSpellLevel = M_TACT_GetActionSpellLevel(jAction, iSpell);
    int iMetaMagic = JsonGetInt(JsonObjectGet(jAction, "metamagic"));
    int iClusterMinimum = JsonGetString(JsonObjectGet(jCondition, "kind")) == "cluster" ? JsonGetInt(JsonObjectGet(jCondition, "value")) : 1;
    if (iSpell < 0) return M_TACT_Fail(oActor, "invalid_spell");
    if (JsonGetString(JsonObjectGet(jCondition, "kind")) == "cluster" && (!M_TACT_IsSpellHostile(iSpell) || !M_TACT_IsSpellArea(iSpell))) return M_TACT_Fail(oActor, "condition_incompatible");
    string sSource = JsonGetString(JsonObjectGet(jAction, "source"));
    int iClass = JsonGetInt(JsonObjectGet(jAction, "class"));
    int iDomain = JsonGetInt(JsonObjectGet(jAction, "domain"));
    if (sSource == "item") iClass = CLASS_TYPE_INVALID;
    if (sSource != "item")
    {
        iClass = M_TACT_FindCastingClass(oActor, iSpell, iClass, iMetaMagic, iDomain);
        if (iClass == CLASS_TYPE_INVALID && sSource == "any" && M_TACT_FindAnyCastingVariant(oActor, iSpell))
        {
            iClass = GetLocalInt(oActor, M_TACT_LOCAL_EVAL_CLASS);
            iMetaMagic = GetLocalInt(oActor, M_TACT_LOCAL_EVAL_METAMAGIC);
            iDomain = GetLocalInt(oActor, M_TACT_LOCAL_EVAL_DOMAIN);
            iSpellLevel = iDomain > 0 ? iDomain : GetSpellLevelByClass(iClass, iSpell);
            DeleteLocalInt(oActor, M_TACT_LOCAL_EVAL_CLASS);
            DeleteLocalInt(oActor, M_TACT_LOCAL_EVAL_METAMAGIC);
            DeleteLocalInt(oActor, M_TACT_LOCAL_EVAL_DOMAIN);
        }
    }
    object oAvailableItem = sSource != "spell" && iClass == CLASS_TYPE_INVALID ? M_TACT_FindCastItem(oActor, jAction, iSpell) : OBJECT_INVALID;
    if (iClass == CLASS_TYPE_INVALID && !GetIsObjectValid(oAvailableItem)) return M_TACT_Fail(oActor, "selected_source_unavailable");
    if (iClass == CLASS_TYPE_INVALID) iMetaMagic = METAMAGIC_NONE;
    if (!M_TACT_ResolveTarget(oActor, oPC, jAction, iSpell, iSpellLevel, iMetaMagic, iClusterMinimum, jPriorities, jCondition)) return FALSE;
    if (!M_TACT_IsTargetInRange(oActor, jAction, iSpell)) return M_TACT_Fail(oActor, "target_out_of_range_or_sight");
    if (iClass != CLASS_TYPE_INVALID)
    {
        M_TACT_BeginOwnedAction(oActor, oPC, ACTION_CASTSPELL);
        M_TACT_SetActiveAoe(oActor, oPC, jAction, iSpell, iSpellLevel, iMetaMagic, iClusterMinimum);
        if (GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION))
            AssignCommand(oActor, ActionCastSpellAtLocation(iSpell, GetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION), iMetaMagic, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, FALSE, iClass, FALSE, iDomain));
        else
        {
            object oTarget = GetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET);
            SetLocalObject(oActor, M_TACT_LOCAL_ACTIVE_TARGET, oTarget);
            SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_TARGET_SET, TRUE);
            AssignCommand(oActor, ActionCastSpellAtObject(iSpell, oTarget, iMetaMagic, FALSE, iDomain, PROJECTILE_PATH_TYPE_DEFAULT, FALSE, iClass));
        }
        AssignCommand(oActor, ActionDoCommand(ExecuteScript("m_tact_done", oActor)));
        return TRUE;
    }
    if (GetIsObjectValid(oAvailableItem))
    {
        itemproperty ip = M_TACT_FindCastProperty(oAvailableItem, JsonGetInt(JsonObjectGet(jAction, "item_property")), iSpell);
        if (!GetIsItemPropertyValid(ip)) return M_TACT_Fail(oActor, "item_power_unavailable");
        M_TACT_BeginOwnedAction(oActor, oPC, ACTION_ITEMCASTSPELL);
        M_TACT_SetActiveAoe(oActor, oPC, jAction, iSpell, iSpellLevel, iMetaMagic, iClusterMinimum);
        int iEquipSlot = MEMORIA_FindPreferredEquipSlot(oActor, oAvailableItem);
        if (iEquipSlot >= 0 && MEMORIA_GetEquippedSlot(oActor, oAvailableItem) < 0)
        {
            if (!GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION))
            {
                SetLocalObject(oActor, M_TACT_LOCAL_ACTIVE_TARGET, GetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET));
                SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_TARGET_SET, TRUE);
            }
            M_TACT_QueueEquip(oActor, oAvailableItem, iEquipSlot, jAction, TRUE);
            return TRUE;
        }
        if (GetLocalInt(oActor, M_TACT_LOCAL_EVAL_IS_LOCATION))
            AssignCommand(oActor, ActionUseItemAtLocation(oAvailableItem, ip, GetLocalLocation(oActor, M_TACT_LOCAL_EVAL_LOCATION)));
        else
        {
            object oTarget = GetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET);
            SetLocalObject(oActor, M_TACT_LOCAL_ACTIVE_TARGET, oTarget);
            SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_TARGET_SET, TRUE);
            AssignCommand(oActor, ActionUseItemOnObject(oAvailableItem, ip, oTarget));
        }
        AssignCommand(oActor, ActionDoCommand(ExecuteScript("m_tact_done", oActor)));
        return TRUE;
    }
    return M_TACT_Fail(oActor, "selected_source_unavailable");
}

int M_TACT_ExecuteAction(object oActor, object oPC, json jAction, json jCondition, json jPriorities)
{
    DeleteLocalString(oActor, M_TACT_LOCAL_FAILURE);
    string sKind = JsonGetString(JsonObjectGet(jAction, "kind"));
    if (JsonGetString(JsonObjectGet(jCondition, "kind")) == "cluster" && sKind != "spell") return M_TACT_Fail(oActor, "condition_incompatible");
    if (sKind == "spell") return M_TACT_ExecuteSpellAction(oActor, oPC, jAction, jCondition, jPriorities);
    if (sKind == "equip")
    {
        object oItem = M_TACT_FindEquipItem(oActor, jAction);
        if (!GetIsObjectValid(oItem)) return M_TACT_Fail(oActor, "selected_item_unavailable");
        if (MEMORIA_GetEquippedSlot(oActor, oItem) >= 0) return M_TACT_Fail(oActor, "item_already_equipped");
        int iEquipSlot = MEMORIA_FindPreferredEquipSlot(oActor, oItem);
        if (iEquipSlot < 0) return M_TACT_Fail(oActor, "item_cannot_be_equipped");
        M_TACT_BeginOwnedAction(oActor, oPC, ACTION_USEOBJECT);
        M_TACT_QueueEquip(oActor, oItem, iEquipSlot, jAction, FALSE);
        return TRUE;
    }
    if (sKind == "familiar")
    {
        if (!GetHasFeat(FEAT_SUMMON_FAMILIAR, oActor)) return M_TACT_Fail(oActor, "familiar_feat_unavailable");
        if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oActor))) return M_TACT_Fail(oActor, "familiar_already_present");
        M_TACT_BeginOwnedAction(oActor, oPC, ACTION_USEOBJECT);
        AssignCommand(oActor, ActionUseFeat(FEAT_SUMMON_FAMILIAR, oActor));
        AssignCommand(oActor, ActionDoCommand(ExecuteScript("m_tact_done", oActor)));
        return TRUE;
    }
    if (sKind == "attack" && M_TACT_ResolveTarget(oActor, oPC, jAction, -1, -1, METAMAGIC_NONE, 1, jPriorities, jCondition))
    {
        object oEnemy = GetLocalObject(oActor, M_TACT_LOCAL_EVAL_TARGET);
        if (!GetIsObjectValid(oEnemy)) return M_TACT_Fail(oActor, "no_sensible_enemy");
        M_TACT_BeginOwnedAction(oActor, oPC, ACTION_ATTACKOBJECT);
        SetLocalObject(oActor, M_TACT_LOCAL_ACTIVE_TARGET, oEnemy);
        SetLocalInt(oActor, M_TACT_LOCAL_ACTIVE_TARGET_SET, TRUE);
        AssignCommand(oActor, ActionAttack(oEnemy));
        AssignCommand(oActor, ActionDoCommand(ExecuteScript("m_tact_done", oActor)));
        return TRUE;
    }
    return M_TACT_Fail(oActor, "action_not_configured");
}

string M_TACT_DebugReasonText(object oPC, string sReason)
{
    int bRussian = FALSE;
    if (sReason == "allies_moving") return "waiting for nearby allies to stop moving";
    if (FindSubString(sReason, "ally_trajectory:") == 0) return "an ally may enter the spell area: " + GetSubString(sReason, 16, GetStringLength(sReason) - 16);
    if (sReason == "ally_trajectory") return bRussian ? "Союзник может попасть в область заклинания" : "an ally may enter the spell area";
    if (sReason == "not_enough_predicted_enemies") return bRussian ? "К моменту попадания враги не образуют достаточное скопление" : "too few enemies are predicted to remain clustered at impact";
    if (sReason == "no_reachable_predicted_cluster") return bRussian ? "Нет доступной точки прогнозируемого скопления" : "no predicted cluster point is available";
    if (sReason == "invalid_object") return bRussian ? "объект больше не существует" : "object is no longer valid";
    if (sReason == "negative_vs_undead") return bRussian ? "негативная энергия неразумна против нежити" : "negative energy is unsuitable against undead";
    if (sReason == "status_immunity") return bRussian ? "иммунитет к эффекту заклинания" : "immune to the spell effect";
    if (sReason == "damage_immunity") return bRussian ? "полный иммунитет к типу урона" : "fully immune to the damage type";
    if (sReason == "spell_immunity") return bRussian ? "иммунитет к конкретному заклинанию" : "immune to this spell";
    if (sReason == "limited_absorption") return bRussian ? "заклинание поглотит мантия" : "spell will be absorbed by a mantle";
    if (sReason == "unlimited_absorption") return bRussian ? "заклинание поглотит сфера" : "spell will be absorbed by a globe";
    if (sReason == "unbeatable_spell_resistance") return bRussian ? "сопротивление магии непреодолимо" : "spell resistance cannot be overcome";
    if (sReason == "effect_already_present") return bRussian ? "эффект уже действует" : "effect is already active";
    if (sReason == "extension_rejected") return bRussian ? "цель отклонена расширением метаданных" : "rejected by the metadata extension";
    if (sReason == "selected_source_unavailable") return bRussian ? "выбранная ячейка или источник недоступны" : "selected spell slot or source is unavailable";
    if (sReason == "target_out_of_range_or_sight") return bRussian ? "цель вне дистанции или прямой видимости, а перемещение запрещено" : "target is out of range or sight and movement is disabled";
    if (FindSubString(sReason, "no_sensible_enemy") == 0) return (bRussian ? "нет подходящего врага" : "no sensible enemy") + (GetStringLength(sReason) > 18 ? ": " + M_TACT_DebugReasonText(oPC, GetSubString(sReason, 18, GetStringLength(sReason) - 18)) : "");
    if (FindSubString(sReason, "no_sensible_cluster") == 0) return bRussian ? "нет подходящего скопления врагов" : "no sensible enemy cluster";
    if (sReason == "summon_already_present") return bRussian ? "призванное существо уже существует" : "a summoned creature is already present";
    if (sReason == "familiar_already_present") return bRussian ? "фамильяр уже призван" : "the familiar is already present";
    if (sReason == "familiar_feat_unavailable") return bRussian ? "способность призыва фамильяра недоступна" : "summon familiar feat is unavailable";
    if (sReason == "selected_item_unavailable") return "selected item is unavailable";
    if (sReason == "item_already_equipped") return "item is already equipped";
    if (sReason == "item_cannot_be_equipped") return "item cannot be equipped";
    if (sReason == "action_not_configured") return bRussian ? "действие не настроено" : "action is not configured";
    if (sReason == "condition_incompatible") return "action is incompatible with the rule condition";
    return sReason == "" ? (bRussian ? "действие неприменимо" : "action is not applicable") : sReason;
}

string M_TACT_DebugConditionText(object oActor, json jCondition)
{
    string sKind = JsonGetString(JsonObjectGet(jCondition, "kind"));
    if (sKind == "enemy_rating")
    {
        int iExpected = JsonGetInt(JsonObjectGet(jCondition, "value"));
        return "matching targets=" + IntToString(M_TACT_CountMatchingEnemies(oActor, jCondition)) + ", rating " + (JsonGetString(JsonObjectGet(jCondition, "comparison")) == "max" ? "<= " : ">= ") + IntToString(iExpected);
    }
    return sKind == "" ? "always" : sKind;
}

string M_TACT_DebugActionText(json jAction)
{
    string sKind = JsonGetString(JsonObjectGet(jAction, "kind"));
    if (sKind == "spell") return RegExpReplace("_", Get2DAString("spells", "Label", JsonGetInt(JsonObjectGet(jAction, "spell"))), " ");
    if (sKind == "equip") return "equip " + JsonGetString(JsonObjectGet(jAction, "item_name"));
    return sKind;
}

void M_TACT_SendDebugTrace(object oActor, object oPC, string sTrace)
{
    if (!M_TACT_GetDebugEnabled(oPC)) return;
    string sMessage = "[M_TACT] " + GetName(oActor) + sTrace;
    if (GetLocalString(oActor, M_TACT_LOCAL_DEBUG_LAST) == sMessage) return;
    SetLocalString(oActor, M_TACT_LOCAL_DEBUG_LAST, sMessage);
    SendMessageToPC(oPC, sMessage);
}

void M_TACT_RunActor(object oActor, object oPC)
{
    if (!M_TACT_CanTakeAction(oActor, oPC))
        return;
    int iProfile = M_TACT_FindRuntimeProfile(oPC, oActor);
    if (iProfile < 0)
        return;
    json jProfile = M_TACT_GetProfile(oPC, iProfile);
    json jTactics = JsonObjectGet(jProfile, "tactics");
    int iActive = JsonGetInt(JsonObjectGet(jProfile, "active"));
    json jTactic = JsonArrayGet(jTactics, iActive);
    if (JsonGetType(jTactic) != JSON_TYPE_OBJECT || !JsonGetInt(JsonObjectGet(jTactic, "enabled")))
        return;
    json jRules = JsonObjectGet(jTactic, "rules");
    string sTrace;
    int iRule;
    for (iRule = 0; iRule < JsonGetLength(jRules); iRule++)
    {
        json jRule = JsonArrayGet(jRules, iRule);
        if (!JsonGetInt(JsonObjectGet(jRule, "enabled"))) continue;
        json jCondition = JsonObjectGet(jRule, "condition");
        if (!M_TACT_MatchesCondition(oActor, oPC, jCondition))
        {
            sTrace += "\n#" + IntToString(iRule + 1) + ": condition false (" + M_TACT_DebugConditionText(oActor, jCondition) + ")";
            continue;
        }
        json jActions = JsonObjectGet(jRule, "actions");
        int iAction;
        for (iAction = 0; iAction < JsonGetLength(jActions); iAction++)
        {
            json jAction = JsonArrayGet(jActions, iAction);
            if (!JsonGetInt(JsonObjectGet(jAction, "enabled"))) continue;
            json jPriorities = M_TACT_GetEffectiveTargetPriorities(jAction, jRule, jTactic);
            if (M_TACT_ExecuteAction(oActor, oPC, jAction, jCondition, jPriorities))
            {
                sTrace += "\n#" + IntToString(iRule + 1) + "." + IntToString(iAction + 1) + " " + M_TACT_DebugActionText(jAction) + ": execute";
                M_TACT_SendDebugTrace(oActor, oPC, sTrace);
                return;
            }
            sTrace += "\n#" + IntToString(iRule + 1) + "." + IntToString(iAction + 1) + " " + M_TACT_DebugActionText(jAction) + ": " + M_TACT_DebugReasonText(oPC, GetLocalString(oActor, M_TACT_LOCAL_FAILURE));
        }
    }
    M_TACT_SendDebugTrace(oActor, oPC, sTrace);
}

void M_TACT_RunDispatcher(object oPC)
{
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC) || GetIsDM(oPC) || GetIsObjectValid(GetMaster(oPC)) || IsInConversation(oPC))
        return;
    int iTick = GetLocalInt(oPC, M_TACT_LOCAL_DISPATCH_TICK) + 1;
    SetLocalInt(oPC, M_TACT_LOCAL_DISPATCH_TICK, iTick);
    int iIndex;
    for (iIndex = 1; iIndex <= M_TACT_GetGroupCount(oPC); iIndex++)
    {
        object oActor = M_TACT_GetGroupMember(oPC, iIndex);
        if (M_TACT_IsGroupCreature(oActor, oPC))
        {
            SetLocalInt(oActor, M_TACT_LOCAL_ACTOR_TICK, iTick);
            M_TACT_UpdateMotion(oActor, iTick);
        }
    }
    for (iIndex = 1; iIndex <= M_TACT_GetGroupCount(oPC); iIndex++)
    {
        object oActor = M_TACT_GetGroupMember(oPC, iIndex);
        if (M_TACT_IsGroupCreature(oActor, oPC))
            M_TACT_RunActor(oActor, oPC);
    }
}

void M_TACT_Schedule(object oPC)
{
    float fDelay = M_TACT_INTERVAL;
    while (fDelay < M_TACT_HEARTBEAT_SECONDS)
    {
        DelayCommand(fDelay, ExecuteScript("m_tact_tick", oPC));
        fDelay += M_TACT_INTERVAL;
    }
}

void M_TACT_Heartbeat(object oPC)
{
    if (!GetIsPC(oPC) || GetIsDM(oPC) || GetIsObjectValid(GetMaster(oPC)))
        return;
    M_TACT_InstallHook();
    M_TACT_EnsureItem(oPC);
    M_TACT_BuildGroupCache(oPC);
    M_TACT_RunDispatcher(oPC);
    M_TACT_Schedule(oPC);
    if (!GetLocalInt(oPC, M_TACT_LOCAL_INSTALLED))
    {
        SetLocalInt(oPC, M_TACT_LOCAL_INSTALLED, TRUE);
        SendMessageToPC(oPC, M_TACT_GetText(M_TACT_TEXT_INSTALLED, oPC) + " " + M_TACT_VERSION);
    }
}
