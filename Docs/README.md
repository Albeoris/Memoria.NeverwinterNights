# Documentation registry

Short, single-topic docs for architecture decisions and conventions that aren't obvious from the code alone. Add one short `.md` file per topic here and list it below; keep entries to a couple of paragraphs plus a pointer to the real source.

| Doc | Topic |
| --- | --- |
| [EventScriptInjection.md](EventScriptInjection.md) | Persistent event trampolines, transient ESI hook registrations, and saved-game migration. |
| [localization.md](localization.md) | Shared per-mod localization table loader (`memoria_loc.nss`): resource naming, key naming, and caching. |
| [PackageManifests.md](PackageManifests.md) | Shared `*_memoria.txt` package envelope and subsystem-owned sections. |
| [ApiSnapshots.md](ApiSnapshots.md) | Compile-time validation against each dependency's minimum supported NWScript API. |
| [NuiHelp.md](NuiHelp.md) | Shared right-click contextual help for Memoria-owned NUI windows. |
| [NuiLayouts.md](NuiLayouts.md) | Content insets, conditional groups, and safety margins used by NUI layout validation. |
