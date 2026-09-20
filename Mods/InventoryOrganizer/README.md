# Memoria Inventory Organizer (MEIO)

Memoria Inventory Organizer adds a spellbook-shaped **Scriptorium** to every player character. The visible book is a UI handle; its physical scroll inventory lives in a hidden store belonging to the current game state. The store is saved and restored with the save game, so loading an older save also restores its earlier scroll contents. Scrolls remain ordinary NWN item objects with their complete runtime state.

## Features

- Automatically stores newly acquired scrolls, including the acquired portion of a merged stack.
- Imports all carried scrolls once when the character first receives the Scriptorium, using bounded batches every 0.1 seconds to stay within the VM instruction limit.
- Displays the current physical contents as compact spell-icon rows grouped by spell level, with localized names in tooltips.
- Filters scrolls by self, ally/beneficial-area, or enemy/hostile-area targeting; search matches both the current language and the English 2DA label.
- Keeps different cast-spell subtypes separate, so variants with different caster levels remain distinguishable.
- Extracts one non-merging scroll for normal item-use targeting, then returns it on cancellation, interruption, or failed use when it remains available.
- Withdraws one scroll with a right-click and returns carried scrolls with the button in bounded asynchronous batches.
- Keeps cast and explicitly withdrawn scrolls outside automatic storage through item locals, a player-side object registry, and acquisition-safe temporary tags until they are consumed or explicitly returned.
- Configures automatic storage on `OnAcquireItem` or request-only storage through Memoria Configuration Manager. Heartbeats never move scrolls from the player inventory.
- Provides an opt-in debug-message setting that traces acquisition, extraction, casting, and storage decisions both in character chat and `nwengineLog.txt`.
- Rejects non-scroll contents and drops them at the player character's location.

Custom scrolls are supported when they contain exactly one `ITEM_PROPERTY_CAST_SPELL` property whose `iprp_spells.2da` row points to a valid `spells.2da` row.

## Usage

Use the Scriptorium's **Unique Power (Self Only)** ability to open the NUI spellbook. Item powers are engine actions and therefore consume action time; **Examine** from its radial menu opens the same window immediately without entering the action queue.

## Compatibility

MEIO requires Memoria and Event Script Injector. Its module acquire-item, activate-item, GUI, and player-target handlers are registered through ESI and do not replace module scripts directly. Scriptorium contents are scoped to the current save game and are never synchronized through a profile-wide campaign database.

## Installation

Install Memoria, ESI, and then MEIO by copying each package's `override` contents into the NWN user `override` directory.

## Localization

English, Russian, French, German, Italian, and Spanish are included. Other languages fall back to English.
