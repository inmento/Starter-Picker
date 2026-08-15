# Starter Picker

> **AI assisted; not AI created.**

Starter Picker lets players choose starters by original ball position in Gen 1 and Gold. Each starter ball has an independent selector, and the game’s rival counter-pick relationship remains intact.

## Install

Import the `starter_picker-1.0.1.zip` release archive through Gen 1 Recomp’s **Import mod .zip** action. The archive extracts directly to a `starter_picker/` folder containing `manifest.json` and `main.lua`.

## Features

The three starter selectors are live settings. Configure them before receiving a starter, or update the selector matching the player’s chosen ball later to rebuild the tracked player starter. The rival’s future counter-pick relationship remains tied to the ball positions, while player-only stat and held-item options never modify the rival’s DVs or held item.

Gen 1 covers Oak’s Lab in Red and Blue with all 151 species, including Mew. Pokémon Yellow’s distinct Pikachu/Eevee sequence is intentionally unchanged.

## Gold

Gold covers Elm’s Lab with all 251 species, including Mew and Celebi. Cyndaquil, Totodile, and Chikorita have independent left, middle, and right ball selectors. The player’s configured selection remains authoritative while preserving Gold’s intended rival counter-pick flow.

Gold provides player-only DV modes: preserve the native DVs, apply maximum DVs, generate random DVs, or apply a legal Shiny DV spread. Shiny mode sets Defense, Speed, and Special to 10 and selects a valid Attack DV, keeping the resulting starter shiny without touching the rival.

Gold starter held-item support offers Vanilla, named, and saved weighted results. Weighted selection may deliberately choose no held item, a lower-value item, a useful held item, or a premium result. Key items, HMs, non-tossable items, and invalid records are excluded.

## Randomizer compatibility

Starter Picker supports the authorized Gen 1 and Gold Randomizer compatibility paths. Confirmed Randomizer starter modes can apply their setup while the player’s explicit Starter Picker ball selection remains the final player-starter choice. Inactive or absent Randomizer configurations leave normal Starter Picker behavior unchanged.

## Compatibility

Starter Picker targets Mod API 2 and supports Gen 1 and Gold. See [CHANGELOG.md](CHANGELOG.md) for the complete release feature list, including player-only DV modes and held-item behavior. See [CREDITS.md](CREDITS.md) for Randomizer compatibility credit.
