#include "metact_ui"

void main()
{
    object oPC = GetPCChatSpeaker();
    if (!GetIsPC(oPC) || GetIsDM(oPC) || GetPCChatMessage() != "/memoria-tact")
    {
        return;
    }
    SetPCChatMessage("");
    METACT_OpenMain(oPC);
}
