#include "mecm_lib"

void main()
{
    if (GetLocalInt(GetModule(), MECM_OC_RESTORING_ITEMS))
        return;
    object oItem = GetModuleItemLost();
    object oLostBy = GetModuleItemLostBy();
    string sHenchmanId = GetLocalString(oItem, MECM_OC_MANAGED_OWNER);
    string sUuid = GetIsObjectValid(oItem) ? GetObjectUUID(oItem) : "";
    DelayCommand(0.1f, MECM_HandleOcItemLost(oItem, oLostBy, sHenchmanId, sUuid));
}
