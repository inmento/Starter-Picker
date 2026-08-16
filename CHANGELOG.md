# Changelog

## 1.0.5 — Current Randomizer Rival Compatibility

Starter Picker now reads the current `pokemon_randomizer` save namespace rather than obsolete Gen 1 compatibility fields. When the Randomizer’s saved Gen 1 starter mode is active, rival parties resolve from the Randomizer’s saved physical starter-slot mapping while preserving Starter Picker’s selected species and intended counter-pick relationship.

The Gen 1 rival projection runs after the Randomizer’s trainer-party projection and copies the party without altering rival DVs, moves, levels, or held-item data. Gold behavior is unchanged in this release.
