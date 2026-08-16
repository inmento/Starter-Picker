# Changelog

## 1.0.6 — Randomizer Starter Synchronization (Untested)

Added defensive detection for the supported Gen 1 and Gold randomizer save states. When randomized starters are active, Starter Picker now synchronizes its three starter selectors with the randomizer’s saved assignments where available, and observes the final transformed starter gift when a Gold randomizer does not expose a three-slot mapping.

Reworked the rival starter projection using Starter Picker’s own logic. The rival now prefers a starter that is super-effective against the player’s final choice; when no direct weakness exists, it avoids candidates that the player defeats super-effectively when possible, and otherwise chooses randomly among the remaining candidates. The rule applies consistently to the opening Oak/Elm handoff and later rival battles without changing rival DVs, moves, levels, or other party data.

A deliberate Starter Picker change after synchronization is treated as the player’s authoritative assignment for that save. Existing Gen 1 and Gold portrait, name, cry, held-item, and player-only DV behavior is retained.

This release is **untested in live gameplay**. The included Gen 1 and Gold harnesses and static compatibility checks pass, but save stability and interaction with the real randomizer builds still require player testing.
