# Tactics Architect (METACT)

Tactics Architect adds a persistent Dragon Age-style tactics editor for the player character and companions.

**Warning:** Tactics Architect is under active development and is currently tested primarily while playing a Sorcerer. It may not work in some situations, may behave unexpectedly, and may not yet support the functionality or tactical behavior you want.

## Features

- Builds ordered tactics from conditions and one or more actions.
- Uses attacks, spells, abilities, usable items, summons, and equipment changes.
- Selects targets through global, rule-specific, and action-specific priorities.
- Reacts to health, nearby enemies, enemy strength, clustered targets, and active summons or familiars.
- Predicts area-of-effect targets and provides several friendly-fire safety policies.
- Saves tactics for an individual character or creature type.

## Compatibility

METACT works with most modules and override mods. Mods that also automate player or companion actions may issue competing commands or alter their action queues.

The [original LSE](https://steamcommunity.com/sharedfiles/filedetails/?id=2307769974) is incompatible with Memoria and its mods. Use the [Memoria edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3803404663) instead.

## Installation

Install Memoria, ESI, MECONFIG, and then METACT by copying each package's `override` contents into the NWN user `override` directory.

Open **Memoria Configuration** from the inventory, select **Tactics Architect**, and choose **Open tactics editor**.

## Localization

English, Russian, French, German, Italian, and Spanish are included. Other languages fall back to English.
