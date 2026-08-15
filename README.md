# Starter Picker

Starter Picker is a separate Gen 1 Recomp mod for the three-ball Oak’s Lab sequence in Red and Blue. The mod options provide three independent, named Pokémon selectors: one each for the original **Charmander Ball**, **Bulbasaur Ball**, and **Squirtle Ball**.

| Option | Original Oak’s Lab ball | Native rival counter-pick |
|---|---|---|
| **CHARMANDER BALL** | Charmander | Squirtle Ball |
| **SQUIRTLE BALL** | Squirtle | Bulbasaur Ball |
| **BULBASAUR BALL** | Bulbasaur | Charmander Ball |
| **MAX PLAYER STARTER DVS** | Gives only the player's selected starter maximum Gen 1 DVs | Does not affect the rival |

Each selector lists the standard 151 Gen 1 Pokémon, including Mew. The vanilla species remain available so any position can be left unchanged. Duplicate choices are allowed deliberately: you can put the same Pokémon into more than one ball if you want.

## How it works

The mod replaces only the three starter-ball interactions. It preserves the original ball-position flags, object hiding, rival movement, and counter-pick relationship. For example, if you set **CHARMANDER BALL** to Mewtwo and **SQUIRTLE BALL** to Mew, choosing the original Charmander Ball gives you Mewtwo and makes the rival take Mew from the Squirtle Ball. The rival’s later teams retain their native levels, moves, and party structure, with only that starter-line Pokémon replaced.

The selectors are read live rather than being fixed when a save loads. A player can load a playthrough, open the mod options, and change any of the three named selections. After Oak’s Lab, changing the selector for the ball position that was chosen immediately replaces the tracked starter in the party.

## Maximum player-starter DVs

Enable **MAX PLAYER STARTER DVS** before receiving a starter to set the player’s selected starter to maximum Gen 1 DVs: **HP, Attack, Defense, Speed, and Special are all 15**. The engine derives the HP DV from the other four DVs; with all four at 15, HP is also 15. Enabling this option after Oak’s Lab applies it to the tracked player starter, and selecting a different species for that same chosen ball keeps the maximum-DV setting enabled.

This option intentionally does **not** change the rival path. The mod’s rival-party integration only substitutes the configured species in the rival’s appropriate starter slot. It does not read, write, or recalculate rival DVs, so the game continues to use its normal trainer-party DV assignment.

## Gen 1 Randomizer interoperability

Starter Picker explicitly checks for the installed **Gen 1 Randomizer** (`gen1_randomizer`) and reads that save’s confirmed setup. Its starter randomization is considered active only after the Randomizer setup is confirmed with **LOGIC** or **NO LOGIC** mode; **VANILLA** mode is recognized as inactive.

When active, Starter Picker applies its configured ball species after Gen 1 Randomizer’s own Oak’s Lab gift transform. This event priority is deterministic, so the Starter Picker choice wins even if Gen 1 Randomizer was selected first when the game booted. Inactive or absent Randomizer installations do not change normal Starter Picker behavior.

## When to configure the selections

You may change all three named selectors at any time, including after loading a save. Before Oak’s Lab, this is intended for a player who has a starter randomizer enabled and wants to choose the final species manually before accepting the starter.

After the starter has been received, change **only the selector matching the ball position you chose**. The mod immediately rebuilds that tracked party Pokémon as the newly selected species while preserving its level, DVs, stat experience, original trainer data, and current HP loss. Its moves, experience total, catch rate, status, and stats are refreshed for the new species; it is also marked as owned in the Pokédex. Changing one of the two unchosen ball selectors updates the rival’s corresponding future team but does not alter the player’s party.

This version targets the Red/Blue three-ball Oak’s Lab sequence. Pokémon Yellow has a different Pikachu/Eevee starter scene and is intentionally left unchanged.

## Install

Import `starter_picker-0.0.2.zip` through Gen 1 Recomp’s **Import mod .zip** action, or extract the files into this exact layout:

```text
mods/
└── starter_picker/
    ├── manifest.json
    ├── main.lua
    └── README.md
```

There must be no nested parent folder between `starter_picker/` and `manifest.json`.

## Verification status

The manifest has been checked as valid JSON and `main.lua` has passed offline Lua syntax parsing. It has not been run against a player-imported game in this environment.
