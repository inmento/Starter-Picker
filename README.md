# Starter Picker

> **AI assisted; not AI created.**

Starter Picker lets players choose starters by original ball position in Gen 1 and Gold. Each starter ball has an independent selector, and the game’s rival counter-pick relationship remains intact.

## Install

Import the `starter_picker-1.0.6.zip` release archive through Gen 1 Recomp’s **Import mod .zip** action. The archive extracts directly to a `starter_picker/` folder containing `manifest.json` and `main.lua`.

## Features

The three starter selectors are live settings. Configure them before receiving a starter, or update the selector matching the player’s chosen ball later to rebuild the tracked player starter. When a supported Gen 1 or Gold Randomizer has active starter randomization, Starter Picker synchronizes its selectors with the Randomizer’s actual assignments when those assignments are available. A deliberate selector change afterward becomes the player’s authority for that save. Player-only stat and held-item options never modify the rival’s DVs or held item.

Gen 1 covers Oak’s Lab in Red and Blue with all 151 species, including Mew. **MAX PLAYER STARTER DVS** applies only to the player’s selected starter and now has both a post-gift and script-completion safeguard. For faster selection, open **START > OPTIONS** and choose **PICK LEFT BALL**, **PICK MIDDLE BALL**, or **PICK RIGHT BALL**. Press A to browse all 151 species, hold Up or Down to scroll, use Left or Right to jump ten entries, press A to confirm, or B to cancel. Pokémon Yellow’s distinct Pikachu/Eevee sequence is intentionally unchanged.

## Gold

Gold covers Elm’s Lab with all 251 species, including Mew and Celebi. Cyndaquil, Totodile, and Chikorita have independent left, middle, and right ball selectors. The player’s configured selection remains authoritative while preserving Gold’s intended rival counter-pick flow. If active randomizer code transforms the final Elm gift without exposing a three-slot mapping, Starter Picker observes that final species and synchronizes the selected ball.

Gold provides player-only DV modes: preserve the native DVs, apply maximum DVs, generate random DVs, or apply a legal Shiny DV spread. Shiny mode sets Defense, Speed, and Special to 10 and selects a valid Attack DV, keeping the resulting starter shiny without touching the rival.

Gold starter held-item support offers Vanilla, named, and saved weighted results. Weighted selection may deliberately choose no held item, a lower-value item, a useful held item, or a premium result. Key items, HMs, non-tossable items, and invalid records are excluded.

## Randomizer compatibility

Starter Picker supports the authorized Gen 1 and Gold Randomizer compatibility paths. Active randomizer assignments are detected from the supported save state and synchronized into Starter Picker where possible. The rival then prefers a starter super-effective against the player’s final choice; if no direct weakness exists, it avoids candidates the player defeats super-effectively when possible and otherwise chooses randomly. Inactive or absent Randomizer configurations leave normal Starter Picker behavior unchanged. This compatibility update is explicitly untested in live gameplay.

## Compatibility

Starter Picker targets Mod API 2 and supports Gen 1 and Gold. It uses the engine’s active GameVersion to select the correct Gen 1 or Gold starter branch before registering generation-specific behavior. See [CHANGELOG.md](CHANGELOG.md) for the complete release feature list, including player-only DV modes and held-item behavior. See [CREDITS.md](CREDITS.md) for Randomizer compatibility credit.
