#include "metact_core"

void main()
{
    if (!METACT_HasOwnedCombatMode(OBJECT_SELF))
        return;
    int iActionMode = METACT_GetOwnedCombatMode(OBJECT_SELF);
    int bWasActive = GetActionMode(OBJECT_SELF, iActionMode);
    if (!bWasActive)
        SetActionMode(OBJECT_SELF, iActionMode, TRUE);
    object oPC = MEMORIA_GetRootPlayer(OBJECT_SELF);
    if (GetIsObjectValid(oPC) && METACT_GetDebugEnabled(oPC))
    {
        string sFeatName = MEMORIA_GetFeatName(METACT_GetOwnedCombatModeFeat(OBJECT_SELF));
        METACT_SendDebugMessage(oPC, "[METACT] " + GetName(OBJECT_SELF) + "\ncombat round end: " + (sFeatName == "" ? "action mode " + IntToString(iActionMode) : sFeatName) + (bWasActive ? " already active" : " restored"));
    }
}
