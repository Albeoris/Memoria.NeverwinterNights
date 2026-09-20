#include "meio_cast"

void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    object oReserved = GetLocalObject(oPC, MEIO_LOCAL_RESERVED);
    object oTarget = GetTargetingModeSelectedObject();
    MEIO_Debug(oPC, "OnPlayerTarget entered target=" + ObjectToString(oTarget) + " issued=" + IntToString(GetLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED)) + " " + MEIO_DebugItemState(oPC, oReserved));
    if (!GetIsObjectValid(oReserved))
    {
        MEIO_Debug(oPC, "OnPlayerTarget decision=ignore reason=no-reservation");
        return;
    }
    if (GetLocalInt(oPC, MEIO_LOCAL_RESERVED_ISSUED))
    {
        MEIO_Debug(oPC, "OnPlayerTarget decision=ignore reason=use-already-issued");
        return;
    }
    if (!GetIsObjectValid(oTarget))
    {
        MEIO_Debug(oPC, "OnPlayerTarget decision=return-reservation reason=invalid-target");
        MEIO_ReturnReservation(oPC);
        return;
    }
    if (oTarget == GetArea(oPC))
    {
        MEIO_Debug(oPC, "OnPlayerTarget decision=use-at-location");
        location lTarget = Location(oTarget, GetTargetingModeSelectedPosition(), 0.0f);
        MEIO_IssueUseAtLocation(oPC, lTarget);
    }
    else
    {
        MEIO_Debug(oPC, "OnPlayerTarget decision=use-on-object target=" + ObjectToString(oTarget));
        MEIO_IssueUseOnObject(oPC, oTarget);
    }
}
