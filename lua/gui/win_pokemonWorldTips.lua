local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "pokemonWorldTips.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonWorldTipsPanel = self:child("pokemonWorldTips-panel")
  self.imgPokemonWorldTipsBg = self:child("pokemonWorldTips-bg")
  self.imgPokemonWorldTipsBg2 = self:child("pokemonWorldTips-bg2")
  self.imgPokemonWorldTipsBg2:SetVisible(false)
  self.txtPokemonWorldTipsContentPanel = self:child("pokemonWorldTips-content-panel")
  self.txtPokemonWorldTipsContent = self:child("pokemonWorldTips-content")
  self.lytPokemonWorldTipsPanel:SetVisible(false)
  self.contentInitWidth = self.txtPokemonWorldTipsContentPanel:GetWidth()[2]
end

function M:initEvent()
end

function M:subscribeEvent()
end

function M:initView()
  self.totalPassTime = 0
  self.curFontPosX = 0
  self.needChangePosX = nil
  self.stayCurPosXTime = 0
  self.tipTimer = LuaTimer:scheduleTimer(function()
    self.totalPassTime = self.totalPassTime + 25
    self:updateContentShow()
  end, 25, -1)
end

function M:updateContentShow()
  if self.totalPassTime % 1000 == 0 then
    if 0 >= #self.contentList then
      self:onHide()
    elseif self.contentList[#self.contentList].startShowTime then
      if self.needChangePosX then
        if os.time() - self.contentList[#self.contentList].startShowTime > self.contentList[#self.contentList].totalShowTime and self.curFontPosX >= self.needChangePosX then
          self.contentList[#self.contentList] = nil
          self.lytPokemonWorldTipsPanel:SetVisible(false)
        end
      elseif os.time() - self.contentList[#self.contentList].startShowTime > self.contentList[#self.contentList].totalShowTime then
        self.contentList[#self.contentList] = nil
        self.lytPokemonWorldTipsPanel:SetVisible(false)
      end
    else
      self:showWorldCommonTips()
    end
  end
  if self.needChangePosX and self.curFontPosX < self.needChangePosX then
    self.curFontPosX = self.curFontPosX + self.onceChangePosX
    self.txtPokemonWorldTipsContent:SetXPosition({
      0,
      -self.curFontPosX
    })
    self.stayCurPosXTime = 0
  end
end

function M:showWorldCommonTips()
  if #self.contentList > 0 then
    self.lytPokemonWorldTipsPanel:SetVisible(true)
    self.contentList[#self.contentList].startShowTime = os.time()
    self.contentList[#self.contentList].totalShowTime = World.cfg.worldCommonTipTime
    local curText = self.contentList[#self.contentList].content
    local type = self.contentList[#self.contentList].type
    if type == 1 then
      self.imgPokemonWorldTipsBg:SetVisible(true)
      self.imgPokemonWorldTipsBg2:SetVisible(false)
    elseif type == 2 then
      self.imgPokemonWorldTipsBg:SetVisible(false)
      self.imgPokemonWorldTipsBg2:SetVisible(true)
    end
    self.txtPokemonWorldTipsContent:SetText(curText)
    self.txtPokemonWorldTipsContent:SetXPosition({0, 0})
    self.curFontPosX = 0
    self.needChangePosX = nil
    self.onceChangePosX = 1
    self.contentCurWidth = self.txtPokemonWorldTipsContent:GetFont():GetTextExtent(curText, 1.0)
    self.txtPokemonWorldTipsContent:SetWidth({
      0,
      self.contentCurWidth
    })
    if self.contentCurWidth > self.contentInitWidth then
      self.stayCurPosXTime = 0
      self.needChangePosX = self.contentCurWidth - self.contentInitWidth
      self.onceChangePosX = 1
    end
  else
    self.needChangePosX = nil
    self.lytPokemonWorldTipsPanel:SetVisible(false)
  end
end

function M:pushWorldCommonTips(txtInfo, type)
  local contentInfo = {}
  contentInfo.content = txtInfo
  contentInfo.type = type
  if #self.contentList > 0 then
    table.insert(self.contentList, 1, contentInfo)
  else
    table.insert(self.contentList, 1, contentInfo)
  end
end

function M:onHide()
  UI:closeWnd("pokemonWorldTips")
end

function M:onShow(isShow, type)
  if isShow then
    if not UI:isOpen(self) then
      if type == 1 then
        self.imgPokemonWorldTipsBg:SetVisible(true)
        self.imgPokemonWorldTipsBg2:SetVisible(false)
      elseif type == 2 then
        self.imgPokemonWorldTipsBg:SetVisible(false)
        self.imgPokemonWorldTipsBg2:SetVisible(true)
      end
      UI:openWnd("pokemonWorldTips")
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self.contentList = {}
  self:subscribeEvent()
  self:initView()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.tipTimer then
    LuaTimer:cancel(self.tipTimer)
    self.tipTimer = nil
  end
end

return M
