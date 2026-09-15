# Memoria Configuration Manager

MEMORIA_CONFIG provides one persistent configuration item and a NUI menu for installed Memoria mods. Configuration metadata lives in the optional `configuration` section of each package's `resources/memoria_*.json` manifest; the build emits that single manifest as a `.txt` resource for NWN.

## Registration

A shared manifest has package-wide `schema` and `id` fields. Bootstrapper and Configuration Manager independently read their own optional sections:

```json
{
  "schema": 1,
  "id": "ACME_PACKAGE",
  "bootstrapper": {
    "heartbeat": "acme_hb",
    "priority": 200
  },
  "configuration": {
    "name": "Package Name",
    "name_key": "mod_display_name",
    "localization": { "prefix": "acme" },
    "apply": "acme_apply",
    "diagnostic": "acme_diag",
    "options": [
      { "type": "bool", "scope": "player", "local": "ACME_ENABLED", "label": "Enabled", "label_key": "enabled_label" },
      { "type": "action", "label": "Open editor", "script": "acme_open" }
    ]
  }
}
```

`scope` is `player` or `module`; `int` and `float` options must also declare inclusive `minimum` and `maximum` values. `apply` runs after settings are saved, and `diagnostic` runs when the shared item targets an object. `localization`, `name_key`, and `label_key` are optional; when present, `name_key` and `label_key` name keys in the mod's own `<prefix>_loc_<language>.txt` table, falling back to the manifest's plain `name` or `label` text when the key or table is missing.

Both consumers discover `memoria_*.txt` resources once per loaded game or module and cache only their own extracted data. A missing section is valid and is ignored by the consumer that does not use it.

## Minimal configurable mod

This example adds player boolean and integer settings, a module float setting, an action button, and localized labels using the shared `memoria_i18n` loader.

`resources/memoria_acme.json`:

```json
{
  "schema": 1,
  "id": "ACME_TINY",
  "configuration": {
    "name": "Tiny Config Example",
    "name_key": "mod_display_name",
    "localization": { "prefix": "acme_cfg" },
    "apply": "acme_cfg_apply",
    "options": [
      { "type": "bool", "scope": "player", "local": "ACME_TINY_CFG_ENABLED", "label": "Enabled", "label_key": "enabled_label" },
      { "type": "int", "scope": "player", "local": "ACME_TINY_CFG_LEVEL", "label": "Debug level", "label_key": "debug_level_label", "minimum": 0, "maximum": 10 },
      { "type": "float", "scope": "module", "local": "ACME_TINY_CFG_DELAY", "label": "Delay", "label_key": "delay_label", "minimum": 0.0, "maximum": 5.0 },
      { "type": "action", "label": "Test settings", "label_key": "test_settings_label", "script": "acme_cfg_ping" }
    ]
  }
}
```

`resources/acme_cfg_loc_en.resjson`:

```json
{
  "mod_display_name": "Tiny Config Example",
  "enabled_label": "Enabled",
  "debug_level_label": "Debug level",
  "delay_label": "Delay",
  "test_settings_label": "Test settings"
}
```

`acme_cfg_apply.nss`, compiled as `override/acme_cfg_apply.ncs`:

```c
void main()
{
    string sEnabled = GetLocalInt(OBJECT_SELF, "ACME_TINY_CFG_ENABLED") ? "on" : "off";
    int nLevel = GetLocalInt(OBJECT_SELF, "ACME_TINY_CFG_LEVEL");
    float fDelay = GetLocalFloat(GetModule(), "ACME_TINY_CFG_DELAY");
    SendMessageToPC(OBJECT_SELF, "[ACME_TINY_CFG] saved: " + sEnabled + ", level " + IntToString(nLevel) + ", delay " + FloatToString(fDelay, 0, 1) + ".");
}
```

The finished mod contains one shared registration manifest:

```text
override/
|-- memoria_acme.txt
|-- acme_cfg_apply.ncs
|-- acme_cfg_ping.ncs
`-- acme_cfg_loc_en.txt
```

`ACME` stands for the mod author's own unique prefix. Config stores each value directly in the declared local variable. UTF-8 `<prefix>_loc_<language>.resjson` sources are validated and converted to game-local `<prefix>_loc_<language>.txt` resources during the build, then cached once per module load. Languages without their own table fall back to `<prefix>_loc_en.txt`, and missing keys fall back to the manifest's plain text.

## Installation

Install MEBOOTSTRAPPER, ESI, Framework, and MEMORIA_CONFIG before any Memoria mod that declares them as dependencies. The manager automatically grants the configuration item to each player.
