# Memoria Configuration Manager

MEMORIA_CONFIG provides one persistent configuration item and a NUI menu for installed Memoria mods. Mods register their configuration fields and actions through `mconfig_*.txt` resources.

## Registration

Each participating package supplies one resource whose name starts with `mconfig_`:

```json
{
	"schema": 1,
	"id": "ACME_PACKAGE",
	"name": "Package Name",
	"name_key": 1,
	"localization": { "prefix": "acme_txt_", "parameter": "ACME_TEXT_KEY", "result": "ACME_TEXT_RESULT" },
	"apply": "acme_apply",
	"diagnostic": "acme_diag",
	"options": [
		{ "type": "bool", "scope": "player", "local": "ACME_ENABLED", "label": "Enabled", "label_key": 2 },
		{ "type": "action", "label": "Open editor", "script": "acme_open" }
	]
}
```

`scope` is `player` or `module`; `int` and `float` options must also declare inclusive `minimum` and `maximum` values. `apply` runs after settings are saved, and `diagnostic` runs when the shared item targets an object. `localization`, `name_key`, and `label_key` are optional; the manager executes `<prefix><language>` with the declared script parameter and result local, falling back to `<prefix>en` and then the manifest text.

Registration resources are discovered once per loaded game or module. The cached manifests are discarded automatically after loading a game or entering another module.

## Minimal configurable mod

This example adds player boolean and integer settings, a module float setting, an action button, and English/Russian labels.

`override/mconfig_acme.txt`:

```json
{
    "schema": 1,
    "id": "ACME_TINY_CFG",
    "name": "Tiny Config Example",
    "name_key": 1,
    "localization": { "prefix": "acme_cfg_txt_", "parameter": "ACME_CFG_TEXT_KEY", "result": "ACME_CFG_TEXT_RESULT" },
    "apply": "acme_cfg_apply",
    "options": [
        { "type": "bool", "scope": "player", "local": "ACME_TINY_CFG_ENABLED", "label": "Enabled", "label_key": 2 },
        { "type": "int", "scope": "player", "local": "ACME_TINY_CFG_LEVEL", "label": "Debug level", "label_key": 3, "minimum": 0, "maximum": 10 },
        { "type": "float", "scope": "module", "local": "ACME_TINY_CFG_DELAY", "label": "Delay", "label_key": 4, "minimum": 0.0, "maximum": 5.0 },
        { "type": "action", "label": "Test settings", "label_key": 5, "script": "acme_cfg_ping" }
    ]
}
```

`acme_cfg_txt_en.nss`, compiled as `override/acme_cfg_txt_en.ncs`:

```c
void main()
{
    int nKey = StringToInt(GetScriptParam("ACME_CFG_TEXT_KEY"));
    string sText = nKey == 1 ? "Tiny Config Example" : nKey == 2 ? "Enabled" : nKey == 3 ? "Debug level" : nKey == 4 ? "Delay" : nKey == 5 ? "Test settings" : "";
    SetLocalString(OBJECT_SELF, "ACME_CFG_TEXT_RESULT", sText);
}
```

`acme_cfg_txt_ru.nss`, compiled as `override/acme_cfg_txt_ru.ncs`:

```c
void main()
{
    int nKey = StringToInt(GetScriptParam("ACME_CFG_TEXT_KEY"));
    string sText = nKey == 1 ? "Пример настроек" : nKey == 2 ? "Включено" : nKey == 3 ? "Уровень отладки" : nKey == 4 ? "Задержка" : nKey == 5 ? "Проверить настройки" : "";
    SetLocalString(OBJECT_SELF, "ACME_CFG_TEXT_RESULT", sText);
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
├── acme_cfg_txt_en.ncs
└── acme_cfg_txt_ru.ncs
```

`ACME` stands for the mod author's own unique prefix; `mconfig_` is required only for Config discovery. Config stores each value directly in the declared local variable. Languages without `acme_cfg_txt_<language>.ncs` automatically use `acme_cfg_txt_en.ncs`; if that is also absent, the manifest labels are used.

## Installation

Install M_BOOTSTRAPPER, ESI, and MEMORIA_CONFIG before any Memoria mod that declares it as a dependency. The manager automatically grants the configuration item to each player.
