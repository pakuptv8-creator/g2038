function M:init()
  WinBase.init(self, "PokemonLuckyProbability.json")
  
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgMask = self:child("PokemonLuckyProbability-Mask")
  self.lytBg = self:child("PokemonLuckyProbability-Bg")
  self.imgTopBg = self:child("PokemonLuckyProbability-topBg")
  self.txtTitle = self:child("PokemonLuckyProbability-Title")
  self.lytContentList = self:child("PokemonLuckyProbability-contentList")
  self.txtContentTxt = self:child("PokemonLuckyProbability-contentTxt")
  self.btnCloseBtn = self:child("PokemonLuckyProbability-closeBtn")
  self.imgBottomBg = self:child("PokemonLuckyProbability-bottomBg")
  self.imgBottomTitle = self:child("PokemonLuckyProbability-bottomTitle")
  self.imgBottomTime = self:child("PokemonLuckyProbability-bottomTime")
  self.gvModelTxtDec = UIMgr:new_widget("grid_view")
  self.lytContentList:AddChildWindow(self.gvModelTxtDec)
  self.gvModelTxtDec:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvModelTxtDec:InitConfig(0, 5, 1)
  self.gvModelTxtDec:AddItem(self.txtContentTxt)
  self.txtTitle:SetText(Lang:toText("gui_lucky_egg_probability_title"))
  self.imgBottomTitle:SetText(Lang:toText("gui_lucky_egg_probability_title2"))
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytBg, 776, 467)
end

function M:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView(poolId)
  self.curPoolId = poolId
  local LuckyCardPoolTopRes = {
    [1] = "set:pokemon_lucky_egg.json image:img_9_boxtop_red",
    [2] = "set:pokemon_lucky_egg.json image:img_9_boxtop_yellow",
    [3] = "set:pokemon_lucky_egg.json image:img_9_boxtop_blue"
  }
  self.imgTopBg:SetImage(LuckyCardPoolTopRes[poolId])
  self.imgBottomBg:SetImage(LuckyCardPoolTopRes[poolId])
  self.txtContentTxt:SetText(Lang:toText("gui_lucky_egg_probability_desc" .. poolId))
  self.imgBottomTitle:SetVisible(false)
  self.imgBottomTime:SetVisible(false)
end

function M:onHide()
  UI:closeWnd("pokemonLuckyProbability")
end

function M:onShow(isShow, poolId)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonLuckyProbability", poolId)
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
