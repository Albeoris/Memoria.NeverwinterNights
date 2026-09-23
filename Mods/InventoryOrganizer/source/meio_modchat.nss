#include "meio_ui"

void main()
{
    object oPC = GetPCChatSpeaker();
    if (!MEIO_IsPC(oPC))
    {
        return;
    }
    string sMessage = GetPCChatMessage();
    if (sMessage == "/memoria-io-scrolls")
    {
        SetPCChatMessage("");
        MEIO_OpenTab(oPC, MEIO_TAB_SCROLLS);
    }
    else if (sMessage == "/memoria-io-potions")
    {
        SetPCChatMessage("");
        MEIO_OpenTab(oPC, MEIO_TAB_POTIONS);
    }
    else if (sMessage == "/memoria-io-books")
    {
        SetPCChatMessage("");
        MEIO_OpenTab(oPC, MEIO_TAB_BOOKS);
    }
    else if (sMessage == "/memoria-io-key-items")
    {
        SetPCChatMessage("");
        MEIO_OpenTab(oPC, MEIO_TAB_KEY_ITEMS);
    }
}
