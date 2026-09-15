# Memoria Mods

This monorepo contains independently versioned Neverwinter Nights: Enhanced Edition override mods and their shared development toolchain.

ATTENTION: The mods are ready but are currently being debugged. I will release them once testing is complete.

## Packages

| Package | Runtime dependency | Purpose |
| --- | --- | --- |
| MEBOOTSTRAPPER | None | Owns `default.ncs`, caches discovered module manifests for the current session and module, and dispatches player heartbeats in priority order. |
| ESI | MEBOOTSTRAPPER | Event Script Injector with its original `ESI_*`, `esi_*`, and `rav_*` compatibility surface. Always dispatched first. |
| MEMORIA_CONFIG | MEBOOTSTRAPPER, ESI | Shared inventory tool and NUI Mod Configuration Manager. It caches discovered `mconfig_*.txt` registrations for the loaded game or module. |
| MELSE | MEBOOTSTRAPPER, ESI, MEMORIA_CONFIG | Memoria edition of Looting System Enhanced, namespaced as `MELSE_*` and `melse_*`. |
| MECALM | MEBOOTSTRAPPER, ESI, MEMORIA_CONFIG | Companion Auto-Lock Manager. |
| METACT | MEBOOTSTRAPPER, ESI, MEMORIA_CONFIG | Tactics Architect. |
| Memoria Framework | Compile-time only | Shared `MEMORIA_*` and `memoria_*` NWScript helpers used by MECALM and METACT. |
| Toolset | .NET 10 | Builds, validates, and packages all projects. |

Memoria-owned mod identifiers and resources use package-specific `ME<PACKAGE>_` and `me<package>_` prefixes. Framework uses `MEMORIA_*` and `memoria_*`; ESI retains its original compatibility names.

## Repository layout

Each directory under `Mods` is a self-contained project with its project file, `README.md`, sources, and resources. Shared build definitions live in `Build`, the Toolset and vendored build dependencies live in `Tools`, and generated files go to the ignored `artifacts` directory.

## Build

Requirements: Windows and the .NET 10 SDK. A local NWN installation is not required.

```powershell
dotnet build Memoria.NeverwinterNights.slnx -c Release
```

The build compiles every entry-point script, converts UTI resources, verifies generated NCS files, and runs every MEMORIA_CONFIG and METACT NUI layout through the layout emulator.

Mod projects use wildcard items for `source`, `resources`, documentation, and layouts. MSBuild writes the evaluated inputs to `artifacts/inputs`; there are no hand-maintained file manifests. NWScript sources remain UTF-8 in the repository. The Toolset detects executable entry points, converts a temporary compiler copy to Windows-1251 when Cyrillic is present or Windows-1252 otherwise, and leaves the source unchanged.

Build or publish one package independently:

```powershell
dotnet build Mods/TacticsArchitect/TacticsArchitect.proj -c Release
dotnet msbuild Mods/TacticsArchitect/TacticsArchitect.proj -restore -t:Publish -p:Configuration=Release -p:Version=0.7.0
```

Publish output contains a Workshop-ready directory and a Nexus-ready ZIP under `artifacts/publish`.

For local testing, enable the common-output mode on either build or publish. It merges every package's flat override output into `artifacts/common_output` and fails if two packages produce the same resource:

```powershell
dotnet build Memoria.NeverwinterNights.slnx -c Release -p:CommonOutput=true
dotnet msbuild Memoria.NeverwinterNights.slnx -restore -t:Publish -p:Configuration=Release -p:Version=0.0.0-test -p:CommonOutput=true -m:1
```

## Releases

Push a tag in the form `<package>-v<version>`, for example `metact-v0.7.0` or `mebootstrapper-v1.0.0`. ESI retains `esi-v<version>`. GitHub Actions builds and publishes only that package, uploads the existing Steam Workshop item, and creates the GitHub release.

### Steam Workshop setup

Before the first tagged release:

1. Set `WorkshopPublishedFileId` in the mod project's `Steam Workshop` property group to the public ID of the existing Workshop item. The pipeline deliberately refuses `0` or an empty value so it cannot create duplicate items.
2. Replace `workshop/description.txt`, `workshop/changenote.txt`, and `workshop/preview.png` in that mod. The preview must be a PNG, JPG, or GIF smaller than 1 MB.
3. Add the `STEAM_USERNAME`, `STEAM_PASSWORD`, and base64-encoded mobile-authenticator `STEAM_SHARED_SECRET` Actions secrets. Use the Steam account that owns the Workshop items, preferably a dedicated publishing account.

The project display name supplies the Workshop title. `WorkshopVisibility` defaults to `0` (public); the other accepted values are `1` (friends-only), `2` (private), and `3` (unlisted). SteamCMD's `workshop_build_item` supports title, description, visibility, content, primary preview, and change note updates.

`WorkshopTags` is a semicolon-separated property and currently records the intended Workshop categories in the generated package's `tags.txt`. SteamCMD does not apply Workshop tags, so select the matching category on the Workshop page manually. All current packages use NWN:EE's `override` category.

The workflow downloads Valve's Windows SteamCMD bootstrap, verifies its Authenticode signature before execution, and caches only a self-updated, unauthenticated copy. The cached executable's Valve signature is checked again on every run. Authentication runs in a separate disposable copy that is deleted after the upload; credentials, Steam Guard state, and session files never enter Actions Cache.

## Licensing

Albeoris-authored work is MIT licensed. ESI, MELSE, game-derived scripts, and vendored tools retain their original authorship notices; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
