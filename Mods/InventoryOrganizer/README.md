# Memoria Inventory Organizer (MEIO)

Memoria Inventory Organizer adds **Spatial Storage** to every player character. The visible chest item is both a UI handle and an intake container; scrolls, potions, and books live in separate hidden stores belonging to the current game state. Key items remain as their original physical objects in player-created inventory containers so campaign possession checks continue to work. All stores and containers are saved with the game.

## Features

- Independently configures automatic storage of eligible newly acquired scrolls, potions, and books. Plot, cursed, zero-value, infinite, or enchanted books are never stored; local variables and the creature-loot droppable flag do not affect eligibility.
- Imports all eligible carried scrolls and potions once when the character first receives Spatial Storage, using bounded batches every 0.1 seconds to stay within the VM instruction limit.
- Provides separate Scrolls, Potions, and Books tabs with real item icons. Book search always matches both localized and English titles; a checkbox selects which title is displayed. Left-click opens a description window without closing storage; engine color tags are removed, every black-hidden marker is omitted regardless of its text, and acquisition metadata is highlighted. Duplicate copies can be burned in bounded batches.
- Provides a Key Items tab with one row per physical container. Players explicitly create containers, remove empty ones, store all eligible top-level key items, or retrieve their original objects. Plot or zero-value items qualify; Recall Stones and MEIO service items are excluded. Cursed key items remain visible with a locked frame but cannot be moved. Left-click opens item information; right-click moves an eligible item between the top-level inventory and any directly owned bag while protecting extracted items from automatic return.
- Displays the current physical contents as compact spell-icon rows grouped by spell level, omitting empty levels after every search, filter, addition, or removal, with localized names in tooltips.
- Filters scrolls by self, ally/beneficial-area, or enemy/hostile-area targeting; search matches both the current language and the English 2DA label.
- Keeps different cast-spell subtypes separate, so variants with different caster levels remain distinguishable.
- Extracts one non-merging scroll for normal item-use targeting, then returns it on cancellation, interruption, or failed use when it remains available.
- Withdraws one item with a right-click; buttons store carried items or withdraw every stored item in bounded asynchronous batches. Only one bulk transfer can run at a time, and withdrawal stops safely when the inventory is full.
- Keeps cast and explicitly withdrawn scrolls outside automatic storage through item locals, a player-side object registry, and acquisition-safe temporary tags until they are consumed or explicitly returned.
- Configures automatic storage on `OnAcquireItem` or request-only storage through Memoria Configuration Manager. An optional setting keeps the window open after potions and personal-range scrolls. Heartbeats never perform recurring inventory collection.
- Provides an opt-in debug-message setting that traces acquisition, extraction, casting, and storage decisions both in character chat and `nwengineLog.txt`.
- Rejects contents that do not match their hidden store and drops them at the player character's location.

Custom scrolls are supported when they contain exactly one `ITEM_PROPERTY_CAST_SPELL` property whose `iprp_spells.2da` row points to a valid `spells.2da` row.

## Usage

Spatial Storage is an ordinary chest without a special power. **Examine** from its radial menu opens the NUI immediately without entering the action queue; the standard description panel stays suppressed whether the NUI is closed manually or by using an item. `/memoria-io-scrolls`, `/memoria-io-potions`, `/memoria-io-books`, and `/memoria-io-key-items` open the corresponding tab from chat and can be assigned as quickbar chat macros. Eligible managed items placed directly into the chest are absorbed into their virtual stores; every other item is returned to the character when inventory space is available.

## Uninstallation without losing stored items

Do not remove MEIO while Spatial Storage still contains items: its hidden stores are inaccessible without the mod. Open all four tabs and use **All to inventory** on each one. If the inventory becomes full, free enough space and repeat until every page is empty. Remove the empty key-item containers and empty the visible chest itself. Save the game to a new slot, verify that every required item is in the character inventory, exit the game, and only then remove MEIO from `override` or unsubscribe from it.

## Compatibility

MEIO requires Memoria and Event Script Injector 2.1 or newer. Its module acquire-item, GUI, player-target, and player-chat handlers are registered through ESI and do not replace module scripts directly. The chat handler runs after the module's original handler. Stored contents are scoped to the current save game and are never synchronized through a profile-wide campaign database.

MEIO reserves Big Box appearances `242` and `243` and icon resources `iit_bigbox_242.tga` and `iit_bigbox_243.tga` for Spatial Storage and Key Item Storage. A mod that uses either appearance or resource creates only a soft conflict: storage functionality remains intact, but one of the items may display the wrong icon depending on override load order.

## Installation

Install Memoria, ESI, and then MEIO by copying each package's `override` contents into the NWN user `override` directory.

## Localization

English, Russian, French, German, Italian, and Spanish are included. Other languages fall back to English.
