# Shared package manifests

Each runtime package owns one `resources/memoria_<package>.json` source, emitted as a `memoria_<package>.txt` NWN resource. The root `schema` and `id` identify the package; independent consumers own optional sibling sections. MEBOOTSTRAPPER reads `bootstrapper`, while MEMORIA_CONFIG reads `configuration`. A missing section means that the package does not participate in that subsystem.

Keeping discovery metadata in one resource avoids competing filename prefixes and duplicate package identity. Consumers scan and cache the same manifest set independently, retain only the data in their own section, and report and ignore later manifests with duplicate package IDs. The implementations are [memoria_boot.nss](../Mods/Bootstrapper/source/memoria_boot.nss) and [memoria_config.nss](../Mods/Configuration/source/memoria_config.nss).
