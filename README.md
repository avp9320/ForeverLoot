# ForeverLoot

A lightweight dungeon and raid loot browser made specifically for **World of Warcraft: Forever**.

ForeverLoot is meant to do the useful part of AtlasLoot without turning into a giant always-open database addon. It opens when you want it, stays out of the way when you don't, and exposes a small API that other Forever addons can use.

## Current build: 0.1.0

### Features

- `/fl` opens or closes the browser.
- Browse **Forever dungeons -> bosses -> loot**.
- Separate Dungeon / Raid / All filters.
- Hover items for the normal WoW tooltip.
- Shift-click an item to link it in chat.
- Compact window; nothing stays on screen by default.
- Reads loot from Forever's own Encounter Journal data at runtime.
- Whitelists Forever content so unrelated modern-client instances are ignored.
- Public API for **ForeverDungeon** and future Forever addons.

### Commands

- `/fl`
- `/fl scan`
- `/fl status`
- `/fl api`
- `/foreverloot`

## ForeverDungeon integration

```lua
local instance, loot = ForeverLoot:GetLootForMapID(instanceMapID)
```

Other useful calls:

```lua
ForeverLoot:GetInstances()
ForeverLoot:GetInstanceByMapID(mapID)
ForeverLoot:GetEncounters(instance)
ForeverLoot:GetInstanceLoot(instance, encounterID)
ForeverLoot:GetAPI()
```

`ForeverLoot.API_VERSION` is currently `1`.

## Data philosophy

ForeverLoot does **not** copy AtlasLoot's full database. It reads Forever's Encounter Journal loot data at runtime and keeps only a small content whitelist/fallback layer.

Because Forever does not launch until November 4, 2026, version 0.1.0 is a pre-launch build and needs live-client testing. The addon includes `/fl scan` and graceful API checks specifically for that first test.

## Installation

Place the `ForeverLoot` folder in the WoW: Forever `Interface/AddOns` folder, or install the GitHub repository through WoWUp once releases are configured.

## License

MIT
