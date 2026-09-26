# Memoria Configuration Manager (MECONFIG)

Memoria Configuration Manager provides one persistent inventory item and a shared settings menu for installed Memoria mods.

## Features

- Collects the settings of all compatible Memoria mods in one NUI menu.
- Supports player-specific and module-wide booleans, numbers, choices, action buttons, validation, and mod diagnostics.
- Prompts to save or discard edited settings before another settings page opens or the window closes.
- Stores settings on the character or module so they persist in saved games and during the transition between modules.
- Opens through **Examine** on its inventory item or directly with `/memoria-config`; the command can be assigned as a quickbar chat macro. The standard item-description panel closes automatically.

## Compatibility

MECONFIG works with Memoria mods that register a `configuration` section in their manifest; other mods are unaffected. Its item activation and player-chat hooks require Event Script Injector 2.1 or newer. Mods that replace the module's `OnActivateItem` handler at runtime may prevent its inventory item from opening.

MECONFIG reserves Miscellaneous Small appearance `241` and icon resource `iit_smlmisc_241.tga` for the Memoria Configuration item. A mod that uses the same appearance or resource creates only a soft conflict: functionality remains intact, but one of the items may display the wrong icon depending on override load order.

The [original LSE](https://steamcommunity.com/sharedfiles/filedetails/?id=2307769974) is incompatible with Memoria and its mods. Use the [Memoria edition](https://steamcommunity.com/sharedfiles/filedetails/?id=3803404663) instead.

## Installation

Install Memoria, ESI, and then MECONFIG by copying each package's `override` contents into the NWN user `override` directory. The configuration item is added to each player's inventory automatically.

## Localization

English, Russian, French, German, Italian, and Spanish are included. Other languages fall back to English.

## Mod integration

Configuration metadata lives in the optional `configuration` section of a package's `resources/*_memoria.json` manifest. The build emits this manifest as a `.txt` resource for NWN.

### Registration

A shared schema-1 manifest has package-wide `id`, `name`, `version`, and `dependencies` fields. Memoria validates these once; the heartbeat dispatcher and Configuration Manager consume the same filtered package list. These fields are generated from the mod project's properties and `NwnRequiredPackage` metadata:

```json
{
  "schema": 1,
  "id": "mymod_PACKAGE",
  "name": "Package Name",
  "version": "1.4.0",
  "dependencies": [
    { "id": "MEMORIA", "versions": "[1.5.0,2.0.0)" },
    { "id": "esi", "versions": "[2.2.1,3.0.0)" },
    { "id": "MECONFIG", "versions": "[1.3.4,2.0.0)" }
  ],
  "bootstrapper": {
    "heartbeat": "mymod_hb",
    "priority": 200
  },
  "configuration": {
    "name": "Package Name",
    "name_key": "mod_display_name",
    "localization": { "prefix": "mymod" },
    "apply": "mymod_apply",
    "diagnostic": "mymod_diag",
    "options": [
      { "type": "bool", "scope": "player", "local": "MYMOD_ENABLED", "label": "Enabled", "label_key": "enabled_label" },
      { "type": "choice", "scope": "player", "local": "MYMOD_MODE", "label": "Mode", "choices": [{ "value": 0, "label": "Nearest" }, { "value": 1, "label": "Hardest" }] },
      { "type": "action", "label": "Open editor", "script": "MYMOD_open" }
    ]
  }
}
```

`scope` is `player` or `module`. Numbers require inclusive `minimum` and `maximum`. Choices store an integer from `choices`. An option may name a boolean `local` in `enabled_by` to become disabled while it is off. A `separator` displays an optional localized `label`. A boolean may provide `enable_warning` and `enable_warning_key`, shown as a red confirmation before it is enabled. Actions may set `width`; consecutive booleans with `"layout": "inline"` share a row and may set cell `width`, `heading`, and `heading_key`. `apply` runs after saving; `diagnostic` runs when the item targets an object. Localization keys reference the mod's `<prefix>_loc_<language>.txt`, with plain text as fallback.

Memoria discovers `*_memoria.txt` resources once per loaded game or module. A missing subsystem section is valid and is ignored by the consumer that does not use it.

Package `id` values must be unique. Duplicate IDs disable that identity rather than selecting an arbitrary copy.

### Minimal configurable mod

This example adds player boolean and integer settings, a module float setting, an action button, and localized labels using the shared `memoria_loc` loader.

`override/mymod_memoria.txt`:

```json
{
  "schema": 1,
  "id": "mymod_TINY",
  "configuration": {
    "name": "Tiny Config Example",
    "name_key": "mod_display_name",
    "localization": { "prefix": "mymod_cfg" },
    "apply": "mymod_cfg_apply",
    "options": [
      { "type": "bool", "scope": "player", "local": "mymod_TINY_CFG_ENABLED", "label": "Enabled", "label_key": "enabled_label" },
      { "type": "int", "scope": "player", "local": "mymod_TINY_CFG_LEVEL", "label": "Debug level", "label_key": "debug_level_label", "minimum": 0, "maximum": 10 },
      { "type": "float", "scope": "module", "local": "mymod_TINY_CFG_DELAY", "label": "Delay", "label_key": "delay_label", "minimum": 0.0, "maximum": 5.0 },
      { "type": "action", "label": "Test settings", "label_key": "test_settings_label", "script": "mymod_cfg_ping" }
    ]
  }
}
```

`override/mymod_cfg_loc_en.txt`:

```json
{
  "mod_display_name": "Tiny Config Example",
  "enabled_label": "Enabled",
  "debug_level_label": "Debug level",
  "delay_label": "Delay",
  "test_settings_label": "Test settings"
}
```

`mymod_cfg_apply.nss`, compiled as `override/mymod_cfg_apply.ncs`:

```c
void main()
{
    string sEnabled = GetLocalInt(OBJECT_SELF, "MYMOD_TINY_CFG_ENABLED") ? "on" : "off";
    int nLevel = GetLocalInt(OBJECT_SELF, "MYMOD_TINY_CFG_LEVEL");
    float fDelay = GetLocalFloat(GetModule(), "MYMOD_TINY_CFG_DELAY");
    SendMessageToPC(OBJECT_SELF, "[MYMOD_TINY_CFG] saved: " + sEnabled + ", level " + IntToString(nLevel) + ", delay " + FloatToString(fDelay, 0, 1) + ".");
}
```

The finished mod contains one shared registration manifest:

```text
override/
|-- mymod_memoria.txt
|-- mymod_cfg_apply.ncs
|-- mymod_cfg_ping.ncs
`-- mymod_cfg_loc_en.txt
```

`MYMOD` stands for the mod author's own unique prefix. Config stores each value directly in the declared local variable. UTF-8 `<prefix>_loc_<language>.resjson` sources are validated and converted to game-local `<prefix>_loc_<language>.txt` resources during the build, then cached once per module load. Languages without their own table fall back to `<prefix>_loc_en.txt`, and missing keys fall back to the manifest's plain text.
