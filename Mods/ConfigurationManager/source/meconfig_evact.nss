#include "meconfig"

void main()
{
    object oItem = GetItemActivated();
    object oPC = GetItemActivator();
    if (GetTag(oItem) != MECONFIG_ITEM_TAG || !GetIsPC(oPC))
        return;
    object oTarget = GetItemActivatedTarget();
    if (!GetIsObjectValid(oTarget) || oTarget == oPC)
        MECONFIG_Open(oPC);
    else
        MECONFIG_RunDiagnostics(oPC, oTarget);
}