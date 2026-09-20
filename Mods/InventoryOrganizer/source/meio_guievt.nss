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
        MEIO_Open(oPC);
    }
}
