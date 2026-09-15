# Memoria Framework

Memoria Framework supplies reusable NWScript helpers for mod developers and the shared `memoria_is_ru.ncs` runtime language probe. MECALM and METACT compile the include helpers into their releases; Configuration Manager requires Framework for the probe.

## Includes

- `memoria_core.nss`: player, party, possession, and hit-point helpers.
- `memoria_group.nss`: associate caches.
- `memoria_i18n.nss`: shared per-mod localization table loader (see below).
- `memoria_item.nss`: spells, classes, item properties, and equipment helpers.
- `memoria_locale.nss`: language detection and localized script dispatch.
- `memoria_math.nss`: two-dimensional geometry.
- `memoria_string.nss`: decimal and JSON search-text helpers.

`memoria_locale.nss` dispatches the shared `memoria_is_ru.ncs` probe. Its source contains the readable Russian comparison literal in UTF-8, while the Toolset compiles it through a temporary Windows-1251 copy.

## Localization tables

`memoria_i18n.nss` replaces the older pattern of one `ExecuteScript`-dispatched `.nss` file per language per mod with plain JSON resources. Each mod authors one UTF-8 `<prefix>_loc_<language>.resjson` file per supported language, mapping short, self-documenting keys to that language's text, e.g. `mecalm_loc_en.resjson`, `mecalm_loc_ru.resjson`. The build validates each table and emits `<prefix>_loc_<language>.txt` (RESTYPE_TXT) in Windows-1251 when Cyrillic is present or Windows-1252 otherwise, matching the game-local string expected by `JsonParse`. Call `MEMORIA_I18N_GetText(sPrefix, sLang, sKey)` to look up one string; the underlying table is parsed once per module load and cached on the module (identical tables are shared across all players speaking the same language). Missing language tables fall back to `<prefix>_loc_en.txt`; missing keys return an empty string, which callers can use as a fallback signal.

## Compatibility

Framework has no heartbeat and no logical conflicts. Do not mix different versions of its `memoria_*.nss` include files in the same build environment.
