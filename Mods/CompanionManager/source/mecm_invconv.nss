#include "mecm_lib"

void main()
{
    if (GetListenPatternNumber() != ASSOCIATE_COMMAND_INVENTORY)
        return;
    object oPC = GetLastSpeaker();
    object oRootMaster = MECM_GetRootMaster(OBJECT_SELF);
    if (!MECM_IsRootPlayer(oPC) || oPC != oRootMaster || !GetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY))
        return;
    OpenInventory(OBJECT_SELF, oPC);
    ESI_ConsumeEvent();
}
