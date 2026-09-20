# Memoria Inventory Organizer (MEIO)

Memoria Inventory Organizer adds a spellbook-shaped **Scriptorium** to every player character. The visible book is a UI handle; its physical scroll inventory lives in a runtime store with up to 25 pages. The store is serialized to the `MEMORIA_MEIO` campaign database after each mutation and restored across module transitions. Scrolls remain ordinary NWN item objects with their complete runtime state.

## Features

- Automatically stores newly acquired scrolls, including the acquired portion of a merged stack.
- Imports all carried scrolls once when the character first receives the Scriptorium.
- Displays the current physical contents as compact spell-icon rows grouped by spell level, with localized names in tooltips.
- Filters scrolls by arcane/divine spell lists and offensive/non-offensive behavior; search matches both the current language and the English 2DA label.
- Keeps different cast-spell subtypes separate, so variants with different caster levels remain distinguishable.
- Extracts one non-merging scroll for normal item-use targeting, then returns it on cancellation, interruption, or failed use when it remains available.
- Withdraws one scroll with a right-click and returns carried scrolls with the button in the Scriptorium window.
- Keeps cast and explicitly withdrawn scrolls outside automatic storage through item locals, a player-side object registry, and acquisition-safe temporary tags until they are consumed or explicitly returned.
- Configures automatic storage on `OnAcquireItem` or request-only storage through Memoria Configuration Manager. Heartbeats never move scrolls from the player inventory.
- Provides an opt-in debug-message setting that traces acquisition, extraction, casting, and storage decisions both in character chat and `nwengineLog.txt`.
- Rejects non-scroll contents and drops them at the player character's location.

Custom scrolls are supported when they contain exactly one `ITEM_PROPERTY_CAST_SPELL` property whose `iprp_spells.2da` row points to a valid `spells.2da` row.

## Usage

Use the Scriptorium's **Unique Power (Self Only)** ability to open the NUI spellbook. Item powers are engine actions and therefore consume action time; **Examine** from its radial menu opens the same window immediately without entering the action queue.

## Compatibility

MEIO requires Memoria and Event Script Injector. Its module acquire-item, activate-item, GUI, and player-target handlers are registered through ESI and do not replace module scripts directly. The campaign database is independent of an individual module save; loading an older save uses the latest successfully written Scriptorium snapshot for that character.

## Installation

Install Memoria, ESI, and then MEIO by copying each package's `override` contents into the NWN user `override` directory.

## Localization

English, Russian, French, German, Italian, and Spanish are included. Other languages fall back to English.
