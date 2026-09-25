#include "meconfig"

int MECONFIG_IsExaminedItem(object oPC, object oItem)
{
    return GetIsObjectValid(oItem) && GetItemPossessor(oItem) == oPC && GetTag(oItem) == MECONFIG_ITEM_TAG;
}

void main()
{
    int nEvent = GetLastGuiEventType();
    object oPC = GetLastGuiEventPlayer();
    if (!GetIsPC(oPC))
        return;
    if (nEvent == GUIEVENT_DISABLED_PANEL_ATTEMPT_OPEN && GetLastGuiEventInteger() == GUI_PANEL_EXAMINE_ITEM)
    {
        if (MECONFIG_IsExaminedItem(oPC, GetLastGuiEventObject()))
            MECONFIG_Open(oPC);
        return;
    }
    if (nEvent != GUIEVENT_EXAMINE_OBJECT)
        return;
    object oItem = GetLastGuiEventObject();
    if (!MECONFIG_IsExaminedItem(oPC, oItem))
        return;
    MEMORIA_GUI_ScheduleItemExamineSuppression(oPC, oItem);
    MECONFIG_Open(oPC);
}
