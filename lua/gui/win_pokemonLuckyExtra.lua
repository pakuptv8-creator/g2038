local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")

function M:init()
  WinBase.init(self, "PokemonLuckyExtra.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgMask = self:child("PokemonLuckyExtra-Mask")
  self.lytBg = self:child("PokemonLuckyExtra-Bg")
  self.imgTopBg = self:child("PokemonLuckyExtra-topBg")
  self.txtTitle = self:child("PokemonLuckyExtra-Title")
  self.lytAwardList = self:child("PokemonLuckyExtra-awardList")
  self.txtTitle:SetText(Lang:toText("gui_lucky_egg_cumulative_award"))
  self.extraGridView = UIMgr:new_widget("grid_view", self.lytAwardList)
  self.extraGridView:SetAutoColumnCount(false)
  self.extraGridView:InitConfig(0, 0, 1)
  self.extraAdapter = UIMgr:new_adapter("pokemonLuckyExtraItem", 769, 100)
  self.extraGridView:invoke("setAdapter", self.extraAdapter)
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytBg, 776, 547)
end

function M:initEvent()
  self:subscribe(self.imgMask, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_RECEIVE_LUCKY_EGG_EXTRA, function(extraId)
    local luckyEggInfo = Me:getLuckyEggInfo()
    local curCount = 0
    if luckyEggInfo[self.curPoolId] then
      curCount = luckyEggInfo[self.curPoolId].totalTakeCounts
    end
    local extraList = PokemonLuckyExtraConfig:getDataByPoolId(self.curPoolId)
    local curExtraId = 0
    for k, data in pairs(extraList) do
      if curExtraId == 0 and curCount < data.take_count then
        curExtraId = data.id
      end
    end
    local gridView = self.extraGridView
    local count = gridView:invoke("CHILD_COUNT")
    for i = 1, count do
      local item = gridView:invoke("GET_ITEM", i - 1)
      if item then
        item:invoke("updateItemShow", curExtraId)
      end
    end
  end)
end

function M:initView(poolId)
  self.curPoolId = poolId
  self:updateExtraListShow(poolId)
end

function M:updateExtraListShow(poolId)
  local LuckyExtraTopRes = {
    [1] = "set:pokemon_lucky_egg.json image:img_9_boxtop_red",
    [2] = "set:pokemon_lucky_egg.json image:img_9_boxtop_yellow",
    [3] = "set:pokemon_lucky_egg.json image:img_9_boxtop_blue"
  }
  self.imgTopBg:SetImage(LuckyExtraTopRes[poolId])
  self.extraAdapter:clearItems()
  self.extraGridView:ResetPos()
  local luckyEggInfo = Me:getLuckyEggInfo()
  local curCount = 0
  if luckyEggInfo[poolId] then
    curCount = luckyEggInfo[poolId].totalTakeCounts
  end
  local extraList = PokemonLuckyExtraConfig:getDataByPoolId(poolId)
  local curExtraId = 0
  for k, data in pairs(extraList) do
    if curExtraId == 0 and curCount < data.take_count then
      curExtraId = data.id
    end
  end
  for k, data in pairs(extraList) do
    data.curExtraId = curExtraId
    self.extraAdapter:addItem(data)
  end
end

function M:onHide()
  UI:getWnd("pokemonLuckyEgg"):updateCountAndTicket()
  UI:closeWnd("pokemonLuckyExtra")
end

function M:onShow(isShow, poolId)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonLuckyExtra", poolId)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(poolId)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(poolId)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
