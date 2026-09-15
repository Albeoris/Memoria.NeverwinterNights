# Localization

**Entry point:** `Mods/Framework/source/memoria_i18n.nss` — `MEMORIA_I18N_GetText(sPrefix, sLang, sKey)`.

Each mod authors one UTF-8 JSON resource per supported language, named `<prefix>_i18n_<language>.resjson`, e.g. `mecalm_i18n_en.resjson`, `mecalm_i18n_ru.resjson`. Every file is a flat object mapping short, self-documenting keys to that language's text:

```json
{ "mod_display_name": "Companion Auto-Lock Manager", "search_radius_label": "Search radius (1-100 m)" }
```

The Toolset validates each `.resjson` source and emits `<prefix>_i18n_<language>.txt` in the game-local encoding expected by NWN:EE's `JsonParse`: Windows-1251 when the table contains Cyrillic, or Windows-1252 otherwise. The checked-in translation remains readable UTF-8; only the disposable build output is transcoded.

Do not replace localized characters with JSON `\uXXXX` escape sequences. Although they are valid JSON, this runtime path has been verified to turn the resulting Cyrillic text into question marks before it reaches NUI.

`MEMORIA_I18N_GetText` parses and caches the requested emitted table once per module load (stored as module-scoped local JSON, since the same `prefix`+`lang` table is identical for every player), then does an O(1) key lookup. Missing language tables fall back to `<prefix>_i18n_en.txt`; a missing key returns `""`, which callers use as a fallback signal (e.g. to the plain-text `label`/`name` field in a `memoria_*.txt` manifest's `configuration` section).

Each mod still owns its own player-facing `<prefix>_is_ru.nss` probe and `<PREFIX>_GetLanguage(oPC)` wrapper around `MEMORIA_GetLanguage` (`memoria_locale.nss`) — `memoria_i18n.nss` only replaces the old per-key `ExecuteScript`-dispatched `.nss` file per language (ternary/`if` chains keyed by integer) with plain data files. Debug/diagnostic-only output is intentionally left as hardcoded English and not routed through this system.

This replaced LSE's older bespoke `melse_sin_lib.nss` "SIN" system, whose language detection was hardcoded to only accept `de`/`en` — removed as part of the migration.

Every localization table defines `mod_display_name` with the mod's English display name. Configuration manifests consistently use that key as `name_key`; translated titles used elsewhere in a mod remain separate keys.

See [Framework/README.md](../Mods/Framework/README.md#localization-tables) and [Configuration/README.md](../Mods/Configuration/README.md) for the `configuration.name_key`, `configuration.options[].label_key`, and `configuration.localization.prefix` integration.
