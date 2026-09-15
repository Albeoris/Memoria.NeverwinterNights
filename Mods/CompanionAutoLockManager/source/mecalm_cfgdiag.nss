#include "mecalm_lib"

void main()
{
    object oPC = MECALM_GetRootMaster(OBJECT_SELF);
    object oTarget = GetLocalObject(oPC, "MEMORIA_CONFIG_DIAGNOSTIC_TARGET");
    MECALM_ReportObject(oPC, oTarget);
}