# Changelog

## 1.0.10 — Shedinja optional-provider order repair

Gen 1 Shedinja’s package ID is now lowercase (`gen1_shedinja`). Starter Picker 1.0.9 still named its optional ordering relationship with the previous uppercase ID, so the loader could start Starter Picker before Shedinja and build the selector at the native #151 ceiling. This release updates that **optional** relationship to `gen1_shedinja`.

Shedinja is still not a required dependency. With Gen 1 Shedinja enabled, Starter Picker now reliably builds after the provider and exposes **#152 SHEDINJA**. Without it, Starter Picker remains a normal Gen 1/Gold starter selector with its native choices.

## 1.0.9 — Merged live-data compatibility

Starter Picker now builds its Gen 1 selection list from the **effective merged Pokédex range** rather than permanently stopping at #151. It only lists species records that are actually present in the active merged registry and does not overwrite another mod’s authored species data.

Known content providers, including Crystal 251 and Gen 1 Shedinja, are declared as optional ordering relationships so their registries are available before the selector is built when installed. This means a valid active expansion can offer its own registered species in the picker; for example, Gen 1 Shedinja can appear as #152 when that standalone mod is enabled.

The existing randomizer synchronization, player-only DV options, rival counter-pick logic, Gold held-item options, trade-evolution option, Game Corner option, and Crystal 251 behavior remain intact.
