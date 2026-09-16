# Localization

**Entry point:** `Mods/Memoria/source/memoria_i18n.nss` — `MEMORIA_I18N_GetText(sPrefix, sLang, sKey)`.

Each mod authors one UTF-8 JSON resource per supported language, named `<prefix>_loc_<language>.resjson`, e.g. `mecm_loc_en.resjson`, `mecm_loc_ru.resjson`. Every file is a flat object mapping short, self-documenting keys to that language's text:

```json
{ "mod_display_name": "Companion Manager", "search_radius_label": "Search radius (1-100 m)" }
```

The Toolset validates each `.resjson` source and emits `<prefix>_loc_<language>.txt` in the game-local encoding expected by NWN:EE's `JsonParse`: Windows-1251 when the table contains Cyrillic, or Windows-1252 otherwise. The checked-in translation remains readable UTF-8; only the disposable build output is transcoded.

Do not replace localized characters with JSON `\uXXXX` escape sequences. Although they are valid JSON, this runtime path has been verified to turn the resulting Cyrillic text into question marks before it reaches NUI.

`MEMORIA_I18N_GetText` parses and caches the requested emitted table once per module load (stored as module-scoped local JSON, since the same `prefix`+`lang` table is identical for every player), then does an O(1) key lookup. Missing language tables fall back to `<prefix>_loc_en.txt`; a missing key returns `""`, which callers use as a fallback signal (e.g. to the plain-text `label`/`name` field in a `*_memoria.txt` manifest's `configuration` section).

`MEMORIA_GetLanguage` lives in `memoria_locale.nss` and dispatches the shared `memoria_is_ru.ncs` probe supplied by Memoria. The probe compares string 3 with the Russian translation of "Bards". Its checked-in NWScript remains UTF-8; the Toolset detects the Cyrillic literal and compiles a temporary Windows-1251 copy. Mods keep only their `<PREFIX>_GetLanguage(oPC)` wrapper and language cache. Debug/diagnostic-only output is intentionally left as hardcoded English and not routed through this system.

This replaced LSE's older bespoke `melse_sin_lib.nss` "SIN" system, whose language detection was hardcoded to only accept `de`/`en` — removed as part of the migration.

Every localization table defines `mod_display_name` with the mod's English display name. Configuration manifests consistently use that key as `name_key`; translated titles used elsewhere in a mod remain separate keys.

See [Memoria/README.md](../Mods/Memoria/README.md#localization-tables) and [Configuration/README.md](../Mods/Configuration/README.md) for the `configuration.name_key`, `configuration.options[].label_key`, and `configuration.localization.prefix` integration.
