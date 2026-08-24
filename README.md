# Starter Picker

> **AI assisted; not AI created.**

Starter Picker lets players choose starters by original ball position in Gen 1, Gold, Silver, and Crystal. Each starter ball has an independent selector, and the game’s rival counter-pick relationship remains intact.

## Install

Import the current `starter_picker-<version>.zip` release archive through Gen 1 Recomp’s **Import mod .zip** action. The archive extracts directly to a `starter_picker/` folder containing `manifest.json` and `main.lua`.

## Features

The three starter selectors are live settings. Configure them before receiving a starter, or update the selector matching the player’s chosen ball later to rebuild the tracked player starter. Before accepting a Gen 1 ball, Starter Picker shows a compact species-and-type summary; Gold, Silver, and Crystal update Elm’s prompt with the same information. **STARTER STATUS** and **RIVAL PREVIEW** are read-only views for checking the confirmed selection and matchup.

When a supported Gen 1 or Gen 2 Randomizer has active starter randomization, Starter Picker synchronizes its selectors with the Randomizer’s actual assignments when those assignments are available. A deliberate selector change afterward becomes the player’s authority for that save. **LOCK CONFIRMED STARTER** optionally freezes the received player starter and the saved three-ball configuration so later option changes cannot silently rebuild the player or rival starter. Player-only stat and held-item options never modify the rival’s DVs or held item.

Gen 1 covers Oak’s Lab in Red and Blue with the native 151 species, including Mew. When a compatible expanded-dex provider is active, Starter Picker reads the merged live registry and can additionally list only the valid species that provider registered; it never invents, modifies, or assumes foreign species records. For example, the standalone Gen 1 Shedinja mod can expose Shedinja #152 when enabled. **MAX PLAYER STARTER DVS** applies only to the player’s selected starter and now has both a post-gift and script-completion safeguard. For faster selection, open **START > OPTIONS** and choose **PICK LEFT BALL**, **PICK MIDDLE BALL**, or **PICK RIGHT BALL**. Press A to browse available species, hold Up or Down to scroll, use Left or Right to jump ten entries, press A to confirm, or B to cancel. Pokémon Yellow’s distinct Pikachu/Eevee sequence is intentionally unchanged. **STARTER TRADE EVO AT 42** is optional and applies only to the confirmed player starter when it has an otherwise unresolved native trade evolution; it never changes other party Pokémon.

## Gold, Silver, and Crystal

Gold, Silver, and Crystal cover Elm’s Lab with all 251 species, including Mew and Celebi. Cyndaquil, Totodile, and Chikorita have independent left, middle, and right ball selectors. The player’s configured selection remains authoritative while preserving the intended Gen 2 rival counter-pick flow. If active randomizer code transforms the final Elm gift without exposing a three-slot mapping, Starter Picker observes that final species and synchronizes the selected ball.

Crystal uses its own verified Elm Lab script and prompt identifiers for the same three native ball positions. The mod selects this Crystal profile only when `GameVersion.engine()` identifies the active runtime as `crystal`; Gold and Silver retain their existing shared profile.

Gold, Silver, and Crystal provide player-only DV modes: preserve the native DVs, apply maximum DVs, generate random DVs, or apply a legal Shiny DV spread. Shiny mode sets Defense, Speed, and Special to 10 and selects a valid Attack DV, keeping the resulting starter shiny without touching the rival.

Gold, Silver, and Crystal starter held-item support offers Vanilla, named, no-item, random-safe, recovery-oriented, and type-supporting choices. The generated modes use stable saved results for the current selection and exclude key items, HMs, machines, mail, non-tossable items, and invalid records.

## Game Corner exclusives

In Gen 1, **GAME CORNER EXCLUSIVES** optionally repurposes the third native Celadon prize vendor into a separate coin-priced broker for base Pokémon covering the Red, Blue, and Yellow version-exclusive families. The first two vendors remain unchanged. The broker uses normal party/box capacity behavior, requires the Coin Case, and falls through to the original vendor when the option is disabled.

## Randomizer compatibility

Starter Picker supports the authorized Gen 1 and Gen 2 Randomizer compatibility paths. Active randomizer assignments are detected from the supported save state and synchronized into Starter Picker where possible. The rival then prefers a starter super-effective against the player’s final choice; if no direct weakness exists, it avoids candidates the player defeats super-effectively when possible and otherwise chooses randomly. Inactive or absent Randomizer configurations leave normal Starter Picker behavior unchanged. This compatibility update is explicitly untested in live gameplay.

## Compatibility

Starter Picker targets Mod API 2 and supports Gen 1, Gold, Silver, and Crystal on Gen1Recomp `0.2.24` or later. It uses the engine’s active GameVersion generation contract for normal Gen 2 behavior and `GameVersion.engine()` only to choose the verified Crystal Elm Lab script profile. It includes no Crystal ROM data or assets.

**Expanded Pokédex providers are optional.** In Red, Blue, and Yellow, Starter Picker reads the effective merged dex size and only lists live species records that an enabled provider has registered. Crystal 251 (a Gen 1 expansion framework, not native Pokémon Crystal support) and Shedinja (`shedinja`) are known optional providers and are ordered before the selector when installed. They are not required dependencies. The mod does not require either provider and preserves foreign data, evolution rules, and map content. Crystal’s existing trade-evolution conversions take precedence over the optional Starter Picker level-42 fallback. Do not combine independent expansion mods that claim the same species index. See [CHANGELOG.md](CHANGELOG.md) for the complete release feature list, including player-only DV modes and held-item behavior. See [CREDITS.md](CREDITS.md) for Randomizer compatibility credit.
