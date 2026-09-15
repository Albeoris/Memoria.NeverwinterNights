#include "m_calm_lib"

void main()
{
    object oPC = M_CALM_GetRootMaster(OBJECT_SELF);
    if (!GetIsPC(oPC) || GetIsPC(OBJECT_SELF))
        return;

    object oTarget = GetAttackTarget(OBJECT_SELF);
    if (!GetIsObjectValid(oTarget))
        oTarget = GetAttemptedAttackTarget();
    if (M_CALM_ShouldProtectTarget(oTarget, oPC))
        ClearAllActions(TRUE);
}
