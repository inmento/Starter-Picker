local callbacks, storage = { hooks = {}, hookPriority = {}, events = {} }, {}
local optionValues = {
  cyndaquil_ball = "CELEBI", totodile_ball = "MEW", chikorita_ball = "CHIKORITA",
  max_starter_dvs = true, shiny_player_starter = false, starter_held_item = "BERRY_JUICE",
}
local species = {
  CHIKORITA = { dex = 152, name = "CHIKORITA", index = 152, growthRate = "GROWTH_MEDIUM_SLOW", baseStats = { hp = 45, attack = 49, defense = 65, speed = 45, specialAttack = 49, specialDefense = 65 }, levelMoves = { { level = 1, move = "TACKLE" } } },
  CYNDAQUIL = { dex = 155, name = "CYNDAQUIL", index = 155, growthRate = "GROWTH_MEDIUM_SLOW", baseStats = { hp = 39, attack = 52, defense = 43, speed = 65, specialAttack = 60, specialDefense = 50 }, levelMoves = { { level = 1, move = "TACKLE" } } },
  TOTODILE = { dex = 158, name = "TOTODILE", index = 158, growthRate = "GROWTH_MEDIUM_SLOW", baseStats = { hp = 50, attack = 65, defense = 64, speed = 43, specialAttack = 44, specialDefense = 48 }, levelMoves = { { level = 1, move = "SCRATCH" } } },
  MEW = { dex = 151, name = "MEW", index = 151, growthRate = "GROWTH_MEDIUM_SLOW", baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialAttack = 100, specialDefense = 100 }, levelMoves = { { level = 1, move = "POUND" } } },
  CELEBI = { dex = 251, name = "CELEBI", index = 251, growthRate = "GROWTH_MEDIUM_FAST", baseStats = { hp = 100, attack = 100, defense = 100, speed = 100, specialAttack = 100, specialDefense = 100 }, levelMoves = { { level = 1, move = "CONFUSION" } } },
  BEYOND = { dex = 252, name = "BEYOND", index = 252, growthRate = "GROWTH_FAST", baseStats = {} },
}
local items = {
  BERRY = { index = 173, name = "BERRY", heldEffect = "HELD_BERRY", canToss = true, pocket = "ITEM", price = 10 },
  BERRY_JUICE = { index = 139, name = "BERRY JUICE", heldEffect = "HELD_BERRY", canToss = true, pocket = "ITEM", price = 100 },
  BRICK_PIECE = { index = 33, name = "BRICK PIECE", heldEffect = "HELD_NONE", canToss = true, pocket = "ITEM", price = 50 },
  LEFTOVERS = { index = 234, name = "LEFTOVERS", heldEffect = "HELD_LEFTOVERS", canToss = true, pocket = "ITEM", price = 10000 },
  BADGE = { index = 240, name = "BADGE", heldEffect = "HELD_NONE", canToss = false, pocket = "KEY_ITEM", price = 0 },
}
local byIndex = {}
for id, def in pairs(species) do byIndex[def.index] = id end

local game = {
  data = { gen2Maps = {}, pokemon = species, items = items, moves = {} },
  save = {
    flags = {}, party = {}, pokedex = { seen = {}, caught = {} },
    modData = {
      gen2_randomizer = {
        startup_config_confirmed = true,
        randomizer_mode = "logic",
        seed = 777,
      },
    },
  },
}
local dispatched
local mod = {
  id = "starter_picker", game = game,
  find = function(_, id)
    if id == "gen2_randomizer" then return { id = id, version = "0.1.3", exports = {} } end
    return nil
  end,
  content = {
    pokemon = { each = function() return pairs(species) end },
    items = { each = function() return pairs(items) end },
    map_scripts = { register = function() error("Gold must not register Gen 1 map scripts") end },
  },
  options = { define = function(_, schema) callbacks.schema = schema end, get = function(_, key) return optionValues[key] end },
  save = { get = function(_, key) return storage[key] end, set = function(_, key, value) storage[key] = value end },
  events = { on = function(_, name, fn, priority) callbacks.events[name] = { fn = fn, priority = priority } end },
  hooks = {
    wrap = function(_, name, fn, priority)
      callbacks.hooks[name] = fn
      callbacks.hookPriority[name] = priority
    end,
  },
}

assert(loadfile("/home/ubuntu/starter_picker/main.lua"))()(mod)
assert(#callbacks.schema == 6, "Gold starter options missing")
assert(callbacks.schema[1].key == "cyndaquil_ball", "Gold left ball option missing")
assert(callbacks.schema[5].key == "shiny_player_starter", "Gold shiny player starter option missing")
assert(callbacks.hookPriority["script.command"] == -10000,
  "Gold starter override did not register after Gen 2 Randomizer")
assert(callbacks.hookPriority["trainer.party"] == -10000,
  "Gold rival counter-pick did not register after Gen 2 Randomizer")
local choices = callbacks.schema[1].choices
local sawCelebi, sawBeyond = false, false
for _, row in ipairs(choices) do
  if row[2] == "CELEBI" then sawCelebi = true end
  if row[2] == "BEYOND" then sawBeyond = true end
end
assert(sawCelebi and not sawBeyond, "Gold picker did not limit choices to the standard 251 species")
local heldChoices = callbacks.schema[6].choices
local sawWeighted = false
for _, row in ipairs(heldChoices) do if row[2] == "RANDOM_WEIGHTED" then sawWeighted = true end end
assert(sawWeighted, "weighted Gold starter held-item option missing")

local function invokeGoldStarter(cmd)
  callbacks.hooks["script.command"](function(_, _, _, finalCmd)
    dispatched = finalCmd
    local monSpecies = assert(byIndex[finalCmd.species], "Gold givepoke species index was invalid")
    local itemName = finalCmd.item == 0 and nil
      or (finalCmd.item == 139 and "BERRY_JUICE")
      or (finalCmd.item == 173 and "BERRY")
      or (finalCmd.item == 33 and "BRICK_PIECE")
      or (finalCmd.item == 234 and "LEFTOVERS")
    game.save.party = {
      { species = monSpecies, level = 5, item = itemName,
        hp = 20, dvs = { hp = 8, attack = 8, defense = 8, speed = 8, special = 8 },
        statExp = { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 },
        stats = { hp = 20, attack = 10, defense = 10, speed = 10, specialAttack = 10, specialDefense = 10 },
      },
    }
  end, { generation = 2, mapId = "ELMS_LAB", object = 3 }, "givepoke", {}, cmd)
end

-- Model a confirmed LOGIC-mode Gen 2 Randomizer having already rewritten the
-- native Cyndaquil species to Chikorita before Starter Picker receives the
-- command. The named Cyndaquil-ball selector must be the final player result.
invokeGoldStarter({ species = 152, level = 5, item = 173 })
assert(dispatched.species == 251, "Elm’s Lab starter did not accept a Gen 2 dex-251 selection")
assert(dispatched.item == 139, "Gold selected starter held item was not written to givepoke")
assert(storage.gen2_randomizer_starter_override_active == true,
  "confirmed Gen 2 Randomizer LOGIC mode was not detected")
local player = game.save.party[1]
assert(player.species == "CELEBI" and player.item == "BERRY_JUICE", "Gold player starter was not created with the selected species and item")
assert(player.dvs.attack == 15 and player.dvs.defense == 15 and player.dvs.speed == 15
  and player.dvs.special == 15 and player.dvs.hp == 15, "Gold maximum DVs were not applied to the player starter")
assert(player.stats.specialAttack and player.stats.specialDefense, "Gold split Special stats were not recalculated")

-- Shiny is also player-only. It takes precedence when the maximum-DV toggle
-- is still on and creates a valid Gen 2 shiny combination from the stored DVs.
optionValues.shiny_player_starter = true
invokeGoldStarter({ species = 152, level = 5, item = 173 })
local shiny = game.save.party[1].dvs
local shinyAttack = { [2] = true, [3] = true, [6] = true, [7] = true, [10] = true, [11] = true, [14] = true, [15] = true }
assert(shinyAttack[shiny.attack] and shiny.defense == 10 and shiny.speed == 10 and shiny.special == 10,
  "Gold shiny player starter did not receive a valid shiny DV combination")
assert(shiny.hp == ((shiny.attack % 2 == 1) and 8 or 0),
  "Gold shiny player starter did not derive HP DV from the shiny stored DVs")
assert(storage.starter_shiny_dvs_applied == true and storage.starter_max_dvs_applied == nil,
  "Gold shiny starter did not take precedence over maximum DVs")
optionValues.shiny_player_starter = false

-- NO LOGIC is also an active Randomizer mode. VANILLA is deliberately not.
game.save.modData.gen2_randomizer.randomizer_mode = "nologic"
invokeGoldStarter({ species = 158, level = 5, item = 173 })
assert(storage.gen2_randomizer_starter_override_active == true,
  "confirmed Gen 2 Randomizer NO LOGIC mode was not detected")
game.save.modData.gen2_randomizer.randomizer_mode = "vanilla"
invokeGoldStarter({ species = 158, level = 5, item = 173 })
assert(storage.gen2_randomizer_starter_override_active == false,
  "Gen 2 Randomizer VANILLA mode was incorrectly reported as active")
game.save.modData.gen2_randomizer.randomizer_mode = "logic"

-- RANDOM (WEIGHTED) uses one persistent safe result for the selected player
-- starter. Changing the Randomizer seed afterward cannot reroll it.
optionValues.starter_held_item = "RANDOM_WEIGHTED"
storage.gold_weighted_starter_held_item_index = nil
storage.gold_weighted_starter_held_item_seed = nil
game.save.modData.gen2_randomizer.seed = 2468
invokeGoldStarter({ species = 155, level = 5, item = 173 })
local firstWeighted = dispatched.item
assert(firstWeighted == 0 or firstWeighted == 33 or firstWeighted == 139
  or firstWeighted == 173 or firstWeighted == 234,
  "weighted result was not empty or a safe tossable Gold item")
assert(storage.gold_weighted_starter_held_item_index == firstWeighted,
  "weighted result was not stored for the save")
game.save.modData.gen2_randomizer.seed = 999999
invokeGoldStarter({ species = 155, level = 5, item = 173 })
assert(dispatched.item == firstWeighted,
  "weighted starter held item rerolled after its persistent result was chosen")

-- The weighted table deliberately includes itemless outcomes. Search a finite
-- deterministic seed window to exercise the 40% no-item branch.
local sawNoItem = false
for seed = 1, 128 do
  storage.gold_weighted_starter_held_item_index = nil
  storage.gold_weighted_starter_held_item_seed = nil
  game.save.modData.gen2_randomizer.seed = seed
  invokeGoldStarter({ species = 155, level = 5, item = 173 })
  if dispatched.item == 0 then
    sawNoItem = true
    break
  end
end
assert(sawNoItem, "weighted Gold held-item mode did not produce a supported no-item outcome")

-- Never add an item to a native itemless starter command, even when weighted
-- mode is selected. In Gold's script representation, item index 0 means none.
storage.gold_weighted_starter_held_item_index = nil
storage.gold_weighted_starter_held_item_seed = nil
invokeGoldStarter({ species = 155, level = 5, item = 0 })
assert(dispatched.item == 0 and storage.gold_weighted_starter_held_item_index == 0,
  "weighted held-item mode added an item to an originally itemless starter")

local rivalVanilla = {
  { species = "ZUBAT", level = 5 },
  { species = "TOTODILE", level = 5, item = "BERRY", dvs = { hp = 1, attack = 1, defense = 1, speed = 1, special = 1 } },
}
local rival = callbacks.hooks["trainer.party"](function(_, _, party) return party end, "RIVAL1", "RIVAL1_1_TOTODILE", rivalVanilla)
assert(rival[#rival].species == "MEW", "Gold rival did not use the configured middle-ball counter-pick")
assert(rival[#rival].item == "BERRY" and rival[#rival].dvs.attack == 1 and rival[#rival].dvs.hp == 1,
  "player-only Gold starter handling changed the rival’s held item or DVs")
assert(rivalVanilla[#rivalVanilla].species == "TOTODILE", "Gold rival projection mutated the original party")
print("gold starter picker 1.0.1 harness: valid")
