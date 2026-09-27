#include "mecm_lib"

void main()
{
    if (GetLocalInt(GetModule(), MECM_OC_RESTORING_ITEMS))
        return;
    object oItem = GetModuleItemAcquired();
    object oAcquiredBy = GetModuleItemAcquiredBy();
    object oFrom = GetModuleItemAcquiredFrom();
    int iAcquired = GetModuleItemAcquiredStackSize();
    DelayCommand(0.1f, MECM_HandleOcItemAcquired(oItem, oAcquiredBy, oFrom, iAcquired));
}
