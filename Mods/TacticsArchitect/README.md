# Tactics Architect (M_TACT)

M_TACT adds a persistent Dragon Age-style behavior editor for the player character and associates.

## Features

- Named tactics with ordered conditions and actions.
- Spells, attacks, usable items, equipment changes, and familiar summoning.
- Target priorities at tactic, rule, and action level.
- Health, enemy count, challenge rating, cluster, and summon conditions.
- Predictive area targeting with configurable friendly-fire protection.
- Persistent profiles and localized runtime UI.
- The half-second dispatcher remains idle until an enabled tactic contains an enabled action.

## Installation

Install M_BOOTSTRAPPER, ESI, MEMORIA_CONFIG, and then M_TACT by copying each package's `override` contents into the NWN user `override` directory.

Open **Memoria Configuration** from the inventory, select Tactics Architect, and choose **Open tactics editor**.

## Compatibility

M_TACT has no file conflicts with other mods. Logical conflicts are possible with mods that also control companion AI or action queues, or replace module event handlers at runtime.

## Languages

Russian, English, French, Italian, German, and Spanish are included.
