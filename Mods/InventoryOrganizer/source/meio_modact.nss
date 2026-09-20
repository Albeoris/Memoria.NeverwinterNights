#include "meio_ui"

void main()
{
    object oItem = GetItemActivated();
    object oPC = GetItemActivator();
    MEIO_Debug(oPC, "OnActivateItem entered " + MEIO_DebugItemState(oPC, oItem));
    if (GetTag(oItem) == MEIO_SCRIPTORIUM_TAG && MEIO_IsPC(oPC) && MEIO_IsDirectlyIn(oItem, oPC))
    {
        MEIO_Debug(oPC, "OnActivateItem decision=open-scriptorium");
        MEIO_Open(oPC);
    }
}
