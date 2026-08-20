# Changelog


## 1.0.13 — Corrected Shedinja provider identity

Starter Picker’s optional Shedinja integration now names the corrected `shedinja` package ID. This preserves optional load ordering for Shedinja-aware starter choices after the core package migration; no gameplay setting, starter selection, rival logic, or randomizer behavior changed.

## 1.0.12 — Gold mobile option-label fix

Gold’s fixed mod-options panel does not wrap individual labels, so the longer Starter Picker labels could run past the right edge on mobile. The visible labels are now compact, unambiguous terms such as `CYNDAQUIL`, `TRADE @42`, `DV MODE`, and `HELD ITEM`; all option keys, defaults, values, and behavior remain unchanged.

The Gen 1 Oak Lab rival projection is also covered explicitly for a selected Shedinja. If neither remaining offered starter is super-effective against Bug/Ghost, the rival selects one of the two remaining safe candidates, as intended.

## 1.0.11 — Compact option labels and National Dex display

Every starter-setting label now fits the fixed 17-column mod-settings viewport. The setting keys, defaults, randomizer synchronization, player-only DV behavior, trade-evolution option, and rival logic are unchanged.

When Gen 1 Shedinja 0.1.6 is enabled, its existing optional load-order relationship now also lets the selector display the provider’s official **#292 SHEDINJA** row. Shedinja remains optional and is not a dependency.

## 1.0.10 — Shedinja optional-provider order repair

Gen 1 Shedinja’s package ID is now lowercase (`gen1_shedinja`). Starter Picker 1.0.9 still named its optional ordering relationship with the previous uppercase ID, so the loader could start Starter Picker before Shedinja and build the selector at the native #151 ceiling. This release updates that **optional** relationship to `gen1_shedinja`.

Shedinja is still not a required dependency. With Gen 1 Shedinja enabled, Starter Picker now reliably builds after the provider and exposes **#152 SHEDINJA**. Without it, Starter Picker remains a normal Gen 1/Gold starter selector with its native choices.

## 1.0.9 — Merged live-data compatibility

Starter Picker now builds its Gen 1 selection list from the **effective merged Pokédex range** rather than permanently stopping at #151. It only lists species records that are actually present in the active merged registry and does not overwrite another mod’s authored species data.

Known content providers, including Crystal 251 and Gen 1 Shedinja, are declared as optional ordering relationships so their registries are available before the selector is built when installed. This means a valid active expansion can offer its own registered species in the picker; for example, Gen 1 Shedinja can appear as #152 when that standalone mod is enabled.

The existing randomizer synchronization, player-only DV options, rival counter-pick logic, Gold held-item options, trade-evolution option, Game Corner option, and Crystal 251 behavior remain intact.
