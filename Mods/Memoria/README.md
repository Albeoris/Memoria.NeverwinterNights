# Memoria

Memoria combines the universal heartbeat bootstrapper with the shared NWScript framework. It owns `default.ncs`, discovers schema-1 `*_memoria.txt` manifests in `OVERRIDE:`, validates package versions and dependency graphs, and dispatches only compatible mod heartbeats. Memoria has no gameplay heartbeat or configuration entry of its own.

## Compatibility model

Every package manifest has an X.Y.Z `version` and a `dependencies` array. A requirement such as `esi` 1.2.0 accepts 1.2.0 through any later 1.x release and rejects earlier versions and every 2.x release. Missing, malformed, duplicate, incompatible, and transitively disabled packages are excluded from both heartbeat dispatch and the Configuration Manager.

Manifests are discovered once per loaded game or module and cached in a hidden server-side NUI window. Loading a save or changing modules invalidates the cache naturally. ESI is always dispatched before other compatible heartbeat packages.

## Includes

- `memoria_core.nss`: player, party, possession, and hit-point helpers.
- `memoria_group.nss`: associate caches.
- `memoria_i18n.nss`: shared per-mod localization table loader.
- `memoria_item.nss`: spells, classes, item properties, and equipment helpers.
- `memoria_loader.nss`: manifest discovery and SemVer dependency filtering.
- `memoria_locale.nss`: language detection and localized script dispatch.
- `memoria_math.nss`: two-dimensional geometry.
- `memoria_string.nss`: decimal and JSON search-text helpers.

These include sources are distributed by Memoria for mod authors. Dependent repository projects consume them through `NwnRequiredPackage`; they are compiler inputs and are not copied into dependent build or publish outputs.

## Localization tables

`memoria_i18n.nss` loads a mod's UTF-8 `<prefix>_loc_<language>.resjson` source after the Toolset validates and converts it to a game-local `<prefix>_loc_<language>.txt` resource. Tables are cached per module and language, missing languages fall back to English, and missing keys return an empty string.

`memoria_locale.nss` dispatches the shared `memoria_is_ru.ncs` probe. Its checked-in source stays UTF-8 while the Toolset compiles a temporary Windows-1251 copy.

## Installation

Install Memoria before every dependent package by copying its `override` contents into the NWN user `override` directory. Memoria conflicts by filename with any other package that provides `default.ncs`; such a package is compatible only when its default script calls `memoria_boot`.
