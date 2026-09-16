# Looting System Enhanced - Memoria Edition

MELSE automates looting and adds configurable lootable corpses, container handling, treasure notifications, and item filters.

## Features

- Automatic looting from defeated creatures and containers.
- Configurable item value and weight limits.
- Lootable corpses with configurable decay time.
- Treasure notifications and container tracking.
- Item descriptions with acquisition details.
- Event hooks are restored from the transient ESI registry on the first heartbeat of each loaded game, and each area's static objects are registered once per runtime session.

## Installation

Remove any legacy LSE installation, then install Memoria, ESI, MEMORIA_CONFIG, and MELSE by copying each package's `override` contents into the NWN user `override` directory.

Open **Memoria Configuration** from the inventory and select Looting System Enhanced to change its options.

## Compatibility

Do not combine MELSE with legacy LSE. Logical conflicts are possible with other mods that automate looting, preserve corpses, or change container behavior.

## Credits

Original LSE design, scripts, and documentation are by Ravick. See [CHANGELOG.md](CHANGELOG.md) for the original release history and the repository's third-party notices for licensing details.

- [Ravick on Steam](https://steamcommunity.com/profiles/76561198044092406/)
- [Ravick on Neverwinter Vault](https://forum.neverwintervault.org/u/Ravick/summary)
- [Ravick on Nexus Mods](https://www.nexusmods.com/users/3628084)
