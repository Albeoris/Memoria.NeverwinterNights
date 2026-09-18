# Companion Manager (MECM)

Companion Manager automatically sends companions and other allied creatures to unlock nearby doors and containers outside combat.

## Features

- Uses the best available companion with the right key or a trained Open Lock skill.
- Chooses either the nearest available target or the hardest target a companion can handle, while prioritizing detected traps.
- Avoids traps, unreachable locks, busy companions, and targets already assigned to someone else.
- Prevents companions from attacking locked doors and containers that should be unlocked or disarmed instead.
- Supports henchmen, familiars, animal companions, summons, and dominated creatures.

## Compatibility

MECM works with most modules and override mods. Mods that automate locks or traps, control companion actions, or replace the module's `OnActivateItem` handler at runtime may interfere with it.

The [original LSE](https://steamcommunity.com/sharedfiles/filedetails/?id=2307769974) is incompatible with Memoria and its mods. Use the [Memoria edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3803404663) instead.

## Installation

Install Memoria, ESI, MECONFIG, and then MECM by copying each package's `override` contents into the NWN user `override` directory.

Open **Memoria Configuration** from the inventory to configure MECM. Target a lockable object with the same item to run diagnostics.

## Localization

English, Russian, French, German, Italian, and Spanish are included. Other languages fall back to English.
