# Memoria Bootstrapper

M_BOOTSTRAPPER loads registered Memoria mods in the correct order on each player heartbeat. It is required by ESI, M_LSE, M_CALM, and M_TACT.

## Installation

Copy the package's `override` contents into the NWN user `override` directory before installing dependent mods.

## Compatibility

M_BOOTSTRAPPER conflicts by file with any other mod that provides `default.ncs`. Such a mod is compatible only if its default script calls `memoria_boot`.
