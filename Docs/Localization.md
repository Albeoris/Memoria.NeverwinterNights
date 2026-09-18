# Localization

**Entry point:** `Mods/Memoria/source/memoria_loc.nss` — `MEMORIA_LOC_GetText(sPrefix, sLang, sKey)`.

Each mod authors one UTF-8 JSON resource per supported language, named `<prefix>_loc_<language>.resjson`, e.g. `mecm_loc_en.resjson`, `mecm_loc_ru.resjson`. Every file is a flat object mapping short, self-documenting keys to that language's text:

```json
{ "mod_display_name": "Companion Manager", "search_radius_label": "Search radius (1-100 m)" }
```

The Toolset validates each `.resjson` source and emits `<prefix>_loc_<language>.txt` in the game-local encoding expected by NWN:EE's `JsonParse`: Windows-1251 when the table contains Cyrillic, or Windows-1252 otherwise. The checked-in translation remains readable UTF-8; only the disposable build output is transcoded.

Do not replace localized characters with JSON `\uXXXX` escape sequences. Although they are valid JSON, this runtime path has been verified to turn the resulting Cyrillic text into question marks before it reaches NUI.

`MEMORIA_LOC_GetText` parses and caches the requested emitted table once per module load (stored as module-scoped local JSON, since the same `prefix`+`lang` table is identical for every player), then does an O(1) key lookup. Missing language tables fall back to `<prefix>_loc_en.txt`; a missing key returns `""`, which callers use as a fallback signal (e.g. to the plain-text `label`/`name` field in a `*_memoria.txt` manifest's `configuration` section).

`MEMORIA_GetLanguage` dispatches `memoria_is_ru.ncs` for every language request. The probe compares string 3 with the Russian translation of "Bards", then maps the remaining supported `GetPlayerLanguage` values. Its checked-in NWScript remains UTF-8; the Toolset detects the Cyrillic literal and compiles a temporary Windows-1251 copy. The probe returns its result through player locals because NWScript entry points cannot return values; `MEMORIA_GetLanguage` deletes those locals immediately after reading them, so no detected language persists in a character or module. The legacy mod-local parameter remains only for source compatibility and is ignored. Debug/diagnostic-only output is intentionally left as hardcoded English and not routed through this system.

This replaced LSE's older bespoke `melse_sin_lib.nss` "SIN" system, whose language detection was hardcoded to only accept `de`/`en` — removed as part of the migration.

Every localization table defines `mod_display_name` with the mod's English display name. Configuration manifests consistently use that key as `name_key`; translated titles used elsewhere in a mod remain separate keys.

See [Memoria/README.md](../Mods/Memoria/README.md#localization-tables) and [ConfigurationManager/README.md](../Mods/ConfigurationManager/README.md) for the `configuration.name_key`, `configuration.options[].label_key`, and `configuration.localization.prefix` integration.
