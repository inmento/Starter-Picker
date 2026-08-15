local callbacks, storage = { hooks = {}, events = {} }, {}
local optionValues = {
  cyndaquil_ball = "CELEBI", totodile_ball = "MEW", chikorita_ball = "CHIKORITA",
  max_starter_dvs = true, starter_held_item = "BERRY_JUICE",
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
  BERRY = { index = 173, name = "BERRY", heldEffect = "HELD_BERRY", canToss = true, pocket = "ITEM" },
  BERRY_JUICE = { index = 139, name = "BERRY JUICE", heldEffect = "HELD_BERRY", canToss = true, pocket = "ITEM" },
}
local byIndex = {}
for id, def in pairs(species) do byIndex[def.index] = id end

local game = {
  data = { gen2Maps = {}, pokemon = species, items = items, moves = {} },
  save = { flags = {}, party = {}, pokedex = { seen = {}, caught = {} } },
}
local mod = {
  id = "starter_picker", game = game,
  content = {
    pokemon = { each = function() return pairs(species) end },
    items = { each = function() return pairs(items) end },
    map_scripts = { register = function() error("Gold must not register Gen 1 map scripts") end },
  },
  options = { define = function(_, schema) callbacks.schema = schema end, get = function(_, key) return optionValues[key] end },
  save = { get = function(_, key) return storage[key] end, set = function(_, key, value) storage[key] = value end },
  events = { on = function(_, name, fn, priority) callbacks.events[name] = { fn = fn, priority = priority } end },
  hooks = { wrap = function(_, name, fn) callbacks.hooks[name] = fn end },
}

assert(loadfile("/home/ubuntu/starter_picker/main.lua"))()(mod)
assert(#callbacks.schema == 5, "Gold starter options missing")
assert(callbacks.schema[1].key == "cyndaquil_ball", "Gold left ball option missing")
local choices = callbacks.schema[1].choices
local sawCelebi, sawBeyond = false, false
for _, row in ipairs(choices) do
  if row[2] == "CELEBI" then sawCelebi = true end
  if row[2] == "BEYOND" then sawBeyond = true end
end
assert(sawCelebi and not sawBeyond, "Gold picker did not limit choices to the standard 251 species")

local dispatched
callbacks.hooks["script.command"](function(_, _, _, cmd)
  dispatched = cmd
  local monSpecies = assert(byIndex[cmd.species], "Gold givepoke species index was invalid")
  game.save.party = {
    { species = monSpecies, level = 5, item = cmd.item == 139 and "BERRY_JUICE" or "BERRY",
      hp = 20, dvs = { hp = 8, attack = 8, defense = 8, speed = 8, special = 8 },
      statExp = { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 },
      stats = { hp = 20, attack = 10, defense = 10, speed = 10, specialAttack = 10, specialDefense = 10 },
    },
  }
end, { generation = 2, mapId = "ELMS_LAB", object = 3 }, "givepoke", {}, { species = 155, level = 5, item = 173 })
assert(dispatched.species == 251, "Elm’s Lab starter did not accept a Gen 2 dex-251 selection")
assert(dispatched.item == 139, "Gold selected starter held item was not written to givepoke")
local player = game.save.party[1]
assert(player.species == "CELEBI" and player.item == "BERRY_JUICE", "Gold player starter was not created with the selected species and item")
assert(player.dvs.attack == 15 and player.dvs.defense == 15 and player.dvs.speed == 15
  and player.dvs.special == 15 and player.dvs.hp == 15, "Gold maximum DVs were not applied to the player starter")
assert(player.stats.specialAttack and player.stats.specialDefense, "Gold split Special stats were not recalculated")

local rivalVanilla = { { species = "ZUBAT", level = 5 }, { species = "TOTODILE", level = 5, item = "BERRY", dvs = { hp = 1, attack = 1, defense = 1, speed = 1, special = 1 } } }
local rival = callbacks.hooks["trainer.party"](function(_, _, party) return party end, "RIVAL1", "RIVAL1_1_TOTODILE", rivalVanilla)
assert(rival[#rival].species == "MEW", "Gold rival did not use the configured middle-ball counter-pick")
assert(rival[#rival].item == "BERRY" and rival[#rival].dvs.attack == 1 and rival[#rival].dvs.hp == 1,
  "player-only Gold starter handling changed the rival’s held item or DVs")
assert(rivalVanilla[#rivalVanilla].species == "TOTODILE", "Gold rival projection mutated the original party")
print("gold starter picker harness: valid")
