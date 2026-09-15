#include "m_calm_lib"

void main()
{
    object oItem = GetItemActivated();
    object oActivator = GetItemActivator();
    if (GetTag(oItem) == M_CALM_ITEM_TAG)
    {
        object oTarget = GetItemActivatedTarget();
        if (!GetIsObjectValid(oTarget))
            ExecuteScript("m_calm_settings", oActivator);
        else if (oTarget != oActivator)
            AssignCommand(oActivator, M_CALM_ReportObject(oActivator, oTarget));
        else
            ExecuteScript("m_calm_toggle", oActivator);
    }
}
