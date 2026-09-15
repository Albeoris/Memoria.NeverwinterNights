#include "mecalm_lib"

void main()
{
    object oPC = MECALM_GetRootMaster(OBJECT_SELF);
    if (!GetIsPC(oPC) || GetIsPC(OBJECT_SELF))
        return;

    object oTarget = GetAttackTarget(OBJECT_SELF);
    if (!GetIsObjectValid(oTarget))
        oTarget = GetAttemptedAttackTarget();
    if (MECALM_ShouldProtectTarget(oTarget, oPC))
        ClearAllActions(TRUE);
}
