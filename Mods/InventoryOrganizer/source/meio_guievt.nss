#include "meio_ui"

void main()
{
    if (GetLastGuiEventType() != GUIEVENT_EXAMINE_OBJECT)
    {
        return;
    }
    object oPC = GetLastGuiEventPlayer();
    object oItem = GetLastGuiEventObject();
    if (MEIO_IsPC(oPC) && MEIO_IsDirectlyIn(oItem, oPC) && GetTag(oItem) == MEIO_SCRIPTORIUM_TAG)
    {
        SetLocalObject(oPC, MEIO_LOCAL_EXAMINE_ITEM, oItem);
        SetLocalInt(oPC, MEIO_LOCAL_EXAMINE_DISABLED, TRUE);
        SetGuiPanelDisabled(oPC, GUI_PANEL_EXAMINE_ITEM, TRUE, oItem);
        MEIO_Open(oPC);
        if (NuiFindWindow(oPC, MEIO_WINDOW) <= 0)
        {
            SetGuiPanelDisabled(oPC, GUI_PANEL_EXAMINE_ITEM, FALSE, oItem);
            DeleteLocalObject(oPC, MEIO_LOCAL_EXAMINE_ITEM);
            DeleteLocalInt(oPC, MEIO_LOCAL_EXAMINE_DISABLED);
        }
    }
}
