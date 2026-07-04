require("script_client.lib")
require("script_client.ui.ui_manager")
require("script_client.entity.entity")
require("script_client.entity.entity_event")
require("script_client.player.player")
require("script_client.player.player_dialog")
require("script_client.player.player_packet")
require("script_client.player.player_control")
require("script_client.player.player_pokemon_swap")
require("script_client.player.player_ui_manager")
require("script_client.world.map")
require("script_client.world.region")
require("script_client.skill.timeLine")
require("script_client.skill.skill")
require("script_client.skill.base")
require("script_client.missile.missile_client")
require("script_client.entity.interaction_event")
require("script_client.rank")
require("script_client.ui.main_ui_menu_manager")
require("script_client.event_cache")
local debugport = require("common.debugport")
Sound3DRollOffType = {
  INVERSE = 1048576,
  LINEAR = 2097152,
  LINEARSQUARE = 4194304,
  INVERSETAPERED = 8388608,
  CUSTOM = 67108864
}
local main = {}
local tickEngineHandler = L("tickEngineHandler", handle_tick)
local grassMoveTable = Lib.newWeakTable({})
local grassMoveEntityPool = {}
local grassMovePoolPtr = 1

function handle_tick(frameTime)
  tickEngineHandler(frameTime)
end

Lib.subscribeKeyDownEvent("key.f1", function()
  if Me.disableControl then
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end
end)
local flag = false
Lib.subscribeKeyDownEvent("key.f11", function()
  if Me.disableControl then
    if not flag then
      Game.RunTelnet(1, debugport.port)
    else
      Game.RunTelnet(2, debugport.serverPort)
    end
    flag = not flag
  end
end)

function main:init()
  Blockman.instance:setAutoSetMaxFps(false)
  CGame.Instance():SetMaxFps(World.cfg.maxFps)
  self:initLog()
  self:setGlobalProperty()
  self:loadConfig()
  local MovieManager = require("script_client.movie.movie_manager")
  MovieManager:init()
  local BattleActionManager = require("script_client.battle.battle_action_manager")
  BattleActionManager:init()
  local PokemonManager = require("script_client.pokemon.pokemon_manager")
  PokemonManager:init()
  local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
  UIRedDotMgr:init()
  UIMgr.MainUIMenuManage:init()
  self:initClientGrassAni()
end

function main:initClientGrassAni()
  World.Timer(1, function()
    for i = 1, 10 do
      grassMoveEntityPool[i] = EntityClient.CreateClientEntity({
        cfgName = "myplugin/tallgrass_move",
        pos = {
          x = 0,
          y = -3,
          z = 0
        },
        name = ""
      })
    end
    Lib.subscribeEvent(Event.EVENT_BLOCK_POS_CHANGE, function(oldPos, curPos)
      self:actionGrassAni(oldPos, curPos)
    end)

    local encounterTimer = 0
    World.AutoEncounter = true
    World.LightTimer("grassCheck", 1, function()
      if Me.removed then
        return false
      end
      local curPos = Me:curBlockPos()

      encounterTimer = encounterTimer + 1
      if encounterTimer >= 20 then -- Every 1 second (approx 20 ticks)
        encounterTimer = 0
        if World.AutoEncounter and not Me:isInBattle() and not UI:isOpen("battle_pre_animation") then
             local pos = Me:getPosition()
             -- Simulate a small jitter to trick the server's distance-based encounter logic
             Me:sendPacket({
                pid = "ControlMovement",
                pos = {x = pos.x + 0.01, y = pos.y, z = pos.z + 0.01},
                pitch = Me:getRotationPitch(),
                yaw = Me:getRotationYaw(),
                moveState = 1
             })
             Me:sendPacket({
                pid = "ControlMovement",
                pos = pos,
                pitch = Me:getRotationPitch(),
                yaw = Me:getRotationYaw(),
                moveState = 0
             })
        end
      end

      if self.oldPos == curPos then
        return true
      end
      if not self.oldPos then
        self.oldPos = curPos
      end
      Lib.emitEvent(Event.EVENT_BLOCK_POS_CHANGE, self.oldPos, curPos)
      return true
    end)
  end)
end

function main:actionGrassAni(oldPos, curPos)
  self.oldPos = curPos
  if World.CurMap:getBlockConfigId(curPos) == 31 then
    local keyName = curPos.x .. "-" .. curPos.y .. "-" .. curPos.z
    if grassMoveTable[keyName] then
      grassMoveTable[keyName .. "Timer"]()
    else
      grassMoveTable[keyName] = grassMoveEntityPool[grassMovePoolPtr]
      if grassMovePoolPtr == 10 then
        grassMovePoolPtr = 1
      else
        grassMovePoolPtr = grassMovePoolPtr + 1
      end
    end
    if not grassMoveTable[keyName].map then
      grassMoveTable[keyName]:setMap(World.CurMap)
    end
    grassMoveTable[keyName]:setPosition({
      x = curPos.x + 0.5,
      y = curPos.y,
      z = curPos.z + 0.5
    })
    grassMoveTable[keyName]:updateUpperAction("move", -1)
    grassMoveTable[keyName .. "Timer"] = World.LightTimer("grassMoveTable", 15, function()
      World.LightTimer("grassMoveTable_n", 1, function()
        if not grassMoveTable[keyName] then
          return
        end
        grassMoveTable[keyName]:setPosition({
          x = 0,
          y = -3,
          z = 0
        })
        grassMoveTable[keyName] = nil
      end)
    end)
  end
end

function main:hideEngineUI()
  World.Timer(1, function()
    UI:closeWnd(UI:getWnd("skills", false))
    UI:closeWnd(UI:getWnd("topteamInfo", false))
    UI:closeWnd(UI:getWnd("playerList", false))
    UI:closeWnd(UI:getWnd("reload", false))
    UI:getWnd("battle_results"):onHide()
  end)
end

function main:setGlobalProperty()
  GlobalProperty.Instance():setBoolProperty("DisableCheckBlockTouch", true)

  -- Force UI visibility for Jump and Toolbar
  World.Timer(20, function()
      local actionControl = UI:getWnd("actionControl", false)
      if actionControl then
          actionControl:SetVisible(true)
          for i = 0, actionControl:GetChildCount() - 1 do
              local child = actionControl:GetChildByIndex(i)
              child:SetVisible(true)
              child:SetEnabled(true)
          end
      end
      local toolbar = UI:getWnd("toolbar", false)
      if toolbar then toolbar:SetVisible(true) end
      return true
  end)

  -- ULTRA HACK: Auto Star-Up System (Optimized Mass Upgrader)
  World.AutoStarUp = true
  World.Timer(20, function() -- Every 1 second
      if not World.AutoStarUp or Me:isInBattle() then return true end

      local battlePetList = Me:getValue("battlePetList") or {}
      local packetPetList = Me:getValue("packetPetList") or {}

      local function isInTeam(objId)
          for _, id in pairs(battlePetList) do
              if id == objId then return true end
          end
          return false
      end

      local PokemonConfig = T(Config, "PokemonConfig")
      local PokemonManager = require("script_client.pokemon.pokemon_manager")

      PokemonManager:getPokemonList(packetPetList, function(pokemonList)
          -- Sort to prioritize 1-2 star pets
          table.sort(pokemonList, function(a, b) return a:getStar() < b:getStar() end)

          local processed = 0
          local materialsUsed = {}

          -- Find candidates (Epic/Rare/Legendary pets in box)
          for _, pet in pairs(pokemonList) do
              if processed >= 5 then break end -- Limit to 5 upgrades per tick to avoid kicks

              local star = pet:getStar()
              local quality = pet:getQuality()
              local petId = pet:getObjId()

              -- Only auto-upgrade up to 5 stars as requested
              if star < 5 and not isInTeam(petId) and not materialsUsed[petId] then
                  local starCfg = PokemonConfig:getStarConfig(star)
                  local cost = starCfg.starUpCost -- [count, star_level]

                  if cost and cost[1] > 0 then
                      local materials = {}
                      -- Find materials
                      for _, mat in pairs(pokemonList) do
                          local matId = mat:getObjId()
                          -- RULES: Not self, Not in team, Not locked, Not already used this tick, NOT TURTLEMAGE (10201001)
                          if matId ~= petId and not isInTeam(matId) and not mat:isLocked() and not materialsUsed[matId] and mat:getCfgId() ~= 10201001 then
                              if mat:getStar() == tonumber(cost[2]) and (mat:getRace() == pet:getRace() or mat:getRace() == 5 or mat:getRace() == 6 or starCfg.needSameRace == 0) then
                                  table.insert(materials, matId)
                                  if #materials >= tonumber(cost[1]) then
                                      break
                                  end
                              end
                          end
                      end

                      if #materials >= tonumber(cost[1]) then
                          print("AUTO STAR-UP: Elevating " .. pet:getName() .. " (Level " .. star .. ")")
                          Me:sendPacket({
                              pid = "pokemonStarUp",
                              objId = petId,
                              selectObjIds = materials
                          })
                          processed = processed + 1
                          materialsUsed[petId] = true
                          for _, mId in ipairs(materials) do materialsUsed[mId] = true end
                      end
                  end
              end
          end
      end)
      return true
  end)
end

function main:initLog()
  Lib.setDebugLog(CGame.Instance():isDebuging())
end

function main:loadConfig()
  local PokemonRotaryTableConfig = T(Config, "PokemonRotaryTableConfig")
  PokemonRotaryTableConfig:init()
  local PokemonGloryHallConfig = T(Config, "PokemonGloryHallConfig")
  PokemonGloryHallConfig:init()
  local MainUiMenuBtnConfig = T(Config, "MainUiMenuBtnConfig")
  MainUiMenuBtnConfig:init()
  local PokemonLuckyRareConfig = T(Config, "PokemonLuckyRareConfig")
  PokemonLuckyRareConfig:init()
  local PokemonLuckyPriceConfig = T(Config, "PokemonLuckyPriceConfig")
  PokemonLuckyPriceConfig:init()
  local PokemonLuckyPkmConfig = T(Config, "PokemonLuckyPkmConfig")
  PokemonLuckyPkmConfig:init()
  local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
  PokemonLuckyExtraConfig:init()
  local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
  TriggerGiftConfig:init()
  local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
  RegularGiftItemConfig:init()
  local RegularGiftConfig = T(Config, "RegularGiftConfig")
  RegularGiftConfig:init()
  local RechargeAwardConfig = T(Config, "RechargeAwardConfig")
  RechargeAwardConfig:init()
  local WorldCommonTipsConfig = T(Config, "WorldCommonTipsConfig")
  WorldCommonTipsConfig:init()
  local PayShopConfig = T(Config, "PayShopConfig")
  PayShopConfig:init()
  local SoundConfig = T(Config, "SoundConfig")
  SoundConfig:init()
  local GloryConfig = T(Config, "GloryConfig")
  GloryConfig:init()
  local PlayerExpConfig = T(Config, "PlayerExpConfig")
  PlayerExpConfig:init()
  local NormalBattleRewardConfig = T(Config, "NormalBattleRewardConfig")
  NormalBattleRewardConfig:init()
  local MainBattleRewardConfig = T(Config, "MainBattleRewardConfig")
  MainBattleRewardConfig:init()
  local SpriteBallConfig = T(Config, "SpriteBallConfig")
  SpriteBallConfig:init()
  local SkillConfig = T(Config, "SkillConfig")
  SkillConfig:init()
  local SkillEffectConfig = T(Config, "SkillEffectConfig")
  SkillEffectConfig:init()
  local DailyLotteryConfig = T(Config, "DailyLotteryConfig")
  DailyLotteryConfig:init()
  local NPCConfig = T(Config, "NPCConfig")
  NPCConfig:init()
  local NPCPokemonConfig = T(Config, "NPCPokemonConfig")
  NPCPokemonConfig:init()
  local PokemonLeaderboardRewardConfig = T(Config, "PokemonLeaderboardRewardConfig")
  PokemonLeaderboardRewardConfig:init()
  local MapConfig = T(Config, "MapConfig")
  MapConfig:init()
  local RegionConfig = T(Config, "RegionConfig")
  RegionConfig:init()
  local GymConfig = T(Config, "GymConfig")
  GymConfig:init()
  local GymDefaultRankConfig = T(Config, "GymDefaultRankConfig")
  GymDefaultRankConfig:init()
  local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
  PokemonGuideConfig:init()
  local SkillPerformConfig = T(Config, "SkillPerformConfig")
  SkillPerformConfig:init()
  local ActiveRewardConfig = T(Config, "ActiveRewardConfig")
  ActiveRewardConfig:init()
  local PokemonTaskConfig = T(Config, "PokemonTaskConfig")
  PokemonTaskConfig:init()
end

function main:getGrassMoveTable()
  return grassMoveTable
end

main:init()
return main
