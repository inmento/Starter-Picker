# Changelog

## 1.0.7 — Starter Visibility and Crystal-Safe Options

Starter Picker now recognizes **Crystal 251** as an optional Red, Blue, and Yellow overhaul. It uses the merged live species and evolution registries when Crystal is active, but does not require Crystal 251 and does not replace its imported data, evolution rules, or map content.

**STARTER STATUS** and **RIVAL PREVIEW** provide read-only views of the configured or confirmed player starter, its types, compatibility state, and the rival’s matchup. A confirmed starter record is now saved when the player receives their starter. **LOCK CONFIRMED STARTER** can keep that accepted selection authoritative, preventing later option changes from silently rebuilding the starter or rival configuration.

**STARTER TRADE EVO AT 42** is an optional player-starter-only fallback for unresolved native trade evolutions. It applies only to the confirmed starter at level 42, never to other party Pokémon, and does not override Crystal 251’s existing level or item evolution conversions.

Gen 1 adds optional **GAME CORNER EXCLUSIVES**. When enabled, the third native Celadon prize vendor offers a separate coin-priced list of base Pokémon that cover the Red, Blue, and Yellow version-exclusive families. The other prize vendors remain untouched, the feature uses standard party/box capacity handling, and disabling it falls through to the native vendor behavior.

Gold adds safe held-item themes: vanilla, no item, random safe, recovery-oriented, or type-supporting. Mail, machines, key items, and non-tossable records are excluded from generated Gold starter held items. Existing player-only Max/Random/Shiny DV modes, randomizer synchronization, rival counter-picks, Gen 1 list-browser navigation, and native Elm presentation remain supported.

Gen 1 and Gold regression harnesses, package validation, linting, and Gen 2 safety checks passed. Live testing is still needed for the Game Corner broker, starter trade-evolution movie, confirmation lock, and Crystal 251 interactions.
