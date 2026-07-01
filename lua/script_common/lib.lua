local Lib = _ENV.Lib
local os_date = os.date
local os_time = os.time

function Lib.arrayAdd(arr, value)
  if type(arr) ~= "table" then
    return
  end
  for i, v in pairs(arr) do
    if v == value then
      return
    end
  end
  table.insert(arr, value)
end

function Lib.arrayRemove(arr, value)
  if type(arr) ~= "table" then
    return
  end
  for i, v in ipairs(arr) do
    if v == value then
      table.remove(arr, i)
      break
    end
  end
end

function Lib.removeElementByKey(tbl, key)
  local tmp = {}
  for i in pairs(tbl) do
    table.insert(tmp, i)
  end
  local newTbl = {}
  local i = 1
  while i <= #tmp do
    local val = tmp[i]
    if val == key then
      table.remove(tmp, i)
    else
      newTbl[val] = tbl[val]
      i = i + 1
    end
  end
  return newTbl
end

function Lib.confirmDateChanged(oldTime, curTime, offsetTime)
  local oTime = Lib.copy(oldTime)
  local cTime = Lib.copy(curTime)
  if offsetTime then
    oTime = oTime - offsetTime
    cTime = cTime - offsetTime
  end
  if Lib.isSameDay(oTime, cTime) then
    return false
  else
    return true
  end
end

function Lib.confirmMinuteChanged(oldTime, curTime)
  if Lib.isSameMin(oldTime, curTime) then
    return false
  else
    return true
  end
end

function Lib.confirmHourChanged(oldTime, curTime)
  if Lib.isSameHour(oldTime, curTime) then
    return false
  else
    return true
  end
end

local function getMinuteTime(time)
  local minute = time / 60
  if minute <= 0 then
    return "0_minutes"
  elseif 0 < minute and minute <= 1 then
    return "0_1_minutes"
  elseif 1 < minute and minute <= 3 then
    return "1_3_minutes"
  elseif 3 < minute and minute <= 5 then
    return "3_5_minutes"
  elseif 5 < minute and minute <= 10 then
    return "5_10_minutes"
  elseif 10 < minute and minute <= 15 then
    return "10_15_minutes"
  elseif 15 < minute and minute <= 20 then
    return "15_20_minutes"
  elseif 20 < minute and minute <= 25 then
    return "20_25_minutes"
  elseif 25 < minute and minute <= 30 then
    return "25_30_minutes"
  elseif 30 < minute and minute <= 40 then
    return "30_40_minutes"
  elseif 40 < minute and minute <= 60 then
    return "40_60_minutes"
  elseif 60 < minute and minute <= 90 then
    return "60_90_minutes"
  elseif 90 < minute and minute <= 120 then
    return "90_120_minutes"
  elseif 120 < minute then
    return "120_INF_minutes"
  end
end

local function getPlayerGameTime(player)
  local time = os.time() - player:data("main").inGameTime or os.time()
  return getMinuteTime(time)
end

function Lib.reportPlayerGameTime(player)
  local parts = {
    "player_datetime",
    getPlayerGameTime(player)
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportData(player, parts)
  if player and player:isValid() then
    GameAnalytics.Design(player.platformUserId, 1, parts)
  end
end

function Lib.reportOperatingTime(player, time, isMult)
  local reportTitle = (isMult and "2v2" or "") .. "battle_roundtime"
  print("reportTitle battle_roundtime:", reportTitle)
  if player and player:isValid() then
    local timeStr = ""
    if 0 <= time and time <= 5 then
      timeStr = "0_5"
    elseif 6 <= time and time <= 10 then
      timeStr = "6_10"
    elseif 11 <= time and time <= 15 then
      timeStr = "11_15"
    elseif 16 <= time and time <= 30 then
      timeStr = "16_30"
    elseif 31 <= time and time <= 45 then
      timeStr = "31_45"
    elseif 46 <= time and time <= 60 then
      timeStr = "46_60"
    else
      timeStr = "60AI"
    end
    GameAnalytics.Design(player.platformUserId, 1, {reportTitle, timeStr})
  end
end

local function getPlayerGold(player)
  local currency = player:getCurrency("gold_coin")
  local gold = tonumber(currency.count)
  if gold <= 100 then
    return "0_100_gold"
  elseif 100 < gold and gold <= 300 then
    return "100_300_gold"
  elseif 300 < gold and gold <= 500 then
    return "300_500_gold"
  elseif 500 < gold and gold <= 1000 then
    return "500_1K_gold"
  elseif 1000 < gold and gold <= 2000 then
    return "1K_2K_gold"
  elseif 2000 < gold and gold <= 5000 then
    return "2K_5K_gold"
  else
    return "5K_INF_gold"
  end
end

function Lib.reportPlayerGold(player)
  local parts = {
    "player_outcoins",
    getPlayerGold(player)
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportPlayerLevel(player)
  local parts = {
    "player_out",
    "player_level_" .. player:getPlayerLevel()
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportPlayerPKMMaxLevel(player)
  local maxLevel = 0
  for key, val in pairs(player:getBattlePokemon()) do
    if maxLevel < val.attr.level then
      maxLevel = val.attr.level
    end
  end
  local parts = {
    "player_out",
    "pet_levelmax_" .. maxLevel
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportPlayerPKMCount(player)
  local parts = {
    "player_out",
    "pet_amount_" .. #player:getBattlePokemon() + #player:getPacketPokemon()
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportChallengeNpc(player, npcId, isMult)
  local reportTitle = (isMult and "2v2" or "") .. "npc_challenge"
  print("reportTitle npc_challenge:", reportTitle)
  local parts = {reportTitle, npcId}
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportResultNpc(player, npcId, isMult)
  local reportTitle = (isMult and "2v2" or "") .. "npc_result"
  print("reportTitle npc_result:", reportTitle)
  local parts = {reportTitle, npcId}
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportChallengePetNumber(player, npcId)
  local reportTitle = "PetNumberChallenge_" .. npcId
  local pokemons = player:getBattlePokemon()
  local parts = {
    reportTitle,
    #pokemons
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportChallengePVPGym(player, gym_id, gym_index)
  local reportTitle = "pvp_challenge"
  local parts = {
    reportTitle,
    gym_id .. "_" .. gym_index
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportSuccessPetNumber(player, npcId)
  local reportTitle = "PetNumberSuccess_" .. npcId
  local pokemons = player:getBattlePokemon()
  local parts = {
    reportTitle,
    #pokemons
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportResultPVPGym(player, gym_id, gym_index)
  local reportTitle = "pvp_win"
  local parts = {
    reportTitle,
    gym_id .. "_" .. gym_index
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportRoundPVPGym(player, round, gym_id, gym_index)
  local reportTitle = "pvp_round"
  local parts = {
    reportTitle,
    round .. "_" .. gym_id .. "_" .. gym_index
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function Lib.reportResultMonster(player, monsterLv, isWin, isMult)
  local areaStr = "unkown"
  local retStr = "unkown"
  if 50 < monsterLv then
    areaStr = "51_60"
  elseif 40 < monsterLv then
    areaStr = "41_50"
  elseif 30 < monsterLv then
    areaStr = "31_40"
  elseif 25 < monsterLv then
    areaStr = "26_30"
  elseif 20 < monsterLv then
    areaStr = "21_25"
  elseif 15 < monsterLv then
    areaStr = "16_20"
  elseif 10 < monsterLv then
    areaStr = "11_15"
  elseif 5 < monsterLv then
    areaStr = "6_10"
  else
    areaStr = "1_5"
  end
  if isWin then
    retStr = "success"
  else
    retStr = "fail"
  end
  print("reportResultMonster areaStr:", areaStr)
  print("reportResultMonster retStr:", retStr)
  local reportTitle = (isMult and "2v2" or "") .. "battle_result"
  print("reportTitle:", reportTitle)
  local parts = {
    reportTitle,
    retStr .. "_" .. areaStr
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
  if not player.actionCache then
    return
  end
  if player.actionCache[Define.BATTLE_ACTION.RUNAWAY] then
    retStr = "run"
    print("reportResultMonster retStr:", retStr)
    GameAnalytics.Design(player.platformUserId, 1, {
      reportTitle,
      retStr .. "_" .. areaStr
    })
  end
  if player.actionCache[Define.BATTLE_ACTION.BALL] then
    retStr = "catch"
    print("reportResultMonster retStr:", retStr)
    GameAnalytics.Design(player.platformUserId, 1, {
      reportTitle,
      retStr .. "_" .. areaStr
    })
  end
  reportTitle = (isMult and "2v2" or "") .. "battle_useitem"
  print("reportTitle battle_useitem:", reportTitle)
  if player.useItemCache then
    if player.useItemCache[Define.CURE_TYPE.HP] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_heal"
      })
    end
    if player.useItemCache[Define.CURE_TYPE.LIFE] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_relive"
      })
    end
    if player.useItemCache[Define.CURE_TYPE.DBUFF] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_remove"
      })
    end
    if player.useItemCache[Define.CURE_TYPE.PP] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_pp"
      })
    end
    player.useItemCache = nil
  end
  player.actionCache = nil
end

function Lib.reportUseItemNpc(player, npcId, isMult)
  if not player.useItemCache then
    return
  end
  local reportTitle = (isMult and "2v2" or "") .. "npc_useitem"
  print("reportTitle npc_useitem:", reportTitle)
  if player.useItemCache[Define.CURE_TYPE.HP] then
    GameAnalytics.Design(player.platformUserId, 1, {
      reportTitle,
      npcId .. "_heal"
    })
  end
  if player.useItemCache[Define.CURE_TYPE.LIFE] then
    GameAnalytics.Design(player.platformUserId, 1, {
      reportTitle,
      npcId .. "_relive"
    })
  end
  if player.useItemCache[Define.CURE_TYPE.DBUFF] then
    GameAnalytics.Design(player.platformUserId, 1, {
      reportTitle,
      npcId .. "_remove"
    })
  end
  if player.useItemCache[Define.CURE_TYPE.PP] then
    GameAnalytics.Design(player.platformUserId, 1, {
      reportTitle,
      npcId .. "_pp"
    })
  end
  player.useItemCache = nil
end

function Lib.reportUseTime(player, selectTime, isMult)
end

function Lib.reportUseItem1V1(player, isMult)
  local reportTitle = isMult and "2v2_useitem" or "1v1_useitem"
  print("reportTitle pk_useitem:", reportTitle)
  local areaStr = "unkown"
  local monsterLv = player:getPlayerLevel()
  if 60 < monsterLv then
    areaStr = "60up"
  elseif 50 < monsterLv then
    areaStr = "51_60"
  elseif 40 < monsterLv then
    areaStr = "41_50"
  elseif 30 < monsterLv then
    areaStr = "31_40"
  elseif 25 < monsterLv then
    areaStr = "26_30"
  elseif 20 < monsterLv then
    areaStr = "21_25"
  elseif 15 < monsterLv then
    areaStr = "16_20"
  elseif 10 < monsterLv then
    areaStr = "11_15"
  elseif 5 < monsterLv then
    areaStr = "6_10"
  else
    areaStr = "1_5"
  end
  print("pvp item user areaStr:", areaStr)
  if player.useItemCache then
    if player.useItemCache[Define.CURE_TYPE.HP] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_heal"
      })
    end
    if player.useItemCache[Define.CURE_TYPE.LIFE] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_relive"
      })
    end
    if player.useItemCache[Define.CURE_TYPE.DBUFF] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_remove"
      })
    end
    if player.useItemCache[Define.CURE_TYPE.PP] then
      GameAnalytics.Design(player.platformUserId, 1, {
        reportTitle,
        areaStr .. "_pp"
      })
    end
    player.useItemCache = nil
  end
end

function Lib.reportChanllgerWin(player, isMult)
  print("pvp reportChanllgerWin:")
  local reportTitle = isMult and "2v2_result" or "1v1_result"
  print("reportTitle pk_result:", reportTitle)
  GameAnalytics.Design(player.platformUserId, 1, {"1v1_result"})
end

function Lib.reportChanllgePK(player, isMult)
  print("pvp reportChanllgePK:")
  local reportTitle = isMult and "2v2_challenge" or "1v1_challenge"
  print("reportTitle pk_challenge:", reportTitle)
  GameAnalytics.Design(player.platformUserId, 1, {
    "1v1_challenge"
  })
end

function Lib.getCurMapIndex(pos, map_name)
  local index = 1
  local mapName = map_name or "map001"
  if mapName == "map001" then
    if pos.x >= -80 and 1 > pos.x and pos.z >= 324 and pos.z <= 493 then
      index = 1
    elseif 1 <= pos.x and pos.x < 200 and pos.z >= 324 and pos.z <= 493 then
      index = 2
    elseif pos.x >= 200 and pos.x < 348 and pos.z >= 324 and pos.z <= 493 then
      index = 3
    elseif pos.x >= 348 and pos.x < 407 and pos.z >= 324 and pos.z <= 493 then
      index = 4
    elseif pos.x >= 507 and pos.x < 618 and pos.z >= 324 and pos.z <= 493 then
      index = 5
    elseif pos.x >= 618 and pos.x < 756 and pos.z >= 324 and pos.z <= 493 then
      index = 6
    end
  end
  return index
end

function Lib.getPVPMapName(pos)
  local map_name
  local index = Lib.getCurMapIndex(pos)
  if index == 1 then
    map_name = "map002"
  elseif index == 2 then
    map_name = "map002"
  elseif index == 3 then
    map_name = "map005"
  elseif index == 4 then
    map_name = "map008"
  elseif index == 5 then
    map_name = "map011"
  elseif index == 6 then
    map_name = "map014"
  end
  return map_name
end

function Lib.getFormatTime(time)
  local seconds = string.format("%02d", math.floor(time % 60))
  local min = string.format("%02d", math.floor(time / 60 % 60))
  local hour = string.format("%02d", math.floor(time / 3600))
  local decTime = hour .. ":" .. min .. ":" .. seconds
  return decTime
end

function Lib.getRankCounterKey(code)
  local key = ""
  if code == "en" then
    key = "en_rank_counter"
  elseif code == "zh" then
    key = "zh_rank_counter"
  elseif code == "ru" then
    key = "ru_rank_counter"
  elseif code == "es" then
    key = "es_rank_counter"
  elseif code == "ko" then
    key = "ko_rank_counter"
  else
    key = "en_rank_counter"
  end
  local curTime = os.time()
  local year = Lib.getYear(curTime)
  local week = os.date("%W", curTime)
  key = key .. "." .. year .. "." .. week
  Lib.logDebug("getRankCounterKey key = ", key)
  return key
end

function Lib.getLangCode(type)
  local code = "en"
  if type == Define.RANK_LANG_TYPE.EN then
    code = "en"
  elseif type == Define.RANK_LANG_TYPE.ZH then
    code = "zh"
  elseif type == Define.RANK_LANG_TYPE.RU then
    code = "ru"
  elseif type == Define.RANK_LANG_TYPE.ES then
    code = "es"
  elseif type == Define.RANK_LANG_TYPE.PT then
    code = "pt"
  elseif type == Define.RANK_LANG_TYPE.ID then
    code = "id"
  end
  return code
end

function Lib.getLangType(code)
  local type = Define.RANK_LANG_TYPE.EN
  if code == "en" then
    type = Define.RANK_LANG_TYPE.EN
  elseif code == "zh" then
    type = Define.RANK_LANG_TYPE.ZH
  elseif code == "ru" then
    type = Define.RANK_LANG_TYPE.RU
  elseif code == "es" then
    type = Define.RANK_LANG_TYPE.ES
  elseif code == "pt" then
    type = Define.RANK_LANG_TYPE.PT
  elseif code == "id" then
    type = Define.RANK_LANG_TYPE.ID
  end
  return type
end

function Lib.reportPetWalk(player, petId)
  local monsterLv = player:getPlayerLevel()
  local areaStr = "unkown"
  if 60 < monsterLv then
    areaStr = "60up"
  elseif 50 < monsterLv then
    areaStr = "51_60"
  elseif 40 < monsterLv then
    areaStr = "41_50"
  elseif 35 < monsterLv then
    areaStr = "36_40"
  elseif 30 < monsterLv then
    areaStr = "31_35"
  elseif 25 < monsterLv then
    areaStr = "26_30"
  elseif 20 < monsterLv then
    areaStr = "21_25"
  elseif 15 < monsterLv then
    areaStr = "16_20"
  elseif 10 < monsterLv then
    areaStr = "11_15"
  else
    areaStr = "1_10"
  end
  GameAnalytics.Design(player.platformUserId, 1, {
    "pet_walk",
    petId .. "_" .. areaStr
  })
end

function Lib.reportTalk(player)
  player.textChatTimes = player.textChatTimes or 0
  player.voiceChatTimes = player.voiceChatTimes or 0
  local textChatTimesStr = "unkown"
  local voiceChatTimesStr = "unkown"
  if player.textChatTimes > 16 then
    textChatTimesStr = "16up"
  elseif player.textChatTimes > 10 then
    textChatTimesStr = "11_15"
  elseif player.textChatTimes > 5 then
    textChatTimesStr = "6_10"
  elseif player.textChatTimes > 2 then
    textChatTimesStr = "3_5"
  elseif player.textChatTimes > 0 then
    voiceChatTimesStr = "1_2"
  else
    textChatTimesStr = "0"
  end
  if player.voiceChatTimes > 16 then
    voiceChatTimesStr = "16up"
  elseif player.voiceChatTimes > 10 then
    voiceChatTimesStr = "11_15"
  elseif player.voiceChatTimes > 5 then
    voiceChatTimesStr = "6_10"
  elseif player.voiceChatTimes > 2 then
    voiceChatTimesStr = "3_5"
  elseif 0 < player.voiceChatTimes then
    voiceChatTimesStr = "1_2"
  else
    voiceChatTimesStr = "0"
  end
  print("reportTalk Chat_ByText" .. textChatTimesStr)
  print("reportTalk Chat_ByVoice" .. voiceChatTimesStr)
  GameAnalytics.Design(player.platformUserId, 1, {
    "Chat_ByText" .. textChatTimesStr
  })
  GameAnalytics.Design(player.platformUserId, 1, {
    "Chat_ByVoice" .. voiceChatTimesStr
  })
end

function Lib.reportPokemonSelect(player, petId)
  if World.isClient then
    GameAnalytics.Design(1, {
      "Choose_success"
    })
  else
    GameAnalytics.Design(player.platformUserId, 1, {
      "Choose_success",
      petId
    })
  end
end

function Lib.reportPokemonOpen(player)
  if World.isClient then
    GameAnalytics.Design(1, {
      "Choose_open"
    })
  else
    GameAnalytics.Design(player.platformUserId, 1, {
      "Choose_open"
    })
  end
end

function Lib.getHourStartTime(time)
  local date = os_date("*t", time)
  return os_time({
    year = date.year,
    month = date.month,
    day = date.day,
    hour = date.hour,
    min = 0
  })
end

function Lib.getHourEndTime(time)
  local date = os_date("*t", time)
  return os_time({
    year = date.year,
    month = date.month,
    day = date.day,
    hour = date.hour + 1,
    min = 0
  })
end

function Lib.isSameHour(time1, time2)
  return Lib.getHourEndTime(time1) == Lib.getHourEndTime(time2)
end

function Lib.getMinStartTime(time)
  local date = os_date("*t", time)
  return os_time({
    year = date.year,
    month = date.month,
    day = date.day,
    hour = date.hour,
    min = 0
  })
end

function Lib.getMinEndTime(time)
  local date = os_date("*t", time)
  return os_time({
    year = date.year,
    month = date.month,
    day = date.day,
    hour = date.hour,
    min = date.min + 1
  })
end

function Lib.isSameMin(time1, time2)
  return Lib.getMinEndTime(time1) == Lib.getMinEndTime(time2)
end

function Lib.getFormatDateTime(time)
  local tb = {}
  tb.year = tonumber(os.date("%Y", time))
  tb.month = tonumber(os.date("%m", time))
  tb.day = tonumber(os.date("%d", time))
  tb.hour = tonumber(os.date("%H", time))
  tb.minute = tonumber(os.date("%M", time))
  tb.second = tonumber(os.date("%S", time))
  return tb
end

function Lib.getRaceKey(race)
  local key = ""
  if race == Define.POKEMON_RACE.NORMAL then
    key = "gui.pokemon.race.normal"
  elseif race == Define.POKEMON_RACE.WATER then
    key = "gui.pokemon.race.water"
  elseif race == Define.POKEMON_RACE.FIRE then
    key = "gui.pokemon.race.fire"
  elseif race == Define.POKEMON_RACE.GRASS then
    key = "gui.pokemon.race.grass"
  elseif race == Define.POKEMON_RACE.SUPER then
    key = "gui.pokemon.race.super"
  elseif race == Define.POKEMON_RACE.SPECIAL then
    key = "gui.pokemon.race.special"
  end
  return key
end

function Lib.getGymKey(type)
  local key = ""
  if type == Define.RANK_SUB_TYPE.SUPER_GYM then
    key = "gui.gym.super"
  elseif type == Define.RANK_SUB_TYPE.SPECIAL_GYM then
    key = "gui.gym.special"
  elseif type == Define.RANK_SUB_TYPE.WATER_GYM then
    key = "gui.gym.water"
  elseif type == Define.RANK_SUB_TYPE.FIRE_GYM then
    key = "gui.gym.fire"
  elseif type == Define.RANK_SUB_TYPE.GRASS_GYM then
    key = "gui.gym.grass"
  end
  return key
end

function Lib.checkNumberValueIsNan(value)
  if not value then
    return true
  end
  if type(value) == "number" then
    if value ~= value then
      return true
    end
  else
    Lib.logWarning("warning:checkNumberValueIsNan need a number parameter!!", type(value))
    return false
  end
  return false
end

function Lib.timeScore2Score(timeScore)
  if not timeScore then
    return 0
  end
  return timeScore
end

function Lib.checkNumberValueIsNan(value)
  if not value then
    return true
  end
  if type(value) == "number" then
    if value ~= value then
      return true
    end
  else
    Lib.logWarning("warning:checkNumberValueIsNan need a number parameter!!", type(value))
    return false
  end
  return false
end
