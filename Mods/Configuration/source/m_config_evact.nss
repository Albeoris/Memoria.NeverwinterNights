#include "memoria_config"

void main()
{
    object oItem = GetItemActivated();
    object oPC = GetItemActivator();
    if (GetTag(oItem) != MEMORIA_CONFIG_ITEM_TAG || !GetIsPC(oPC))
        return;
    object oTarget = GetItemActivatedTarget();
    if (!GetIsObjectValid(oTarget) || oTarget == oPC)
        MEMORIA_CONFIG_Open(oPC);
    else
        MEMORIA_CONFIG_RunDiagnostics(oPC, oTarget);
}