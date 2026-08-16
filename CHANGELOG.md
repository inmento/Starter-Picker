# Changelog

## 1.0.4 — New Game Settings Reset

Starter Picker now resets its ball selectors and player-only stat/item settings to their native defaults when a new save is created. The mod manager stores options globally, so the previous build could silently carry a prior run’s starter selections into the next run. Each new game now starts clean, while settings can still be configured normally before Oak’s Lab or Elm’s Lab.

This change covers Gen 1 ball choices and maximum DVs, plus Gold ball choices, player DV mode, and held-item selection. Existing saves retain their already-received starter behavior.

## 1.0.3 — Gen 2 Detection Stability

Starter Picker now reads the engine’s active `GameVersion.get()` value before registering starter options, hooks, and UI. This makes the Gen 1 Oak’s Lab branch and Gold Elm’s Lab branch deterministic when Red, Blue, Yellow, or Gold is loaded, instead of inferring the generation from data-table shape.

No starter selection, rival counter-pick, DV, held-item, Gold Elm dialogue, or Randomizer compatibility behavior changed in this update.

## 1.0.2 — Gen 1 Starter Controls and Maximum-DV Fix

The Gen 1 **MAX PLAYER STARTER DVS** option now applies at both Oak's Lab's post-gift screen boundary and script completion. This keeps the change limited to the player starter while covering Oak's Lab presentation paths that previously missed the update.

Gen 1 now also adds **PICK LEFT BALL**, **PICK MIDDLE BALL**, and **PICK RIGHT BALL** to **START > OPTIONS**. Press **A** on a row to open a dedicated 151-species browser. Hold Up or Down to scroll, use Left or Right to jump ten Pokédex entries, press A to select, and press B to cancel. The original compact mod-menu selectors remain available.

Gold behavior is unchanged in this release.

## 1.0.1 — Gold Elm Dialogue and Presentation Fix

Elm’s Lab now updates each starter ball’s selection prompt, preview picture, cry, and received-Pokémon name to use the configured species before the gift is added to the party. The initial player starter uses the configured species name in uppercase, matching the Gold presentation style.

## 1.0.0 — Full Release

Starter Picker 1.0.0 lets players choose starters by their original ball position while preserving the game’s rival counter-pick logic. The selected player ball remains the source of truth in both Gen 1 and Gold, and selections can be adjusted from the mod options before the starter is received.

### Core features

| Feature | What it does |
|---|---|
| Ball-position selection | Each original starter ball has its own named selector. |
| Live configuration | Starter settings are applied from the current option state rather than being locked when a save first loads. |
| Rival counter-pick | The rival continues to choose the configured counter-ball relationship. |
| Player-only stat options | DV settings apply only to the player’s selected starter. Rival DVs remain independent. |
| Randomizer interoperability | Starter Picker recognizes supported Gen 1 and Gold Randomizer starter modes and keeps the player’s named ball selection authoritative. |

### Gen 1 support

Gen 1 supports the three Oak’s Lab balls and the complete 151-species selection set, including Mew. The original ball flags, object hiding, rival flow, and later rival-party structure remain intact.

The **MAX PLAYER STARTER DVS** option gives only the player’s chosen Gen 1 starter maximum DVs. It does not modify the rival’s DVs.

### Gold support

Gold support covers Elm’s Lab and the complete 251-species selection range. Each of Cyndaquil, Totodile, and Chikorita has an independent ball selector, while the player’s selected ball remains compatible with Gold’s rival counter-pick flow.

| Gold option | Effect |
|---|---|
| **CYNDAQUIL BALL** | Chooses the species in Elm’s left ball. |
| **TOTODILE BALL** | Chooses the species in Elm’s middle ball. |
| **CHIKORITA BALL** | Chooses the species in Elm’s right ball. |
| **PLAYER DV MODE** | Preserves native DVs or applies Max, Random, or Shiny DVs to the player starter only. |
| **HELD ITEM** | Preserves the native item, selects a named item, or uses a saved weighted random result. |

Shiny mode uses a legal Gen 2 shiny spread: Defense, Speed, and Special DVs are set to 10 and Attack is selected from the valid shiny values. Max, Random, and Shiny modes never alter rival DVs.

### Gold held items and Randomizer compatibility

Gold starter held items support Vanilla, named, and weighted results. Weighted results are stored per save and may deliberately be no item, a lower-value result, a useful held item, or a premium held item. Unsafe key items, HMs, non-tossable items, and invalid records remain excluded.

Starter Picker supports the authorized Gen 1 and Gold Randomizer compatibility paths. Confirmed Randomizer starter modes can perform their own setup while the player’s explicit Starter Picker ball selection remains the final player-starter choice.

### Compatibility and quality

This release targets Mod API 2 and supports both Gen 1 and Gold. Mobile labels are compact, selected starters retain normal party behavior, and the release archive contains only mod source, metadata, documentation, credits, and license material.
