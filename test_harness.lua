local callbacks = { hooks = {}, hookPriority = {}, events = {}, mapContribution = nil }
local optionValues = {
  charmander_ball = "MEWTWO",
  squirtle_ball = "MEW",
  bulbasaur_ball = "BULBASAUR",
  max_starter_dvs = true,
  shiny_player_starter = false,
  starter_held_item = "VANILLA",
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
  save = {
    flags = { EVENT_FOLLOWED_OAK_INTO_LAB = true },
    modData = {
      gen1_randomizer = {
        startup_config_confirmed = true,
        randomizer_mode = "logic",
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
    if id == "gen1_randomizer" then return { id = id, version = "0.2.0", exports = {} } end
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
      callbacks.hooks[name] = fn
      callbacks.hookPriority[name] = priority
    end,
  },
}

local entry = assert(loadfile("/home/ubuntu/starter_picker/main.lua"))
entry()(mod)
assert(#callbacks.schema == 6, "three picker options, the max-DV toggle, shiny toggle, and Gold held-item option were not defined")
assert(callbacks.schema[1].key == "charmander_ball", "Charmander Ball option missing")
assert(callbacks.schema[2].key == "squirtle_ball", "Squirtle Ball option missing")
assert(callbacks.schema[3].key == "bulbasaur_ball", "Bulbasaur Ball option missing")
assert(callbacks.schema[4].key == "max_starter_dvs", "max player starter DVs option missing")
assert(callbacks.schema[5].key == "shiny_player_starter", "player shiny starter option missing")
assert(callbacks.schema[6].key == "starter_held_item", "Gold starter held-item option missing")
assert(callbacks.events["pokemon.before_give"].priority == -10000,
  "starter gift override did not register after Randomizer")
assert(callbacks.events["mod.options_changed"], "live selector-change listener missing")
assert(callbacks.hookPriority["trainer.party"] == -10000,
  "rival counter-pick did not register after competing trainer transforms")

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
assert(modSave.gen1_randomizer_starter_override_active == true,
  "confirmed Randomizer starter mode was not detected")
assert(modSave.pending_starter_slot == nil, "pending starter state was not cleaned up")

-- An installed Randomizer in VANILLA mode is detected as inactive. The named
-- ball choice still works normally and does not rely on Randomizer behavior.
game.save.modData.gen1_randomizer.randomizer_mode = "vanilla"
modSave.pending_starter_slot = "LEFT"
local vanillaGift = {
  ctx = { game = game, overworld = overworld, save = game.save },
  species = "BULBASAUR", level = 5,
}
callbacks.events["pokemon.before_give"].fn(vanillaGift)
assert(vanillaGift.species == "MEWTWO", "vanilla-mode gift did not use configured ball")
assert(modSave.gen1_randomizer_starter_override_active == false,
  "Randomizer VANILLA mode was incorrectly reported as active")
modSave.pending_starter_slot = nil
game.save.modData.gen1_randomizer.randomizer_mode = "logic"

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
local projected = callbacks.hooks["trainer.party"](
  function(_, _, party) return party end, "OPP_RIVAL1", 1, originalParty)
assert(projected[#projected].species == "MEW", "rival party 1 did not use the Squirtle ball")
assert(originalParty[#originalParty].species == "SQUIRTLE", "vanilla party was mutated")
assert(projected[#projected].dvs.attack == 1 and projected[#projected].dvs.hp == 1,
  "max player starter DVs leaked into the rival party projection")

-- The selectors are read live after loading: changing Squirtle Ball makes the
-- next rival team projection use the changed selection without restarting.
optionValues.squirtle_ball = "BULBASAUR"
local updated = callbacks.hooks["trainer.party"](
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

-- The shiny toggle creates a valid Gen 1/2 shiny DV combination on only the
-- marked player starter. Shiny takes precedence over the maximum-DV setting.
optionValues.max_starter_dvs = true
optionValues.shiny_player_starter = true
game.save.flags.EVENT_GOT_STARTER = false
modSave.pending_starter_slot = "LEFT"
local shinyGift = {
  ctx = { game = game, overworld = overworld, save = game.save },
  species = "BULBASAUR", level = 5,
}
callbacks.events["pokemon.before_give"].fn(shinyGift)
game.save.party = {
  {
    species = shinyGift.species, level = 5, hp = 20,
    dvs = { hp = 2, attack = 2, defense = 2, speed = 2, special = 2 },
    statExp = { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 },
    stats = { hp = 20, attack = 10, defense = 10, speed = 10, special = 10 },
  },
}
callbacks.events["screen.pushed"].fn({ state = { screenId = "NicknamePrompt" } })
local shiny = game.save.party[1].dvs
local shinyAttack = { [2] = true, [3] = true, [6] = true, [7] = true, [10] = true, [11] = true, [14] = true, [15] = true }
assert(shinyAttack[shiny.attack] and shiny.defense == 10 and shiny.speed == 10 and shiny.special == 10,
  "shiny player starter did not receive a valid shiny DV combination")
assert(shiny.hp == ((shiny.attack % 2 == 1) and 8 or 0),
  "shiny player starter did not derive HP DV from the shiny stored DVs")
assert(modSave.starter_shiny_dvs_applied == true and modSave.starter_max_dvs_applied == nil,
  "shiny starter did not take precedence over maximum DVs")
assert(modSave.pending_shiny_player_starter == nil and modSave.pending_max_starter_dvs == nil,
  "pending player shiny state was not cleared after the starter was created")

print("starter picker named live-selector harness: valid")
