#include "meio_ui"

void main()
{
    object oPC = OBJECT_SELF;
    MEIO_GetUIScalePercent(oPC);
    int iToken = NuiFindWindow(oPC, MEIO_WINDOW);
    if (iToken <= 0)
    {
        return;
    }
    int iTab = GetLocalInt(oPC, MEIO_LOCAL_ACTIVE_TAB);
    json jSearch;
    int iTarget;
    int bEnglishNames;
    int bShowCasterLevel;
    json jBookSearch;
    if (iTab == MEIO_TAB_SCROLLS)
    {
        jSearch = NuiGetBind(oPC, iToken, "search");
        iTarget = JsonGetInt(NuiGetBind(oPC, iToken, "target"));
        bEnglishNames = JsonGetInt(NuiGetBind(oPC, iToken, "english_names"));
        bShowCasterLevel = JsonGetInt(NuiGetBind(oPC, iToken, "show_caster_level"));
    }
    else if (iTab == MEIO_TAB_BOOKS)
    {
        jBookSearch = NuiGetBind(oPC, iToken, "book_search");
    }
    MEIO_OpenTab(oPC, iTab);
    if (iTab == MEIO_TAB_SCROLLS)
    {
        int iNewToken = NuiFindWindow(oPC, MEIO_WINDOW);
        if (iNewToken > 0)
        {
            NuiSetBind(oPC, iNewToken, "search", jSearch);
            NuiSetBind(oPC, iNewToken, "target", JsonInt(iTarget));
            NuiSetBind(oPC, iNewToken, "english_names", JsonBool(bEnglishNames));
            NuiSetBind(oPC, iNewToken, "show_caster_level", JsonBool(bShowCasterLevel));
            MEIO_RefreshWindow(oPC, iNewToken);
        }
    }
    else if (iTab == MEIO_TAB_BOOKS)
    {
        int iNewToken = NuiFindWindow(oPC, MEIO_WINDOW);
        if (iNewToken > 0)
        {
            NuiSetBind(oPC, iNewToken, "book_search", jBookSearch);
            MEIO_RefreshBookWindow(oPC, iNewToken);
        }
    }
}
