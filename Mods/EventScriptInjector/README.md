# Event Script Injector — Memoria Edition

ESI lets override mods add behavior to module, area, creature, and placeable events without replacing the module's original scripts. This package preserves Ravick's original ESI API and resource names.

## Installation

Install M_BOOTSTRAPPER first, then copy ESI's `override` contents into the NWN user `override` directory.

## Compatibility

Do not install this package alongside another ESI distribution or a legacy LSE package that contains ESI files. Mods that replace module event handlers at runtime instead of using ESI may bypass registered injections.

Original ESI scripts are by Ravick. See the repository's third-party notices for licensing details.
