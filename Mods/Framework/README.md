# Memoria Framework

Memoria Framework is a source package of reusable NWScript helpers for mod developers. MECALM and METACT compile the required code into their releases, so players do not need to install Framework separately.

## Includes

- `memoria_core.nss`: player, party, possession, and hit-point helpers.
- `memoria_group.nss`: associate caches.
- `memoria_i18n.nss`: shared per-mod localization table loader (see below).
- `memoria_item.nss`: spells, classes, item properties, and equipment helpers.
- `memoria_locale.nss`: language detection and localized script dispatch.
- `memoria_math.nss`: two-dimensional geometry.
- `memoria_string.nss`: decimal and JSON search-text helpers.

## Localization tables

`memoria_i18n.nss` replaces the older pattern of one `ExecuteScript`-dispatched `.nss` file per language per mod with plain JSON resources. Each mod authors one UTF-8 `<prefix>_i18n_<language>.resjson` file per supported language, mapping short, self-documenting keys to that language's text, e.g. `mecalm_i18n_en.resjson`, `mecalm_i18n_ru.resjson`. The build validates each table and emits `<prefix>_i18n_<language>.txt` (RESTYPE_TXT) in Windows-1251 when Cyrillic is present or Windows-1252 otherwise, matching the game-local string expected by `JsonParse`. Call `MEMORIA_I18N_GetText(sPrefix, sLang, sKey)` to look up one string; the underlying table is parsed once per module load and cached on the module (identical tables are shared across all players speaking the same language). Missing language tables fall back to `<prefix>_i18n_en.txt`; missing keys return an empty string, which callers can use as a fallback signal.

## Compatibility

Framework has no runtime behavior and no logical conflicts. Do not mix different versions of its `memoria_*.nss` include files in the same build environment.
