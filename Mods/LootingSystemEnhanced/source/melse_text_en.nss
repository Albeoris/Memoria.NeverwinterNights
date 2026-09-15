// Original work Copyright (c) 2020 Mischa Dutzik (Ravick).
// Relicensed under the MIT License by Albeoris. See THIRD_PARTY_NOTICES.md.

#include "melse_sin_lib"

void main()
{
    int nStrRef = StringToInt(GetScriptParam(MELSE_SIN_PARAM_STRREF));
    
    string sString = nStrRef == 1   ? "I should keep an eye out for treasure in this area." 
                   : nStrRef == 2   ? "This area appears to be free from treasure." 
                   : nStrRef == 5   ? "dropped a quest item!"
                   : nStrRef == 7   ? "dropped an equipped item!" 
                   : nStrRef == 8   ? "Last acquired by " 
                   : nStrRef == 9   ? "in area " 
                   : nStrRef == 10  ? "Item (Unidentified)"
                   : nStrRef == 11  ? "is ignored."

                   : nStrRef == 99   ? "Looting System Enhanced"
                   : nStrRef == 100  ? "Back..."
                   : nStrRef == 101  ? "Treasure Scanning"
                   : nStrRef == 102  ? "Treasure Tracking"
                   : nStrRef == 103  ? "Treasure Auto Looting"
                   : nStrRef == 104  ? "Lootable Corpses"
                   : nStrRef == 105  ? "Lootable Corpses decay after loot"
                   : nStrRef == 106  ? "Lootable Corpses decay after time"
                   : nStrRef == 107  ? "Lootable Corpses are raiseable"
                   : nStrRef == 108  ? "Corpse Auto Looting after examined"
                   : nStrRef == 109  ? "Corpse Auto Looting after killed"
                   : nStrRef == 110  ? "Corpse Auto Looting after killed by companion"
                   : nStrRef == 111  ? "Item Description displaying last acquired by"
                   : nStrRef == 112  ? "Item Description displaying base item price"

                   : nStrRef == 120  ? "Back..."
                   : nStrRef == 121  ? "Lootable Corpses decay time in seconds"
                   : nStrRef == 122  ? "Auto Looting minimum base item price"
                   : nStrRef == 123  ? "Auto Looting maximum base item weight"

                   : nStrRef == 900  ? "Close."
                   : nStrRef == 901  ? "Features..."
                   : nStrRef == 902  ? "Parameters..."
                   : nStrRef == 911  ? "+ 1"
                   : nStrRef == 912  ? "+ 10"
                   : nStrRef == 913  ? "+ 100"
                   : nStrRef == 914  ? "- 1"
                   : nStrRef == 915  ? "- 10"
                   : nStrRef == 916  ? "- 100"

                   : nStrRef == 951  ? "Destroy selected corpse!"
                   : nStrRef == 952  ? "Destroy all corpses in current area!"
                   : nStrRef == 953  ? "Destroy all corpses in current module!"

                   : nStrRef == 501  ? "Ravick's Looting System Enhanced: Installed Version"
                   : nStrRef == 502  ? "Ravick's Looting System Enhanced: Updated to Version"

                   : nStrRef == 601  ? "Tell me how to use MELSE!"
                   : nStrRef == 602  ? "All the features of MELSE were automatically installed. No need to take any further action, except if you want to toggle or customize some of the features, which is covered by this tutorial."
                   : nStrRef == 603  ? "To interact with MELSE, find and use the \"Player Tool 9\" under \"Special Abilities\" in your right click menu. You will then be required to choose a target, which defines what kind of interaction to take. Do not select anything right now, as this would close the tutorial!"
                   : nStrRef == 604  ? "What happens when I select my character?"
                   : nStrRef == 605  ? "What happens when I select a corpse?"
                   : nStrRef == 606  ? "I know how to use MELSE now. Close the tutorial."
                   : nStrRef == 607  ? "When selecting your character, the configuration panel will be opened. Here you will be able to toggle single features or change specific parameters."
                   : nStrRef == 608  ? "When selecting the corpse of an enemy, the tools panel will be opened. Currently, the available options are currently limited to troubleshooting, like destroying remaining corpses to possibly fix related bugs of certain module scripts depending on the existence of creatures (dead or alive)."

                   :                STRING_EMPTY;

    SetLocalString(OBJECT_SELF, "MELSE_CONFIG_TEXT_RESULT", sString);
    MELSE_SIN_SetBufferedString(nStrRef, sString);
}
