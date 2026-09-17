#include "mecm_lib"

void main()
{
    object oPC = MECM_GetRootMaster(OBJECT_SELF);
    object oTarget = GetLocalObject(oPC, "MECONFIG_DIAGNOSTIC_TARGET");
    MECM_ReportObject(oPC, oTarget);
}