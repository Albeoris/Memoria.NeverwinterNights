# Memoria Framework

Memoria Framework is a source package of reusable NWScript helpers for mod developers. MECALM and METACT compile the required code into their releases, so players do not need to install Framework separately.

## Includes

- `memoria_core.nss`: player, party, possession, and hit-point helpers.
- `memoria_group.nss`: associate caches.
- `memoria_item.nss`: spells, classes, item properties, and equipment helpers.
- `memoria_locale.nss`: language detection and localized script dispatch.
- `memoria_math.nss`: two-dimensional geometry.
- `memoria_string.nss`: decimal and JSON search-text helpers.

## Compatibility

Framework has no runtime behavior and no logical conflicts. Do not mix different versions of its `memoria_*.nss` include files in the same build environment.
