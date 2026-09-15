# Memoria Configuration Manager

MEMORIA_CONFIG provides one persistent configuration item and a NUI menu for installed Memoria mods. Mods author their configuration registrations as pretty-printed `resources/mconfig_*.json`; the build emits them as `mconfig_*.txt` resources for NWN.

## Registration

Each participating package supplies one JSON source whose name starts with `mconfig_`:

```json
{
	"schema": 1,
	"id": "ACME_PACKAGE",
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
```

`scope` is `player` or `module`; `int` and `float` options must also declare inclusive `minimum` and `maximum` values. `apply` runs after settings are saved, and `diagnostic` runs when the shared item targets an object. `localization`, `name_key`, and `label_key` are optional; when present, `name_key`/`label_key` name a key in the mod's own `<prefix>_i18n_<language>.txt` table (see [Framework's shared localization loader](../Framework/source/memoria_i18n.nss)), falling back to the manifest's plain `name`/`label` text when the key or table is missing.

Registration resources are discovered once per loaded game or module. The cached manifests are discarded automatically after loading a game or entering another module.

## Minimal configurable mod

This example adds player boolean and integer settings, a module float setting, an action button, and English/Russian labels using the shared `memoria_i18n` loader (see [Framework's README](../Framework/README.md) for the loader itself).

`resources/mconfig_acme.json`:

```json
{
    "schema": 1,
    "id": "ACME_TINY_CFG",
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
```

`resources/acme_cfg_i18n_en.resjson`:

```json
{
    "mod_display_name": "Tiny Config Example",
    "enabled_label": "Enabled",
    "debug_level_label": "Debug level",
    "delay_label": "Delay",
    "test_settings_label": "Test settings"
}
```

`resources/acme_cfg_i18n_ru.resjson`:

```json
{
    "mod_display_name": "Tiny Config Example",
    "enabled_label": "Включено",
    "debug_level_label": "Уровень отладки",
    "delay_label": "Задержка",
    "test_settings_label": "Проверить настройки"
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

`acme_cfg_ping.nss`, compiled as `override/acme_cfg_ping.ncs`:

```c
void main()
{
    SendMessageToPC(OBJECT_SELF, "[ACME_TINY_CFG] action button works.");
}
```

The finished mod contains:

```text
override/
├── mconfig_acme.txt
├── acme_cfg_apply.ncs
├── acme_cfg_ping.ncs
├── acme_cfg_i18n_en.txt
└── acme_cfg_i18n_ru.txt
```

`ACME` stands for the mod author's own unique prefix; `mconfig_` is required only for Config discovery. Config stores each value directly in the declared local variable. UTF-8 `<prefix>_i18n_<language>.resjson` sources are validated and converted to game-local `<prefix>_i18n_<language>.txt` resources during the build (Windows-1251 for Cyrillic, Windows-1252 otherwise), then cached once per module load; languages without their own table automatically fall back to `<prefix>_i18n_en.txt`, and missing keys fall back to the manifest's plain text.

## Installation

Install MEBOOTSTRAPPER, ESI, and MEMORIA_CONFIG before any Memoria mod that declares it as a dependency. The manager automatically grants the configuration item to each player.
