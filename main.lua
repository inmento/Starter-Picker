-- Starter Picker
-- Gen 1 Recomp mod API 2
--
-- The three Oak's Lab ball positions retain their native relationship:
-- choosing left gives the rival the configured middle-ball Pokémon;
-- choosing middle gives the rival the configured right-ball Pokémon;
-- choosing right gives the rival the configured left-ball Pokémon.

return function(mod)
  local function isGen2(game)
    game = game or mod.game
    return game and game.data and game.data.gen2Maps ~= nil
  end

  local GEN1_SLOTS = {
    LEFT = {
      option = "charmander_ball", default = "CHARMANDER",
      ballText = "TEXT_OAKSLAB_CHARMANDER_POKE_BALL",
      ballObject = "OAKSLAB_CHARMANDER_POKE_BALL",
      choseFlag = "EVENT_CHOSE_CHARMANDER",
      rivalSlot = "MIDDLE",
      rivalBallObject = "OAKSLAB_SQUIRTLE_POKE_BALL",
    },
    MIDDLE = {
      option = "squirtle_ball", default = "SQUIRTLE",
      ballText = "TEXT_OAKSLAB_SQUIRTLE_POKE_BALL",
      ballObject = "OAKSLAB_SQUIRTLE_POKE_BALL",
      choseFlag = "EVENT_CHOSE_SQUIRTLE",
      rivalSlot = "RIGHT",
      rivalBallObject = "OAKSLAB_BULBASAUR_POKE_BALL",
    },
    RIGHT = {
      option = "bulbasaur_ball", default = "BULBASAUR",
      ballText = "TEXT_OAKSLAB_BULBASAUR_POKE_BALL",
      ballObject = "OAKSLAB_BULBASAUR_POKE_BALL",
      choseFlag = "EVENT_CHOSE_BULBASAUR",
      rivalSlot = "LEFT",
      rivalBallObject = "OAKSLAB_CHARMANDER_POKE_BALL",
    },
  }

  local GOLD_SLOTS = {
    LEFT = {
      option = "cyndaquil_ball", default = "CYNDAQUIL", objectIndex = 3,
      scriptKey = "60:40c6", promptText = "60:45e3", promptLead = "ELM: You'll take",
      nativeSpeciesIndex = 155, rivalSlot = "MIDDLE",
    },
    MIDDLE = {
      option = "totodile_ball", default = "TOTODILE", objectIndex = 4,
      scriptKey = "60:4108", promptText = "60:460e", promptLead = "ELM: Do you want",
      nativeSpeciesIndex = 158, rivalSlot = "RIGHT",
    },
    RIGHT = {
      option = "chikorita_ball", default = "CHIKORITA", objectIndex = 5,
      scriptKey = "60:4144", promptText = "60:463a", promptLead = "ELM: So, you like",
      nativeSpeciesIndex = 152, rivalSlot = "LEFT",
    },
  }

  local SLOTS = isGen2() and GOLD_SLOTS or GEN1_SLOTS

  local PENDING_STARTER_SLOT_KEY = "pending_starter_slot"
  local STARTER_SLOT_KEY = "received_starter_slot"
  local STARTER_SPECIES_KEY = "received_starter_species"
  local RANDOMIZER_ID = isGen2() and "gen2_randomizer" or "gen1_randomizer"
  local RANDOMIZER_OVERRIDE_KEY = isGen2()
    and "gen2_randomizer_starter_override_active"
    or "gen1_randomizer_starter_override_active"
  local MAX_STARTER_DVS_OPTION = "max_starter_dvs"
  local PENDING_MAX_STARTER_DVS_KEY = "pending_max_starter_dvs"
  local MAX_STARTER_DVS_APPLIED_KEY = "starter_max_dvs_applied"
  local GOLD_RECEIVED_KEY = "gold_received_starter"
  local GOLD_ITEM_KEY = "gold_starter_item"
  local GOLD_DVS_KEY = "gold_starter_dvs"
  local lastGame = mod.game
  local findTrackedStarter
  local SLOT_NAME_BY_OPTION = {
    [SLOTS.LEFT.option] = "LEFT",
    [SLOTS.MIDDLE.option] = "MIDDLE",
    [SLOTS.RIGHT.option] = "RIGHT",
  }

  local function choiceRows()
    local rows = {}
    for speciesId, pokemon in mod.content.pokemon:each() do
      local maxDex = isGen2() and 251 or 151
      if type(pokemon.dex) == "number" and pokemon.dex >= 1 and pokemon.dex <= maxDex then
        rows[#rows + 1] = { string.format("%03d %s", pokemon.dex, pokemon.name), speciesId }
      end
    end
    table.sort(rows, function(a, b) return a[1] < b[1] end)
    return rows
  end

  local CHOICES = choiceRows()
  local GOLD_DV_MODE_OPTION = "gold_player_dv_mode"
  local GOLD_HELD_ITEM_OPTION = "gold_held_item"

  local function goldHeldItemChoices()
    local rows = {
      { "VANILLA", "VANILLA" },
      { "RANDOM WEIGHTED", "RANDOM" },
    }
    if not (isGen2() and mod.content.items and mod.content.items.each) then return rows end
    for itemId, item in mod.content.items:each() do
      if type(itemId) == "string" and type(item) == "table" and item.index
        and item.canToss ~= false and item.keyItem ~= true
        and item.pocket ~= "KEY_ITEM" then
        rows[#rows + 1] = { string.format("%03d %s", item.index, item.name or itemId), itemId }
      end
    end
    table.sort(rows, function(a, b)
      if a[2] == "VANILLA" then return true end
      if b[2] == "VANILLA" then return false end
      if a[2] == "RANDOM" then return true end
      if b[2] == "RANDOM" then return false end
      return a[1] < b[1]
    end)
    return rows
  end

  local optionDefs = {
    {
      key = SLOTS.LEFT.option,
      label = isGen2() and "CYNDAQUIL BALL" or "CHARMANDER BALL",
      type = "choice", default = SLOTS.LEFT.default, choices = CHOICES,
    },
    {
      key = SLOTS.MIDDLE.option,
      label = isGen2() and "TOTODILE BALL" or "SQUIRTLE BALL",
      type = "choice", default = SLOTS.MIDDLE.default, choices = CHOICES,
    },
    {
      key = SLOTS.RIGHT.option,
      label = isGen2() and "CHIKORITA BALL" or "BULBASAUR BALL",
      type = "choice", default = SLOTS.RIGHT.default, choices = CHOICES,
    },
  }
  if isGen2() then
    optionDefs[#optionDefs + 1] = {
      key = GOLD_DV_MODE_OPTION, label = "PLAYER DV MODE", type = "choice",
      default = "PRESERVE",
      choices = {
        { "PRESERVE", "PRESERVE" }, { "MAX", "MAX" },
        { "RANDOM", "RANDOM" }, { "SHINY", "SHINY" },
      },
    }
    optionDefs[#optionDefs + 1] = {
      key = GOLD_HELD_ITEM_OPTION, label = "HELD ITEM", type = "choice",
      default = "VANILLA", choices = goldHeldItemChoices(),
    }
  else
    optionDefs[#optionDefs + 1] = {
      key = MAX_STARTER_DVS_OPTION, label = "MAX PLAYER STARTER DVS",
      type = "toggle", default = false,
    }
  end
  mod.options:define(optionDefs)

  local function validSpecies(game, speciesId)
    return type(speciesId) == "string"
      and game and game.data and game.data.pokemon
      and game.data.pokemon[speciesId] ~= nil
  end

  local function selectedSpecies(game, slot)
    local chosen = mod.options:get(slot.option)
    if validSpecies(game, chosen) then return chosen end
    return slot.default
  end

  -- Gen 1 Randomizer randomizes Oak's Lab starters only after its setup has
  -- been confirmed and its mode is LOGIC or NO LOGIC. Read its per-save state
  -- rather than assuming installation alone means starter randomization.
  local function randomizerStarterRandomizationActive(game)
    local state = game and game.save and game.save.modData
      and game.save.modData[RANDOMIZER_ID]
    if type(state) ~= "table" then return false end

    local installed = false
    if type(mod.find) == "function" then
      local ok, handle = pcall(mod.find, mod, RANDOMIZER_ID)
      installed = ok and handle ~= nil
    end
    if not installed then return false end

    local mode = tostring(state.randomizer_mode or "vanilla")
    return state.startup_config_confirmed == true
      and (mode == "logic" or mode == "nologic")
  end

  local function chosenStarterSlot(flags)
    if flags.EVENT_CHOSE_CHARMANDER then return "LEFT" end
    if flags.EVENT_CHOSE_SQUIRTLE then return "MIDDLE" end
    if flags.EVENT_CHOSE_BULBASAUR then return "RIGHT" end
    return nil
  end

  local function expForLevel(growthRate, level)
    if growthRate == "SLIGHTLY_FAST" then
      return math.max(0, math.floor((3 * level ^ 3) / 4) + 10 * level ^ 2 - 30)
    elseif growthRate == "SLIGHTLY_SLOW" then
      return math.max(0, math.floor((3 * level ^ 3) / 4) + 20 * level ^ 2 - 70)
    elseif growthRate == "MEDIUM_SLOW" then
      return math.max(0, math.floor((6 * level ^ 3) / 5) - 15 * level ^ 2
        + 100 * level - 140)
    elseif growthRate == "FAST" then
      return math.floor((4 * level ^ 3) / 5)
    elseif growthRate == "SLOW" then
      return math.floor((5 * level ^ 3) / 4)
    end
    return level ^ 3 -- MEDIUM_FAST and a safe fallback
  end

  local function recalculatedStats(speciesDef, level, dvs, statExp)
    local stats = {}
    local keys = { "hp", "attack", "defense", "speed", "special" }
    for _, key in ipairs(keys) do
      local base = (speciesDef.baseStats and speciesDef.baseStats[key]) or 1
      local dv = (dvs and dvs[key]) or 0
      local ev = math.floor(math.min(255,
        math.ceil(math.sqrt((statExp and statExp[key]) or 0))) / 4)
      local value = math.floor(((base + dv) * 2 + ev) * level / 100)
      stats[key] = value + (key == "hp" and level + 10 or 5)
    end
    return stats
  end

  -- In Gen 1, HP DV is derived from the low bits of Attack, Defense, Speed,
  -- and Special. Four maximum DVs therefore make HP maximum as well.
  local function maxDVs()
    return { hp = 15, attack = 15, defense = 15, speed = 15, special = 15 }
  end

  local function forceMaxDVs(game, mon)
    local speciesDef = game and game.data and game.data.pokemon
      and mon and game.data.pokemon[mon.species]
    if type(mon) ~= "table" or not speciesDef then return false end

    local level = math.max(1, math.min(100, tonumber(mon.level) or 5))
    local oldMaxHp = mon.stats and mon.stats.hp or mon.hp or 1
    local hpLost = math.max(0, oldMaxHp - (tonumber(mon.hp) or oldMaxHp))
    mon.statExp = mon.statExp
      or { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 }
    mon.dvs = maxDVs()
    mon.stats = recalculatedStats(speciesDef, level, mon.dvs, mon.statExp)
    mon.hp = math.max(1, mon.stats.hp - hpLost)
    return true
  end

  local function copyDVs(dvs)
    local out = {}
    for _, key in ipairs({ "attack", "defense", "speed", "special", "hp" }) do
      if dvs and dvs[key] ~= nil then out[key] = dvs[key] end
    end
    return out
  end

  local function randomDv()
    if love and love.math and love.math.random then return love.math.random(0, 15) end
    return math.random(0, 15)
  end

  local function goldDvMode()
    local mode = mod.options:get("player_starter_dv_mode") or mod.options:get(GOLD_DV_MODE_OPTION)
    if mode == "MAX" or mode == "RANDOM" or mode == "SHINY" then return mode end
    return "PRESERVE"
  end

  local function goldDVs(existing)
    local mode = goldDvMode()
    if mode == "PRESERVE" then return copyDVs(existing) end
    if mode == "MAX" then return { attack = 15, defense = 15, speed = 15, special = 15 } end
    if mode == "SHINY" then
      local attack = ({ 2, 3, 6, 7, 10, 11, 14, 15 })[randomDv() % 8 + 1]
      return { attack = attack, defense = 10, speed = 10, special = 10 }
    end
    local saved = mod.save:get(GOLD_DVS_KEY)
    if type(saved) == "table" then return copyDVs(saved) end
    saved = { attack = randomDv(), defense = randomDv(), speed = randomDv(), special = randomDv() }
    mod.save:set(GOLD_DVS_KEY, saved)
    return copyDVs(saved)
  end

  local function goldItemIndex(game, itemId)
    for id, item in pairs(game and game.data and game.data.items or {}) do
      if id == itemId and type(item) == "table" then return item.index end
    end
    return nil
  end

  local function goldHeldItem(game, nativeItem)
    local selected = mod.options:get("starter_held_item") or mod.options:get(GOLD_HELD_ITEM_OPTION)
    if selected == "VANILLA" or selected == nil then return nativeItem end
    if selected ~= "RANDOM" and goldItemIndex(game, selected) then return selected end

    local saved = mod.save:get(GOLD_ITEM_KEY)
    if saved == "NONE" then return nil end
    if goldItemIndex(game, saved) then return saved end
    if randomDv() < 6 then
      mod.save:set(GOLD_ITEM_KEY, "NONE")
      return nil
    end

    local pool = {}
    for itemId, item in pairs(game and game.data and game.data.items or {}) do
      if type(itemId) == "string" and type(item) == "table" and item.index
        and item.canToss ~= false and item.keyItem ~= true
        and item.pocket ~= "KEY_ITEM" then
        pool[#pool + 1] = itemId
      end
    end
    table.sort(pool)
    if #pool == 0 then return nativeItem end
    local choice = pool[randomDv() % #pool + 1]
    mod.save:set(GOLD_ITEM_KEY, choice)
    return choice
  end

  local function goldSlotForScript(ctx)
    if not (ctx and ctx.generation == 2 and ctx.scriptKey) then return nil end
    for slotName, slot in pairs(GOLD_SLOTS) do
      if ctx.scriptKey == slot.scriptKey then return slotName end
    end
    return nil
  end

  local function goldDisplayName(game, species)
    local def = game and game.data and game.data.pokemon and game.data.pokemon[species]
    return tostring((def and def.name) or species):upper()
  end

  local function updateGoldElmPrompt(game, slotName)
    local slot = GOLD_SLOTS[slotName]
    if not (slot and slot.promptText) then return end
    local text = game and game.data and (game.data.gen2Text or game.data.text)
    if type(text) ~= "table" then return end
    local species = selectedSpecies(game, slot)
    text[slot.promptText] = string.format("%s\n%s, the\nPOKéMON?", slot.promptLead, goldDisplayName(game, species))
    -- World keeps the same source table in normal Gold play, but update its
    -- live reference too so the current Elm script sees a changed selection.
    if game.world and type(game.world.text) == "table" then
      game.world.text[slot.promptText] = text[slot.promptText]
    end
  end

  local function rebuildGoldStarter(game, mon, slotName)
    if not (isGen2(game) and type(mon) == "table" and GOLD_SLOTS[slotName]) then return false end
    local Mon = require("src.battle.gen2.Mon")
    local slot = GOLD_SLOTS[slotName]
    local species = selectedSpecies(game, slot)
    local firstGift = not mod.save:get(GOLD_RECEIVED_KEY)
    local old = {
      ot = mon.ot, otName = mon.otName, otId = mon.otId, nickname = mon.nickname,
      happiness = mon.happiness, pokerus = mon.pokerus,
    }
    local replacement = Mon.new(game.data, species, mon.level or 5, {
      dvs = goldDVs(mon.dvs), item = goldHeldItem(game, mon.item),
      nickname = firstGift and nil or old.nickname, happiness = old.happiness, pokerus = old.pokerus,
    })
    if not replacement then return false end
    -- The Elm choice screen and party summary use the selected species name,
    -- not the native ball species or a carried-over nickname from recovery.
    replacement.name = goldDisplayName(game, species)
    for key in pairs(mon) do mon[key] = nil end
    for key, value in pairs(replacement) do mon[key] = value end
    mon.ot, mon.otName, mon.otId = old.ot, old.otName, old.otId
    Mon.refreshStats(mon, game.data)
    local dex = game.save and game.save.pokedex
    if dex then
      dex.seen, dex.caught = dex.seen or {}, dex.caught or {}
      dex.seen[species], dex.caught[species] = true, true
    end
    mod.save:set(STARTER_SLOT_KEY, slotName)
    mod.save:set(STARTER_SPECIES_KEY, species)
    mod.save:set(GOLD_RECEIVED_KEY, true)
    return true
  end

  local function applyGoldLiveSettings(game)
    if not (isGen2(game) and mod.save:get(GOLD_RECEIVED_KEY)) then return end
    local slotName = mod.save:get(STARTER_SLOT_KEY)
    local mon = findTrackedStarter(game, mod.save:get(STARTER_SPECIES_KEY))
    if slotName and mon then rebuildGoldStarter(game, mon, slotName) end
  end

  local function movesAtLevel(game, speciesDef, level)
    local ids, seen = {}, {}
    local function add(moveId)
      if moveId and not seen[moveId] then
        seen[moveId] = true
        ids[#ids + 1] = moveId
      end
    end
    for _, moveId in ipairs(speciesDef.level1Moves or {}) do add(moveId) end
    for _, entry in ipairs(speciesDef.learnset or {}) do
      if entry.level <= level then add(entry.move) end
    end
    while #ids > 4 do table.remove(ids, 1) end

    local moves = {}
    for _, moveId in ipairs(ids) do
      local moveDef = game.data.moves and game.data.moves[moveId] or {}
      moves[#moves + 1] = { id = moveId, pp = moveDef.pp or 0 }
    end
    return moves
  end

  local function replaceStarterSpecies(game, mon, speciesId)
    local speciesDef = game and game.data and game.data.pokemon
      and game.data.pokemon[speciesId]
    if type(mon) ~= "table" or not speciesDef then return false end

    local level = math.max(1, math.min(100, tonumber(mon.level) or 5))
    local oldMaxHp = mon.stats and mon.stats.hp or mon.hp or 1
    local hpLost = math.max(0, oldMaxHp - (tonumber(mon.hp) or oldMaxHp))
    mon.dvs = mon.dvs or { attack = 0, defense = 0, speed = 0, special = 0, hp = 0 }
    mon.statExp = mon.statExp
      or { hp = 0, attack = 0, defense = 0, speed = 0, special = 0 }
    mon.species = speciesId
    mon.level = level
    mon.exp = expForLevel(speciesDef.growthRate, level)
    mon.stats = recalculatedStats(speciesDef, level, mon.dvs, mon.statExp)
    mon.hp = math.max(1, mon.stats.hp - hpLost)
    mon.moves = movesAtLevel(game, speciesDef, level)
    mon.catchRate = speciesDef.catchRate
    mon.status = nil

    local dex = game.save and game.save.pokedex
    if dex then
      dex.seen = dex.seen or {}
      dex.owned = dex.owned or {}
      dex.seen[speciesId] = true
      dex.owned[speciesId] = true
    end
    return true
  end

  findTrackedStarter = function(game, expectedSpecies)
    local party = game and game.save and game.save.party or {}
    for _, mon in ipairs(party) do
      if mon.species == expectedSpecies then return mon end
    end
    -- An older release cannot have stored a species marker. With only one
    -- party member, that Pokémon is unambiguously the player’s starter.
    if #party == 1 then return party[1] end
    return nil
  end

  local function applyPostLabMaxDVs(game)
    if isGen2(game) then return false end
    local flags = game and game.save and game.save.flags or {}
    -- The player-selected ball is stored before the gift is constructed. It
    -- remains a reliable starter marker even during the short window before
    -- Oak's Lab commits EVENT_GOT_STARTER to the save.
    if not flags.EVENT_GOT_STARTER and not mod.save:get(STARTER_SLOT_KEY) then return false end

    local mon = findTrackedStarter(game, mod.save:get(STARTER_SPECIES_KEY))
    if forceMaxDVs(game, mon) then
      mod.save:set(MAX_STARTER_DVS_APPLIED_KEY, true)
      return true
    end
    return false
  end

  local function applyPendingMaxDVs(game)
    if isGen2(game) or not mod.save:get(PENDING_MAX_STARTER_DVS_KEY) then return false end
    local mon = findTrackedStarter(game, mod.save:get(STARTER_SPECIES_KEY))
    if forceMaxDVs(game, mon) then
      mod.save:set(MAX_STARTER_DVS_APPLIED_KEY, true)
      mod.save:set(PENDING_MAX_STARTER_DVS_KEY, nil)
      return true
    end
    return false
  end

  local function applyPostLabSelection(game, slotName)
    if isGen2(game) then return end
    local flags = game and game.save and game.save.flags or {}
    local chosenSlot = mod.save:get(STARTER_SLOT_KEY) or chosenStarterSlot(flags)
    if not flags.EVENT_GOT_STARTER or chosenSlot ~= slotName then return end

    local species = selectedSpecies(game, SLOTS[slotName])
    local mon = findTrackedStarter(game, mod.save:get(STARTER_SPECIES_KEY))
    if replaceStarterSpecies(game, mon, species) then
      if mod.options:get(MAX_STARTER_DVS_OPTION) == true then
        forceMaxDVs(game, mon)
        mod.save:set(MAX_STARTER_DVS_APPLIED_KEY, true)
      end
      mod.save:set(STARTER_SLOT_KEY, slotName)
      mod.save:set(STARTER_SPECIES_KEY, species)
    end
  end

  mod.events:on("game.ready", function(event)
    lastGame = (event and event.game) or lastGame or mod.game
    if not isGen2(lastGame) and mod.options:get(MAX_STARTER_DVS_OPTION) == true then
      applyPostLabMaxDVs(lastGame)
    end
  end)

  mod.events:on("mod.options_changed", function(event)
    if type(event) ~= "table" then return end
    local changedModId = type(event.mod) == "table" and event.mod.id or event.mod
    if changedModId ~= mod.id then return end

    local game = mod.game or lastGame
    if isGen2(game) then
      if SLOT_NAME_BY_OPTION[event.key] or event.key == GOLD_DV_MODE_OPTION
        or event.key == GOLD_HELD_ITEM_OPTION or event.key == "player_starter_dv_mode"
        or event.key == "starter_held_item" or event.key == "starter_settings_scope" then
        applyGoldLiveSettings(game)
      end
      return
    end

    local slotName = SLOT_NAME_BY_OPTION[event.key]
    if slotName then
      applyPostLabSelection(game, slotName)
    elseif event.key == MAX_STARTER_DVS_OPTION and event.value == true then
      -- Turning the setting on after Oak's Lab upgrades only the tracked
      -- player starter. Turning it off deliberately does not rewrite DVs.
      applyPostLabMaxDVs(mod.game or lastGame)
    end
  end)

  -- `pokemon.before_give` runs before the engine constructs the Pokémon, and
  -- its current public payload only applies species, level, and nickname.
  -- The first screen after Oak's Lab's give command is the nickname prompt;
  -- by then the player mon has entered the party, so this applies DVs only to
  -- that marked gift and never enters the independent trainer.party path.
  if not isGen2() then
    mod.events:on("screen.pushed", function()
      applyPendingMaxDVs(lastGame or mod.game)
    end)

    -- Oak's Lab can reach the player starter through different presentation
    -- paths. Script completion is the definitive post-gift boundary, so it is a
    -- second chance to apply the pending player-only maximum DVs if a screen
    -- transition was skipped or handled by another mod.
    mod.events:on("script.ended", function(event)
      local game = (event and event.ctx and event.ctx.game) or lastGame or mod.game
      if event and event.completed == false then return end
      applyPendingMaxDVs(game)
    end)
  end

  -- The generic mod-manager choice control changes one entry per button press.
  -- Gen 1 adds a compact browser under START > OPTIONS instead: holding Up or
  -- Down repeats, Left/Right jump ten Pokédex entries, A confirms, and B
  -- cancels. Gold does not register this UI hook.
  local GEN1_CHOICE_INDEX = {}
  if not isGen2() then
    for index, row in ipairs(CHOICES) do GEN1_CHOICE_INDEX[row[2]] = index end
  end

  local function setGen1PickerOption(game, key, value)
    if not (game and game.save) then return false end
    game.save.options = game.save.options or {}
    game.save.options.modOptions = game.save.options.modOptions or {}
    game.save.options.modOptions[mod.id] = game.save.options.modOptions[mod.id] or {}
    game.save.options.modOptions[mod.id][key] = value

    local loader = game.mods
    if loader then
      loader.modOptions = loader.modOptions or {}
      loader.modOptions[mod.id] = loader.modOptions[mod.id] or {}
      loader.modOptions[mod.id][key] = value
    end
    if game.writeOptions then game:writeOptions() end
    if loader and loader.events then
      loader.events:emit("mod.options_changed", { mod = mod.id, key = key, value = value })
    else
      local slotName = SLOT_NAME_BY_OPTION[key]
      if slotName then applyPostLabSelection(game, slotName) end
    end
    return true
  end

  local function openGen1SpeciesBrowser(game, slotName)
    if isGen2(game) or not (game and game.stack and game.stack.push) then return end
    local slot = GEN1_SLOTS[slotName]
    if not slot then return end
    local Font = require("src.render.Font")
    local Theme = require("src.ui.Theme")
    local index = GEN1_CHOICE_INDEX[selectedSpecies(game, slot)] or 1
    local screen = { game = game, isOpaque = true, repeatDir = nil, repeatLeft = 0 }

    local function move(dir)
      index = ((index - 1 + dir) % #CHOICES) + 1
    end

    function screen:update(dt)
      local input = self.game.input
      local dir = input:wasPressed("up") and -1 or (input:wasPressed("down") and 1 or nil)
      if dir then
        move(dir)
        self.repeatDir, self.repeatLeft = dir, 0.35
      elseif self.repeatDir and input:isDown(self.repeatDir < 0 and "up" or "down") then
        self.repeatLeft = self.repeatLeft - (dt or 0)
        while self.repeatLeft <= 0 do
          move(self.repeatDir)
          self.repeatLeft = self.repeatLeft + 0.075
        end
      else
        self.repeatDir, self.repeatLeft = nil, 0
      end

      if input:wasPressed("left") then
        move(-10)
      elseif input:wasPressed("right") then
        move(10)
      elseif input:wasPressed("a") then
        setGen1PickerOption(self.game, slot.option, CHOICES[index][2])
        self.game.stack:pop()
      elseif input:wasPressed("b") then
        self.game.stack:pop()
      end
    end

    function screen:draw()
      Font.drawBox(0, 0, 20, 18)
      love.graphics.setColor(0, 0, 0, 1)
      Font.draw("PICK " .. slotName .. " BALL", 16, 8)
      local first = math.max(1, math.min(#CHOICES - 6, index - 3))
      for row = 0, 6 do
        local choice = CHOICES[first + row]
        if choice then Font.draw(choice[1], 24, (3 + row * 2) * 8) end
      end
      Font.drawCode(Theme.cursor, 8, (3 + (index - first) * 2) * 8)
      Font.draw("U/D:SCROLL  L/R:10", 8, 128)
      Font.draw("A:SELECT  B:CANCEL", 8, 136)
      love.graphics.setColor(1, 1, 1, 1)
    end

    game.stack:push(screen)
  end

  if not isGen2() then
    mod.hooks:wrap("ui.options.rows", function(next, game, rows)
      rows = next(game, rows)
      local out = {}
      for _, row in ipairs(rows or {}) do out[#out + 1] = row end
      for _, slotName in ipairs({ "LEFT", "MIDDLE", "RIGHT" }) do
        local slot = GEN1_SLOTS[slotName]
        out[#out + 1] = {
          id = "starter_picker_" .. slotName:lower(),
          label = "PICK " .. slotName .. " BALL",
          value = function(currentGame)
            local species = selectedSpecies(currentGame, slot)
            local choice = CHOICES[GEN1_CHOICE_INDEX[species] or 1]
            return choice and choice[1] or tostring(species)
          end,
          activate = function(currentGame) openGen1SpeciesBrowser(currentGame, slotName) end,
        }
      end
      return out
    end)
  end

  local function ballX(objectId)
    if objectId == "OAKSLAB_CHARMANDER_POKE_BALL" then return 6 end
    if objectId == "OAKSLAB_SQUIRTLE_POKE_BALL" then return 7 end
    if objectId == "OAKSLAB_BULBASAUR_POKE_BALL" then return 8 end
    return 7
  end

  -- A competing starter randomizer may transform every give_pokemon command.
  -- This low-priority listener runs after ordinary gift transforms and applies
  -- the current named selector only to the starter gift this mod initiated.
  mod.events:on("pokemon.before_give", function(gift)
    local ctx = gift and gift.ctx
    if isGen2(ctx and ctx.game) then return end
    local game = ctx and ctx.game
    local flags = ctx and ctx.save and ctx.save.flags or {}
    local slotName = mod.save:get(PENDING_STARTER_SLOT_KEY)
    local slot = slotName and SLOTS[slotName]

    if flags.EVENT_GOT_STARTER or not slot then return end
    -- Randomizer's own listener runs at its default event priority. This
    -- handler deliberately runs after it, so the player’s named ball choice
    -- wins regardless of which mod was selected first at boot.
    local randomizerActive = randomizerStarterRandomizationActive(game)
    gift.species = selectedSpecies(game, slot)
    gift.level = 5
    lastGame = game or lastGame
    mod.save:set(PENDING_MAX_STARTER_DVS_KEY,
      mod.options:get(MAX_STARTER_DVS_OPTION) == true or nil)
    mod.save:set(RANDOMIZER_OVERRIDE_KEY, randomizerActive)
    mod.save:set(STARTER_SLOT_KEY, slotName)
    mod.save:set(STARTER_SPECIES_KEY, gift.species)
  end, -10000)

  local function starterBallHandler(slotName, slot)
    return function(game, overworld, npc, onDone)
      if not (overworld and overworld.runner and overworld.runner.run) then
        if onDone then onDone() end
        return
      end

      local flags = game.save.flags or {}
      if flags.EVENT_GOT_STARTER then
        overworld.runner:run({
          { "face_object", 5, "down" },
          { "show_text", "That's PROF.OAK's\nlast Pokémon!" },
        }, { npc = npc, onDone = onDone })
        return
      end
      if not flags.EVENT_FOLLOWED_OAK_INTO_LAB then
        overworld.runner:run({
          { "show_text", "_OaksLabThoseArePokeBallsText" },
        }, { npc = npc, onDone = onDone })
        return
      end

      local playerSpecies = selectedSpecies(game, slot)
      local rivalSpecies = selectedSpecies(game, SLOTS[slot.rivalSlot])
      mod.save:set(PENDING_STARTER_SLOT_KEY, slotName)
      local function finish()
        mod.save:set(PENDING_STARTER_SLOT_KEY, nil)
        if onDone then onDone() end
      end
      overworld.runner:run({
        { "push_screen", "DexEntryMenu", { species = playerSpecies, forceOwned = true } },
        { "ask", "So! You want\n{RAM}?", { RAM = playerSpecies } },
        { "jump_if_false", "done" },
        { "play_sound", "Get_Key_Item" },
        { "show_text", "_OaksLabReceivedMonText", { RAM = playerSpecies } },
        { "give_pokemon", playerSpecies, 5 },
        -- Preserve the original position flag: Oak's Lab and the vanilla
        -- rival scripts continue to choose party branch 1/2/3 by ball slot.
        { "set_flag", "EVENT_GOT_STARTER" },
        { "set_flag", slot.choseFlag },
        { "hide_object", "OAKS_LAB", slot.ballObject },
        { "move_npc_to", 1, ballX(slot.rivalBallObject), 4 },
        { "face_object", 1, "up" },
        { "show_text", "_OaksLabRivalIllTakeThisOneText" },
        { "hide_object", "OAKS_LAB", slot.rivalBallObject },
        { "play_sound", "Get_Key_Item" },
        { "show_text", "_OaksLabRivalReceivedMonText", { RAM = rivalSpecies } },
        { "label", "done" },
      }, { npc = npc, onDone = finish })
    end
  end

  if not isGen2() then
    mod.content.map_scripts:register("OAKS_LAB", {
      priority = 120,
      talk = {
        TEXT_OAKSLAB_CHARMANDER_POKE_BALL = starterBallHandler("LEFT", SLOTS.LEFT),
        TEXT_OAKSLAB_SQUIRTLE_POKE_BALL = starterBallHandler("MIDDLE", SLOTS.MIDDLE),
        TEXT_OAKSLAB_BULBASAUR_POKE_BALL = starterBallHandler("RIGHT", SLOTS.RIGHT),
      },
    })
  end

  if isGen2() then
    local function goldSpeciesIdByIndex(game, index)
      for speciesId, species in pairs(game and game.data and game.data.pokemon or {}) do
        if type(species) == "table" and species.index == index then return speciesId end
      end
      return nil
    end

    mod.hooks:wrap("script.command", function(next, ctx, name, args, cmd)
      local game = mod.game or lastGame
      local slotName = goldSlotForScript(ctx)
      if not slotName then return next(ctx, name, args, cmd) end

      local slot = GOLD_SLOTS[slotName]
      local target = selectedSpecies(game, slot)
      local targetDef = game and game.data and game.data.pokemon and game.data.pokemon[target]
      if not targetDef or not cmd then return next(ctx, name, args, cmd) end

      -- Elm previews each native starter before `givepoke`. Rewrite the visual,
      -- cry, dynamic species-name command, and native ball prompt so the whole
      -- selection scene represents the configured starter rather than only the
      -- final party data.
      if name == "writetext" and cmd.text == slot.promptText then
        updateGoldElmPrompt(game, slotName)
        return next(ctx, name, args, cmd)
      end

      if name == "pokepic" or name == "cry" or name == "getmonname" then
        local rewritten = {}
        for key, value in pairs(cmd) do rewritten[key] = value end
        if name == "cry" then
          -- Gold's `cry` carries its species as `id`; Elm's `pokepic` and
          -- `getmonname` carry it as `species`.
          rewritten.id = targetDef.index
        else
          rewritten.species = targetDef.index
        end
        return next(ctx, name, args, rewritten)
      end

      if name ~= "givepoke" or mod.save:get(GOLD_RECEIVED_KEY) then
        return next(ctx, name, args, cmd)
      end

      local rewritten = {}
      for key, value in pairs(cmd) do rewritten[key] = value end
      rewritten.species = targetDef.index
      local nativeItem = goldItemIndex(game, cmd.item)
      local heldItem = goldHeldItem(game, nativeItem)
      local heldIndex = goldItemIndex(game, heldItem)
      rewritten.item = heldIndex or 0

      local party = game and game.save and game.save.party or {}
      local before = #party
      local result = next(ctx, name, args, rewritten)
      local received = party[#party]
      if #party == before + 1 and received then rebuildGoldStarter(game, received, slotName) end
      return result
    end)

    mod.events:on("script.ended", function(event)
      local ctx = event and event.ctx
      local game = mod.game or lastGame
      local slotName = goldSlotForScript(ctx)
      if not (event and event.completed ~= false and slotName and not mod.save:get(GOLD_RECEIVED_KEY)) then return end
      local party = game and game.save and game.save.party or {}
      local mon = party[#party]
      local native = goldSpeciesIdByIndex(game, GOLD_SLOTS[slotName].nativeSpeciesIndex)
      if mon and (#party == 1 or mon.species == native) then rebuildGoldStarter(game, mon, slotName) end
    end)
  end

  local RIVAL_CLASSES = {
    OPP_RIVAL1 = true,
    OPP_RIVAL2 = true,
    OPP_RIVAL3 = true,
  }
  -- Native party indices 1/2/3 correspond to player left/middle/right,
  -- whose rival counter-picks are middle/right/left respectively.
  local RIVAL_SLOT_BY_PARTY_OFFSET = { "MIDDLE", "RIGHT", "LEFT" }

  local function copyParty(party)
    local out = {}
    for i, member in ipairs(party or {}) do
      local copy = {}
      for key, value in pairs(member) do copy[key] = value end
      out[i] = copy
    end
    return out
  end

  mod.hooks:wrap("trainer.party", function(next, trainerClass, partyIndex, party)
    party = next(trainerClass, partyIndex, party)
    if isGen2() then
      local goldRival = trainerClass == 9 or trainerClass == 42
        or trainerClass == "RIVAL1" or trainerClass == "RIVAL2"
      local chosen = mod.save:get(STARTER_SLOT_KEY)
      local slot = chosen and GOLD_SLOTS[chosen]
      if not (goldRival and slot and #party > 0) then return party end
      local replaced = copyParty(party)
      replaced[#replaced].species = selectedSpecies(mod.game or lastGame, GOLD_SLOTS[slot.rivalSlot])
      return replaced
    end
    if not RIVAL_CLASSES[trainerClass]
      or type(partyIndex) ~= "number"
      or partyIndex < 1
      or #party == 0 then
      return party
    end

    local slotName = RIVAL_SLOT_BY_PARTY_OFFSET[((partyIndex - 1) % 3) + 1]
    local species = selectedSpecies(mod.game, SLOTS[slotName])
    if not validSpecies(mod.game, species) then return party end

    local replaced = copyParty(party)
    -- Rival branches place their starter-line Pokémon in the last party slot.
    -- Keep the original levels, moves, and the rest of each vanilla party.
    replaced[#replaced].species = species
    return replaced
  end)
end
