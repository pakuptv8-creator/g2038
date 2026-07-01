local LuaTimer = T(Lib, "LuaTimer")
local GymDefaultRankConfig = T(Config, "GymDefaultRankConfig")
local setting = require("common.setting")
local tabs = {
  [1] = Define.RANK_SUB_TYPE.POWER,
  [2] = Define.RANK_SUB_TYPE.WATER_GYM,
  [3] = Define.RANK_SUB_TYPE.FIRE_GYM,
  [4] = Define.RANK_SUB_TYPE.GRASS_GYM,
  [5] = Define.RANK_SUB_TYPE.SUPER_GYM,
  [6] = Define.RANK_SUB_TYPE.SPECIAL_GYM
}

function M:init()
  WinBase.init(self, "PokemonLeaderboard.json", false)
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.tabCells = {}
  self.subId = Define.RANK_SUB_TYPE.POWER
  self.curPage = 1
  self.pageCount = 1
  self.rankData = {}
  self.reward_queue = {}
end

function M:initWnd()
  self.btnClose = self:child("PokemonLeaderboard-BtnClose")
  self.btnAbout = self:child("PokemonLeaderboard-BtnAbout")
  self.stMainTitle = self:child("PokemonLeaderboard-Title")
  self.stMainTitle:SetText(Lang:toText("gui.leaderboard"))
  self.tabs = self:child("PokemonLeaderboard-Tabs")
  self.tab_grid_view = UIMgr:new_widget("grid_view")
  self.tabs:AddChildWindow(self.tab_grid_view)
  self.tab_grid_view:SetAutoColumnCount(false)
  self.tab_grid_view:SetMoveAble(false)
  self.tab_grid_view:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.tab_grid_view:InitConfig(0, 3, 1)
  self:initTabList()
  self.siAvatar1 = self:child("PokemonLeaderboard-Rank-Avatar-1")
  self.siAvatar2 = self:child("PokemonLeaderboard-Rank-Avatar-2")
  self.siAvatar3 = self:child("PokemonLeaderboard-Rank-Avatar-3")
  self.actor1 = self:child("PokemonLeaderboard-Rank-Actor-1")
  self.actor2 = self:child("PokemonLeaderboard-Rank-Actor-2")
  self.actor3 = self:child("PokemonLeaderboard-Rank-Actor-3")
  self.trophy1 = self:child("PokemonLeaderboard-Rank-Actor-Trophy-1")
  self.trophy1:SetVisible(false)
  self.trophy2 = self:child("PokemonLeaderboard-Rank-Actor-Trophy-2")
  self.trophy2:SetVisible(false)
  self.trophy3 = self:child("PokemonLeaderboard-Rank-Actor-Trophy-3")
  self.trophy3:SetVisible(false)
  self.stName1 = self:child("PokemonLeaderboard-Rank-Actor-Name-1")
  self.stName1:SetVisible(false)
  self.stName2 = self:child("PokemonLeaderboard-Rank-Actor-Name-2")
  self.stName2:SetVisible(false)
  self.stName3 = self:child("PokemonLeaderboard-Rank-Actor-Name-3")
  self.stName3:SetVisible(false)
  self.stSubTitle = self:child("PokemonLeaderboard-Board-Name")
  self.btnReward = self:child("PokemonLeaderboard-Board-BtnReward")
  self.stRewardText = self:child("PokemonLeaderboard-RewardText")
  self.stRewardText:SetText(Lang:toText("gui.leaderboard.reward.title"))
  self.stRank = self:child("PokemonLeaderboard-Board-Head-Rank")
  self.stRank:SetText(Lang:toText("gui.leaderboard.rank"))
  self.stName = self:child("PokemonLeaderboard-Board-Head-Name")
  self.stName:SetText(Lang:toText("gui.leaderboard.name"))
  self.stScore = self:child("PokemonLeaderboard-Board-Head-Score")
  self.stScore:SetText(Lang:toText("gui.leaderboard.score"))
  self.btnPrev = self:child("PokemonLeaderboard-Board-Page-BtnPrev")
  self.btnNext = self:child("PokemonLeaderboard-Board-Page-BtnNext")
  self.stInidcator = self:child("PokemonLeaderboard-Board-Page-Indicator")
  self.btnRefresh = self:child("PokemonLeaderboard-Board-BtnRefresh")
  self.stRefreshTime = self:child("PokemonLeaderboard-Board-Refresh-Time")
  self.ranks = self:child("PokemonLeaderboard-Board-Ranks")
  self.rank_grid_view = UIMgr:new_widget("grid_view")
  self.ranks:AddChildWindow(self.rank_grid_view)
  self.rank_grid_view:SetMoveAble(false)
  self.rank_grid_view:SetAutoColumnCount(false)
  self.rank_grid_view:InitConfig(0, 1, 1)
  self.stSelfRank = self:child("PokemonLeaderboard-Board-Self-Rank")
  self.stSelfRank:SetText("--")
  self.stSelfName = self:child("PokemonLeaderboard-Board-Self-Name")
  self.stSelfName:SetText(Me.name)
  self.stSelfScore = self:child("PokemonLeaderboard-Board-Self-Score")
  self.stSelfScore:SetText(0)
  self.btnCollectReward = self:child("PokemonLeaderboard-Board-BtnCollectReward")
  self.btnCollectReward:SetVisible(false)
end

function M:initTabList()
  for i, rankType in pairs(tabs) do
    local tabCell = UIMgr:new_widget("pokemon_leaderboard_tab")
    tabCell:invoke("initTabByType", rankType)
    self:subscribe(tabCell, UIEvent.EventWindowClick, function()
      Lib.logDebug("tabCell click tabId = ", rankType)
      self:selectTab(rankType)
    end)
    self.tab_grid_view:AddItem(tabCell)
    table.insert(self.tabCells, tabCell)
  end
end

function M:onCheckTabClick(subId)
  for _, cell in pairs(self.tabCells) do
    cell:invoke("onCheckClick", subId)
  end
end

function M:initEvent()
  Lib.subscribeEvent(Event.EVENT_RECEIVE_RANK_DATA, function(subId)
    Lib.logDebug("EVENT_RECEIVE_RANK_DATA subId = ", subId)
    if subId == self.subId then
      Lib.logDebug("EVENT_RECEIVE_RANK_DATA call refresh")
      self:refresh()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_CHECK_RANK_REWARD, function(subId, rank)
    Lib.logDebug("EVENT_CHECK_RANK_REWARD subId and rank = ", subId, rank)
    if not UI:isOpen("pokemonLeaderboardReceive") then
      UI:getWnd("pokemonLeaderboardReceive"):onShow(subId, rank)
    else
      self.reward_queue[subId] = rank
    end
  end)
  Lib.subscribeEvent(Event.EVENT_RECEIVE_PLAYER_RANK, function(rankType, subId, rankIndex, rank, score)
    Lib.logDebug("EVENT_RECEIVE_PLAYER_RANK rankType, subId, rankIndex, rank, score = ", rankType, subId, rankIndex, rank, score)
    if subId == self.subId then
      self:refreshPlayer(rank, score)
    end
  end)
  Lib.subscribeEvent(Event.EVENT_CLOSE_REWARD_RECEIVE, function()
    Lib.logInfo("EVENT_CLOSE_REWARD_RECEIVE before self.reward_queue = ", Lib.v2s(self.reward_queue))
    local subId, rank = next(self.reward_queue)
    Lib.logInfo("EVENT_CLOSE_REWARD_RECEIVE subId and rank = ", subId, rank)
    if subId then
      Lib.logInfo("before remove self.reward_queue = ", Lib.v2s(self.reward_queue))
      self.reward_queue = Lib.removeElementByKey(self.reward_queue, subId)
      Lib.logInfo("after remove self.reward_queue = ", Lib.v2s(self.reward_queue))
      if not UI:isOpen("pokemonLeaderboardReceive") then
        UI:getWnd("pokemonLeaderboardReceive"):onShow(subId, rank)
      end
    end
  end)
  self:subscribe(self.btnAbout, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonCommonDialog"):onShow("gui.leaderboard.about.title", "gui.leaderboard.about.content", nil, Define.COMMON_DIALOG_MODE.NOBUTTON)
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPrev, UIEvent.EventButtonClick, function()
    if self.curPage > 1 then
      self.curPage = self.curPage - 1
      self.stInidcator:SetText(self.curPage .. "/" .. self.pageCount)
      Lib.logDebug("btnPrev self.curPage = ", self.curPage)
      self:refreshRankList(self.subId, self.rankData)
    end
  end)
  self:subscribe(self.btnNext, UIEvent.EventButtonClick, function()
    if self.curPage < self.pageCount then
      self.curPage = self.curPage + 1
      self.stInidcator:SetText(self.curPage .. "/" .. self.pageCount)
      Lib.logDebug("btnNext self.curPage = ", self.curPage)
      self:refreshRankList(self.subId, self.rankData)
    end
  end)
  self:subscribe(self.btnRefresh, UIEvent.EventButtonClick, function()
    self:startCountdown()
    self:selectTab(self.subId)
  end)
  self:subscribe(self.btnReward, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonLeaderboardReward"):onShow(self.subId)
  end)
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonLeaderboard")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:refresh()
  Lib.logInfo("refresh rankIndex = ", Me:getRankIndex())
  local rankIndex = Me:getRankIndex()
  if rankIndex == 0 then
    self.stSubTitle:SetText(Lang:toText("gui.leaderboard.title." .. self.subId) .. Lang:toText("gui.leaderboard.rookie"))
  else
    self.stSubTitle:SetText(Lang:toText("gui.leaderboard.title." .. self.subId) .. Lang:toText({
      "gui.leaderboard.rankIndex",
      rankIndex
    }))
  end
  self.rankData = Rank.GetRankData(self.subId)
  if self.rankData and 0 < #self.rankData then
    Blockman.instance.gameSettings:setUiActorBrightness({
      x = 1,
      y = 1,
      z = 1
    })
    for i = 1, 3 do
      if self.rankData[i] then
        local userId = self.rankData[i].userId
        local nickName = self.rankData[i].name
        local rank = self.rankData[i].rank
        local isnpc = self.rankData[i].isnpc
        Lib.logDebug("userId and nickname and rank and isnpc = ", userId, nickName, rank, isnpc)
        if isnpc == true then
          self:refreshNpc(self.subId, rank, userId)
        else
          AsyncProcess.GetUserDetail(userId, function(userinfo)
            local sex = 1
            if userinfo then
              sex = userinfo.sex
              nickName = userinfo.nickName
            end
            AsyncProcess.GetUserDecoration(userId, function(decoration)
              self:refreshActor(rank, nickName, sex, decoration)
            end)
          end)
        end
      end
    end
    self.pageCount = math.ceil(#self.rankData / World.cfg.rankPerPage)
    self.stInidcator:SetText(self.curPage .. "/" .. self.pageCount)
    self:refreshRankList(self.subId, self.rankData)
  else
    self.stInidcator:SetText("0/0")
    self:refreshPlayer(0, 0)
    self.rank_grid_view:RemoveAllItems()
    self.stName1:SetVisible(false)
    self.stName2:SetVisible(false)
    self.stName3:SetVisible(false)
    self.trophy1:SetVisible(false)
    self.trophy2:SetVisible(false)
    self.trophy3:SetVisible(false)
    self.siAvatar1:SetVisible(true)
    self.siAvatar2:SetVisible(true)
    self.siAvatar3:SetVisible(true)
    self.actor1:SetActor1("")
    self.actor2:SetActor1("")
    self.actor3:SetActor1("")
  end
end

function M:refreshPlayer(rank, score)
  self.stSelfRank:SetText(rank)
  self.stSelfScore:SetText(score)
end

function M:refreshActor(rank, nickName, sex, decoration)
  if rank == 1 then
    self.stName1:SetVisible(true)
    self.stName1:SetText(nickName)
    self.trophy1:SetVisible(true)
    self.trophy1:SetImage("set:pokemon_leaderboard.json image:img_0_cup_1")
    self.siAvatar1:SetVisible(false)
    self.actor1:SetActor1(sex == 1 and "boy.actor" or "girl.actor", "idle")
    self.actor1:SetRotateY(0)
    for k, v in pairs(decoration or {}) do
      self.actor1:UseBodyPart(k, v)
    end
    local scale = self.actor1:GetPixelSize().x / 100
    self.actor1:SetActorScale(2 * scale)
    self.actor1:UpdateSelf(1)
  elseif rank == 2 then
    self.stName2:SetVisible(true)
    self.stName2:SetText(nickName)
    self.trophy2:SetVisible(true)
    self.trophy2:SetImage("set:pokemon_leaderboard.json image:img_0_cup_2")
    self.siAvatar2:SetVisible(false)
    self.actor2:SetActor1(sex == 1 and "boy.actor" or "girl.actor", "idle")
    self.actor2:SetRotateY(0)
    for k, v in pairs(decoration or {}) do
      self.actor2:UseBodyPart(k, v)
    end
    local scale = self.actor2:GetPixelSize().x / 100
    self.actor2:SetActorScale(2 * scale)
    self.actor2:UpdateSelf(1)
  elseif rank == 3 then
    self.stName3:SetVisible(true)
    self.stName3:SetText(nickName)
    self.trophy3:SetVisible(true)
    self.trophy3:SetImage("set:pokemon_leaderboard.json image:img_0_cup_3")
    self.siAvatar3:SetVisible(false)
    self.actor3:SetActor1(sex == 1 and "boy.actor" or "girl.actor", "idle")
    self.actor3:SetProperty("ActorWindowRotateY", "15")
    self.actor3:SetRotateY(0)
    for k, v in pairs(decoration or {}) do
      self.actor3:UseBodyPart(k, v)
    end
    local scale = self.actor3:GetPixelSize().x / 100
    self.actor3:SetActorScale(2 * scale)
    self.actor3:UpdateSelf(1)
  end
end

function M:refreshNpc(subId, rank, userId)
  local npc_id = userId
  local npc_data = GymDefaultRankConfig:getSpecificNpc(subId, npc_id)
  if npc_data and npc_data.cfg_fullname then
    local cfgname = "myplugin/" .. npc_data.cfg_fullname
    local cfg = setting:fetch("entity", cfgname)
    if rank == 1 then
      self.stName1:SetVisible(true)
      self.stName1:SetText(Lang:toText(npc_data.name))
      self.trophy1:SetVisible(true)
      self.trophy1:SetImage("set:pokemon_leaderboard.json image:img_0_cup_1")
      self.siAvatar1:SetVisible(false)
      self.actor1:SetActor1(cfg.actorName, "idle")
      self.actor1:SetRotateY(0)
      local scale = self.actor1:GetPixelSize().x / 100
      self.actor1:SetActorScale(2 * scale)
      self.actor1:UpdateSelf(1)
    elseif rank == 2 then
      self.stName2:SetVisible(true)
      self.stName2:SetText(Lang:toText(npc_data.name))
      self.trophy2:SetVisible(true)
      self.trophy2:SetImage("set:pokemon_leaderboard.json image:img_0_cup_2")
      self.siAvatar2:SetVisible(false)
      self.actor2:SetActor1(cfg.actorName, "idle")
      self.actor2:SetRotateY(0)
      local scale = self.actor2:GetPixelSize().x / 100
      self.actor2:SetActorScale(2 * scale)
      self.actor2:UpdateSelf(1)
    elseif rank == 3 then
      self.stName3:SetVisible(true)
      self.stName3:SetText(Lang:toText(npc_data.name))
      self.trophy3:SetVisible(true)
      self.trophy3:SetImage("set:pokemon_leaderboard.json image:img_0_cup_3")
      self.siAvatar3:SetVisible(false)
      self.actor3:SetActor1(cfg.actorName, "idle")
      self.actor3:SetProperty("ActorWindowRotateY", "15")
      self.actor3:SetRotateY(0)
      local scale = self.actor3:GetPixelSize().x / 100
      self.actor3:SetActorScale(2 * scale)
      self.actor3:UpdateSelf(1)
    end
  end
end

function M:refreshRankList(subId, rankData)
  if not rankData then
    return
  end
  self.rank_grid_view:RemoveAllItems()
  local hasPlayer = false
  local end_index = self.curPage * World.cfg.rankPerPage
  local start_index = end_index - World.cfg.rankPerPage + 1
  for i = start_index, end_index do
    local data = rankData[i]
    if data then
      local node = UIMgr:new_widget("pokemon_leaderboard_rank_cell")
      node:invoke("initViewDataWithoutAdapter", subId, data)
      self.rank_grid_view:AddItem(node, true)
      if data.userId == Me.platformUserId then
        hasPlayer = true
        self:refreshPlayer(data.rank, data.score)
      end
    end
  end
  if not hasPlayer then
    self:refreshPlayer("-", "-")
  end
end

function M:onHide()
  UI:closeWnd("pokemonLeaderboard")
end

function M:selectTab(rankType)
  self.subId = rankType
  self.curPage = 1
  self:onCheckTabClick(self.subId)
  Rank.RequestRankData(Me:getLangType(), self.subId)
  self:refresh()
end

function M:startCountdown()
  local time = World.cfg.rankRefreshTime
  self.btnRefresh:SetEnabled(false)
  LuaTimer:cancel(self.countDownTimer)
  self.countDownTimer = LuaTimer:scheduleTimer(function()
    time = time - 1
    local txtTime = time .. "s"
    self.stRefreshTime:SetText(txtTime)
    if time == 0 then
      self.btnRefresh:SetEnabled(true)
    end
  end, 1000, World.cfg.rankRefreshTime)
end

function M:onOpen()
  Lib.logDebug("onOpen")
  Me:CheckRankReward()
  self:startCountdown()
  self:selectTab(self.subId)
end

function M:onClose()
  Lib.logDebug("onClose")
end

return M
