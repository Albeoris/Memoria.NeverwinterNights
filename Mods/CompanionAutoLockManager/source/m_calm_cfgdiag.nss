#include "m_calm_lib"

void main()
{
    object oPC = M_CALM_GetRootMaster(OBJECT_SELF);
    object oTarget = GetLocalObject(oPC, "MEMORIA_CONFIG_DIAGNOSTIC_TARGET");
    M_CALM_ReportObject(oPC, oTarget);
}