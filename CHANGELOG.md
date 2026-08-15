# Changelog

All notable changes to Starter Picker are documented in this file.

## [0.0.4] - 2026-08-14

### Added

- Explicit interoperability with the authorized **Gen 2 Randomizer** (`gen2_randomizer`). Starter Picker now recognizes only confirmed **LOGIC** and **NO LOGIC** setups as active, while **VANILLA** and unconfirmed setups remain inactive.
- Deterministic final-pass handling for Gold’s Elm’s Lab `givepoke` command and rival-party projection. An active Gen 2 Randomizer can perform its own transform first, then the player’s named Starter Picker selection is applied as the final starter result.
- **RANDOM (WEIGHTED)** for **STARTER HELD ITEM (GOLD)**. The save stores one generated player-starter result: it may be no item, a low-value/inert tossable item, an ordinary useful held item, or a premium held item, with the outcomes weighted toward no/inert results.
- **SHINY PLAYER STARTER**, which applies only to the chosen player starter. It sets Defense, Speed, and Special DVs to 10 and selects Attack from the valid shiny values 2, 3, 6, 7, 10, 11, 14, or 15. It takes precedence over the maximum-DV option and never alters the rival’s DVs or held item.
- Weighted-item safeguards excluding key items, HMs, non-tossable records, invalid records, and added items for an originally itemless native starter command.
- Isolated Gold harness coverage for Gen 2 Randomizer LOGIC/NO LOGIC/VANILLA state detection, final species precedence, valid player-only shiny spreads, weighted-item persistence, no-item outcomes, itemless native gifts, and rival item/DV isolation.

### Changed

- Updated Starter Picker’s internal source header, manifest, README installation filename, and distribution version to **0.0.4**.
- Extended Wes_Kestis credit to cover the authorized Gen 2 Randomizer compatibility review.

### Known limitations

- Gold support, including this v0.0.4 compatibility path, has passed offline syntax and isolated harness validation but remains untested in a player-imported Gold save. Back up a save before testing.

