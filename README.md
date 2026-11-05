# ForeverLoot

A lightweight dungeon and raid loot browser made specifically for **World of Warcraft: Forever**.

ForeverLoot is meant to do the useful part of AtlasLoot without turning into a giant always-open database addon. It opens when you want it, stays out of the way when you don't, and exposes a small API that other Forever addons can use.

## Current build: 0.2.2

### Features

- `/fl` opens or closes the browser.
- Browse **Forever dungeons -> bosses -> loot**.
- Separate Dungeon / Raid / All filters.
- Hover items for the normal WoW tooltip.
- Shift-click an item to link it in chat.
- Compact window; nothing stays on screen by default.
- Uses published Forever reference tables for 12 Hall of Thanes, 18 Ruins of Lordaeron, 9 Excavation Site, and 24 City of Dalaran equipment drops (63 reference items total), with boss attribution and item IDs.
- Automatically learns equippable uncommon-or-better drops from actual dungeon loot and saves observed results account-wide, including in dungeons missing reference tables.
- Groups newly observed drops under their boss when identifiable, or under "Observed drops (boss unknown)" rather than inventing a source.
- Reference loot is flagged as provisional; only drops actually seen are marked observed. The browser shows an explicit source label for each item so reference drops cannot masquerade as observed drops.
- Reads live Encounter Journal data if the client exposes it, but no longer depends on a Journal existing.
- Whitelists Forever content so unrelated modern-client instances are ignored.
- Public API for **ForeverDungeon** and future Forever addons.

### Commands

- `/fl`
- `/fl scan`
- `/fl learned` — number of item drops saved from live play
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

ForeverLoot does **not** depend on AtlasLoot or a working Encounter Journal. It ships a growing sourced boss-and-item fallback catalog. Hall of Thanes, Ruins of Lordaeron, Excavation Site, and City of Dalaran loot is backed by 2026 client item IDs and independent third-party boss guides, not guaranteed live drop tables. Unknown dungeons gain a usable list as loot is observed. Until a dungeon is comprehensively documented, a missing item does **not** mean it cannot drop.

Automated loot learning and the Forever-specific dungeon reference tables still need live-client verification. The current client may block parts of the loot or item APIs; the addon preserves existing saved records and does not pretend missing data proves no upgrades.

## Installation

Place the `ForeverLoot` folder in the WoW: Forever `Interface/AddOns` folder, or install the GitHub repository through WoWUp once releases are configured.

## License

MIT
