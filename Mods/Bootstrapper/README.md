# Memoria Bootstrapper

MEBOOTSTRAPPER loads registered Memoria mods in the correct order on each player heartbeat. It discovers registration manifests once per loaded game or module, then dispatches the cached heartbeat list without touching the manifest resources again. Loading a game or entering another module invalidates the cache. It is required by ESI, MELSE, MECALM, and METACT.

## Installation

Copy the package's `override` contents into the NWN user `override` directory before installing dependent mods.

## Minimal heartbeat mod

This example initializes once for a player character and then prints a debug message on every six-second dispatch.

`override/memoria_acme.txt`:

```json
{"schema":1,"id":"ACME_TINY","heartbeat":"acme_tiny_hb","priority":200}
```

`acme_tiny_hb.nss`, compiled as `override/acme_tiny_hb.ncs`:

```c
const string ACME_TINY_INITIALIZED = "ACME_TINY_INITIALIZED";
const string ACME_TINY_TICK = "ACME_TINY_TICK";

void ACME_TINY_Initialize(object oPC)
{
    SendMessageToPC(oPC, "[ACME_TINY] initialized.");
    SetLocalInt(oPC, ACME_TINY_INITIALIZED, TRUE);
}

void main()
{
    object oPC = OBJECT_SELF;
    if (!GetLocalInt(oPC, ACME_TINY_INITIALIZED)) ACME_TINY_Initialize(oPC);
    int nTick = GetLocalInt(oPC, ACME_TINY_TICK) + 1;
    SetLocalInt(oPC, ACME_TINY_TICK, nTick);
    SendMessageToPC(oPC, "[ACME_TINY] heartbeat " + IntToString(nTick) + ".");
}
```

The finished mod contains:

```text
override/
├── memoria_acme.txt
└── acme_tiny_hb.ncs
```

`ACME` stands for the mod author's own unique prefix; it is not a Memoria namespace. The `memoria_` filename prefix is required only so Bootstrapper can discover the registration. The initialization flag is stored on the player character and persists in saved games. A real mod can replace `ACME_TINY_Initialize` with default-setting, migration, or event-registration code and change the flag name when a new initialization version is required. Lower priorities run first. Every registered heartbeat is dispatched in its own execution context; if one aborts, the player receives its manifest `id` and script name, and the other queued mods continue to run.

## Compatibility

MEBOOTSTRAPPER conflicts by file with any other mod that provides `default.ncs`. Such a mod is compatible only if its default script calls `memoria_boot`.
