#include "mecm_lib"

void main()
{
    object oPC = MECM_GetRootMaster(OBJECT_SELF);
    if (!GetIsPC(oPC) || GetIsPC(OBJECT_SELF))
        return;

    object oTarget = GetAttackTarget(OBJECT_SELF);
    if (!GetIsObjectValid(oTarget))
        oTarget = GetAttemptedAttackTarget();
    if (MECM_ShouldProtectTarget(oTarget, oPC))
        ClearAllActions(TRUE);
}
