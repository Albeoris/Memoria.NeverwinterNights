# Documentation registry

Short, single-topic docs for architecture decisions and conventions that aren't obvious from the code alone. Add one short `.md` file per topic here and list it below; keep entries to a couple of paragraphs plus a pointer to the real source.

| Doc | Topic |
| --- | --- |
| [EventScriptInjection.md](EventScriptInjection.md) | Persistent event trampolines, transient ESI hook registrations, and saved-game migration. |
| [localization.md](localization.md) | Shared per-mod localization table loader (`memoria_i18n.nss`): resource naming, key naming, and caching. |
| [PackageManifests.md](PackageManifests.md) | Shared `*_memoria.txt` package envelope and subsystem-owned sections. |
