#include "meconfig"

void main()
{
    object oPC = GetPCChatSpeaker();
    if (!GetIsPC(oPC) || GetIsDM(oPC) || GetPCChatMessage() != "/memoria-config")
    {
        return;
    }
    SetPCChatMessage("");
    MECONFIG_Open(oPC);
}
