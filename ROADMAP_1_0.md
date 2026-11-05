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
