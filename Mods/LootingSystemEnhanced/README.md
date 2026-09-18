# Looting System Enhanced - Memoria Edition (MELSE)

Looting System Enhanced automates looting and adds configurable treasure tracking, lootable corpses, and item filters.

This edition fixes an original LSE bug that could remove corpses together with key items: a corpse now disappears only when its inventory is empty. Its temporary runtime hooks are rebuilt on every game start, so MELSE can be disabled without damaging saved games.

## Features

- Finds, tracks, and automatically loots treasure from defeated creatures and containers.
- Filters automatic looting by item value and weight.
- Makes corpses lootable and optionally raiseable, then removes them after looting or a chosen delay.
- Reports important drops and records where acquired items came from in their descriptions.

## Compatibility

Remove the [original LSE](https://steamcommunity.com/sharedfiles/filedetails/?id=2307769974) before installing MELSE; it is incompatible with Memoria. Use this version as its replacement.

MELSE works with most modules and override mods. Mods that also automate looting, preserve corpses, or change container behavior may interfere with it.

## Installation

After removing the original LSE, install Memoria, ESI, MECONFIG, and then MELSE by copying each package's `override` contents into the NWN user `override` directory.

Open **Memoria Configuration** from the inventory and select **Looting System Enhanced** to configure it.

## Localization

English, Russian, French, German, Italian, and Spanish are included. Other languages fall back to English.

## Credits

Original LSE design, scripts, and documentation are by Ravick. See the repository's third-party notices for licensing details.

- [Ravick on Steam](https://steamcommunity.com/profiles/76561198044092406/)
- [Ravick on Neverwinter Vault](https://forum.neverwintervault.org/u/Ravick/summary)
- [Ravick on Nexus Mods](https://www.nexusmods.com/users/3628084)
