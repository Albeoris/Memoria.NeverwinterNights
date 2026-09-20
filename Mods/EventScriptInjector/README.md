# Event Script Injector - Memoria Edition (ESI)

Event Script Injector lets multiple override mods add behavior to game events without replacing the module's original scripts or one another's handlers.

## Features

- Injects scripts into module, area, creature, and placeable events.
- Preserves the original event script and supports ordered handlers from multiple mods.
- Retains Ravick's original `ESI_InjectToObject` API and resource names for existing integrations and saved games.
- Rebuilds runtime registrations after a game or module is loaded.
- Supports the module player-chat event while preserving and invoking the module's original chat script.

## Compatibility

ESI supports mods written for Ravick's original API. Do not install it alongside another ESI distribution; mods that replace event handlers at runtime instead of using ESI may bypass injected scripts.

The [original LSE](https://steamcommunity.com/sharedfiles/filedetails/?id=2307769974) is incompatible with Memoria and includes legacy ESI files. Use the [Memoria edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3803404663) instead.

## Installation

Install Memoria first, then copy ESI's `override` contents into the NWN user `override` directory.

## Minimal event mod

This example registers an `OnActivateItem` handler without replacing the module's original event script or handlers installed by other mods.

`override/mymod_evt_memoria.txt`:

```json
{"schema":1,"id":"MYMOD_TINY_EVT","version":"1.0.0","dependencies":[{"id":"MEMORIA","versions":"[1.0.0,2.0.0)"},{"id":"esi","versions":"[2.0.0,3.0.0)"}],"bootstrapper":{"heartbeat":"mymod_evt_hb","priority":200}}
```

`mymod_evt_hb.nss`, compiled as `override/mymod_evt_hb.ncs`:

```c
#include "esi_lib"

void main()
{
    object oModule = GetModule();
    ESI_InjectToObject(oModule, "mymod.module.activate", EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, "mymod_evt_act", ESI_INJECTION_PLACEMENT_LAST);
}
```

`mymod_evt_act.nss`, compiled as `override/mymod_evt_act.ncs`:

```c
void main()
{
    object oPC = GetItemActivator();
    object oItem = GetItemActivated();
    if (GetIsPC(oPC)) SendMessageToPC(oPC, "[MYMOD_TINY_EVT] activated " + GetName(oItem) + ".");
}
```

The finished mod contains:

```text
override/
├── mymod_evt_memoria.txt
├── mymod_evt_act.ncs
└── mymod_evt_hb.ncs
```

`MYMOD` stands for the mod author's own unique prefix. The `_memoria` filename suffix identifies the shared package manifest; Memoria reads its dependency and `bootstrapper` data. Use a namespaced injection key such as `acme.module.activate`. `ESI_InjectToObject` checks the current runtime registry internally, so repeated heartbeats are cheap while a newly loaded game registers the hook again automatically. Use `ESI_IsRegistered` directly only when its result lets the caller skip additional work beyond the registration call itself.

## Credits

Original ESI scripts are by Ravick. See the repository's third-party notices for licensing details.
