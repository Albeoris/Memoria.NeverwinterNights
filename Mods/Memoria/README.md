# Memoria

Memoria is the shared loader and framework that lets multiple Neverwinter Nights: Enhanced Edition override mods run together through one heartbeat script. It has no gameplay effects on its own.

## Features

- Loads compatible Memoria mods through a single `default.ncs` instead of letting them overwrite one another.
- Checks package versions and dependencies, disables incompatible packages, and keeps the remaining mods running.
- Provides shared NWScript helpers for mod authors.
- Provides consistent right-click contextual help for Memoria-owned NUI windows.

## Compatibility

Mods that do not provide their own `default.ncs` generally work with Memoria without changes. A mod that relies on `default.ncs` must register with Memoria instead of replacing or merging that file. Only Memoria may provide `default.ncs`.

An external mod that needs a heartbeat registers a unique package manifest named `<package>_memoria.txt` and moves its periodic entry point into a separate script with its own non-`default` resource name. Memoria discovers the manifest, validates its version and dependencies, and invokes the compatible heartbeat at the declared priority.

The [original LSE](https://steamcommunity.com/sharedfiles/filedetails/?id=2307769974) is incompatible with Memoria and its mods. Use the [Memoria edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3803404663) instead.

## Installation

Copy Memoria's `override` contents into the NWN user `override` directory before installing any dependent package.

## Integrating an external mod

This integration does not require the external mod to be added to the Memoria repository or built with its Toolset. Compile the mod's periodic code as a uniquely named entry point such as `mymod_hb.nss`/`mymod_hb.ncs`, then place the compiled `.ncs` in the NWN user `override` directory alongside the manifest.

Create `override/mymod_memoria.txt` as a complete runtime manifest:

```json
{
  "schema": 1,
  "id": "MYMOD",
  "name": "My External Mod",
  "version": "1.0.0",
  "dependencies": [
    {
      "id": "MEMORIA",
      "versions": "[1.0.0,2.0.0)"
    }
  ],
  "bootstrapper": {
    "heartbeat": "mymod_hb",
    "priority": 200
  }
}
```

The manifest filename and heartbeat are NWN resource names and must be unique and respect the game's resref length limit. Lower numeric priorities run earlier; ESI is always forced to priority `0`. Implement the heartbeat as a normal compiled entry point containing `void main()`; Memoria invokes it with the player character as `OBJECT_SELF`.

Distribute `mymod_memoria.txt` and `mymod_hb.ncs` with the external mod. Do not distribute `default.nss` or `default.ncs`; the installed Memoria package dispatches the registered heartbeat through its own `default.ncs`.
