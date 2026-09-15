#include "metact_core"

void main()
{
    int iEvent = GetLastGuiEventType();
    if (iEvent != GUIEVENT_SELECT_CREATURE && iEvent != GUIEVENT_UNSELECT_CREATURE)
        return;
    object oPC = GetLastGuiEventPlayer();
    object oActor = GetLastGuiEventObject();
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oActor) || oActor == oPC || !METACT_IsGroupCreature(oActor, oPC))
        return;
    if (iEvent == GUIEVENT_SELECT_CREATURE)
        SetLocalInt(oActor, METACT_LOCAL_MANUAL, TRUE);
}
