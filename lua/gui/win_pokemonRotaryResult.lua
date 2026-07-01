local WinPokemonRotaryResult = M
local PokemonRotaryTableConfig = T(Config, "PokemonRotaryTableConfig")
local PokemonConfig = T(Config, "PokemonConfig")

function WinPokemonRotaryResult:init()
  WinBase.init(self, "PokemonRotaryResult.json")
  self:initUI()
  self:initEvent()
end

function WinPokemonRotaryResult:initUI()
  self.lytBlackBg = self:child("PokemonRotaryResult-blackBg")
  self.lytContentPanel = self:child("PokemonRotaryResult-contentPanel")
  self.imgContentBg = self:child("PokemonRotaryResult-contentBg")
  self.txtTitleTxt = self:child("PokemonRotaryResult-titleTxt")
  self.btnCloseBtn = self:child("PokemonRotaryResult-closeBtn")
  self.lytGoodPanel = self:child("PokemonRotaryResult-goodPanel")
  self.imgNormalBg = self:child("PokemonRotaryResult-normalBg")
  self.imgGoodIcon = self:child("PokemonRotaryResult-goodIcon")
  self.imgGoodFrame = self:child("PokemonRotaryResult-goodFrame")
  self.txtGoodNumTxt = self:child("PokemonRotaryResult-goodNumTxt")
  self.txtRatioTxt = self:child("PokemonRotaryResult-ratioTxt")
  self.txtTotalTips = self:child("PokemonRotaryResult-totalTips")
  self.imgTotalIcon = self:child("PokemonRotaryResult-totalIcon")
  self.txtTotalNum = self:child("PokemonRotaryResult-totalNum")
  self.txtTitleTxt:SetText(Lang:toText("gui_main_rotary_result_title"))
  self.txtTotalTips:SetText(Lang:toText("gui_main_rotary_result_tip"))
end

function WinPokemonRotaryResult:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytBlackBg, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytGoodPanel, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.resultData.fullName ~= "" then
      UI:getWnd("pokemonItemDetail"):onShow(self.resultData.fullName, dx, dy)
    elseif self.resultData.goldIcon ~= "" then
      return
    elseif self.resultData.pkm_id ~= 0 then
      UI:getWnd("pokemonLuckyDetails"):onShow(true, self.resultData.pkm_id)
    end
  end)
end

function WinPokemonRotaryResult:subscribeEvent()
end

function WinPokemonRotaryResult:initView(tabKey, resultID)
  if not resultID then
    return
  end
  self.resultData = PokemonRotaryTableConfig:getCfgById(resultID)
  local itemData = self.resultData
  self.txtGoodNumTxt:SetText("x" .. tostring(BigInteger.Create(itemData.award_num)))
  self.txtRatioTxt:SetText("x" .. tostring(BigInteger.Create(itemData.ratio_num)))
  self.txtTotalNum:SetText(tostring(BigInteger.Create(itemData.award_num * itemData.ratio_num)))
  if itemData.fullName ~= "" then
    local setting = require("common.setting")
    local cfg = setting:fetch("item", itemData.fullName)
    if cfg then
      self.imgGoodIcon:SetImage(cfg.icon)
      self.imgTotalIcon:SetImage(cfg.icon)
    end
  elseif itemData.goldIcon ~= "" then
    self.imgGoodIcon:SetImage(itemData.goldIcon)
    self.imgTotalIcon:SetImage(itemData.goldIcon)
  elseif itemData.pkm_id ~= 0 then
    local pkmInfo = PokemonConfig:getConfigById(itemData.pkm_id)
    self.imgGoodIcon:SetImage(pkmInfo.icon)
    self.imgTotalIcon:SetImage(itemData.goldIcon)
    local qualityFrame = PokemonConfig:getQualityFrame(itemData.pkmId)
    self.imgGoodFrame:SetVisible(true)
    self.imgGoodFrame:SetImage(qualityFrame)
  end
  if tabKey == Define.RotaryTabType.goldTab then
    self.imgNormalBg:SetImage("set:pokemon_rotary_table.json image:img_0_frame_gold")
    self.txtRatioTxt:SetTextColor({
      0.807843137254902,
      0.16862745098039217,
      0.9607843137254902,
      1
    })
  else
    self.imgNormalBg:SetImage("set:pokemon_rotary_table.json image:img_0_frame_candy")
    self.txtRatioTxt:SetTextColor({
      0.6470588235294118,
      0.27450980392156865,
      1.0,
      1
    })
  end
end

function WinPokemonRotaryResult:onHide()
  UI:closeWnd("pokemonRotaryResult")
end

function WinPokemonRotaryResult:onShow(isShow, tabKey, resultID)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonRotaryResult", tabKey, resultID)
    end
  else
    self:onHide()
  end
end

function WinPokemonRotaryResult:onOpen(tabKey, resultID)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(tabKey, resultID)
  self.takeSoundSit = Me:playSoundByKey("ui_rotary_table_award")
end

function WinPokemonRotaryResult:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.takeSoundSit then
    Me:stopSound(self.takeSoundSit)
  end
end

return WinPokemonRotaryResult
