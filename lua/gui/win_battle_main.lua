local LuaTimer = T(Lib, "LuaTimer")
local operationTime = World.cfg.operationTime
local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local skillCellHeight = 59
local skillCellVerticalInterval = 13
local headCellWidthInterval = 10
local headCellWidth = 297
local headCellHeight = 88
local QUEUE_TYPE = {OUR = 1, ENEMY = 2}
local commandType = {
  select = 1,
  skill = 2,
  ball = 3
}
local switchType = {add = 1, sub = 2}
local M = _ENV.M

function M:init()
  Lib.logInfo("******************************** init battle_main ********************************")
  WinBase.init(self, "battle_main.json", false)
  self.ourCells = {}
  self.enemyCells = {}
  self.battleQueue = {}
  self.ourQueue = {}
  self.auto = false
  self.isShowRestraint = false
  self.canCommand = true
  self.opPokemon = nil
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytcanvas = self:child("canvas")
  self.infoCenter = self:child("canvas-info_center")
  self.lytcanvasCommand = self:child("canvas-command")
  self.btncanvasFight = self:child("canvas-fight")
  self.btncanvasRunaway = self:child("canvas-runaway")
  self.btncanvasPokemon = self:child("canvas-pokemon")
  self.rounds = self:child("canvas-rounds")
  self.timeText = self:child("canvas-time")
  self.btnGM = self:child("Main-GM")
  self.btnGM:SetVisible(World.gameCfg.gm or false)
  Lib.logInfo("btnGM SetVisible", World.gameCfg.gm or false)
  self.lyCanvasCenterTop = self:child("canvas-center-top")
  self.lyCommandSelect = self:child("canvas-command_select")
  self.lyCommandSkill = self:child("canvas-command_skill")
  self.btnCommandSkillReturn = self:child("canvas-command_skill_return")
  self.lyCommandSkillList = self:child("canvas-command_skill_list")
  self.gvSkillList = UIMgr:new_widget("grid_view")
  self.lyCanvasNoncombat = self:child("canvas-noncombat")
  self.lyNoncombat = self:child("canvas-noncombat_btn_list")
  self.btnNoncombatSwitch = self:child("canvas-noncombat_switch")
  self.lySkillDetailMask = self:child("canvas-skill_detail_mask")
  self.lySkillDetail = self:child("canvas-skill_detail")
  self.descItem = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.descItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lySkillDetail:AddChildWindow(self.descItem)
  self.btnCanvasBag = self:child("canvas-bag")
  self.btnCanvasBall = self:child("canvas-ball")
  self.lytCanvasCommandBall = self:child("canvas-command_ball")
  self.imgCanvasCommandBallIcon = self:child("canvas-command_ball_icon")
  self.txtCanvasCommandBallName = self:child("canvas-command_ball_name")
  self.txtCanvasCommandBallNum = self:child("canvas-command_ball_num")
  self.btnAuto = self:child("canvas-auto")
  self.btnCanvasCommandBallLeft = self:child("canvas-command_ball_left")
  self.btnCanvasCommandBallRight = self:child("canvas-command_ball_right")
  self.btnCanvasCommandBallConfirm = self:child("canvas-command_ball_confirm")
  self.btnCanvasCommandBallClose = self:child("canvas-command_ball_close")
  self.lyCanvasCommandBallDetailList = self:child("canvas-command_ball_detail_list")
  self.gvBallDec = UIMgr:new_widget("grid_view")
  self.stBallDetailText = self:child("canvas-command_ball_detail_text")
  self.txtCanvasAutoCountDown = self:child("canvas-auto_count_down")
  self.lyOurQueueList = self:child("canvas-lb_pet_info")
  self.lyEnemyQueueList = self:child("canvas-ru_pet_info")
  self:child("canvas-fight_text"):SetText(Lang:toText("ui_fight"))
  self:child("canvas-bag_text"):SetText(Lang:toText("title_bag"))
  self:child("canvas-pokemon_text"):SetText(Lang:toText("ui_pokemon"))
  self:child("canvas-runaway_text"):SetText(Lang:toText("ui_runaway"))
  self.btnCanvasTimingGift = self:child("canvas-TimingGift")
  self.txtCanvasTimingTitle = self:child("canvas-TimingTitle")
  self.txtCanvasTimingTitle:SetText("00:00:00")
  self.btnCanvasGrowthGift = self:child("canvas-GrowthGift")
  self.txtCanvasGrowthTitle = self:child("canvas-GrowthTitle")
  self.txtCanvasGrowthTitle:SetText("00:00:00")
  self.llCanvasTypeRestraint = self:child("canvas-type_restraint")
  self:child("canvas-restraint_title"):SetText(Lang:toText("ui_type_restraint"))
  self.imgCanvasRestraint = self:child("canvas-restraint_img")
  self.btnCanvasRestraint = self:child("canvas-restraint")
  self.lyPrompt = self:child("canvas-prompt")
  self.stPromptText = self:child("canvas-prompt-text")
  self.btnPrompt = self:child("canvas-prompt-btnClose")
  self.lyPrompt:SetVisible(false)
  self:initList()
  self:showInfoCenter(false)
end

function M:hideRunaway(hide)
  self.btncanvasRunaway:SetEnabled(not hide)
  Lib.logDebug("hideRunaway", hide)
end

function M:showInfoCenter(show)
  if self.infoCenter then
    self.infoCenter:SetVisible(show)
    self.infoCenter:SetText(show and Lang:getMessage("battle_pvp_wait_player_op") or "")
  end
end

function M:initEvent()
  self:lightSubscribe("error!!!!!", self.btnGM, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btncanvasFight event : EventButtonClick", self.btncanvasFight, UIEvent.EventButtonClick, function()
    self:openCommandWinByType(commandType.skill)
    self:getSkillDamageEffect(self.enemyQueue, self.skillCells)
    if not self.viewOnceSkills then
      self:showTypeRestraint(true, true)
      self.viewOnceSkills = true
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnAuto event : EventButtonClick", self.btnAuto, UIEvent.EventButtonClick, function()
    self:onAuto()
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasTimingGift event : EventButtonClick", self.btnCanvasTimingGift, UIEvent.EventButtonClick, function()
    UI:openWnd("pokemonGiftBag", Define.TRIGGER_GIFT_TYPE.TIME)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasGrowthGift event : EventButtonClick", self.btnCanvasGrowthGift, UIEvent.EventButtonClick, function()
    UI:openWnd("pokemonGiftBag", Define.TRIGGER_GIFT_TYPE.GROW)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btncanvasRunaway event : EventButtonClick", self.btncanvasRunaway, UIEvent.EventButtonClick, function()
    Lib.logDebug("btncanvasRunaway EventButtonClick")
    local wnd = UI:getWnd("battle_dialog")
    wnd:showDialogText({
      text = Lang:getMessage("ui_are_you_sure_runaway"),
      noCb = function()
      end,
      yesCb = function()
        Me:battleAction(Define.BATTLE_ACTION.RUNAWAY)
        if Me.battleFieldInfo and Me.battleFieldInfo.mode == Define.BATTLE_MODE.PVP or Me:isJoinTeam() then
          self:showControlWin(false)
        end
      end
    })
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btncanvasPokemon event : EventButtonClick", self.btncanvasPokemon, UIEvent.EventButtonClick, function()
    UI:openWnd("battle_pokemon", true)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasBag event : EventButtonClick", self.btnCanvasBag, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonBag"):onShow(true, Define.SCENE_TYPE.BATTLE)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnNoncombatSwitch event : EventButtonClick", self.btnNoncombatSwitch, UIEvent.EventButtonClick, function()
    if not self.lyNoncombat:IsVisible() then
      self.lyNoncombat:SetVisible(true)
      self.btnNoncombatSwitch:SetPushedImage("set:pokemon_battle.json image:return")
      self.btnNoncombatSwitch:SetNormalImage("set:pokemon_battle.json image:return")
    else
      self.lyNoncombat:SetVisible(false)
      self.btnNoncombatSwitch:SetPushedImage("set:pokemon_battle.json image:expand")
      self.btnNoncombatSwitch:SetNormalImage("set:pokemon_battle.json image:expand")
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCommandSkillReturn event : EventButtonClick", self.btnCommandSkillReturn, UIEvent.EventButtonClick, function()
    self:openCommandWinByType(commandType.select)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main lySkillDetailMask event : EventWindowClick", self.lySkillDetailMask, UIEvent.EventWindowClick, function()
    self.lySkillDetail:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasBall event : EventButtonClick", self.btnCanvasBall, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_USE_BALL then
      Me:gotoNextGuide()
    else
      self:openCommandWinByType(commandType.ball)
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasCommandBallClose event : EventButtonClick", self.btnCanvasCommandBallClose, UIEvent.EventButtonClick, function()
    self:openCommandWinByType(commandType.select)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasCommandBallConfirm event : EventButtonClick", self.btnCanvasCommandBallConfirm, UIEvent.EventButtonClick, function()
    if not self.ballCfg then
      return
    end
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_CONFIRM_BALL then
      UI:getWnd("pokemonGuide"):onShow(false)
    end
    if self.enemyQueue and #self.enemyQueue == 1 then
      self:onUsePokemonBall(self.enemyQueue[1].objId)
    elseif self.enemyQueue and #self.enemyQueue > 1 then
      UI:openWnd("battle_select_target", Define.BATTLE_TARGET.ENEMY, 1, function(objId)
        self:onUsePokemonBall(objId)
      end)
    end
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasCommandBallLeft event : EventButtonClick", self.btnCanvasCommandBallLeft, UIEvent.EventButtonClick, function()
    self:switchBallPaging(switchType.sub)
    self:showBallWindow(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasRestraint event : EventButtonClick", self.btnCanvasRestraint, UIEvent.EventButtonClick, function()
    self:showTypeRestraint(not self.isShowRestraint, true)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnCanvasCommandBallRight event : EventButtonClick", self.btnCanvasCommandBallRight, UIEvent.EventButtonClick, function()
    self:switchBallPaging(switchType.add)
    self:showBallWindow(true)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_battle_main Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    for _, cell in pairs(self.ourCells or {}) do
      local pokemon = cell:invoke("getPokemon")
      if pokemon then
        local masterId = pokemon:getMasterId()
        if Me.platformUserId == masterId and objId == pokemon:getObjId() then
          self:updateSkillList(pokemon)
        end
      end
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_battle_main Lib event : EVENT_UPDATE_BATTLE_PET_LIST", Event.EVENT_UPDATE_BATTLE_PET_LIST, function(value)
    local objIds = self:neatenObjIds(value, 2)
    Me:getPokemonList(objIds, function(pokemonList)
      self:initBothQueue(pokemonList, self.ourCells, QUEUE_TYPE.OUR)
      self.ourQueue = pokemonList
      for _, pokemon in pairs(self.ourQueue or {}) do
        local masterId = pokemon:getMasterId()
        if Me.platformUserId == masterId then
          self:updateSkillList(pokemon)
        end
      end
    end)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_battle_main Lib event : EVENT_UPDATE_ENEMY_PET_LIST", Event.EVENT_UPDATE_ENEMY_PET_LIST, function(value)
    local objIds = self:neatenObjIds(value, 2)
    Me:getPokemonList(objIds, function(pokemonList)
      self:initBothQueue(pokemonList, self.enemyCells, QUEUE_TYPE.ENEMY)
      self.enemyQueue = pokemonList
    end)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_battle_main Lib event : EVENT_REFRESH_PLAYER_BAG", Event.EVENT_REFRESH_PLAYER_BAG, function()
    if not UI:isOpen(self) then
      return
    end
    self:updateBallInfo()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_battle_main Lib event : EVENT_UPDATE_BATTLE_NPC_ID", Event.EVENT_UPDATE_BATTLE_NPC_ID, function(npcId)
    self.npcId = npcId
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_battle_main Lib event : EVENT_SHOW_PVP_PROMPT", Event.EVENT_SHOW_PVP_PROMPT, function(playerName, rank)
    if not UI:isOpen(self) then
      return
    end
    self:showPVPPrompt(playerName, rank)
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_main btnPrompt event : EventButtonClick", self.btnPrompt, UIEvent.EventButtonClick, function()
    self.lyPrompt:SetVisible(false)
  end)
end

function M:initList()
  self.lyCanvasCommandBallDetailList:AddChildWindow(self.gvBallDec)
  self.gvBallDec:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvBallDec:InitConfig(0, 0, 1)
  self.gvBallDec:AddItem(self.stBallDetailText)
  self.lyCommandSkillList:AddChildWindow(self.gvSkillList)
  self.gvSkillList:SetAutoColumnCount(false)
  self.gvSkillList:SetMoveAble(false)
  self.gvSkillList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvSkillList:InitConfig(0, skillCellVerticalInterval, 1)
end

function M:neatenObjIds(value, sortType)
  local arr = {}
  local objIds = {}
  for key, objId in pairs(value) do
    table.insert(arr, {index = key, objId = objId})
  end
  if sortType == 1 then
    table.sort(arr, function(a, b)
      return a.index < b.index
    end)
  else
    table.sort(arr, function(a, b)
      return a.index > b.index
    end)
  end
  for _, v in ipairs(arr) do
    table.insert(objIds, v.objId)
  end
  return objIds
end

local minH = 64
local maxH = 252

function M:showTypeRestraint(isShow, initiative)
  if initiative then
    local value = (maxH - minH) / 3
    if self.showRestraintTimer then
      self.showRestraintTimer()
    end
    self.imgCanvasRestraint:SetVisible(not isShow)
    if isShow then
      self.llCanvasTypeRestraint:SetVisible(isShow)
    else
      self.imgCanvasRestraint:SetVisible(isShow)
    end
    self.showRestraintTimer = World.Timer(1, function()
      local oldH = self.llCanvasTypeRestraint:GetHeight()[2]
      if isShow then
        self.llCanvasTypeRestraint:SetHeight({
          0,
          oldH + value
        })
      else
        self.llCanvasTypeRestraint:SetHeight({
          0,
          oldH - value
        })
      end
      local curH = self.llCanvasTypeRestraint:GetHeight()[2]
      if curH >= maxH or curH <= minH then
        self.llCanvasTypeRestraint:SetHeight({
          0,
          curH >= maxH and maxH or minH
        })
        self.llCanvasTypeRestraint:SetVisible(isShow)
        self.imgCanvasRestraint:SetVisible(isShow)
        return false
      end
      return true
    end)
  else
    if self.showRestraintTimer then
      self.showRestraintTimer()
    end
    local curH = minH
    if isShow then
      curH = maxH
    end
    self.llCanvasTypeRestraint:SetHeight({0, curH})
    self.llCanvasTypeRestraint:SetVisible(isShow)
    self.imgCanvasRestraint:SetVisible(isShow)
  end
  self.isShowRestraint = isShow
  local icon = isShow and "set:attribute_restraint_relation.json image:btn_0_downarrow" or "set:attribute_restraint_relation.json image:btn_0_uparrow"
  self.btnCanvasRestraint:SetPushedImage(icon)
  self.btnCanvasRestraint:SetNormalImage(icon)
end

function M:showSkillDetail(cell)
  self.lySkillDetail:SetVisible(true)
  local skill = cell:invoke("getSkill")
  self.descItem:invoke("updateInfo", skill)
end

function M:updateSkillList(pokemon)
  local skills = pokemon:getSkillList()
  self.opPokemon = pokemon
  self.gvSkillList:RemoveAllItems()
  self.skillCells = {}
  local lyHeight = 0
  for key, skillInfo in ipairs(skills or {}) do
    local cell = UIMgr:new_widget("pokemon_skill_cell")
    cell:invoke("updateInfo", skillInfo)
    self:lightSubscribe("error!!!!! script_client win_battle_main skillsCell-key=" .. key .. " event : EventWindowClick", cell, UIEvent.EventWindowClick, function()
      Lib.logDebug("btncanvasFight EventButtonClick")
      local skill = cell:invoke("getSkill")
      if self.enemyQueue and #self.enemyQueue == 1 then
        self:onSkillSelect(skill)
      elseif self.enemyQueue and #self.enemyQueue > 1 then
        local skill_config = SkillConfig:getConfigById(skill.skillId)
        if not skill_config then
          return
        end
        UI:openWnd("battle_select_target", Define.BATTLE_TARGET.ENEMY, skill_config.count, function(objId)
          self:onSkillSelect(skill, objId)
        end, skill_config.race)
      end
    end)
    self:lightSubscribe("error!!!!! script_client win_battle_main skillsCell-key=" .. key .. " event : EventWindowLongTouchStart", cell, UIEvent.EventWindowLongTouchStart, function()
      self:showSkillDetail(cell)
    end)
    lyHeight = lyHeight + skillCellVerticalInterval + skillCellHeight
    self.gvSkillList:AddItem(cell)
    table.insert(self.skillCells, cell)
  end
  self.lyCommandSkillList:SetHeight({0, lyHeight})
end

function M:onSkillSelect(skill, objId)
  if not self.opPokemon then
    UI:getWnd("battle_dialog"):showDialogText({
      text = Lang:getMessage("skill_useless"),
      isHideMask = false,
      yesCb = function()
      end
    })
    return
  end
  
  local function selectSkill()
    if not Me:battleAction(Define.BATTLE_ACTION.SKILL, {
      skillId = skill.skillId,
      pet = self.opPokemon,
      targetId = objId
    }) then
      UI:getWnd("battle_dialog"):showDialogText({
        text = Lang:getMessage("skill_useless"),
        isHideMask = false,
        yesCb = function()
        end
      })
    else
      self:showControlWin(false)
    end
  end
  
  if skill.curTimes > 0 then
    selectSkill()
  else
    local skills = self.opPokemon:getSkillList()
    local usableSkills = {}
    for _, _skill in pairs(skills) do
      if _skill.curTimes > 0 then
        table.insert(usableSkills, _skill)
      end
    end
    if 0 < #usableSkills then
      UI:getWnd("battle_dialog"):showDialogText({
        text = Lang:getMessage("skill_no_number"),
        isHideMask = false,
        yesCb = function()
        end
      })
    else
      selectSkill()
    end
  end
end

function M:onAuto()
  self.auto = not self.auto
  local btnImg
  if self.auto then
    btnImg = "set:pokemon_battle.json image:auto_enable"
  else
    btnImg = "set:pokemon_battle.json image:auto_disable"
    self.txtCanvasAutoCountDown:SetVisible(false)
  end
  self.btnAuto:SetPushedImage(btnImg)
  self.btnAuto:SetNormalImage(btnImg)
  local showCommand = not self.auto
  if self.isBattlePhase then
    showCommand = false
  end
  self.lytcanvasCommand:SetVisible(self.canCommand and showCommand or false)
end

function M:initBothQueue(pokemonList, cells, queueType)
  local ratio = headCellHeight / headCellWidth
  local cellWidth = (self.lyOurQueueList:GetPixelSize().x - headCellWidthInterval) / 2
  local cellHeight = ratio * cellWidth
  for i, pokemon in ipairs(pokemonList or {}) do
    if not cells[i] then
      local cell = UIMgr:new_widget("pokemon_head_cell")
      cell:SetWidth({0, cellWidth})
      cell:SetHeight({0, cellHeight})
      cell:invoke("setType", Define.SCENE_TYPE.BATTLE)
      cell:invoke("updateInfo", pokemon)
      cell:invoke("updatePetBuffList", pokemon)
      if pokemon then
        local masterId = pokemon:getMasterId()
        if Me.platformUserId ~= masterId then
          cell:invoke("setPvpQueue", self.battleQueue[masterId])
        end
      end
      local xp = 0
      if queueType == QUEUE_TYPE.OUR then
        cell:SetHorizontalAlignment(0)
        self.lyOurQueueList:AddChildWindow(cell)
        xp = (i - 1) * (headCellWidthInterval + cellWidth)
        cell:invoke("setPetBallsListPos", true)
        cell:invoke("setPetBuffListPos", true)
        cell:SetYPosition({0, -25})
      else
        cell:SetHorizontalAlignment(2)
        self.lyEnemyQueueList:AddChildWindow(cell)
        xp = -1 * (i - 1) * (headCellWidthInterval + cellWidth)
        cell:invoke("setPetBallsListPos", false)
        cell:invoke("setPetBuffListPos", false)
      end
      cell:SetXPosition({0, xp})
      cells[i] = cell
    else
      cells[i]:invoke("updateInfo", pokemon)
      cells[i]:invoke("updatePetBuffList", pokemon)
      if pokemon then
        local masterId = pokemon:getMasterId()
        if Me.platformUserId ~= masterId then
          cells[i]:invoke("setPvpQueue", self.battleQueue[masterId])
        end
      end
    end
  end
  self:neatenQueueShowInfo(pokemonList, cells, queueType)
end

function M:neatenQueueShowInfo(pokemonList, cells, queueType)
  local masterId
  for i, cell in ipairs(cells) do
    if not pokemonList[i] then
      self.lyEnemyQueueList:RemoveChildWindow1(cell)
      cells[i] = nil
    else
      local curMasterId = pokemonList[i]:getMasterId()
      if masterId ~= curMasterId and curMasterId ~= 0 then
        masterId = curMasterId
        cell:invoke("showQueueInfo", true)
      elseif queueType == QUEUE_TYPE.ENEMY and self.npcId and self.initPveEnemyQueue then
        cell:invoke("showQueueInfo", true)
        cell:invoke("setPvpQueue", self.initPveEnemyQueue[i])
      else
        cell:invoke("showQueueInfo", false)
        if queueType == QUEUE_TYPE.OUR and self.initPveHost then
          cell:invoke("setPvpQueue", self.initPveHost)
          cell:invoke("showQueueInfo", true)
        end
      end
    end
  end
end

function M:initPveEnemyQueueInfo(queue)
  self.initPveEnemyQueue = self:neatenObjIds(queue, 2)
end

function M:initPveHostInfo(queue)
  self.initPveHost = queue
end

function M:initBattleQueue(battleQueue)
  self.battleQueue = battleQueue
  self:updateHeadBattleQueueInfo(self.enemyCells)
  self:updateHeadBattleQueueInfo(self.ourCells)
end

function M:updateHeadBattleQueueInfo(cells)
  for i, cell in pairs(cells or {}) do
    local pokemon = cell:invoke("getPokemon")
    if pokemon then
      local masterId = pokemon:getMasterId()
      if self.battleQueue[masterId] and Me.platformUserId ~= masterId then
        cell:invoke("setPvpQueue", self.battleQueue[masterId])
      end
    end
  end
end

function M:openCommandWinByType(cType)
  self.lyCommandSelect:SetVisible(cType == commandType.select)
  self.lyCommandSkill:SetVisible(cType == commandType.skill)
  self:showBallWindow(cType == commandType.ball)
  self.lySkillDetail:SetVisible(false)
end

function M:showBallWindow(isShow)
  self.lytCanvasCommandBall:SetVisible(isShow)
  self.ballCfg = nil
  if isShow then
    if self.balls and next(self.balls) then
      local ballsInfo = self:neatenShowBallsInfo(self.balls)
      local cfg
      for ballId, ball in pairs(ballsInfo) do
        if ballId == self.ballId then
          cfg = ball.item:cfg()
          if not cfg then
            return
          end
          self.ballCfg = cfg
          self:updateCommandBallInfo(cfg, ball)
        end
      end
      if not cfg then
        for ballId, ball in pairs(ballsInfo) do
          cfg = ball.item:cfg()
          if not cfg then
            return
          end
          self.ballCfg = cfg
          self:updateCommandBallInfo(cfg, ball)
          self.ballId = ballId
          break
        end
      end
    else
      self:openCommandWinByType(commandType.select)
      UI:getWnd("battle_dialog"):showDialogText({
        text = Lang:getMessage("ui_are_no_balls"),
        yesCb = function()
        end
      })
    end
  end
end

function M:updateCommandBallInfo(cfg, ball)
  self.imgCanvasCommandBallIcon:SetImage(cfg.icon)
  self.txtCanvasCommandBallNum:SetText(ball.count)
  self.txtCanvasCommandBallName:SetText(Lang:toText(cfg.itemName))
  self.stBallDetailText:SetText(Lang:toText(cfg.desc))
end

function M:updateBallInfo()
  self.balls = Me:getBagItemsByBagType(Define.BAG_TYPE.BALL)
end

function M:neatenShowBallsInfo(balls)
  local ballArr = {}
  for _, ball in pairs(balls) do
    local id = ball._cfg.ballId
    if ballArr[id] then
      table.insert(ballArr[id], ball)
    else
      ballArr[id] = {}
      table.insert(ballArr[id], ball)
    end
  end
  local ballsInfo = {}
  self.ballIds = {}
  for id, _balls in pairs(ballArr) do
    for _, ball in pairs(_balls) do
      if ballsInfo[id] then
        ballsInfo[id].count = ballsInfo[id].count + ball:stack_count()
      else
        ballsInfo[id] = {
          item = ball,
          count = ball:stack_count()
        }
      end
    end
    table.insert(self.ballIds, id)
  end
  table.sort(self.ballIds, function(a, b)
    return a < b
  end)
  return ballsInfo
end

function M:onUsePokemonBall(targetId)
  local isCanUse = false
  for _, pokemon in pairs(self.enemyQueue or {}) do
    if pokemon:getObjId() == targetId and Me:getPlayerLevel() >= pokemon:getLevel() and (not pokemon:getMasterId() or pokemon:getMasterId() == 0) then
      isCanUse = true
    end
  end
  if isCanUse and Me:battleAction(Define.BATTLE_ACTION.BALL, {
    itemId = self.ballCfg.itemId,
    targetId = targetId
  }) then
    self:showControlWin(false)
  else
    UI:getWnd("battle_dialog"):showDialogText({
      text = Lang:getMessage("ui_you_unable_to_capture"),
      yesCb = function()
      end
    })
  end
end

function M:onUseDefaultBall()
  self:onUsePokemonBall(self.enemyQueue[1].objId)
end

function M:switchBallPaging(sType)
  if not self.ballIds or not self.ballId then
    return
  end
  local addId, subId
  if #self.ballIds == 1 then
    return
  end
  for i, ballId in ipairs(self.ballIds) do
    if self.ballId == ballId then
      if i - 1 < 1 then
        subId = self.ballIds[#self.ballIds]
      else
        subId = self.ballIds[i - 1]
      end
      if i + 1 > #self.ballIds then
        addId = self.ballIds[1]
      else
        addId = self.ballIds[i + 1]
      end
    end
  end
  if sType == switchType.add then
    self.ballId = addId
  elseif sType == switchType.sub then
    self.ballId = subId
  end
end

function M:showControlWin(isShow)
  self.lytcanvasCommand:SetVisible(isShow)
  if self.auto then
    self.lytcanvasCommand:SetVisible(false)
  end
  self.lyCanvasCenterTop:SetVisible(isShow)
  self:openCommandWinByType(commandType.select)
  self.isBattlePhase = not isShow
  if not isShow then
    self:cleanCountdownTimer()
    self:showTypeRestraint(false, true)
  end
  if isShow then
    self:showInfoCenter(false)
  end
end

function M:subscribeEvent()
end

function M:initView()
  self:updateBallInfo()
end

function M:onHide()
  UI:closeWnd("battle_main")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("battle_main")
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  Lib.logDebug("battle_main onOpen ")
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  self:showControlWin(true)
  local unlockMod = UI:getWnd("pokemonMain").unlockMod
  unlockMod = unlockMod or PlayerExpConfig:getUnlockModByLv(Me:getPlayerLevel())
  self:specialNpcBattleWndShow(true, unlockMod)
  UI:closeWnd("pokemonGiftBag")
  if Me and Me:isValid() then
    local inNpc = Me:isInNpcBattle()
    self:hideRunaway(Me:isJoinTeam() and not Me:isTeamCaptain() or not unlockMod[Define.MODULE_TYPE.BATTLE_RUNAWAY])
    local isPVPMode = Me.battleFieldInfo and Me.battleFieldInfo.mode == Define.BATTLE_MODE.PVP or false
    self.btnCanvasBall:SetVisible(not inNpc and not isPVPMode)
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_GOTO then
      self.btnCanvasBall:SetVisible(false)
    end
  end
  self:showTypeRestraint(self.isShowRestraint)
end

function M:specialNpcBattleWndShow(isShow, unlockMod)
  self.btnAuto:SetVisible(unlockMod[Define.MODULE_TYPE.BATTLE_AUTO])
  self:showBtnAndSetEnabled(self.btnCanvasBag, isShow, unlockMod[Define.MODULE_TYPE.BATTLE_BAG])
  self:showBtnAndSetEnabled(self.btncanvasPokemon, isShow, unlockMod[Define.MODULE_TYPE.BATTLE_PET])
  self:showBtnAndSetEnabled(self.btnCanvasBall, isShow, unlockMod[Define.MODULE_TYPE.BATTLE_BALL])
  self:showBtnAndSetEnabled(self.btncanvasRunaway, isShow, unlockMod[Define.MODULE_TYPE.BATTLE_RUNAWAY])
  self.lyCanvasNoncombat:SetVisible(unlockMod[Define.MODULE_TYPE.BATTLE_NONCOMBAT])
end

function M:showBtnAndSetEnabled(btn, isShow, isEnabled)
  btn:SetVisible(isShow)
  btn:SetEnabled(isEnabled)
  btn:SetTouchable(isEnabled)
end

function M:onClose()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:cleanCountdownTimer()
  self.initPveEnemyQueue = nil
  self.pveEnemyQueue = nil
  self.npcId = nil
  self.opPokemon = nil
  self:initHeadCells(self.ourCells)
  self:initHeadCells(self.enemyCells)
  self.battleQueue = {}
  self.ourQueue = {}
  self.lyPrompt:SetVisible(false)
end

function M:initHeadCells(cells)
  for _, cell in pairs(cells) do
    cell:invoke("updateInfo")
  end
end

function M:cleanCountdownTimer()
  LuaTimer:cancel(self.roundCountdownTimer)
end

function M:roundStart(packet)
  local rounds = "R " .. packet.rounds
  self.rounds:SetText(rounds)
  if packet.rounds == 0 and not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_GOTO then
    self.btnCanvasBall:SetVisible(true)
    Me:gotoNextGuide()
  end
  if Me.needShowCapture then
    UI:getWnd("pokemonCapture"):onShow()
  end
  UI:getWnd("pokemonBag").lyBattleTopTime:invoke("updateRounds", rounds)
  UI:getWnd("battle_pokemon").lyBattleTopTime:invoke("updateRounds", rounds)
  self:startRoundCountdown()
end

function M:startRoundCountdown()
  local time = operationTime
  self:cleanCountdownTimer()
  UI:getWnd("pokemonBag").lyBattleTopTime:invoke("updateTime", operationTime .. "s")
  UI:getWnd("battle_pokemon").lyBattleTopTime:invoke("updateTime", operationTime .. "s")
  self.txtCanvasAutoCountDown:SetVisible(self.auto)
  local aCountDown = 3
  self.txtCanvasAutoCountDown:SetText(aCountDown)
  self.timeText:SetText(operationTime .. "s")
  self.roundCountdownTimer = LuaTimer:scheduleTimer(function()
    time = time - 1
    aCountDown = aCountDown - 1
    local txtTime = time .. "s"
    UI:getWnd("pokemonBag").lyBattleTopTime:invoke("updateTime", txtTime)
    UI:getWnd("battle_pokemon").lyBattleTopTime:invoke("updateTime", txtTime)
    if 0 <= aCountDown then
      self.txtCanvasAutoCountDown:SetText(aCountDown)
    end
    self.timeText:SetText(txtTime)
    if time == 0 then
      if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_CONFIRM_BALL then
        Lib.logDebug("click ball automatically")
        UI:getWnd("pokemonGuide"):onShow(false)
        self:onUsePokemonBall(self.enemyQueue[1].objId)
      else
        self:doAutoPolicy()
      end
    elseif time == 5 and not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_USE_BALL then
      Lib.logDebug("open ball window automatically")
      self:openCommandWinByType(commandType.ball)
      Me:gotoNextGuide()
    end
    if self.auto then
      if 3 <= operationTime - time then
        self:doAutoPolicy()
        self.txtCanvasAutoCountDown:SetVisible(false)
      else
        self.txtCanvasAutoCountDown:SetVisible(self.auto)
      end
    end
  end, 1000, operationTime)
end

function M:getSkillDamageEffect(targets, skillCells)
  for key, skillCell in pairs(skillCells or {}) do
    local skillRace = skillCell:invoke("getSkillRace")
    local damageRate = 0
    for _, pet in pairs(targets or {}) do
      local petRace = pet:getRace()
      local curHp = pet:getCurHp()
      local result = RaceConfig:getDamageRateByRaceInfo(petRace, skillRace)
      if result and damageRate < result and 0 < curHp then
        damageRate = result
      end
    end
    skillCell:invoke("showSkillResult", damageRate)
  end
end

function M:doAutoPolicy()
  Lib.logDebug("doAutoPolicy")
  if not self.opPokemon then
  end
  if Me.needShowCapture then
    UI:getWnd("pokemonCapture"):releasePet()
  end
  local skills = self.opPokemon:getSkillList()
  local skillId
  local usableSkills = {}
  for _, skill in pairs(skills) do
    if skill.curTimes > 0 then
      table.insert(usableSkills, skill)
    end
    skillId = skillId or skill.skillId
  end
  if 0 < #usableSkills then
    local i = math.random(#usableSkills)
    skillId = usableSkills[i].skillId
  end
  Me:sendPacket({
    pid = "BattleAction",
    type = Define.BATTLE_ACTION.SKILL,
    param = skillId
  })
  self.canCommand = false
end

function M:showPVPPrompt(playerName, rank)
  Lib.logInfo("showPVPPrompt playerName and rank = ", playerName, rank)
  self.lyPrompt:SetVisible(true)
  self.stPromptText:SetText(Lang:toText({
    "gui.pvp.gym.prompt",
    playerName
  }))
end

return M
