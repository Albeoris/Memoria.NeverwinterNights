# AI Agent Guide

## Scope and working tree

- The active repository is `C:\Git\Memoria.NeverwinterNights`.
- `W:\Work\NWNMods` is the pre-migration backup and reference workspace. Do not modify or rebuild into it unless the user explicitly asks.
- Use Windows PowerShell and the .NET SDK selected by `global.json`.
- Preserve unrelated user changes. Generated files are disposable; source files are not.

## Repository layout

- `Mods/<Project>` contains one independently publishable mod, its matching SDK-independent `<Project>.proj`, `README.md`, optional `CHANGELOG.md`, `source`, and `resources`.
- `Tools/Toolset` contains the C# build, validation, layout-emulation, and publishing application.
- `Tools/NeverwinterNim`, `Tools/NwnIncludes`, and `Tools/NwnRoot` are vendored build dependencies. `Tools/NwnRoot/bin` is part of the minimal compiler resource tree, not generated output.
- `Build/NwnModProject.targets` is a checked-in MSBuild definition. The `Build` directory must not contain `bin`, `obj`, manifests, or other generated files.
- Every generated or temporary file must be placed under the ignored `artifacts` directory. This includes MSBuild `bin`/`obj`, evaluated project inputs, compiled mods, layout previews, and release packages.

## Package architecture

Runtime loading order is:

1. MEBOOTSTRAPPER
2. ESI
3. MELSE, MECALM, and METACT

MEBOOTSTRAPPER is the only package allowed to provide `default.ncs`. It discovers the installed `memoria_*.txt` registrations and dispatches heartbeats by priority. ESI must always run before consumers of injected events.

Framework is a compile-time NWScript dependency shared by MECALM and METACT. It is independently packaged for source distribution but does not own a runtime heartbeat.

Memoria-owned mod identifiers use `ME<PACKAGE>_`; corresponding NWN resource files use lowercase `me<package>_` names and must respect NWN resref length limits. Framework and Bootstrapper registration manifests instead use `MEMORIA_*` identifiers and `memoria_*` resources. ESI is the explicit compatibility exception: preserve its original `ESI_*`, `esi_*`, and `rav_*` names and behavior. The Memoria-owned ESI registration wrapper remains separate as `meesi_hb` and `memoria_esi`.

## Project inputs

The mod project is the source of truth. Never add checked-in build or publish manifests and never enumerate individual source/resource files in a project.

Use wildcard project items:

- `NwnSource` for `source/**/*.nss`.
- `NwnResource` for files copied or converted into the override package.
- `NwnLayout` for NUI layout-emulator inputs.
- `NwnPackageFile` for source files intentionally shipped as package content, such as Framework includes.
- `NwnIncludeDirectory` only for cross-project NWScript include directories.
- `PackageDocument` and `NwnRequiredPackage` items for publishing metadata. Each `NwnRequiredPackage` points to an existing mod project and supplies its published name through `PackageName` metadata.
- Steam Workshop metadata belongs in a separate `PropertyGroup` labeled `Steam Workshop`. `WorkshopTags` is a semicolon-separated property rather than an item because tags are labels, not file dependencies.

MSBuild evaluates these items into `artifacts/inputs/<Mod>.inputs`. Toolset automatically:

- compiles `.nss` files containing `void main()` or `int StartingConditional()`;
- treats other `.nss` files as includes;
- converts resources named like `*.uti.json` from JSON to their three-letter GFF type;
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

Confirm that every package contains its README, MELSE/MECALM/METACT contain their changelogs, no package contains obsolete RTF documentation, and only MEBOOTSTRAPPER contains `override/default.ncs`.

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
