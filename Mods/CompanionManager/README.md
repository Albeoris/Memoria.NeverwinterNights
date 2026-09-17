# Companion Manager (MECM)

MECM lets companions, henchmen, familiars, animal companions, summons, and dominated creatures automatically unlock nearby doors and containers outside combat.

## Features

- Assigns suitable locks to associates with keys or trained Open Lock skill.
- Avoids active traps, blocked routes, manual actions, and locks already assigned to another associate.
- Stops its tasks when combat starts and returns control to the standard AI when no task is active.
- Optional lock highlighting, overhead messages, and diagnostics.
- Configurable range, update interval, line of sight, and attack safety.

## Installation

Install Memoria, ESI, MECONFIG, and then MECM by copying each package's `override` contents into the NWN user `override` directory.

## Use

Open **Memoria Configuration** from the inventory to configure MECM. Settings are stored on the player character and persist in saved games. Target a lockable object with the same item to run MECM diagnostics.

## Compatibility

MECM has no file conflicts with other mods. Logical conflicts are possible with mods that also control companion actions, automate locks or traps, or replace the module's `OnActivateItem` handler at runtime.

## Languages

Russian, English, French, Italian, German, and Spanish are included. Other clients fall back to English.
