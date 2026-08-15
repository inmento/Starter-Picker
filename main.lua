-- Starter Picker
-- Gen 1 Recomp mod API 2
--
-- The three Oak's Lab ball positions retain their native relationship:
-- choosing left gives the rival the configured middle-ball Pokémon;
-- choosing middle gives the rival the configured right-ball Pokémon;
-- choosing right gives the rival the configured left-ball Pokémon.

return function(mod)
  local SLOTS = {
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

  local PENDING_STARTER_SLOT_KEY = "pending_starter_slot"
  local STARTER_SLOT_KEY = "received_starter_slot"
  local STARTER_SPECIES_KEY = "received_starter_species"
  local RANDOMIZER_ID = "gen1_randomizer"
  local RANDOMIZER_OVERRIDE_KEY = "gen1_randomizer_starter_override_active"
  local MAX_STARTER_DVS_OPTION = "max_starter_dvs"
  local PENDING_MAX_STARTER_DVS_KEY = "pending_max_starter_dvs"
  local MAX_STARTER_DVS_APPLIED_KEY = "starter_max_dvs_applied"
  local lastGame = mod.game
  local SLOT_NAME_BY_OPTION = {
    [SLOTS.LEFT.option] = "LEFT",
    [SLOTS.MIDDLE.option] = "MIDDLE",
    [SLOTS.RIGHT.option] = "RIGHT",
  }

  local function choiceRows()
    local rows = {}
    for speciesId, pokemon in mod.content.pokemon:each() do
      -- Limit the picker to the standard 151 Pokédex entries. Any species a
      -- content mod adds beyond Gen 1's dex range stays out of this UI.
      if type(pokemon.dex) == "number" and pokemon.dex >= 1 and pokemon.dex <= 151 then
        rows[#rows + 1] = { string.format("%03d %s", pokemon.dex, pokemon.name), speciesId }
      end
    end
    table.sort(rows, function(a, b) return a[1] < b[1] end)
    return rows
  end

  local CHOICES = choiceRows()
  mod.options:define({
    {
      key = "charmander_ball",
      label = "CHARMANDER BALL",
      type = "choice",
      default = SLOTS.LEFT.default,
      choices = CHOICES,
    },
    {
      key = "squirtle_ball",
      label = "SQUIRTLE BALL",
      type = "choice",
      default = SLOTS.MIDDLE.default,
      choices = CHOICES,
    },
    {
      key = "bulbasaur_ball",
      label = "BULBASAUR BALL",
      type = "choice",
      default = SLOTS.RIGHT.default,
      choices = CHOICES,
    },
    {
      key = MAX_STARTER_DVS_OPTION,
      label = "MAX PLAYER STARTER DVS",
      type = "toggle",
      default = false,
    },
  })

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

  local function findTrackedStarter(game, expectedSpecies)
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
    local flags = game and game.save and game.save.flags or {}
    if not flags.EVENT_GOT_STARTER then return end

    local mon = findTrackedStarter(game, mod.save:get(STARTER_SPECIES_KEY))
    if forceMaxDVs(game, mon) then
      mod.save:set(MAX_STARTER_DVS_APPLIED_KEY, true)
    end
  end

  local function applyPostLabSelection(game, slotName)
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
  end)

  mod.events:on("mod.options_changed", function(event)
    if type(event) ~= "table" then return end
    local changedModId = type(event.mod) == "table" and event.mod.id or event.mod
    if changedModId ~= mod.id then return end

    local slotName = SLOT_NAME_BY_OPTION[event.key]
    if slotName then
      applyPostLabSelection(mod.game or lastGame, slotName)
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
  mod.events:on("screen.pushed", function()
    if not mod.save:get(PENDING_MAX_STARTER_DVS_KEY) then return end
    local game = lastGame or mod.game
    local mon = findTrackedStarter(game, mod.save:get(STARTER_SPECIES_KEY))
    if forceMaxDVs(game, mon) then
      mod.save:set(MAX_STARTER_DVS_APPLIED_KEY, true)
    end
    mod.save:set(PENDING_MAX_STARTER_DVS_KEY, nil)
  end)

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

  mod.content.map_scripts:register("OAKS_LAB", {
    priority = 120,
    talk = {
      TEXT_OAKSLAB_CHARMANDER_POKE_BALL = starterBallHandler("LEFT", SLOTS.LEFT),
      TEXT_OAKSLAB_SQUIRTLE_POKE_BALL = starterBallHandler("MIDDLE", SLOTS.MIDDLE),
      TEXT_OAKSLAB_BULBASAUR_POKE_BALL = starterBallHandler("RIGHT", SLOTS.RIGHT),
    },
  })

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
