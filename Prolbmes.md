# Cross-Mod Conflict Risks

Research-only findings (no fixes applied yet). These are places where two different-author mods (Memoria-owned or third-party) could silently conflict, mostly because a hardcoded integer-like index or a bare/generic string is used where a namespaced, collision-resistant identifier should be used instead.

## 1. ESI injection keys are plain strings with no uniqueness registry (highest severity)

`ESI_InjectToObject(oObject, sKey, nHandler, sScript, nPlacement)` in [Mods/EventScriptInjector/source/esi_lib.nss](Mods/EventScriptInjector/source/esi_lib.nss#L159-L172) stores the injected script in a JSON map keyed by `sKey` as-is: `JsonObjectSet(jScripts, sKey, JsonString(sScript))`. If two mods pass the same `sKey` for the same `(nHandler, nPlacement)` pair, the second one **silently overwrites** the first one's handler — no error, no warning.

Keys are currently authored by hand as bare numbers instead of namespaced strings:

- [Mods/LootingSystemEnhanced/source/melse_lib.nss:106-111](Mods/LootingSystemEnhanced/source/melse_lib.nss#L106-L111) — `MELSE_INJECT_KEY_* = "100"`, `"200"`, `"300"`, `"400"`, `"410"`, `"500"` — short round numbers, very likely to collide with another author's (or even a future first-party) mod.
- [Mods/CompanionAutoLockManager/source/mecalm_lib.nss:10](Mods/CompanionAutoLockManager/source/mecalm_lib.nss#L10) — `MECALM_ESI_INJECTION_KEY = "9317"`.
- [Mods/TacticsArchitect/source/metact_core.nss:9](Mods/TacticsArchitect/source/metact_core.nss#L9) — `METACT_ESI_KEY = "7421"`.
- [Mods/Configuration/source/memoria_config.nss:399](Mods/Configuration/source/memoria_config.nss#L399) — literal `"config"`, an even more likely collision candidate since it's a common, generic word.
- The ESI README itself demonstrates the correct pattern with a namespaced example key `"acme_evt"` ([Mods/EventScriptInjector/README.md:31](Mods/EventScriptInjector/README.md#L31)), but CALM/TACT/LSE/Configuration do not follow it.

Additionally, when `sKey` is numeric (`^[0-9]+$`), the value is also stored via `RAV_SetLocalArrayString(oObject, ..., StringToInt(sKey), sScript)` ([Mods/EventScriptInjector/source/esi_lib.nss:172](Mods/EventScriptInjector/source/esi_lib.nss#L172)) — the number is literally used as an array index rather than just a name.

## 2. Full-file overrides of engine scripts (flat override namespace)

LSE fully replaces `nw_c2_default1.nss`, `nw_c2_default5.nss`, and `nw_c2_defaultb.nss` ([Mods/LootingSystemEnhanced/source](Mods/LootingSystemEnhanced/source)) — some of the most commonly customized creature AI scripts in NWN modules. Because the override directory is a flat namespace (one resref = one file), **any other mod or module that also overrides these same scripts fully wins or fully loses** — the conflict is resolved by whichever file loads last, not by merging.

`default.ncs` has the same property. It is intentionally documented in AGENTS.md as "only MEBOOTSTRAPPER may provide it," but it remains a hard conflict point against any third-party (non-Memoria) package that also ships its own `default.ncs`.

## 3. Duplicate `id` handling gap between two independent registries

- In Bootstrapper (`MEBOOTSTRAPPER_DiscoverEntries`, [Mods/Bootstrapper/source/memoria_boot.nss](Mods/Bootstrapper/source/memoria_boot.nss)), a duplicate `id` from `memoria_*.txt` is at least **detected** (`MEBOOTSTRAPPER_HasId`) and reported to the player once — but the second mod with that `id` is simply never registered, silently.
- `MEMORIA_CONFIG_LoadModules()` ([Mods/Configuration/source/memoria_config.nss](Mods/Configuration/source/memoria_config.nss)) has **no duplicate-`id` check at all** for `mconfig_*.txt`. `MEMORIA_CONFIG_GetSelectedModule` returns the first array match for the given `id` in a name-sorted array — if two different `mconfig_*.txt` manifests from different authors share an `id`, the second mod's options can never be reached in the UI (not merely overwritten — permanently inaccessible), and saving settings could apply to the wrong mod's options if the sort order lines up unfavorably.

## 4. `MEMORIA_CONFIGURATION_ITEM` tag collision has a destructive side effect

`MEMORIA_CONFIG_EnsureItem` ([Mods/Configuration/source/memoria_config.nss](Mods/Configuration/source/memoria_config.nss)) locates an item via `GetItemPossessedBy(oPC, MEMORIA_CONFIG_ITEM_TAG)`, and if the found object doesn't have the expected `MEMORIA_CONFIG_LOCAL_ITEM_SCHEMA`, it calls **`DestroyObject(oItem)`**. If a third-party mod or author happens to create an unrelated item with the same tag (`"MEMORIA_CONFIGURATION_ITEM"`), the Configuration Manager will destroy it.

## 5. Language detection hardcodes vanilla TLK string ref #3

All `*_is_ru.nss` probes (`mecalm_is_ru.nss`, `metact_is_ru.nss`, `meconfig_is_ru.nss`, and `meboot_is_ru.nss` if present) detect Russian installs via `GetStringByStrRef(3) == "Барды"`. This hardcodes a dependency on one specific vanilla `dialog.tlk` string index. Any third-party mod, localization patch, or total conversion that changes string #3 breaks language auto-detection across **all** Memoria mods at once.

## 6. LSE's custom-TLK strref offset scheme

`RAV_GetStringByStrRef` in [Mods/EventScriptInjector/source/rav_util.nss:130-133](Mods/EventScriptInjector/source/rav_util.nss#L130-L133) reads `GetStringByStrRef(RAV_STRREF_BASE + RAV_STRREF_OFFSET + nStrRef)`, with `RAV_STRREF_OFFSET = 0` — i.e., raw index numbers into the module's `custom.tlk` are used directly. If the module or another mod also writes to `custom.tlk` and their index ranges overlap with the ones LSE uses (`nStrRef` from `melse_text_*`, roughly 1-999), text can be swapped or garbled.

## 7. Hardcoded string ref 6416 in TACT UI

[Mods/TacticsArchitect/source/metact_ui.nss:81](Mods/TacticsArchitect/source/metact_ui.nss#L81) and [Mods/TacticsArchitect/source/metact_ui.nss:268](Mods/TacticsArchitect/source/metact_ui.nss#L268): `GetStringByStrRef(6416 + iRating)` — "enemy rating" labels are read directly from vanilla `dialog.tlk` by number. A module with a modified TLK (common in custom rulesets) will show incorrect labels.

## 8. NUI window IDs share a per-player namespace

Strings such as `"memoria_config"` (`MEMORIA_CONFIG_WINDOW_ID`), `"meconfig_cache"`, and `"meboot_cache"` are NUI window identifiers shared on the player's client, with no built-in protection against collision with another (non-Memoria) mod's window ID. `NuiFindWindow`/`NuiDestroy` calls using these IDs could target or close the wrong window if a name collides.

## 9. Lower-severity / secondary notes

- Effect tags such as `MECALM_LOCK_GLOW_9F31` are lower risk (they include a random suffix), but a collision with another mod's identical effect tag could cause `MECALM_ClearHighlight`'s `RemoveEffect` loop to strip a foreign effect.
- `Mods/Framework/source/memoria_item.nss` resolves names via `Get2DAString("classes"/"metamagic", "Name", iRow)` by row number — customized `classes.2da`/`metamagic.2da` content could cause name mismatches (depends on the caller supplying `iRow`).
- Shared resource resrefs (e.g., the `memoria_config` item) fall into the same category as #2/#3, but with a much more specific name, so the collision probability is lower.
