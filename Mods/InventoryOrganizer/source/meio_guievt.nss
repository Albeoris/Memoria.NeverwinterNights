#include "meio_ui"

void main()
{
    int iEvent = GetLastGuiEventType();
    object oPC = GetLastGuiEventPlayer();
    if (!MEIO_IsPC(oPC))
    {
        return;
    }
    if (iEvent == GUIEVENT_DISABLED_PANEL_ATTEMPT_OPEN && GetLastGuiEventInteger() == GUI_PANEL_EXAMINE_ITEM)
    {
        object oExamined = GetLastGuiEventObject();
        MEIO_Debug(oPC, "GUI disabled-panel attempt panel=" + IntToString(GetLastGuiEventInteger()) + " target=" + ObjectToString(oExamined));
        if (MEIO_IsDirectlyIn(oExamined, oPC) && GetTag(oExamined) == MEIO_SCRIPTORIUM_TAG)
        {
            MEIO_Open(oPC);
        }
        return;
    }
    if (iEvent != GUIEVENT_EXAMINE_OBJECT)
    {
        return;
    }
    object oItem = GetLastGuiEventObject();
    MEIO_Debug(oPC, "GUI examine-object panel=" + IntToString(GetLastGuiEventInteger()) + " target=" + ObjectToString(oItem));
    if (MEIO_IsDirectlyIn(oItem, oPC) && GetTag(oItem) == MEIO_SCRIPTORIUM_TAG)
    {
        MEIO_ScheduleExamineSuppression(oPC, oItem, "initial-examine");
        MEIO_Open(oPC);
    }
}
