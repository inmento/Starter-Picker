local callbacks = { hooks = {}, events = {}, mapContribution = nil }
package.preload["src.core.GameVersion"] = function()
  return { get = function() return "red" end }
end
local optionValues = {
  charmander_ball = "MEWTWO",
  squirtle_ball = "MEW",
  bulbasaur_ball = "BULBASAUR",
  max_starter_dvs = true,
}
local modSave = {}
local species = {
  CHARMANDER = { dex = 4, name = "CHARMANDER" },
  SQUIRTLE = { dex = 7, name = "SQUIRTLE" },
  BULBASAUR = { dex = 1, name = "BULBASAUR" },
  MEW = { dex = 151, name = "MEW" },
  MEWTWO = { dex = 150, name = "MEWTWO" },
}

local game = {
  mods = { modOptions = { starter_picker = optionValues } },
  save = {
    options = { modOptions = { starter_picker = optionValues } },
    flags = { EVENT_FOLLOWED_OAK_INTO_LAB = true },
    modData = {
      pokemon_randomizer = {
        enabled = true,
        settings = { starters = "random" },
        mappings = {
          starters = {
            LEFT = { rivalSlot = "MIDDLE", rivalSpecies = "SQUIRTLE" },
            MIDDLE = { rivalSlot = "RIGHT", rivalSpecies = "BULBASAUR" },
            RIGHT = { rivalSlot = "LEFT", rivalSpecies = "CHARMANDER" },
          },
          starterFlags = { partyOffsetSlots = { "LEFT", "MIDDLE", "RIGHT" } },
        },
      },
    },
  },
  data = { pokemon = species },
}
local recordedRows
local emittedGift
local overworld = {
  map = { id = "OAKS_LAB" },
  runner = {
    run = function(_, rows, opts)
      recordedRows = rows
      for _, row in ipairs(rows) do
        if row[1] == "give_pokemon" then
          -- Model Gen 1 Randomizer's default-priority Oak's Lab mutation
          -- completing before Starter Picker's lower-priority final override.
          emittedGift = {
            ctx = { game = game, overworld = overworld, save = game.save },
            species = "BULBASAUR",
            level = 5,
          }
          callbacks.events["pokemon.before_give"].fn(emittedGift)
          -- The engine creates and adds the player mon before it opens the
          -- nickname prompt. Model that boundary so the max-DV listener can
          -- affect only this player gift after construction.
          game.save.party = {
            {
              species = emittedGift.species, level = emittedGift.level, hp = 20,
              dvs = { hp = 8, attack = 8, defense = 8, speed = 8, special = 8 },
              statExp = { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 },
              stats = { hp = 20, attack = 10, defense = 10, speed = 10, special = 10 },
            },
          }
          callbacks.events["screen.pushed"].fn({ state = { screenId = "NicknamePrompt" } })
        end
      end
      if opts and opts.onDone then opts.onDone() end
    end,
  },
}

local mod = {
  id = "starter_picker",
  game = game,
  find = function(_, id)
    if id == "pokemon_randomizer" then return { id = id, version = "1.0.0", exports = {} } end
    return nil
  end,
  content = {
    pokemon = { each = function() return pairs(species) end },
    map_scripts = {
      register = function(_, mapId, contribution)
        assert(mapId == "OAKS_LAB")
        callbacks.mapContribution = contribution
      end,
    },
  },
  options = {
    define = function(_, schema) callbacks.schema = schema end,
    get = function(_, key) return optionValues[key] end,
  },
  save = {
    get = function(_, key) return modSave[key] end,
    set = function(_, key, value) modSave[key] = value end,
  },
  events = {
    on = function(_, name, fn, priority)
      callbacks.events[name] = { fn = fn, priority = priority }
    end,
  },
  hooks = {
    wrap = function(_, name, fn, priority)
      if priority then
        callbacks.hooks[name] = { fn = fn, priority = priority }
      else
        callbacks.hooks[name] = fn
      end
    end,
  },
}

local entry = assert(loadfile("main.lua"))
entry()(mod)
assert(#callbacks.schema == 4, "three picker options and the max-DV toggle were not defined")
assert(callbacks.schema[1].key == "charmander_ball", "Charmander Ball option missing")
assert(callbacks.schema[2].key == "squirtle_ball", "Squirtle Ball option missing")
assert(callbacks.schema[3].key == "bulbasaur_ball", "Bulbasaur Ball option missing")
assert(callbacks.schema[4].key == "max_starter_dvs", "max player starter DVs option missing")
assert(callbacks.events["pokemon.before_give"].priority == -10000,
  "starter gift override did not register after Randomizer")
assert(callbacks.events["mod.options_changed"], "live selector-change listener missing")
assert(callbacks.hooks["trainer.party"].priority == -10000,
  "rival projection did not register after the Randomizer")

callbacks.mapContribution.talk.TEXT_OAKSLAB_CHARMANDER_POKE_BALL(
  game, overworld, {}, function() end)
local received, rivalReceived
for _, row in ipairs(recordedRows) do
  if row[1] == "give_pokemon" then received = row[2] end
  if row[1] == "show_text" and row[2] == "_OaksLabRivalReceivedMonText" then
    rivalReceived = row[3].RAM
  end
end
assert(received == "MEWTWO", "Charmander ball did not use its configured species")
assert(rivalReceived == "MEW", "Charmander ball did not retain the Squirtle-ball rival pick")
assert(emittedGift.species == "MEWTWO", "configured starter did not override competing gift transform")
assert(emittedGift.level == 5, "starter gift level was not preserved")
assert(game.save.party[1].dvs.attack == 15 and game.save.party[1].dvs.defense == 15
  and game.save.party[1].dvs.speed == 15 and game.save.party[1].dvs.special == 15
  and game.save.party[1].dvs.hp == 15,
  "max-DV option did not apply maximum DVs to the player starter")
assert(modSave.pending_max_starter_dvs == nil,
  "pending player max-DV marker was not cleared after the starter was created")
assert(modSave.pokemon_randomizer_starter_override_active == true,
  "confirmed Randomizer starter mode was not detected")
assert(modSave.pending_starter_slot == nil, "pending starter state was not cleaned up")

-- An installed Randomizer in VANILLA mode is detected as inactive. The named
-- ball choice still works normally and does not rely on Randomizer behavior.
game.save.modData.pokemon_randomizer.enabled = false
  game.save.modData.pokemon_randomizer.settings.starters = "off"
modSave.pending_starter_slot = "LEFT"
local vanillaGift = {
  ctx = { game = game, overworld = overworld, save = game.save },
  species = "BULBASAUR", level = 5,
}
callbacks.events["pokemon.before_give"].fn(vanillaGift)
assert(vanillaGift.species == "MEWTWO", "vanilla-mode gift did not use configured ball")
assert(modSave.pokemon_randomizer_starter_override_active == false,
  "Randomizer VANILLA mode was incorrectly reported as active")
modSave.pending_starter_slot = nil
game.save.modData.pokemon_randomizer.enabled = true
  game.save.modData.pokemon_randomizer.settings.starters = "random"

-- Once Oak has given the starter, changing its named selector rebuilds the
-- party record at the same level with valid species-derived fields.
game.save.flags.EVENT_GOT_STARTER = true
game.save.flags.EVENT_CHOSE_CHARMANDER = true
game.save.party = {
  {
    species = "MEWTWO", level = 5, hp = 20,
    dvs = { hp = 8, attack = 8, defense = 8, speed = 8, special = 8 },
    statExp = { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 },
    stats = { hp = 25, attack = 20, defense = 20, speed = 20, special = 20 },
    moves = {}, catchRate = 3,
  },
}
optionValues.charmander_ball = "MEW"
callbacks.events["mod.options_changed"].fn({
  mod = "starter_picker", key = "charmander_ball", value = "MEW",
})
assert(game.save.party[1].species == "MEW", "post-Oak selector change did not replace starter")
assert(game.save.party[1].level == 5, "post-Oak replacement did not preserve level")
assert(game.save.party[1].stats and game.save.party[1].stats.hp,
  "post-Oak replacement did not recalculate stats")
assert(game.save.party[1].dvs.attack == 15 and game.save.party[1].dvs.hp == 15,
  "post-Oak species replacement did not preserve the player-only maximum DVs")
assert(modSave.received_starter_species == "MEW", "starter tracking was not updated")

local originalParty = {
  { species = "RATTATA", level = 5 },
  {
    species = "SQUIRTLE", level = 5,
    dvs = { hp = 1, attack = 1, defense = 1, speed = 1, special = 1 },
  },
}
local projected = callbacks.hooks["trainer.party"].fn(
  function(_, _, party) return party end, "OPP_RIVAL1", 1, originalParty)
assert(projected[#projected].species == "MEW", "rival party 1 did not use the current Randomizer-selected rival ball")
assert(originalParty[#originalParty].species == "SQUIRTLE", "vanilla party was mutated")
assert(projected[#projected].dvs.attack == 1 and projected[#projected].dvs.hp == 1,
  "max player starter DVs leaked into the rival party projection")

-- With current Randomizer starter mode active, changing the Starter Picker's
-- rival ball must change the projected rival species without restarting.
optionValues.squirtle_ball = "BULBASAUR"
local updated = callbacks.hooks["trainer.party"].fn(
  function(_, _, party) return party end, "OPP_RIVAL1", 1, originalParty)
assert(updated[#updated].species == "BULBASAUR", "post-load selector change was not read live")

-- With the toggle disabled, the post-gift listener has no pending player
-- adjustment and must leave the engine-generated DVs intact.
optionValues.max_starter_dvs = false
game.save.flags.EVENT_GOT_STARTER = false
modSave.pending_starter_slot = "LEFT"
local unmodifiedGift = {
  ctx = { game = game, overworld = overworld, save = game.save },
  species = "BULBASAUR", level = 5,
}
callbacks.events["pokemon.before_give"].fn(unmodifiedGift)
game.save.party = {
  {
    species = unmodifiedGift.species, level = 5, hp = 20,
    dvs = { hp = 2, attack = 2, defense = 2, speed = 2, special = 2 },
    statExp = { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 },
    stats = { hp = 20, attack = 10, defense = 10, speed = 10, special = 10 },
  },
}
callbacks.events["screen.pushed"].fn({ state = { screenId = "NicknamePrompt" } })
assert(game.save.party[1].dvs.attack == 2 and game.save.party[1].dvs.hp == 2,
  "disabled max-DV option incorrectly rewrote the player starter's DVs")

-- A New Game must not inherit a prior run's global selector settings.
optionValues.charmander_ball = "MEWTWO"
optionValues.squirtle_ball = "MEW"
optionValues.bulbasaur_ball = "MEW"
optionValues.max_starter_dvs = true
callbacks.hooks["save.new_game"](function(save) return save end, game.save)
assert(optionValues.charmander_ball == "CHARMANDER"
  and optionValues.squirtle_ball == "SQUIRTLE"
  and optionValues.bulbasaur_ball == "BULBASAUR"
  and optionValues.max_starter_dvs == false,
  "New Game did not reset carried-over Starter Picker settings")

print("starter picker named live-selector, player-only DV, and New Game reset harness: valid")
