# Memoria Mods

[Support development on Patreon](https://www.patreon.com/Albeoris/join)

This monorepo contains independently versioned Neverwinter Nights: Enhanced Edition override mods and their shared development toolchain.

ATTENTION: The mods are ready but are currently being debugged. I will release them once testing is complete.

## Packages

| Package | Runtime dependency | Purpose |
| --- | --- | --- |
| MEMORIA | None | Owns `default.ncs`, shared `memoria_*.nss` helpers, manifest caching, dependency validation, and compatible heartbeat dispatch. |
| ESI | MEMORIA `[1.0.0,2.0.0)` | Event Script Injector with persistent compatible `esi_uni_*` trampolines and a transient runtime hook registry. Always dispatched first. |
| MECONFIG | MEMORIA `[1.0.0,2.0.0)`, ESI `[2.0.0,3.0.0)` | Shared inventory tool and NUI Mod Configuration Manager. It uses Memoria's compatible manifest list. |
| MEDT | MEMORIA `[1.0.0,2.0.0)`, ESI `[2.0.0,3.0.0)`, MECONFIG `[1.0.0,2.0.0)` | Debug Tools for examining and explicitly deleting inventory items and world objects. |
| MELSE | MEMORIA `[1.0.0,2.0.0)`, ESI `[2.0.0,3.0.0)`, MECONFIG `[1.0.0,2.0.0)` | Memoria edition of Looting System Enhanced, namespaced as `MELSE_*` and `melse_*`. |
| MECM | MEMORIA `[1.0.0,2.0.0)`, ESI `[2.0.0,3.0.0)`, MECONFIG `[1.0.0,2.0.0)` | Companion Manager. |
| METACT | MEMORIA `[1.0.0,2.0.0)`, ESI `[2.0.0,3.0.0)`, MECONFIG `[1.0.0,2.0.0)` | Tactics Architect. |
| Toolset | .NET 10 | Builds, validates, and packages all projects. |

Memoria-owned mod identifiers and resources use package-specific `ME<PACKAGE>_` and `me<package>_` prefixes. MEMORIA uses `MEMORIA_*` and `memoria_*`; ESI retains its original compatibility names.

## Repository layout

Each directory under `Mods` is a self-contained project with its project file, `README.md`, sources, and resources. Shared build definitions live in `Build`, the Toolset and vendored build dependencies live in `Tools`, and generated files go to the ignored `artifacts` directory.

## Build

Requirements: Windows and the .NET 10 SDK. A local NWN installation is not required.

```powershell
dotnet build Memoria.NeverwinterNights.slnx -c Release
```

The build compiles every entry-point script, converts UTI and ResJSON resources, verifies generated NCS files, and runs every MECONFIG and METACT NUI layout through the layout emulator.

Mod projects use wildcard items for `source`, `resources`, documentation, and layouts. MSBuild writes the evaluated inputs to `artifacts/inputs`; there are no hand-maintained file manifests. Each package owns one `<package>_memoria.json` manifest. `ModId` is the mod's single identity and `ModDisplayName` is its player-facing name. `NwnRequiredPackage` provides compile-time includes without copying dependency files into the current build or publish output. Its `Versions` range must have a bounded, inclusive minimum; compilation uses that version's immutable [API snapshot](Docs/ApiSnapshots.md), or local sources when the minimum equals the dependency's current version. The dependency metadata is also emitted into the package's schema-2 manifest together with the mod `Version` and display name.

NWScript sources and `.resjson` resources remain UTF-8 in the repository. The Toolset detects executable entry points, converts a temporary compiler copy to Windows-1251 when Cyrillic is present or Windows-1252 otherwise, and leaves the source unchanged. It also validates each `.resjson` file and emits a `.txt` resource in Windows-1251 when Cyrillic is present or Windows-1252 otherwise, matching the game-local encoding expected by `JsonParse`. Plain `.json` resources are validated as non-localized English ASCII and emitted as `.txt`.

Build or publish one package independently:

```powershell
dotnet build Mods/TacticsArchitect/TacticsArchitect.proj -c Release
dotnet msbuild Mods/TacticsArchitect/TacticsArchitect.proj -restore -t:Publish -p:Configuration=Release -p:Version=0.7.0
```

Build logging is minimal by default: each mod reports what is being built, its output directory, failures, and a final summary. Pass `-p:ToolsetVerbosity=verbose` to show compact per-file progress such as `Compiled[X/N]` and `Skipped[X/N]`; non-default NWScript encodings are shown on the affected files.

Publish output contains a Workshop-ready directory and a Nexus-ready ZIP under `artifacts/publish`.

For local testing, enable the common-output mode on either build or publish. It merges every package's flat override output into `artifacts/common_output` and fails if two packages produce the same resource:

```powershell
dotnet build Memoria.NeverwinterNights.slnx -c Release -p:CommonOutput=true
dotnet msbuild Memoria.NeverwinterNights.slnx -restore -t:Publish -p:Configuration=Release -p:Version=0.0.0-test -p:CommonOutput=true -m:1
```

## Releases

Push a tag in the form `<package>-v<X.Y.Z>`, for example `metact-v0.7.0` or `memoria-v1.0.0`. ESI retains `esi-v<X.Y.Z>`. GitHub Actions builds that package once, then updates its existing Steam Workshop item and the single `stable` GitHub Release in parallel. Any publishing failure deletes the pushed package tag so the release can be retried.

The GitHub Release is titled `Stable (YYYY-MM-DD)`. Each mod has one stable technical asset name, while its visible label contains the project `ModDisplayName`, version, and UTC update date. Updating a mod replaces only that mod's archive and the generated all-in-one archive; all other individual archives remain unchanged. The release description lists packages in solution order. The all-in-one archive merges every available package from oldest to newest, using solution order as the tie-breaker, so newer files replace older files.

### Steam Workshop setup

Before the first tagged release:

1. Set `WorkshopPublishedFileId` in the mod project's `Steam Workshop` property group to the public ID of the existing Workshop item. The pipeline deliberately refuses `0` or an empty value so it cannot create duplicate items.
2. Log in once with SteamCMD using the Steam account that owns the Workshop items, encode SteamCMD's authenticated `config/config.vdf` as Base64, and add it as the `STEAM_CONFIG_VDF_BASE64` Actions secret. Refresh this secret when Steam expires the cached session.

The project display name supplies the Workshop title. Publish converts the mod's `README.md` to Steam formatting, excludes its `Installation` section, appends the UTC generation date and a link to the repository copy, and writes the result to the `description` field in `steam-workshop.vdf`. The manifest contains only `appid`, `publishedfileid`, `contentfolder`, `title`, and `description`.

`WorkshopTags` is a semicolon-separated property and currently records the intended Workshop categories in the generated package's `tags.txt`. SteamCMD does not apply Workshop tags, so select the matching category on the Workshop page manually. All current packages use NWN:EE's `override` category.

The workflow downloads Valve's Windows SteamCMD bootstrap, verifies its Authenticode signature before execution, and caches only a self-updated, unauthenticated copy. The cached executable's Valve signature is checked again on every run. The authenticated `config.vdf` is decoded only into a separate disposable runtime copy after the clean SteamCMD cache has been restored or saved. That runtime copy is deleted after the upload, so cached authentication data and session files never enter Actions Cache.

## Licensing

Albeoris-authored work is MIT licensed. ESI, MELSE, game-derived scripts, and vendored tools retain their original authorship notices; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
