# Starter Picker

> **AI assisted; not AI created.**

Starter Picker supports the three-ball Oak’s Lab sequence in Gen 1 and the three-ball Elm’s Lab sequence in Gold. The mod options provide three independent, named Pokémon selectors for the active generation. **Gold support is declared but has not been tested in a player game.**

## Version 0.0.4

This update adds explicit **Gen 2 Randomizer** interoperability, a persistent **RANDOM (WEIGHTED)** Gold starter-held-item result, and a player-only **SHINY PLAYER STARTER** option. When Gen 2 Randomizer setup is confirmed in **LOGIC** or **NO LOGIC** mode, it may perform its own randomizer pass first; Starter Picker then applies the player’s configured Elm-ball species as the final starter result. **VANILLA** and unconfirmed Gen 2 Randomizer setups are recognized as inactive. The player’s configured rival counter-pick, rival DVs, and rival held item remain outside the player-starter item handling.

| Option | Original Oak’s Lab ball | Native rival counter-pick |
|---|---|---|
| **CHARMANDER BALL** | Charmander | Squirtle Ball |
| **SQUIRTLE BALL** | Squirtle | Bulbasaur Ball |
| **BULBASAUR BALL** | Bulbasaur | Charmander Ball |
| **MAX PLAYER STARTER DVS** | Gives only the player's selected starter maximum DVs | Does not affect the rival |
| **SHINY PLAYER STARTER** | Gives only the player’s selected starter a valid Gen 1/2 shiny DV spread; takes precedence over maximum DVs if both are enabled | Does not affect the rival |
| **STARTER HELD ITEM (GOLD)** | Retains the native berry, selects a named safe Gold item, or uses one persistent weighted random result for the player’s Elm’s Lab starter | Does not affect the rival |

Each selector lists the standard 151 Gen 1 Pokémon in Gen 1 and all standard **251** species in Gold, including Mew and Celebi. The vanilla species remain available so any position can be left unchanged. Duplicate choices are allowed deliberately: you can put the same Pokémon into more than one ball if you want.

## How it works

The mod replaces only the three starter-ball interactions. It preserves the original ball-position flags, object hiding, rival movement, and counter-pick relationship. For example, if you set **CHARMANDER BALL** to Mewtwo and **SQUIRTLE BALL** to Mew, choosing the original Charmander Ball gives you Mewtwo and makes the rival take Mew from the Squirtle Ball. The rival’s later teams retain their native levels, moves, and party structure, with only that starter-line Pokémon replaced.

The selectors are read live rather than being fixed when a save loads. A player can load a playthrough, open the mod options, and change any of the three named selections. After Oak’s Lab, changing the selector for the ball position that was chosen immediately replaces the tracked starter in the party.

## Maximum player-starter DVs

Enable **MAX PLAYER STARTER DVS** before receiving a starter to set the player’s selected starter to maximum Gen 1 DVs: **HP, Attack, Defense, Speed, and Special are all 15**. The engine derives the HP DV from the other four DVs; with all four at 15, HP is also 15. Enabling this option after Oak’s Lab applies it to the tracked player starter, and selecting a different species for that same chosen ball keeps the maximum-DV setting enabled.

This option intentionally does **not** change the rival path. The mod’s rival-party integration only substitutes the configured species in the rival’s appropriate starter slot. It does not read, write, or recalculate rival DVs, so the game continues to use its normal trainer-party DV assignment.

## Shiny player starter

Enable **SHINY PLAYER STARTER** before receiving a starter to give only the player’s chosen starter a valid Gen 1/2 shiny DV combination. The stored **Defense**, **Speed**, and **Special** DVs are all set to **10**. **Attack** is set to one of `2`, `3`, `6`, `7`, `10`, `11`, `14`, or `15`; these are the eight valid Attack values for that Defense/Speed/Special pattern. HP is derived from the low bits of the four stored DVs, as the game normally does.

If **SHINY PLAYER STARTER** and **MAX PLAYER STARTER DVS** are both enabled, the shiny setting takes precedence so the result remains shiny. The selected player starter can also be made shiny after the Lab by enabling this option. The rival’s DVs and held item are never read or changed by this feature.

## Gold support — untested

In Gold, the selectors are **CYNDAQUIL BALL**, **TOTODILE BALL**, and **CHIKORITA BALL**. They follow the same left/middle/right rival counter-pick relationship as the Gen 1 version. The mod rewrites only Elm’s Lab’s `givepoke` command for the selected ball, then marks and optionally upgrades only the player’s newly added party Pokémon. Gold’s split Special Attack and Special Defense stats are recalculated from the shared Special DV when a live player-starter species replacement is made.

**STARTER HELD ITEM (GOLD)** defaults to **VANILLA**, retaining Gold’s native starter berry. A named item choice changes only the player’s Elm’s Lab gift. **RANDOM (WEIGHTED)** generates and stores one player-starter result for that save: it has a substantial chance of **no held item**, more weight toward inert or low-value tossable items, a smaller chance of ordinary useful held items, and a small premium-item chance. Key items, HMs, non-tossable items, and invalid records are excluded. The random result is locked after it is first generated, so reopening options or changing the Gen 2 Randomizer seed cannot reroll it. If a future native starter command is itemless, weighted mode leaves it itemless rather than adding an item.

Neither named nor weighted selection writes to the rival party, the rival’s held item, or the rival’s DV fields.

> **Testing notice:** The Gold implementation has offline syntax and isolated harness coverage, but remains untested in a player-imported Gold save. Back up a save before trying it.

## Randomizer interoperability

Starter Picker explicitly checks for the installed **Gen 1 Randomizer** (`gen1_randomizer`) and **Gen 2 Randomizer** (`gen2_randomizer`) and reads each mod’s per-save configuration. Starter randomization is considered active only after that Randomizer’s setup is confirmed with **LOGIC** or **NO LOGIC** mode; **VANILLA** and unconfirmed configurations are recognized as inactive.

In Gen 1, Starter Picker applies its configured ball species after Gen 1 Randomizer’s Oak’s Lab gift transform. In Gold, the shared script-command chain first lets an active Gen 2 Randomizer transform Elm’s Lab’s `givepoke` command, then Starter Picker applies the player’s configured Elm-ball species and player-only held-item setting. The same deterministic final-pass ordering keeps the configured rival counter-pick from being replaced by a competing trainer-party projection. Inactive or absent Randomizer installations do not change normal Starter Picker behavior.

## When to configure the selections

You may change all three named selectors at any time, including after loading a save. Before Oak’s Lab, this is intended for a player who has a starter randomizer enabled and wants to choose the final species manually before accepting the starter.

After the starter has been received, change **only the selector matching the ball position you chose**. The mod immediately rebuilds that tracked party Pokémon as the newly selected species while preserving its level, DVs, stat experience, original trainer data, and current HP loss. Its moves, experience total, catch rate, status, and stats are refreshed for the new species; it is also marked as owned in the Pokédex. Changing one of the two unchosen ball selectors updates the rival’s corresponding future team but does not alter the player’s party.

The Gen 1 path targets the Red/Blue three-ball Oak’s Lab sequence. Pokémon Yellow has a different Pikachu/Eevee starter scene and is intentionally left unchanged. The Gold path targets Elm’s Lab; it is **untested** in-game.

## Install

Import `starter_picker-0.0.4.zip` through Gen 1 Recomp’s **Import mod .zip** action, or extract the files into this exact layout:

```text
mods/
└── starter_picker/
    ├── manifest.json
    ├── main.lua
    └── README.md
```

There must be no nested parent folder between `starter_picker/` and `manifest.json`.

## Verification status

The manifest has been checked as valid JSON and `main.lua` has passed offline Lua syntax parsing. Isolated harnesses cover the established Gen 1 selector/DV isolation flow, valid player-only shiny spreads and shiny precedence, and the Gold 251-species, Elm’s Lab gift, explicit held-item, weighted held-item persistence and itemless outcomes, split-stat, Gen 2 Randomizer LOGIC/NO LOGIC/VANILLA detection, final starter precedence, and rival-isolation paths. **Gold has not been run in a player-imported game**, so please back up a save before testing it.
