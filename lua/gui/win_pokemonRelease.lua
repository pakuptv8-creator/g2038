local RaceConfig = T(Config, "RaceConfig")
local M = _ENV.M

function M:init()
  WinBase.init(self, "PokemonRelease.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonReleaseContent = self:child("PokemonRelease-Content")
  self.lytPokemonReleaseLayout = self:child("PokemonRelease-Layout")
  self.imgPokemonReleaseTitle = self:child("PokemonRelease-Title")
  self.lytPokemonReleaseTabs = self:child("PokemonRelease-Tabs")
  self.lytPokemonReleaseTabsList = self:child("PokemonRelease-Tabs-List")
  self.lytPokemonReleaseButtons = self:child("PokemonRelease-Buttons")
  self.btnPokemonReleaseRelease = self:child("PokemonRelease-Release")
  self.lytPokemonReleasePacketList = self:child("PokemonRelease-Packet-List")
  self.btnPokemonReleaseClose = self:child("PokemonRelease-Close")
  self.imgPokemonReleaseTitleText = self:child("PokemonRelease-Title-Text")
  self.imgPokemonReleaseTitleText:SetText(Lang:toText("gui.title.release"))
  self.btnPokemonReleaseRelease:SetText(Lang:toText("gui.btn.release"))
  self.gvPacketList = UIMgr:new_widget("grid_view")
  self.gvPacketList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvPacketList:InitConfig(10, 10, 6)
  self.lytPokemonReleasePacketList:AddChildWindow(self.gvPacketList)
  self:initClassifyTabs()
end

function M:initEvent()
  self:subscribe(self.btnPokemonReleaseRelease, UIEvent.EventButtonClick, function()
    self:clickRelease()
  end)
  self:subscribe(self.btnPokemonReleaseClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:onHide()
  UI:closeWnd(self)
end

function M:onShow()
  self:upDatePokemonPacketList()
  self:selectClassifyTab(1)
  UI:openWnd("pokemonRelease")
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

function M:selectClassifyTab(index)
  self.classifyTabs[index]:SetChecked(true)
end

function M:changeClassifyTab(raceId)
  self.cur_raceId = raceId
  self:upDatePokemonPacketList()
end

function M:upDatePokemonPacketList()
  local adapter = self.gvPacketList:invoke("getAdapter")
  if not adapter then
    local width = self.gvPacketList:GetPixelSize().x
    local itemWidth = (width - 50) / 6
    adapter = UIMgr:new_adapter("pokemon_packet", itemWidth, itemWidth)
    self.gvPacketList:invoke("setAdapter", adapter)
  end
  local packetPetList = Me:getValue("packetPetList")
  packetPetList = Me:filterLockPokemonToEnd(packetPetList)
  Me:getPokemonList(packetPetList, function(packetList)
    local showList = {}
    for _, pokemon in pairs(packetList) do
      if self.cur_raceId == 0 or tonumber(pokemon:getRace()) == self.cur_raceId then
        table.insert(showList, {
          pokemon = pokemon,
          isChecked = false,
          checkInTeam = true,
          checkLocked = true
        })
      end
    end
    for index = 1, World.cfg.maxBoxPetsCnt do
      if showList[index] then
        showList[index].clickCallBack = function()
          if showList[index].pokemon:isLocked() then
            return
          end
          showList[index].isChecked = not showList[index].isChecked
          adapter:notifyDataChange()
        end
      else
        showList[index] = {pokemon = nil}
      end
    end
    self.adapter_data = showList
    adapter:setData(showList)
  end)
end

function M:clickRelease()
  local release_list = {}
  local hasHighStar = false
  local price = 0
  for _, itemData in pairs(self.adapter_data) do
    local pokemon = itemData.pokemon
    if itemData.isChecked then
      price = price + pokemon:getCfg().price
      if pokemon:getStarLevel() >= 3 then
        hasHighStar = true
      end
      table.insert(release_list, pokemon:getObjId())
    end
  end
  Me:showChatShopDialog({
    titleText = Lang:toText("gui.tip.title"),
    msgText = Lang:toText("gui.tip.sell_can_gain") .. price .. Lang:toText("gui.tip.sell_gain")
  }, function(sure)
    if sure == false then
      return
    end
    World.Timer(1, function()
      if hasHighStar then
        Me:showChatShopDialog({
          titleText = "gui.tip.title",
          msgText = "gui.release.high.star"
        }, function(sure)
          if sure then
            self:sendReleasePacket(release_list)
          end
        end)
        return
      end
      self:sendReleasePacket(release_list)
    end)
  end)
end

function M:sendReleasePacket(release_list)
  Me:sendPacket({
    pid = "sellPokemon",
    objIds = table.concat(release_list, ":")
  }, function(result)
    if result.success then
      Me:playSoundByKey("sell_success")
      UI:closeWnd(self)
      Me:showChatShopDialog({
        titleText = Lang:toText("gui.tip.title"),
        msgText = Lang:toText("gui.tip.sell_info") .. result.gain .. Lang:toText("gui.tip.sell_gain")
      })
    else
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.release.fail"
      })
    end
  end)
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
