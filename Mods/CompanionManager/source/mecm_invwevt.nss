#include "mecm_lib"

const string MECM_CONFIGURATION_WINDOW = "meconfig";
const string MECM_CONFIGURATION_INVENTORY_BIND = "option_8";

void MECM_RejectInventoryAccess(object oPC)
{
    SetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY, FALSE);
    DeleteLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY_CONFIRMED);
    MECM_RemoveInventoryHooks(oPC);
    int iConfigurationToken = NuiFindWindow(oPC, MECM_CONFIGURATION_WINDOW);
    if (iConfigurationToken > 0)
        NuiSetBind(oPC, iConfigurationToken, MECM_CONFIGURATION_INVENTORY_BIND, JsonBool(FALSE));
}

void main()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    if (sEvent == "close")
    {
        MECM_RejectInventoryAccess(oPC);
        return;
    }
    if (sEvent != "click")
        return;
    string sElement = NuiGetEventElement();
    if (sElement == "yes")
    {
        SetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY_CONFIRMED, TRUE);
        SetLocalInt(oPC, MECM_LOCAL_COMPANION_INVENTORY, TRUE);
        MECM_BuildGroupCache(oPC);
        MECM_SynchronizeInventoryHooks(oPC);
    }
    else if (sElement == "no")
        MECM_RejectInventoryAccess(oPC);
    else
        return;
    NuiDestroy(oPC, NuiGetEventWindow());
}
