local RaceConfig = T(Config, "RaceConfig")
local M = _ENV.M

function M:init()
  WinBase.init(self, "PokemonCaptureRelease.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.pokemonSelecting = nil
  self.classifyTabs = {}
  self.imgPokemonCaptureReleaseMask = self:child("PokemonCaptureRelease-Mask")
  self.lytPokemonReleaseContent = self:child("PokemonRelease-Content")
  self.lytPokemonReleaseLayout = self:child("PokemonRelease-Layout")
  self.imgPokemonReleaseTitle = self:child("PokemonRelease-Title")
  self.txtPokemonReleaseTitleText = self:child("PokemonRelease-Title-Text")
  self.lytPokemonReleaseTabs = self:child("PokemonRelease-Tabs")
  self.lytPokemonReleaseTabsList = self:child("PokemonRelease-Tabs-List")
  self.lytPokemonReleaseButtons = self:child("PokemonRelease-Buttons")
  self.btnPokemonReleaseRelease = self:child("PokemonRelease-Release")
  self.lytPokemonReleasePacketList = self:child("PokemonRelease-Packet-List")
  self.btnPokemonReleaseClose = self:child("PokemonRelease-Close")
  self.lytPokemonCaptureReleasePokemonCompare = self:child("PokemonCaptureRelease-PokemonCompare")
  self.imgPokemonCaptureReleaseCompareBG = self:child("PokemonCaptureRelease-CompareBG")
  self.imgPokemonCaptureReleaseSelectPokemon = self:child("PokemonCaptureRelease-SelectPokemon")
  self.imgPokemonCaptureReleaseNotSelectImg = self:child("PokemonCaptureRelease-NotSelectImg")
  self.txtPokemonCaptureReleaseNotSelectTip = self:child("PokemonCaptureRelease-NotSelectTip")
  self.imgPokemonCaptureReleaseSelPokemonIconBG = self:child("PokemonCaptureRelease-SelPokemonIconBG")
  self.imgPokemonCaptureReleaseSelIcon = self:child("PokemonCaptureRelease-SelIcon")
  self.imgPokemonCaptureReleaseSelClassifyIcon = self:child("PokemonCaptureRelease-SelClassifyIcon")
  self.imgPokemonCaptureReleaseSelClassifyBorder = self:child("PokemonCaptureRelease-SelPokemonBorder")
  self.txtPokemonCaptureReleaseSelPokemonName = self:child("PokemonCaptureRelease-SelPokemonName")
  self.txtPokemonCaptureReleaseSelPokemonLv = self:child("PokemonCaptureRelease-SelPokemonLv")
  self.imgPokemonCaptureReleaseSelPokemonScore = self:child("PokemonCaptureRelease-SelPokemonScore")
  self.imgPokemonCaptureReleaseSelCompareImg = self:child("PokemonCaptureRelease-SelCompareImg")
  self.lytPokemonCaptureReleaseSelectingLayout = self:child("PokemonCaptureRelease-SelectingLayout")
  self.txtPokemonCaptureReleaseSelScoreTxt = self:child("PokemonCaptureRelease-SelScoreTxt")
  self.txtPokemonCaptureReleaseSelScoreTxt:SetText(Lang:toText("gui.text.cp"))
  self.txtPokemonCaptureReleaseSelScoreNum = self:child("PokemonCaptureRelease-SelScoreNum")
  self.txtPokemonCaptureReleaseNewScoreNum = self:child("PokemonCaptureRelease-NewScoreNum")
  self.gvPacketList = UIMgr:new_widget("grid_view")
  self.gvPacketList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPacketList:InitConfig(10, 10, 6)
  self.lytPokemonReleasePacketList:AddChildWindow(self.gvPacketList)
  self.txtPokemonReleaseTitleText:SetText(Lang:toText("gui.title.release"))
  self.btnPokemonReleaseRelease:SetText(Lang:toText("gui.btn.capture.release"))
  self.lytSKillDetailLayout = self:child("PokemonCaptureRelease-SkillDetail-Layout")
  self.btnSKillDetailClose = self:child("PokemonRelease-Detail-Close")
  self:initSkillDetail()
  self:initPassiveDetail()
  self:root():SetAlwaysOnTop(true)
end

function M:initSkillDetail()
  self.skillItems = {}
  self:child("PokemonCaptureRelease-Detail-Active-Text"):SetText(Lang:toText("gui.skill.initiative"))
  self:child("PokemonCaptureRelease-Detail-Passive-Text"):SetText(Lang:toText("gui.text.passive"))
  self.stSkillList = self:child("PokemonCaptureRelease-Detail-Skill-List")
  self.lySkillDetail = self:child("PokemonCaptureRelease-ActiveSkill-Detail")
  self.activeDescItem = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.activeDescItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.activeDescItem:invoke("setType")
  self.lySkillDetail:AddChildWindow(self.activeDescItem)
  local itemWidth = self.stSkillList:GetPixelSize().x
  local height = self.stSkillList:GetPixelSize().y
  local itemHeight = (height - 6) / 4
  local positionY = 0
  for index = 1, 4 do
    local item = UIMgr:new_widget("pokemon_skill_cell")
    item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.stSkillList:AddChildWindow(item)
    self.skillItems[index] = item
    positionY = positionY + itemHeight + 2
    self:subscribe(item, UIEvent.EventWindowClick, function()
      self:selectSkillItem(item)
    end)
  end
end

function M:initPassiveDetail()
  self.passiveItems = {}
  self.stPassiveList = self:child("PokemonCaptureRelease-Detail-Passive-List")
  self.lyPassiveDetail = self:child("PokemonCaptureRelease-PassiveSkill-Detail")
  self.passiveDescItem = UIMgr:new_widget("pokemon_passive_detail_cell")
  self.passiveDescItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lyPassiveDetail:AddChildWindow(self.passiveDescItem)
  self.passiveDescItem:invoke("updateSize")
  local width = self.stPassiveList:GetPixelSize().x
  local itemWidth = (width - 42) / 4
  local itemHeight = itemWidth
  local positionY = 0
  local positionX = 0
  for index = 1, 8 do
    local item = UIMgr:new_widget("pokemon_passive_cell")
    item:SetArea({0, positionX}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.stPassiveList:AddChildWindow(item)
    self.passiveItems[index] = item
    positionX = positionX + itemWidth + 14
    if index % 4 == 0 then
      positionX = 0
      positionY = positionY + itemHeight + 14
    end
    self:subscribe(item, UIEvent.EventWindowClick, function()
      self:selectPassiveItem(item)
    end)
  end
end

function M:selectSkillItem(selectItem)
  local skill = selectItem:invoke("getSkill")
  if skill.skillId == 0 then
    return
  end
  self:cancelSKillSelect()
  for _, item in pairs(self.skillItems) do
    if selectItem == item then
      item:invoke("onChecked", true)
      self:showSkillDetail(skill)
    end
  end
end

function M:selectPassiveItem(selectItem)
  local skillId = selectItem:invoke("getSkillId")
  if skillId == 0 then
    return
  end
  self:cancelSKillSelect()
  for _, item in pairs(self.passiveItems) do
    if selectItem == item then
      item:invoke("onChecked", true)
      self:showSkillDetail(skillId)
    end
  end
end

function M:cancelSKillSelect()
  self.lytSKillDetailLayout:SetVisible(false)
  for _, item in pairs(self.skillItems) do
    item:invoke("onChecked", false)
  end
  for _, item in pairs(self.passiveItems) do
    item:invoke("onChecked", false)
  end
end

function M:showSkillDetail(data)
  self.lytSKillDetailLayout:SetVisible(true)
  self.lySkillDetail:SetVisible(false)
  self.lyPassiveDetail:SetVisible(false)
  if type(data) == "table" then
    local skill = data
    self.lySkillDetail:SetVisible(true)
    self.activeDescItem:invoke("updateInfo", skill)
  else
    local skillId = data
    self.lyPassiveDetail:SetVisible(true)
    self.passiveDescItem:invoke("updateInfo", skillId)
  end
end

function M:initEvent()
  self:subscribe(self.btnPokemonReleaseRelease, UIEvent.EventButtonClick, function()
    if self.pokemonSelecting == nil then
      return
    end
    self:replacePacketPokemon()
  end)
  self:subscribe(self.btnPokemonReleaseClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnSKillDetailClose, UIEvent.EventButtonClick, function()
    self:cancelSKillSelect()
  end)
end

function M:subscribeEvent()
end

function M:initView()
  self.battleItems = {}
  self.txtPokemonCaptureReleaseNotSelectTip:SetVisible(true)
  self.imgPokemonCaptureReleaseNotSelectImg:SetVisible(true)
  self.lytPokemonCaptureReleaseSelectingLayout:SetVisible(false)
  for _, tabCheckBox in pairs(self.classifyTabs) do
    tabCheckBox:SetChecked(false)
  end
  self:initClassifyTabs()
end

function M:initClassifyTabs()
  self.classifyTabs = {}
  local raceIds = RaceConfig:getAllRaceId()
  table.insert(raceIds, 1, 0)
  local width = self.lytPokemonReleaseTabsList:GetPixelSize().x
  local itemHeight = self.lytPokemonReleaseTabsList:GetPixelSize().y
  local itemWidth = (width - 10 * (#raceIds - 1)) / #raceIds
  local positionX = 0
  for index, raceId in pairs(raceIds) do
    local tab = UIMgr:new_widget("pokemon_race_tab_cell")
    tab:SetArea({0, positionX}, {0, 0}, {0, itemWidth}, {0, itemHeight})
    tab:invoke("setRaceId", raceId)
    tab:invoke("setType", "replace")
    self.lytPokemonReleaseTabsList:AddChildWindow(tab)
    self.classifyTabs[index] = tab
    self:subscribe(tab, UIEvent.EventCheckStateChanged, function()
      if tab:GetChecked() then
        for _, tabCheckBox in pairs(self.classifyTabs) do
          if tabCheckBox:GetChecked() and tabCheckBox ~= tab then
            tabCheckBox:SetChecked(false)
            tabCheckBox:SetTouchable(true)
          end
        end
        tab:SetTouchable(false)
        self:changeClassifyTab(raceId)
      end
    end)
    positionX = positionX + itemWidth + 10
  end
end

function M:changeClassifyTab(raceId)
  self.cur_raceId = raceId
  self:upDatePokemonPacketList()
end

function M:upDatePokemonPacketList()
  local adapter = self.gvPacketList:invoke("getAdapter")
  if not adapter then
    local width = self.lytPokemonReleasePacketList:GetPixelSize().x
    local itemWidth = (width - 50) / 6
    adapter = UIMgr:new_adapter("pokemon_packet", itemWidth, itemWidth)
    self.gvPacketList:invoke("setAdapter", adapter)
  end
  Me:getPokemonList(self.packetPetList, function(packetList)
    local showList = {}
    for _, pokemon in pairs(packetList) do
      if self.cur_raceId == 0 or tonumber(pokemon:getRace()) == self.cur_raceId then
        table.insert(showList, {
          pokemon = pokemon,
          checkInTeam = true,
          checkLocked = true,
          clickCallBack = function(item)
            if pokemon:isLocked() then
              return
            end
            self:selectPacketItem(pokemon, item)
          end
        })
      end
    end
    for index = 1, World.cfg.maxBoxPetsCnt do
      if not showList[index] then
        showList[index] = {pokemon = nil}
      end
    end
    self.packetShowList = showList
    adapter:setData(showList)
  end)
end

function M:selectPacketItem(pokemon, item)
  if pokemon == nil then
    return
  end
  self.pokemonSelecting = pokemon
  if self.selectingItem ~= nil then
    self.selectingItem:onChecked(false)
  end
  self.selectingItem = item
  self.selectingItem:onChecked(true)
  self.lytPokemonCaptureReleaseSelectingLayout:SetVisible(true)
  self.txtPokemonCaptureReleaseNotSelectTip:SetVisible(false)
  self.imgPokemonCaptureReleaseNotSelectImg:SetVisible(false)
  self.imgPokemonCaptureReleaseSelIcon:SetImage(pokemon:getIcon())
  self.txtPokemonCaptureReleaseSelPokemonName:SetText(pokemon:getName())
  self.txtPokemonCaptureReleaseSelPokemonLv:SetText("LV." .. pokemon:getLevel())
  self.txtPokemonCaptureReleaseSelScoreNum:SetText(pokemon:getFightPower())
  self.txtPokemonCaptureReleaseNewScoreNum:SetText(self.newPokemon:getFightPower())
  self.imgPokemonCaptureReleaseSelClassifyIcon:SetImage(RaceConfig:getClassifyIcon(pokemon:getRace()))
  self.imgPokemonCaptureReleaseSelClassifyBorder:SetImage(pokemon:getIconFrame())
  local newScore = self.newPokemon:getFightPower()
  local thisScore = pokemon:getFightPower()
  if newScore < thisScore then
    self.imgPokemonCaptureReleaseSelCompareImg:SetImage("set:pokemon_capture.json image:img_0_tip_down")
  else
    self.imgPokemonCaptureReleaseSelCompareImg:SetImage("set:pokemon_capture.json image:img_0_tip_up")
  end
  local skillList = pokemon:getSkillList()
  for index, skillItem in pairs(self.skillItems) do
    skillItem:invoke("updateInfo", skillList[index])
  end
  local passiveRule = pokemon:getCfg().passiveRule
  for index, passiveItem in pairs(self.passiveItems) do
    local passiveTable = passiveRule[index] or {}
    local skillId = tonumber(passiveTable[1] or 0)
    local unlockWake = tonumber(passiveTable[2] or 0)
    passiveItem:invoke("updateInfo", skillId, unlockWake > pokemon:getWake())
  end
  self:cancelSKillSelect()
end

function M:replacePacketPokemon()
  local packet = {
    pid = "putCaptureInPacket",
    releaseObjId = self.pokemonSelecting:getObjId(),
    gainObjId = self.newPokemon:getObjId()
  }
  Me:sendPacket(packet, function(code)
    if code == Define.PUT_CAPTURE_IN_PACKET_CODE.SUCCESS then
      UI:closeWnd(self)
      UI:closeWnd("pokemonCapture")
    end
  end)
end

function M:onHide()
  UI:closeWnd("pokemonCaptureRelease")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      self.newPokemon = isShow
      UI:openWnd("pokemonCaptureRelease")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self.packetPetList = Me:getValue("packetPetList")
  self.packetPetList = Me:filterLockPokemonToEnd(self.packetPetList)
  self:initView()
  self:selectClassifyTab(1)
end

function M:selectClassifyTab(index)
  self.classifyTabs[index]:SetChecked(true)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
