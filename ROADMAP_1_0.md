# v1.0 acceptance checklist

This is a release gate, not a claim of implementation. README claims and static code inspection do not substitute for live-client evidence. Check a box only after its behavior is verified; record test date/client and evidence in this file.

- [x] Phase 1: Global browser filter can locate instances by boss names, item names, gear properties, and item IDs, not just instance names (UI.lua; code inspection only, live testing pending).
- [ ] Expand sourced boss and item coverage beyond provisional 63 reference items
- [ ] Live-test automatic observed-drop learning, attribution and account-wide persistence
- [ ] Verify Journal fallback and public API consumers
- [ ] Audit reference versus observed versus unknown coverage displays
- [ ] Verify release packaging and SavedVariables migration

## Evidence

- Code review: 2026-11-05 — added global boss/item discovery to the browser filter; commit ca0b5c2e. It searches existing reference, journal, and learned catalogs, not undiscovered drops. No client verification claimed.
- Automated/static tests: pending
- Live WoW: Forever client verification: pending
- Release ZIP and WoWUp installation: pending

## Status

Pre-1.0. Features described in README may be implemented but are not accepted as verified here until tested. Avoid declaring v1.0 solely on version metadata.

## Phase 1 — observed-loot ownership (2026-11-05)

- [x] `Learning.lua` `isOwnLoot` filters `CHAT_MSG_LOOT` through localized Blizzard self-loot and pushed-self-loot templates before learning an item (commit `326c9c4`). Group members' loot no longer creates false account-wide observations. Unknown formats are ignored instead of assumed personal. SavedVariables schema unchanged.
- [ ] Verify solo and party loot, self-loot stack counts, pushed quest rewards, localized formats, secret message values, and observed-drop persistence in the live Forever client. Static code inspection only; no Lua harness or live-client test.

## Phase 1 — shared-drop boss attribution (2026-11-05)

- [x] `Learning.lua` now deduplicates reference sources by boss ID instead of assigning a shared drop to the first boss encountered in unordered `pairs()` iteration. A unique reference source is attributed directly; a shared source requires a recent successful encounter that matches a documented source; otherwise it remains in the unknown-boss bucket (commit `7776325`). Unreferenced drops retain the existing recent-encounter inference. No SavedVariables migration.
- [ ] Static Lua parsing/regression and live-client verification pending: shared reference drop after each eligible boss, unrelated recent boss, no recent encounter, and a uniquely sourced drop. This is code implementation, not verified client behavior.
