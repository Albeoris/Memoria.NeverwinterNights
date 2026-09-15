#include "m_tact_core"
void main()
{
    object oItem = GetItemActivated();
    object oPC = GetItemActivator();
    if (GetTag(oItem) == M_TACT_ITEM_TAG && GetIsPC(oPC))
        DelayCommand(0.1f, ExecuteScript("m_tact_open", oPC));
}
