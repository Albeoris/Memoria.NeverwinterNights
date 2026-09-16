# Event Script Injector — Memoria Edition

ESI lets override mods add behavior to module, area, creature, and placeable events without replacing the module's original scripts. This package preserves Ravick's original `ESI_InjectToObject` API and resource names.

The union script and the remembered original event script remain on the object and can be serialized by a saved game. Active hooks live only in a server-side NUI user-data registry. ESI creates a new empty registry for every loaded runtime, and consumer mods register their hooks again on their first heartbeat. Until that happens, a saved union script executes only the remembered original script.

Injection keys are exact, namespaced strings. Legacy numeric-key locals are discarded lazily when an event is registered under the new storage schema. Existing saved games keep their original event handlers because the `esi_uni_*` resource names and original-script local names have not changed.

## Installation

Install MEBOOTSTRAPPER first, then copy ESI's `override` contents into the NWN user `override` directory.

## Minimal event mod

This example registers an `OnActivateItem` handler without replacing the module's original event script or handlers installed by other mods.

`override/memoria_acme_evt.txt`:

```json
{"schema":1,"id":"ACME_TINY_EVT","bootstrapper":{"heartbeat":"acme_evt_hb","priority":200}}
```

`acme_evt_hb.nss`, compiled as `override/acme_evt_hb.ncs`:

```c
#include "esi_lib"

void main()
{
    object oModule = GetModule();
    if (!ESI_IsRegistered(oModule, "acme.module.activate", EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, "acme_evt_act", ESI_INJECTION_PLACEMENT_LAST)) ESI_InjectToObject(oModule, "acme.module.activate", EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, "acme_evt_act", ESI_INJECTION_PLACEMENT_LAST);
}
```

`acme_evt_act.nss`, compiled as `override/acme_evt_act.ncs`:

```c
void main()
{
    object oPC = GetItemActivator();
    object oItem = GetItemActivated();
    if (GetIsPC(oPC)) SendMessageToPC(oPC, "[ACME_TINY_EVT] activated " + GetName(oItem) + ".");
}
```

The finished mod contains:

```text
override/
├── memoria_acme_evt.txt
├── acme_evt_act.ncs
└── acme_evt_hb.ncs
```

`ACME` stands for the mod author's own unique prefix. The `memoria_` filename prefix identifies the shared package manifest; Bootstrapper reads its `bootstrapper` section. Use a namespaced injection key such as `acme.module.activate`. `ESI_IsRegistered` checks the current runtime registry, so repeated heartbeats are cheap while a newly loaded game registers the hook again automatically.

## Compatibility

Do not install this package alongside another ESI distribution or a legacy LSE package that contains ESI files. Mods that replace module event handlers at runtime instead of using ESI may bypass registered injections. Runtime hooks require at least one player because the transient registry belongs to a hidden player NUI window; if its owner leaves, ESI recreates the registry and consumers register again on the next heartbeat.

Original ESI scripts are by Ravick. See the repository's third-party notices for licensing details.
