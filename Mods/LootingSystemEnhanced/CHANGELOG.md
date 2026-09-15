Ravick's Looting System Enhanced (MELSE)

# Looting System Enhanced changelog

Original changelog by Ravick.

--- 1.1 ---

Introduces configuration panel, bugfixing tools and related tutorial plus greatly improves stability.

New Features:
- Added custom feat "Player Tool 9" (x3_pl_tool09) to access different functionalities depending on target chosen. Found under "Special Abilities" in the right click menu. Choosed the number 9 with compatibility to "Inventory Sort" mod by NWShacker in mind (which is using x3_pl_tool10). 
- Added Configuration Panel accessable via "Player Tool 9" when PC chosen as target.
- Added toggles for all available features to Configuration Panel.
- Added some specific parameters to Configuration Panel.
- Added Tools Panel accessable via "Player Tool 9" when corpse chosen as target.
- Added options in Tools Panel for destroying corpses individually, area-wide or module-wide. Useful for bugfixing if any script does not trigger correctly due to a creature not being recognized as dead because its corpse still lying around.
- Auto looting now takes a maximum item weight and minimum gold piece value into account. Unidentified items and many base item types will always be looted though. This is mostly useful to prevent simple armor/weapon/book items cluttering up the inventory (automatically ignores "Fire Beetle's Belly" too, what a joy!). A red floating text will indicate that an item was ignored. Customizable using the new Configuration Panel. Defaults are 8 for minimal value (to ignore basic base game books) and 9 for maximal weight.
- A short tutorial conversation will guide you through the manual functionalities of MELSE after installing it or updating it.
- Your character will speak a short notification string after installing or updating MELSE.

Bug Fixes:
- Placeables containing no items will no longer get unuseable after opening. This should solve most problems with containers that are supposed to serve a special purpose, other than just generating random loot and such.
- Containers will only be auto looted (and checked for deactivation) after the first opening. This allows for using containers for hoarding again.
- If client language is not "en" and not "de", the script based translation framework is now working with "en" language by default. If you want to help translating the few strings used into any other language, just drop me a PM and I will send you a single file which can be easily translated using a simple text editor.

General Script Changes:
- Refined area treasure scanning to work more consistent and to take item exclusion rules into account.
- Rearranged many parts of the code in "melse_lib". Planning to separate the one big include into some smaller ones.
- Removed most debugging/logging code for better readibility.

Credits:
- NWShacker: for inspiration and advice on how to implement Player Tool Feats drawn from his great mod "Inventory Sort"!

--- 1.0 ---

Initial release.

New Features:
- Auto Looting for Corpses
- Lootable corpses with long decay time
- Auto Looting for Treasure 
- Tracking of already looted treasure
- Notification for lootable treasure when entering area
- Notification after looting last treasure in area
- Displaying name and area an item was last acquired by in description window
