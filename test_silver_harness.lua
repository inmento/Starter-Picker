local callbacks = { hooks = {}, events = {} }

package.preload["src.core.GameVersion"] = function()
  return {
    get = function() return "silver" end,
    generation = function(id)
      assert(id == "silver", "Starter Picker must classify the active Silver version")
      return 2
    end,
  }
end
package.preload["src.render.TextBox"] = function()
  return { new = function(_, text) return { text = text } end }
end

local optionValues = {
  cyndaquil_ball = "CYNDAQUIL",
  totodile_ball = "TOTODILE",
  chikorita_ball = "CHIKORITA",
  gold_player_dv_mode = "NATIVE",
  gold_held_item = "NONE",
  starter_trade_evolution_42 = false,
  lock_confirmed_starter = false,
  starter_status = false,
  rival_preview = false,
  game_corner_exclusives = false,
}
local species = {
  CYNDAQUIL = { dex = 155, index = 155, name = "CYNDAQUIL", types = { "FIRE" } },
  TOTODILE = { dex = 158, index = 158, name = "TOTODILE", types = { "WATER" } },
  CHIKORITA = { dex = 152, index = 152, name = "CHIKORITA", types = { "GRASS" } },
}
local game = {
  data = { gen2Maps = {}, pokemon = species, items = {}, moves = {}, gen2Text = {} },
  save = { party = {}, options = { modOptions = { starter_picker = optionValues } }, modData = {} },
  stack = { push = function() end },
}
local mod = {
  id = "starter_picker",
  game = game,
  find = function() return nil end,
  content = {
    pokemon = { each = function() return pairs(species) end },
    items = { each = function() return function() return nil end end },
    map_scripts = { register = function() error("Silver must not register Gen 1 Oak map scripts") end },
  },
  options = {
    define = function(_, schema) callbacks.schema = schema end,
    get = function(_, key) return optionValues[key] end,
  },
  save = { get = function() return nil end, set = function() end },
  hooks = { wrap = function(_, name, fn) callbacks.hooks[name] = fn end },
  events = { on = function(_, name, fn) callbacks.events[name] = fn end },
}

assert(loadfile("main.lua"))()(mod)
assert(callbacks.schema[1].key == "cyndaquil_ball"
  and callbacks.schema[2].key == "totodile_ball"
  and callbacks.schema[3].key == "chikorita_ball",
  "Silver must expose the three Gen 2 Elm starter selectors")
assert(callbacks.hooks["script.command"], "Silver must install the Gen 2 script command hook")
assert(callbacks.hooks["trainer.party"], "Silver must install the Gen 2 rival-party hook")

print("Silver Starter Picker routing harness: valid")
