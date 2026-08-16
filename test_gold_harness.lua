local callbacks, storage = { hooks = {}, events = {} }, {}

package.preload["src.core.GameVersion"] = function()
  return { get = function() return "gold" end }
end
package.preload["src.render.TextBox"] = function()
  return { new = function(_, text) return { text=text } end }
end
package.preload["src.battle.gen2.Mon"] = function()
  return {
    new = function(_, species, level, opts)
      return {
        species = species, level = level, item = opts.item, dvs = opts.dvs,
        hp = 20, statExp = { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 },
        stats = { hp = 20, attack = 10, defense = 10, speed = 10, specialAttack = 10, specialDefense = 10 },
      }
    end,
    refreshStats = function(mon)
      mon.stats = mon.stats or {}
      mon.stats.hp = mon.stats.hp or 20
      mon.hp = math.min(mon.hp or mon.stats.hp, mon.stats.hp)
    end,
  }
end

local optionValues = {
  cyndaquil_ball = "CELEBI",
  totodile_ball = "MEW",
  chikorita_ball = "CHIKORITA",
  gold_player_dv_mode = "MAX",
  gold_held_item = "BERRY_JUICE",
  starter_trade_evolution_42 = false,
  lock_confirmed_starter = false,
  starter_status = false,
  rival_preview = false,
  game_corner_exclusives = false,
}
local species = {
  CHIKORITA = { dex = 152, name = "CHIKORITA", index = 152, types = { "GRASS" } },
  CYNDAQUIL = { dex = 155, name = "CYNDAQUIL", index = 155, types = { "FIRE" } },
  TOTODILE = { dex = 158, name = "TOTODILE", index = 158, types = { "WATER" } },
  MEW = { dex = 151, name = "MEW", index = 151, types = { "WATER" } },
  CELEBI = { dex = 251, name = "CELEBI", index = 251, types = { "PSYCHIC", "GRASS" } },
  BEYOND = { dex = 252, name = "BEYOND", index = 252 },
}
local items = {
  BERRY = { index = 173, name = "BERRY", pocket = "ITEM", canToss = true },
  BERRY_JUICE = { index = 139, name = "BERRY JUICE", pocket = "ITEM", canToss = true },
  BADGE = { index = 240, name = "BADGE", pocket = "KEY_ITEM", canToss = false },
}
local byIndex = {}
for id, def in pairs(species) do byIndex[def.index] = id end

local openedText
local game = {
  data = { gen2Maps = {}, pokemon = species, items = items, moves = {}, gen2Text = {} },
  stack = { push = function(_, box) openedText = box and box.text end },
  save = {
    party = {}, pokedex = { seen = {}, caught = {} },
    options = { modOptions = { starter_picker = optionValues } },
    modData = { gen2_randomizer = { randomizer_mode = "logic" } },
  },
}
local mod = {
  id = "starter_picker", game = game,
  find = function() return nil end,
  content = {
    pokemon = { each = function() return pairs(species) end },
    items = { each = function() return pairs(items) end },
    map_scripts = { register = function() error("Gold must not register Gen 1 map scripts") end },
  },
  options = {
    define = function(_, schema) callbacks.schema = schema end,
    get = function(_, key) return optionValues[key] end,
  },
  save = {
    get = function(_, key) return storage[key] end,
    set = function(_, key, value) storage[key] = value end,
  },
  hooks = { wrap = function(_, name, fn) callbacks.hooks[name] = fn end },
  events = { on = function(_, name, fn) callbacks.events[name] = fn end },
}

assert(loadfile("main.lua"))()(mod)
assert(#callbacks.schema == 10, "expanded Gold starter option schema was not registered")
assert(callbacks.schema[1].key == "cyndaquil_ball", "Gold left-ball selector missing")
assert(callbacks.schema[4].key == "starter_trade_evolution_42", "shared trade fallback option missing")
assert(callbacks.schema[9].key == "gold_player_dv_mode", "Gold player-DV mode missing")
assert(callbacks.schema[10].key == "gold_held_item", "Gold held-item selector missing")

local previewPicture, previewCry
callbacks.hooks["script.command"](function(_, _, _, finalCmd)
  previewPicture = finalCmd
  return finalCmd
end, { generation = 2, scriptKey = "60:40c6" }, "pokepic", {}, { species = 155 })
callbacks.hooks["script.command"](function(_, _, _, finalCmd)
  previewCry = finalCmd
  return finalCmd
end, { generation = 2, scriptKey = "60:40c6" }, "cry", {}, { id = 155 })
assert(previewPicture and previewPicture.species == 251,
  "Gold Elm preview portrait did not use the configured left-ball species")
assert(previewCry and previewCry.id == 251,
  "Gold Elm preview cry did not use the configured left-ball species")

local dispatched
callbacks.hooks["script.command"](function(_, _, _, finalCmd)
  dispatched = finalCmd
  local starterId = assert(byIndex[finalCmd.species], "rewritten Gold starter index was invalid")
  table.insert(game.save.party,
    { species = starterId, level = finalCmd.level, item = finalCmd.item,
      dvs = { attack = 1, defense = 1, speed = 1, special = 1 }, hp = 20,
      stats = { hp = 20 }, statExp = {} })
end, { generation = 2, scriptKey = "60:40c6" }, "givepoke", {},
  { species = 151, level = 5, item = 173 })
assert(dispatched and dispatched.species == 151, "Gold accepted starter did not retain the transformed species")
assert(dispatched.item == 139, "Gold accepted starter did not use configured held item")
local player = game.save.party[1]
assert(player.species == "MEW" and player.name == "MEW", "Gold player starter was not rebuilt correctly")
assert(player.item == "BERRY_JUICE", "Gold player starter held item was not preserved as the selected ID")
assert(player.dvs.attack == 15 and player.dvs.defense == 15
  and player.dvs.speed == 15 and player.dvs.special == 15,
  "Gold maximum player starter DVs were not applied")
assert(game.save.pokedex.seen.MEW and game.save.pokedex.caught.MEW,
  "Gold synchronized starter did not update Pokédex ownership")
assert(optionValues.cyndaquil_ball == "MEW",
  "Gold Randomizer-transformed starter was not copied into Starter Picker options")
assert(storage.finalized_starter_selection and storage.finalized_starter_selection.species == "MEW",
  "Gold finalized starter record was not stored")
callbacks.events["mod.options_changed"]({ mod="starter_picker", key="starter_status", value=true })
assert(openedText and openedText:find("CONFIRMED LEFT", 1, true),
  "Gold starter status did not report the finalized selection")
callbacks.events["mod.options_changed"]({ mod="starter_picker", key="rival_preview", value=true })
assert(openedText and openedText:find("RIVAL", 1, true), "Gold rival preview did not open")
optionValues.gold_held_item = "RECOVERY"
callbacks.events["mod.options_changed"]({ mod="starter_picker", key="gold_held_item", value="RECOVERY" })
assert(game.save.party[1].item == "BERRY" or game.save.party[1].item == "BERRY_JUICE",
  "Gold recovery held-item mode did not choose a safe recovery item")
optionValues.gold_held_item = "NONE"
callbacks.events["mod.options_changed"]({ mod="starter_picker", key="gold_held_item", value="NONE" })
assert(game.save.party[1].item == nil, "Gold no-item starter mode did not remove the held item")

local rivalParty = { { species = "CYNDAQUIL", level = 5 } }
local projected = callbacks.hooks["trainer.party"](
  function(_, _, party) return party end, 9, 1, rivalParty)
assert(projected[#projected].species == "CHIKORITA",
  "Gold rival did not choose the weakness-aware counter starter")
assert(rivalParty[#rivalParty].species == "CYNDAQUIL",
  "Gold rival projection mutated the vanilla party")

print("gold starter picker randomizer-sync, preview-cry, accepted-starter, held-item, DV, and rival harness: valid")
