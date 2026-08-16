local callbacks, storage = { hooks = {}, events = {} }, {}

package.preload["src.core.GameVersion"] = function()
  return { get = function() return "gold" end }
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
}
local species = {
  CHIKORITA = { dex = 152, name = "CHIKORITA", index = 152 },
  CYNDAQUIL = { dex = 155, name = "CYNDAQUIL", index = 155 },
  TOTODILE = { dex = 158, name = "TOTODILE", index = 158 },
  MEW = { dex = 151, name = "MEW", index = 151 },
  CELEBI = { dex = 251, name = "CELEBI", index = 251 },
  BEYOND = { dex = 252, name = "BEYOND", index = 252 },
}
local items = {
  BERRY = { index = 173, name = "BERRY", pocket = "ITEM", canToss = true },
  BERRY_JUICE = { index = 139, name = "BERRY JUICE", pocket = "ITEM", canToss = true },
  BADGE = { index = 240, name = "BADGE", pocket = "KEY_ITEM", canToss = false },
}
local byIndex = {}
for id, def in pairs(species) do byIndex[def.index] = id end

local game = {
  data = { gen2Maps = {}, pokemon = species, items = items, moves = {}, gen2Text = {} },
  save = { party = {}, pokedex = { seen = {}, caught = {} }, modData = {} },
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
assert(#callbacks.schema == 5, "current Gold option schema was not registered")
assert(callbacks.schema[1].key == "cyndaquil_ball", "Gold left-ball selector missing")
assert(callbacks.schema[4].key == "gold_player_dv_mode", "Gold player-DV mode missing")
assert(callbacks.schema[5].key == "gold_held_item", "Gold held-item selector missing")

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
  { species = 155, level = 5, item = 173 })
assert(dispatched and dispatched.species == 251, "Gold accepted starter did not use configured species")
assert(dispatched.item == 139, "Gold accepted starter did not use configured held item")
local player = game.save.party[1]
assert(player.species == "CELEBI" and player.name == "CELEBI", "Gold player starter was not rebuilt correctly")
assert(player.item == "BERRY_JUICE", "Gold player starter held item was not preserved as the selected ID")
assert(player.dvs.attack == 15 and player.dvs.defense == 15
  and player.dvs.speed == 15 and player.dvs.special == 15,
  "Gold maximum player starter DVs were not applied")
assert(game.save.pokedex.seen.CELEBI and game.save.pokedex.caught.CELEBI,
  "Gold starter replacement did not update Pokédex ownership")

print("gold starter picker option, preview-cry, accepted-starter, held-item, and DV harness: valid")
