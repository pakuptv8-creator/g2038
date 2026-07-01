local M = _ENV.M
local MaxLenForTopTip = 350

function M:init()
  WinBase.init(self, "PokemonCommonTip.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonCommonTipTopTip = self:child("PokemonCommonTip-TopTip")
  self.txtPokemonCommonTipTopTipText = self:child("PokemonCommonTip-TopTip-Text")
end

function M:initEvent()
end

function M:subscribeEvent()
end

function M:initView(type, text, tickTimes)
  self.imgPokemonCommonTipTopTip:SetVisible(type == Define.CommonTipType.TOP)
  self.txtPokemonCommonTipTopTipText:SetText(text)
  local textLen = self.txtPokemonCommonTipTopTipText:GetFont():GetTextExtent(text, 1.0)
  local textHigh = self.txtPokemonCommonTipTopTipText:GetFont():GetTextHigh(text, 1.0)
  local lineNum = math.ceil(textLen / MaxLenForTopTip)
  self.imgPokemonCommonTipTopTip:SetWidth({
    0,
    math.min(textLen, MaxLenForTopTip) + 150
  })
  self.imgPokemonCommonTipTopTip:SetHeight({
    0,
    textHigh * lineNum + 30
  })
  if tickTimes ~= -1 then
    World.Timer(tickTimes, function()
      self:onHide()
    end)
  end
end

function M:onHide()
  UI:closeWnd("pokemonCommonTip")
end

function M:onOpen(type, text, tickTimes, win_parent)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(type, text, tickTimes, win_parent)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
