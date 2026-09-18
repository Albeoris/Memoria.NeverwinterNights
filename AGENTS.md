# AI Agent Guide

## Scope and working tree

- The active repository is `C:\Git\Memoria.NeverwinterNights`.
- `W:\Work\NWNMods` is the pre-migration backup and reference workspace. Do not modify or rebuild into it unless the user explicitly asks.
- Use Windows PowerShell and the .NET SDK selected by `global.json`.
- Preserve unrelated user changes. Generated files are disposable; source files are not.

## Public package versioning

Every mod project's `Version` tracks its public package API, not its user-facing feature set or internal behavior. Public APIs include shipped or dependency-consumed `.nss` functions and public identifiers, resource contracts, and manifest schemas. Update a changed package's `Version` in the same change according to SemVer:

- Increment PATCH for packaged runtime changes that preserve the public API. This includes implementation fixes, changed defaults, and added or changed user-configurable options when existing consumers and installation contracts remain compatible.
- Increment MINOR and reset PATCH to zero for a backward-compatible public API addition, such as a new public function, a new optional parameter whose default preserves existing calls and behavior, or an optional manifest capability.
- Increment MAJOR and reset MINOR and PATCH to zero only for an incompatible public API change: removing or renaming a public function; changing required parameters, parameter types/order, return type, established function behavior, or side effects; or changing public identifiers, resource contracts, or manifest schema incompatibly. Do not increment MAJOR solely because runtime behavior, defaults, or user-configurable options changed.

After a MAJOR increment, update every dependent project's `Versions` range so the build accepts the new version only when that dependency has been reviewed for compatibility.

Every change within `Mods/<Project>` must increment that project's `Version` by at least PATCH so the change receives a new release tag and is delivered to Steam Workshop. This includes documentation, tests, private implementation changes, and package metadata. A required MINOR or MAJOR increment already satisfies this rule; do not increment the version a second time merely because several kinds of changes are included in the same unreleased working-tree change.

## Repository layout

- `Mods/<Project>` contains one independently publishable mod, its matching SDK-independent `<Project>.proj`, `README.md`, `source`, and `resources`.
- `Tools/Toolset` contains the C# build, validation, layout-emulation, and publishing application.
- `Tools/NeverwinterNim`, `Tools/NwnIncludes`, and `Tools/NwnRoot` are vendored build dependencies. `Tools/NwnRoot/bin` is part of the minimal compiler resource tree, not generated output.
- `Docs/` holds short, single-topic write-ups for architecture decisions that aren't obvious from the code alone (e.g. shared subsystems, caching strategies). Start from `Docs/README.md`, which is the registry/index of these files. Add a new short doc there whenever you introduce a similar shared subsystem.
- `Build/NwnModProject.targets` is a checked-in MSBuild definition. The `Build` directory must not contain `bin`, `obj`, manifests, or other generated files.
- Every generated or temporary file must be placed under the ignored `artifacts` directory. This includes MSBuild `bin`/`obj`, evaluated project inputs, compiled mods, layout previews, and release packages.
- `artifacts/api-cache` contains immutable downloaded NWScript API snapshots and must survive normal clean operations.

## Package architecture

Runtime loading order is:

1. MEMORIA
2. ESI
3. MECONFIG, MEDT, MELSE, MECM, and METACT

MEMORIA combines the bootstrapper and shared Framework. It is the only package allowed to provide `default.ncs`; it validates installed `*_memoria.txt` package versions and dependencies before dispatching compatible heartbeats by priority. ESI must always run before consumers of injected events.

The `memoria_*.nss` helpers are compile-time NWScript dependencies shipped by MEMORIA for source distribution. MEMORIA has no runtime heartbeat of its own beyond initializing other compatible packages.

Memoria-owned mod identifiers use `ME<PACKAGE>_`; corresponding NWN resource files use lowercase `me<package>_` names and must respect NWN resref length limits. Package manifests use the mod-owned `<package>_memoria` resref form. MEMORIA uses `MEMORIA_*` identifiers and `memoria_*` resources; MECONFIG uses `MECONFIG_*` identifiers and `meconfig_*` resources. ESI is the explicit compatibility exception: preserve its original `ESI_*`, `esi_*`, and `rav_*` names and behavior. The Memoria-owned ESI registration wrapper remains separate as `esi_hb` and `esi_memoria`.

## Project inputs

The mod project is the source of truth. Never add checked-in build or publish manifests and never enumerate individual source/resource files in a project.

Use wildcard project items:

- `NwnSource` for `source/**/*.nss`.
- `NwnResource` for files copied or converted into the override package.
- `NwnLayout` for NUI layout-emulator inputs.
- `NwnPackageFile` for source files intentionally shipped as package content, such as MEMORIA includes.
- `NwnRequiredPackage` for cross-project NWScript includes and runtime dependencies. It must declare `ModId`, a NuGet-style `Versions` range with a bounded inclusive minimum, and `PackageName`; dependency sources are compiler inputs only and never enter the dependent package output. Compilation uses the minimum version's immutable API snapshot, or local sources when that minimum equals the dependency project's current version.
- `NwnIncludeDirectory` only for compiler include directories that are not mod-package dependencies.
- `PackageDocument` and `NwnRequiredPackage` items for publishing metadata. Each `NwnRequiredPackage` points to an existing mod project and supplies its published name through `PackageName` metadata.
- Steam Workshop metadata belongs in a separate `PropertyGroup` labeled `Steam Workshop`. `WorkshopTags` is a semicolon-separated property rather than an item because tags are labels, not file dependencies.

MSBuild evaluates these items into `artifacts/inputs/<Mod>.inputs`. Toolset automatically:

- compiles `.nss` files containing `void main()` or `int StartingConditional()`;
- treats other `.nss` files as includes;
- converts resources named like `*.uti.json` from JSON to their three-letter GFF type;
- validates plain `.json` resources as non-localized English ASCII and emits them as `.txt` resources;
- copies ordinary resources into the flat NWN override output;
- validates every `NwnLayout` with the NUI layout emulator;
- rejects duplicate output resrefs.

Adding a file beneath an existing wildcard must be sufficient for it to participate in the next build. If a new resource category is needed, extend the generic project-item/Toolset behavior instead of creating per-file lists.

## Text encoding

- Keep all checked-in NWScript source files in UTF-8.
- Do not convert source files in place to legacy code pages.
- Toolset reads UTF-8, creates a temporary compiler copy, selects Windows-1251 when Cyrillic is present and Windows-1252 otherwise, and passes that encoding to the NWScript compiler.
- Non-localized repository and tooling text must be English. Player-facing localized text belongs in the localization scripts/resources.

## Required validation

After changing build logic or more than one mod, run:

```powershell
dotnet clean Memoria.NeverwinterNights.slnx --configuration Release
dotnet build Memoria.NeverwinterNights.slnx --configuration Release
```

The build must finish with zero warnings and errors, compile and verify every NCS entry point, convert GFF resources, and run every METACT GUI fixture through the layout emulator. GUI changes are not complete without successful emulator validation at all checked-in resolutions/scales.

To validate publishing for all packages, run:

```powershell
dotnet msbuild Memoria.NeverwinterNights.slnx -restore -t:Publish -p:Configuration=Release -p:Version=0.0.0-validation -m:1
```

Confirm that every package contains its README, no package contains obsolete RTF documentation, and only MEMORIA contains `override/default.ncs`.

Build or publish one mod through its project:

```powershell
dotnet build Mods/TacticsArchitect/TacticsArchitect.proj --configuration Release
dotnet msbuild Mods/TacticsArchitect/TacticsArchitect.proj -restore -t:Publish -p:Configuration=Release -p:Version=0.7.0
```

Release tags use `<package>-v<version>`, for example `metact-v0.7.0`. ESI retains the compatibility tag form `esi-v<version>`.

## Licensing and style

- Albeoris-authored work is MIT licensed, Copyright (c) Albeoris.
- Preserve original ESI/MELSE/game-derived copyright and third-party notices when modifying those files.
- Keep method calls and complete argument lists on a single line. Do not wrap code solely because of line length.
- Prefer generalized conventions and wildcard inclusion over duplicated configuration.
