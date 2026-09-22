#include "metact_runtime"

void main()
{
    object oPC = OBJECT_SELF;
    if (!GetIsObjectValid(oPC))
        return;
    METACT_Heartbeat(oPC);
}
