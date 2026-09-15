# Event Script Injector — Memoria Edition

ESI lets override mods add behavior to module, area, creature, and placeable events without replacing the module's original scripts. This package preserves Ravick's original ESI API and resource names.

Injection keys are compared and stored as exact strings. Existing numeric-key locals and saved games remain readable, while non-numeric keys no longer collide through `StringToInt` conversion.

## Installation

Install M_BOOTSTRAPPER first, then copy ESI's `override` contents into the NWN user `override` directory.

## Minimal event mod

This example registers an `OnActivateItem` handler without replacing the module's original event script or handlers installed by other mods.

`override/memoria_acme_evt.txt`:

```json
{"schema":1,"id":"ACME_TINY_EVT","heartbeat":"acme_evt_hb","priority":200}
```

`acme_evt_hb.nss`, compiled as `override/acme_evt_hb.ncs`:

```c
#include "esi_lib"

const string ACME_TINY_EVT_INSTALLED = "ACME_TINY_EVT_INSTALLED";

void main()
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, ACME_TINY_EVT_INSTALLED) && ESI_InjectToObject(oModule, "acme_evt", EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM, "acme_evt_act", ESI_INJECTION_PLACEMENT_LAST)) SetLocalInt(oModule, ACME_TINY_EVT_INSTALLED, TRUE);
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

`ACME` stands for the mod author's own unique prefix. The `memoria_` filename prefix belongs to Bootstrapper's discovery protocol. The injection key `acme_evt` must be unique within this event and placement. The module local and the ESI registration are saved with the module, so subsequent heartbeats are cheap.

## Compatibility

Do not install this package alongside another ESI distribution or a legacy LSE package that contains ESI files. Mods that replace module event handlers at runtime instead of using ESI may bypass registered injections.

Original ESI scripts are by Ravick. See the repository's third-party notices for licensing details.
