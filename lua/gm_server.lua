local GMItem = GM:createGMItem()
local BattleFieldManager = require("script_server.battle.battle_field_manager")
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local PokemonConfig = T(Config, "PokemonConfig")
local setting = require("common.setting")
GMItem["\230\175\143\230\151\165\230\138\189\229\165\150/add\230\172\161\230\149\176"] = function(self)
  self:setLastAddLotteryChanceTime(os.time())
  local lotteryData = self:getCurLotteryInfo() or {}
  lotteryData.curLotteryNum = (lotteryData.curLotteryNum or 0) + 1
  lotteryData.curLotteryCircle = lotteryData.curLotteryCircle or 1
  lotteryData.curPickList = lotteryData.curPickList or {}
  self:setCurLotteryInfo(lotteryData)
end
GMItem["\230\175\143\230\151\165\228\187\187\229\138\161/\229\136\183\230\150\176\228\187\187\229\138\161\229\136\151\232\161\168"] = function(self)
  self:initDailyTask()
end
GMItem["NPC/\230\184\133\233\153\164NPC\230\140\145\230\136\152\231\138\182\230\128\129"] = function(self)
  self:setValue("npcChallengeList", {})
end
GMItem["\230\136\152\230\150\151/\230\140\145\230\136\152NPC"] = function(self)
  self:npcEnterBattle(60309, 783)
end
GMItem["\230\136\152\230\150\151/\229\174\157\229\143\175\230\162\166\231\138\182\230\128\129"] = function(self)
  if self.battleField then
    Lib.logInfo("*****************\229\174\157\229\143\175\230\162\166\231\138\182\230\128\129*****************")
    for _, player in pairs(self.battleField.playerList) do
      local pet = player:getBattlePet()
      if pet then
        Lib.logInfo(player.name, pet:getPokemon():getObjId(), pet:getPokemon():getCfgFullName(), pet:getPokemon():getCurHp())
      end
    end
  end
end
GMItem["pvp\233\129\147\233\166\134/\229\174\140\230\136\144\231\172\172\228\184\128\228\184\170pve\233\129\147\233\166\134"] = function(self)
  self:setGymFinish(1, 1)
end
GMItem["pvp\233\129\147\233\166\134/\229\174\140\230\136\144\231\172\172\228\186\140\228\184\170pve\233\129\147\233\166\134"] = function(self)
  self:setGymFinish(2, 1)
end
GMItem["pvp\233\129\147\233\166\134/\229\174\140\230\136\144\231\172\172\228\184\137\228\184\170pve\233\129\147\233\166\134"] = function(self)
  self:setGymFinish(3, 1)
end
GMItem["pvp\233\129\147\233\166\134/\229\174\140\230\136\144\231\172\172\229\155\155\228\184\170pve\233\129\147\233\166\134"] = function(self)
  self:setGymFinish(4, 1)
end
GMItem["pvp\233\129\147\233\166\134/\229\174\140\230\136\144\231\172\172\228\186\148\228\184\170pve\233\129\147\233\166\134"] = function(self)
  self:setGymFinish(5, 1)
end
GMItem["pvp\233\129\147\233\166\134/\232\174\190\231\189\174progress"] = function(self)
  self:setGymProgress(5, 6)
end
GMItem["\230\136\152\230\150\151/\230\137\128\230\156\137\231\142\169\229\174\182\232\191\155\229\133\165\230\136\152\229\156\186"] = function(self)
  for _, player in pairs(Game.GetAllPlayers()) do
    if player:getFirstBattlePokemon() and not player:isInBattle() then
      EncounterMgr:encounterTrigger(player, Define.MEET_PKM_TYPE.HIDE_PKM, {
        {monsterID = 10200101, rareID = 1}
      })
    end
  end
end
GMItem["\230\136\152\230\150\151/PVE NV1"] = function(self)
  if not self:getFirstBattlePokemon() then
    Lib.logError("not getFirstBattlePokemon", self.name)
    return
  end
  EncounterMgr:encounterTrigger(self, Define.MEET_PKM_TYPE.HIDE_PKM, {
    {monsterID = 1, rareID = 1}
  })
end
GMItem["\230\136\152\230\150\151/PVE NV2"] = function(self)
  local pokemon1 = PokemonManager:createPokemon(1, 1)
  local pokemon2 = PokemonManager:createPokemon(1, 1)
  local battleField = BattleFieldManager:create({
    map = "map002",
    playerNum = self:getMyTeamMateId() and 2 or 1,
    enemy = {
      {pokemon1},
      {pokemon2}
    },
    mode = Define.BATTLE_MODE.PVE,
    endCallBack = function()
      if pokemon1:getMasterId() == 0 then
        pokemon1:onDestroy()
      end
      if pokemon2:getMasterId() == 0 then
        pokemon2:onDestroy()
      end
    end
  })
  if self:isTeamCaptain() then
    TeamMgr:enterBattleField(self, battleField)
  else
    self:enterBattleField(battleField)
  end
end
GMItem["\230\136\152\230\150\151/\231\166\187\229\188\128\230\136\152\229\156\186"] = function(self)
  self:leaveBattleField()
end
GMItem["\230\136\152\230\150\151/3\228\184\170\231\142\169\229\174\182\231\155\184\228\186\146PVP"] = function(self)
  local playerA = World.CurWorld:getEntity(Game.GetPlayerByUserId(59616).objID)
  local playerB = World.CurWorld:getEntity(Game.GetPlayerByUserId(18512).objID)
  local playerC = World.CurWorld:getEntity(Game.GetPlayerByUserId(59536).objID)
  if playerA and playerB and playerC then
    playerA:onEnterPVP(playerB)
    playerB:onEnterPVP(playerC)
    playerC:onEnterPVP(playerA)
    Lib.logInfo("3\228\184\170\231\142\169\229\174\182\231\155\184\228\186\146PVP")
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176\229\189\147\229\137\141\230\140\135\228\187\164"] = function(self)
  if self.battleField then
    Lib.logInfo("battleField curCmd", Lib.inspect(self.battleField.curCmd))
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176battleFieldPos"] = function(self)
  local battleFieldPos = self.map.cfg.battleFieldPos or World.cfg.battleFieldPos
  Lib.logInfo("battleFieldPos", Lib.v2s(battleFieldPos))
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176entityList"] = function(self)
  if self.battleField then
    Lib.logInfo("********************* entityList *********************")
    for index, entity in pairs(self.battleField.entityList) do
      if entity and entity:isValid() then
        Lib.logInfo(index, entity:cfg().fullName, entity.name)
      end
    end
  end
end
GMItem["\230\136\152\230\150\151/\230\136\145\232\166\129\229\143\152\229\188\186"] = function(self)
  local pet = self:getBattlePet()
  if pet and pet:isValid() then
    pet:setSpeed(999999)
    pet:setPAtk(999999)
    pet:setSAtk(999999)
    pet:setPDef(999999)
    pet:setSDef(999999)
    pet.curHp = 999999
  end
end
GMItem["\230\136\152\230\150\151/\230\136\145\230\152\175\229\188\177\233\184\161"] = function(self)
  local pet = self:getBattlePet()
  if pet and pet:isValid() then
    pet:setSpeed(1)
    pet:setPAtk(1)
    pet:setSAtk(1)
    pet:setPDef(1)
    pet:setSDef(1)
    pet.curHp = 1
  end
end
GMItem["\230\136\152\230\150\151/\230\149\140\230\150\185\229\143\152\229\188\177"] = function(self)
  if self.battleField then
    for i, enemy in pairs(self.battleField:getEnemyDataList(self) or {}) do
      if enemy and enemy:isValid() then
        enemy:setSpeed(1)
        enemy:setPAtk(1)
        enemy:setSAtk(1)
        enemy:setPDef(1)
        enemy:setSDef(1)
        enemy.curHp = 1
      end
    end
  end
end
GMItem["\230\136\152\230\150\151/\230\149\140\230\150\185\229\143\152\229\188\186"] = function(self)
  if self.battleField then
    for i, enemy in pairs(self.battleField:getEnemyDataList(self) or {}) do
      if enemy and enemy:isValid() then
        enemy:setSpeed(999999)
        enemy:setPAtk(999999)
        enemy:setSAtk(999999)
        enemy:setPDef(999999)
        enemy:setSDef(999999)
        enemy.curHp = 999999
      end
    end
  end
end
GMItem["\230\136\152\230\150\151/\232\183\179\232\191\135\230\147\141\228\189\156"] = function(self)
  self:setStateReady(true)
  self:setCmdReady(true)
end
GMItem["\230\136\152\230\150\151/\232\183\179\232\191\135\230\137\128\230\156\137\230\147\141\228\189\156"] = function(self)
  for _, player in pairs(self.battleField.playerList or {}) do
    player:setStateReady(true)
    player:setCmdReady(true)
  end
end
GMItem["\230\136\152\230\150\151/S StateReady"] = function(self)
  self.debugStateReady = not self.debugStateReady
end
GMItem["\230\136\152\230\150\151/BattleField Count"] = function(self)
  local list = BattleFieldManager:getBattleFieldList()
  Lib.logInfo("BattleField Count", Lib.getTableSize(list))
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176\231\138\182\230\128\129\230\157\161\228\187\182"] = function(self)
  if self.battleField then
    Lib.logInfo("condition", self.battleField:checkStateReady(), self.battleField:checkCmdReady(), self.battleField:checkBattleEnd(), self.battleField:checkPetValid())
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176\229\174\157\229\143\175\230\162\166\231\138\182\230\128\129"] = function(self)
  Lib.logInfo("********************* battlePetList *********************", self.objID, self.name)
  for _, battlePetId in pairs(self:getValue("battlePetList") or {}) do
    local battlePet = PokemonManager:getPokemon(battlePetId)
    Lib.logInfo(battlePet:getObjId(), battlePet:getName(), battlePet:getCfgFullName(), battlePet:getCurHp())
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176BattleState"] = function(self)
  if self.battleField then
    Lib.logInfo("self.battleState:update", self.battleField.battleState.__name)
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176\229\145\189\228\187\164\233\152\159\229\136\151"] = function(self)
  if self.battleField then
    local data = self.battleField.battleActionQueue._data
    Lib.logInfo("********* battleActionQueue *********")
    for i = 1, #data do
      Lib.logInfo(data[i].type, Lib.v2s(data[i].param))
    end
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176playerList State"] = function(self)
  if self.battleField then
    Lib.logInfo("********* playerList State *********")
    for i, player in pairs(self.battleField.playerList) do
      Lib.logInfo(player.objID, player.name, "stateReady " .. tostring(player.stateReady), "cmdReady " .. tostring(player.cmdReady), "CampId " .. tostring(player:getCampId()), "canBattle " .. tostring(player:canBattle()), "BattlePet isValid " .. tostring(player:getBattlePet() and player:getBattlePet():isValid()))
    end
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176hostList State"] = function(self)
  if self.battleField then
    Lib.logInfo("********* hostList State *********")
    for _, host in pairs(self.battleField.hostList) do
      Lib.logInfo(host.objID, tostring(host.name), host:getBpIndex(), "CampId " .. tostring(host:getCampId()), "canBattle " .. tostring(host:canBattle()), "BattlePet isValid " .. tostring(host:getBattlePet() and host:getBattlePet():isValid()))
    end
  end
end
GMItem["\230\136\152\230\150\151/\230\137\147\229\141\176\231\142\169\229\174\182\232\161\128\233\135\143"] = function(self)
  Lib.logDebug("player curHp", self.curHp)
end
GMItem["\230\136\152\230\150\151/\230\142\146\229\186\143\230\181\139\232\175\149"] = function(self)
  local tb = {
    1,
    5,
    4,
    2,
    3
  }
  table.sort(tb, function(a, b)
    return false
  end)
  Lib.logInfo("******************* result *******************")
  for i = 1, #tb do
    Lib.logInfo(Lib.v2s(tb[i]))
  end
end
GMItem["\230\136\152\230\150\151/\229\133\168\233\131\168\231\166\187\229\188\128\230\136\152\229\156\186"] = function(self)
  if self.battleField then
    for _, player in pairs(self.battleField.playerList) do
      player:leaveBattleField()
    end
  end
end
GMItem["\230\136\152\230\150\151/getEnemyPokemonList"] = function(self)
  Lib.logInfo("**************** getEnemyPokemonList ****************")
  if self.battleField then
    for _, pokemon in pairs(self.battleField:getEnemyPokemonList(self)) do
      Lib.logInfo(pokemon:getObjId(), pokemon:getName())
    end
  end
end
GMItem["\230\136\152\230\150\151/\231\129\188\231\131\167buff"] = function(self)
  if not self:getTypeBuff("fullName", "myplugin/skill_fire_damage_buff_1") then
    self:addBuff("myplugin/skill_fire_damage_buff_1")
  else
    self:removeTypeBuff("fullName", "myplugin/skill_fire_damage_buff_1")
  end
end
GMItem["\229\174\160\231\137\169/\228\184\138\233\152\181\229\174\160\231\137\169\229\138\160\231\187\143\233\170\140"] = GM:inputStr(function(self, expCount)
  local petExpList = {}
  for _, pet in pairs(self:getBattlePokemon()) do
    local extraExp = pet:addExp(expCount)
    table.insert(petExpList, {
      objId = pet:getObjId(),
      exp = expCount - extraExp
    })
  end
  self:sendPacket({
    pid = "RewardResult",
    petExpList = petExpList,
    coin = 0,
    exp = 0
  })
  self:updateAllPokemonPower()
end, "\231\187\143\233\170\140\230\149\176\233\135\143")
GMItem["\229\174\160\231\137\169/\232\142\183\229\190\151\230\137\128\230\156\137\229\174\160\231\137\169"] = function(self)
  local all_config = PokemonConfig:getAllConfig()
  local list = {}
  for _, config in pairs(all_config) do
    table.insert(list, config)
  end
  table.sort(list, function(a, b)
    return a.id < b.id
  end)
  for _, config in pairs(list) do
    self:randomPokemon(config.id)
  end
end
GMItem["\229\174\160\231\137\169/\230\184\133\231\169\186\230\137\128\230\156\137\229\174\160\231\137\169"] = function(self)
  PokemonManager:removePokemonList(self:getValue("battlePetList"))
  PokemonManager:removePokemonList(self:getValue("packetPetList"))
  self:setValue("battlePetList", {})
  self:setValue("packetPetList", {})
  self:setValue("bookRecord", {})
end
GMItem["\229\174\160\231\137\169/\230\137\147\229\141\176AllPokemon"] = function(self)
  Lib.logInfo("******************** \230\137\147\229\141\176AllPokemon ********************")
  for _, pokemon in pairs(PokemonManager:getAllPokemon() or {}) do
    if pokemon then
      Lib.logInfo(pokemon:getObjId(), pokemon:getName(), pokemon:getMaster() and pokemon:getMaster():isValid() and pokemon:getMaster().name)
    end
  end
end
GMItem["\229\174\160\231\137\169/\230\137\147\229\141\176PlayerPokemon"] = function(self)
  Lib.logInfo("******************** \230\137\147\229\141\176PlayerPokemon ********************")
  for _, objId in pairs(self:getValue("battlePetList") or {}) do
    local pokemon = self:getPokemon(objId)
    if pokemon then
      Lib.logInfo(pokemon:getObjId(), pokemon:getName(), pokemon:getMaster() and pokemon:getMaster().name)
    end
  end
end
GMItem["\229\174\160\231\137\169/\230\138\147\230\141\149\229\174\160\231\137\169"] = GM:inputStr(function(self, pokemonId)
  if not tonumber(pokemonId) then
    return
  end
  local pokemon = PokemonManager:createPokemon(pokemonId)
  self:capturePokemon(pokemon)
  pokemon:onDestroy()
end, "\229\174\160\231\137\169Id")
GMItem["\229\174\160\231\137\169/\230\159\165\231\156\139\229\174\160\231\137\169"] = GM:inputStr(function(self, objId)
  if not tonumber(objId) then
    return
  end
  local pokemon = self:getPokemon(objId)
  if pokemon then
    Lib.pv(pokemon.attr)
  end
end, "\229\174\160\231\137\169\229\136\151\232\161\168\231\154\132\231\180\162\229\188\149objId")
GMItem["\229\174\160\231\137\169/\230\136\152\230\150\151\229\136\151\232\161\168"] = function(self)
  print("\230\136\152\230\150\151\229\136\151\232\161\168")
  local packet = self:getBattlePokemon()
  for objId, pokemon in pairs(packet) do
    print("---------" .. objId .. "-----------")
    print("\231\173\137\231\186\167 " .. pokemon:getLevel())
    print("\229\155\190\233\137\180Id " .. pokemon:getBookId())
    print("\229\189\147\229\137\141\231\187\143\233\170\140 " .. pokemon:getCurExp())
    print("\229\141\135\231\186\167\231\187\143\233\170\140 " .. pokemon:getMaxExp())
    print("\230\128\167\229\136\171 " .. pokemon:getSex())
    print("\231\167\141\230\151\143 " .. pokemon:getRace())
    print("\230\156\128\229\164\167\232\161\128\233\135\143 " .. pokemon:getMaxHp())
    print("\229\189\147\229\137\141\232\161\128\233\135\143 " .. pokemon:getCurHp())
    print("\230\138\128\232\131\189\229\136\151\232\161\168--------------------------- ")
    Lib.pv(pokemon:getSkillList())
    print("\232\162\171\229\138\168\230\138\128\232\131\189\229\136\151\232\161\168--------------------------- ")
    Lib.pv(pokemon:getPassiveSkillList())
    print("\229\190\133\229\173\166\230\138\128\232\131\189--------------------------- ")
    Lib.pv(pokemon:getStudySkillList())
  end
end
GMItem["\229\174\160\231\137\169/\232\131\140\229\140\133\229\136\151\232\161\168"] = function(self)
  print("\232\131\140\229\140\133\229\136\151\232\161\168")
  local packet = self:getPacketPokemon()
  for objId, pokemon in pairs(packet) do
    print("---------" .. objId .. "-----------")
    print("\231\173\137\231\186\167 " .. pokemon:getLevel())
    print("\229\189\147\229\137\141\231\187\143\233\170\140 " .. pokemon:getCurExp())
    print("\229\141\135\231\186\167\231\187\143\233\170\140 " .. pokemon:getMaxExp())
    print("\230\128\167\229\136\171 " .. pokemon:getSex())
    print("\231\167\141\230\151\143 " .. pokemon:getRace())
    print("\230\156\128\229\164\167\232\161\128\233\135\143 " .. pokemon:getMaxHp())
    print("\229\189\147\229\137\141\232\161\128\233\135\143 " .. pokemon:getCurHp())
    print("\230\138\128\232\131\189\229\136\151\232\161\168--------------------------- ")
    Lib.pv(pokemon:getSkillList())
    print("\232\162\171\229\138\168\230\138\128\232\131\189\229\136\151\232\161\168--------------------------- ")
    Lib.pv(pokemon:getPassiveSkillList())
    print("\229\190\133\229\173\166\230\138\128\232\131\189--------------------------- ")
    Lib.pv(pokemon:getStudySkillList())
  end
end
GMItem["\229\174\160\231\137\169/\230\129\162\229\164\141\230\137\128\230\156\137\231\138\182\230\128\129"] = function(self)
  local packet = self:getBattlePokemon()
  for _, pokemon in pairs(packet) do
    if pokemon then
      pokemon:recoveryAll()
    end
  end
end
GMItem["\229\174\160\231\137\169/\230\137\147\229\141\176\231\174\161\231\144\134\229\153\168\231\188\147\229\173\152"] = function(self)
  local list = PokemonManager:getAllPokemon()
  for objId, pokemon in pairs(list) do
    print("---------" .. objId .. "-----------")
    print("\231\173\137\231\186\167 " .. pokemon:getLevel())
    print("\229\189\147\229\137\141\231\187\143\233\170\140 " .. pokemon:getCurExp())
    print("\229\141\135\231\186\167\231\187\143\233\170\140 " .. pokemon:getMaxExp())
    print("\230\128\167\229\136\171 " .. pokemon:getSex())
    print("\231\167\141\230\151\143 " .. pokemon:getRace())
    print("\230\156\128\229\164\167\232\161\128\233\135\143 " .. pokemon:getMaxHp())
    print("\229\189\147\229\137\141\232\161\128\233\135\143 " .. pokemon:getCurHp())
    print("\230\138\128\232\131\189\229\136\151\232\161\168--------------------------- ")
    Lib.pv(pokemon:getSkillList())
    print("\232\162\171\229\138\168\230\138\128\232\131\189\229\136\151\232\161\168--------------------------- ")
    Lib.pv(pokemon:getPassiveSkillList())
    print("\229\190\133\229\173\166\230\138\128\232\131\189--------------------------- ")
    Lib.pv(pokemon:getStudySkillList())
    print("------getLongRoundEffectbuffList-------", Lib.v2s(pokemon:getLongRoundEffectbuffList()))
  end
end
GMItem["\231\137\169\229\147\129/\232\142\183\229\190\151\230\137\128\230\156\137\231\178\190\231\129\181\231\144\131"] = function(self)
  local cfgs = setting:modCfgs("item")
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemType) == Define.ITEM_TYPE.BALL then
      self:obtainItemsByFullName(_fullName, 1, "gm.ball")
    end
  end
end
GMItem["\231\137\169\229\147\129/\230\183\187\229\138\160\233\135\145\229\184\129"] = function(self)
  self:addCurrency("gold_coin", 10000000, "GM")
end
GMItem["\231\137\169\229\147\129/\230\183\187\229\138\160\229\129\135\233\173\148\230\150\185"] = function(self)
  self:addCurrency("fDiamonds", 10000000, "GM")
end
GMItem["\231\137\169\229\147\129/\232\142\183\229\190\151\230\137\128\230\156\137\230\129\162\229\164\141"] = function(self)
  local cfgs = setting:modCfgs("item")
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemType) == Define.ITEM_TYPE.CURE then
      self:obtainItemsByFullName(_fullName, 1, "gm.cure")
    end
  end
end
GMItem["\231\137\169\229\147\129/\232\142\183\229\190\151\230\137\128\230\156\137\229\133\182\228\187\150\231\137\169\229\147\129"] = function(self)
  local cfgs = setting:modCfgs("item")
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemType) == Define.ITEM_TYPE.OTHER then
      self:obtainItemsByFullName(_fullName, 1, "gm.other")
    end
  end
end
GMItem["\231\137\169\229\147\129/\232\142\183\229\190\151\230\137\128\230\156\137\230\138\128\232\131\189\228\185\166"] = function(self)
  local cfgs = setting:modCfgs("item")
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemType) == Define.ITEM_TYPE.SKILL then
      self:obtainItemsByFullName(_fullName, 1, "gm.skill")
    end
  end
end
GMItem["\231\137\169\229\147\129/\232\142\183\229\190\151\230\137\128\230\156\137\231\187\143\233\170\140\228\185\166"] = function(self)
  local cfgs = setting:modCfgs("item")
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemType) == Define.ITEM_TYPE.EXP then
      self:obtainItemsByFullName(_fullName, 1, "gm.exp")
    end
  end
end
GMItem["\231\137\169\229\147\129/\232\142\183\229\190\151\230\137\128\230\156\137\230\180\151\231\187\131\231\137\169\229\147\129"] = function(self)
  local cfgs = setting:modCfgs("item")
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemType) == Define.ITEM_TYPE.WASH then
      self:obtainItemsByFullName(_fullName, 1, "gm.wash")
    end
  end
end
GMItem["\231\137\169\229\147\129/\232\142\183\229\190\151\231\179\150\230\158\156"] = function(self)
  local cfgs = setting:modCfgs("item")
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemType) == Define.ITEM_TYPE.Bless then
      self:obtainItemsByFullName(_fullName, 1, "gm.skill")
    end
  end
end
GMItem["template/\230\148\187\229\135\187\229\174\160\231\137\169"] = function(self)
  if self.followPetObjId then
    local entity = World.CurWorld:getEntity(self.followPetObjId)
    if entity then
      SkillMgr:castSkill(self, 101, entity)
    end
  end
end
GMItem["template/\232\138\177\229\133\137\233\135\145\233\173\148\230\150\185"] = function(self)
  Lib.payMoney(self, 100022, 0, 13512, function(success)
  end)
end
GMItem["template/\232\142\183\229\190\151\231\187\143\233\170\1401000"] = function(self)
  self:addPlayerExp(1000)
end
local id = 1
GMItem["template/\228\190\157\230\172\161\232\142\183\229\190\151\229\139\139\231\171\160"] = function(self)
  self:catchGlory(id)
  id = id + 1
end
GMItem["template/\229\158\131\229\156\190\229\155\158\230\148\182"] = function(self)
  if self.battleField then
    Lib.logInfo("getTableSize entityList before", Lib.getTableSize(self.battleField.entityList))
    collectgarbage()
    collectgarbage()
    Lib.logInfo("getTableSize entityList after", Lib.getTableSize(self.battleField.entityList))
  end
end
GMItem["\229\188\149\229\175\188/\232\174\190\231\189\174\229\188\149\229\175\188\229\136\176\231\172\172\228\184\128\228\184\170\233\129\147\233\166\134"] = function(self)
  self:setCurGuideIndex(Define.GUIDE_INDEX.GOTO_GYM_1_BOSS)
end
GMItem["\229\188\149\229\175\188/\229\133\179\233\151\173\229\188\149\229\175\188"] = function(self)
  self:setGuideFinish(true)
end
GMItem["\228\188\160\233\128\129/\233\129\147\233\166\134"] = function(self)
  self:setMapPos(self.map, Lib.v3(49, 5, 432))
end
GMItem["\228\188\160\233\128\129/\229\155\158\229\159\142"] = function(self)
  self:setMapPos(self.map, Lib.v3(36, 5, 473))
end
GMItem["\228\188\160\233\128\129/\229\156\186\230\153\175\228\184\128"] = function(self)
  self:setMapPos("map001", Lib.v3(15.0, 5.01, 410.0))
end
GMItem["\228\188\160\233\128\129/\229\156\186\230\153\175\228\186\140"] = function(self)
  self:setMapPos(self.map, Lib.v3(200, 5, 410))
end
GMItem["\228\188\160\233\128\129/\229\156\186\230\153\175\228\184\137"] = function(self)
  self:setMapPos(self.map, Lib.v3(380, 5, 410))
end
GMItem["\228\188\160\233\128\129/\229\156\186\230\153\175\229\155\155"] = function(self)
  self:setMapPos(self.map, Lib.v3(580, 5, 410))
end
GMItem["\228\188\160\233\128\129/\229\156\186\230\153\175\228\186\148"] = function(self)
  self:setMapPos(self.map, Lib.v3(780, 5, 410))
end
GMItem["\228\188\160\233\128\129/\233\129\147\233\166\134\228\186\140"] = function(self)
  self:setMapPos("map006", Lib.v3(62, 4, -18))
end
GMItem["\228\188\160\233\128\129/\233\129\147\233\166\134\228\184\137"] = function(self)
  self:setMapPos("map001", Lib.v3(417.698212, 5.010008, 427.840729))
end
GMItem["\228\188\160\233\128\129/\233\129\147\233\166\134\229\155\155"] = function(self)
  self:setMapPos("map012", Lib.v3(62, 4, -17))
end
GMItem["\228\188\160\233\128\129/\233\129\147\233\166\134\228\186\148"] = function(self)
  self:setMapPos("map001", Lib.v3(641.41748, 3.009477, 393.522308))
end
GMItem["\228\188\160\233\128\129/\232\141\137\228\184\155"] = function(self)
  self:setMapPos(self.map, Lib.v3(7, 4, 406))
end
GMItem["\228\188\160\233\128\129/???"] = function(self)
  self:setMapPos(self.map, Lib.v3(97, 3, 397))
end
GMItem["\228\188\160\233\128\129/\230\168\161\229\158\139\230\149\136\230\158\156\230\181\139\232\175\149"] = function(self)
  self:setMapPos("map017", Lib.v3(0, 20, 0))
end
GMItem["\230\181\139\232\175\149/\229\136\155\229\187\186\233\151\168"] = function(self)
  local pos = self:getPosition()
  local indexX = math.random(-3, 3)
  local indexz = math.random(-3, 3)
  local params = {
    map = self.map,
    cfgName = "myplugin/g2038_testdoor_fire_off",
    pos = {
      x = pos.x + indexX,
      y = pos.y,
      z = pos.z + indexz
    },
    ry = 0,
    rp = 0
  }
  self.textDoorEntity = EntityServer.Create(params)
end
GMItem["\230\181\139\232\175\149/\233\148\128\230\175\129\233\151\168"] = function(self)
  self.textDoorEntity:addBuff("myplugin/entity_hide_buff")
end
GMItem["\230\181\139\232\175\149/\230\155\180\230\150\176\233\151\168"] = function(self)
  self.textDoorEntity:addBuff("myplugin/entity_show_buff")
end
GMItem["\230\181\139\232\175\149/\233\153\144\230\151\182\230\169\153\229\174\160"] = function(self)
  self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.ORANGE_PET, 10200701)
end
GMItem["\230\181\139\232\175\149/\230\153\174\233\128\154\232\183\145\233\169\172\231\129\175"] = function(self)
  self:sendTopWorldCommonTips("\232\191\153\230\152\175\228\184\128\230\157\161\232\183\145\233\169\172\231\129\175")
end
GMItem["\230\181\139\232\175\149/\230\153\174\233\128\154\228\184\150\231\149\140\232\129\138\229\164\169"] = function(self)
  self:sendChatWorldCommonTips("\232\191\153\230\152\175\228\184\128\230\157\161\228\184\150\231\149\140\232\129\138\229\164\169")
end
GMItem["\230\181\139\232\175\149/\231\137\185\230\174\138\228\184\150\231\149\140\230\143\144\231\164\186"] = function(self)
  local MapConfig = T(Config, "MapConfig")
  local tipsInfo = {
    tipType = 5,
    playerName = "\232\191\153\228\184\170\231\142\169\229\174\182\230\152\175\230\139\156\231\153\187",
    mapIdName = MapConfig:getMapById(1).title or "",
    starLevel = 5,
    quality = 3,
    pkmName = "\232\191\153\228\184\170\229\174\157\229\143\175\230\162\166\230\152\175\233\163\142\230\154\180\228\184\187\229\174\176",
    oldName = "\232\191\153\228\184\170\229\174\157\229\143\175\230\162\166\230\136\145\228\185\159\228\184\141\231\159\165\233\129\147\229\143\171\229\149\165",
    skillName = "",
    growthSCount = 0,
    ownerName = "",
    syntheticNum = 7
  }
  self:sendSpecialWorldCommonTips(tipsInfo)
end
GMItem["\230\181\139\232\175\149/\229\133\133\229\128\18830"] = function(self)
  print("getRechargeSum", self:getRechargeSum())
  self:setRechargeSum(self:getRechargeSum() + 30)
  self:addCurrency("fDiamonds", 30, "daily_reward")
  print("getRechargeSum", self:getRechargeSum())
end
GMItem["\230\181\139\232\175\149/\230\184\133\231\169\186\233\166\150\229\134\178\231\138\182\230\128\129"] = function(self)
  self:setRechargeSum(0)
  self:setRechargeAwardStatus(0)
end
GMItem["\230\181\139\232\175\149/\232\142\183\229\190\151\233\135\145\229\184\1291000"] = function(self)
  self:addCurrency("gold_coin", 1000, "gm_gold")
end
return GMItem
