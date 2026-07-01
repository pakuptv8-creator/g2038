local setting = require("common.setting")

function M:init()
  self.isProtected = true
  WinBase.init(self, "skillEffectDetailTip.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self._desktop = GUISystem.instance:GetRootWindow()
  self.mid_x = self._desktop:GetPixelSize().x / 2
  self.mid_y = self._desktop:GetPixelSize().y / 2
  self.skillEffectDetailTipClickPosition = self:child("skillEffectDetailTip-click-position")
  self.skillEffectDetailTipContent = self:child("skillEffectDetailTip-content")
  self.title = self:child("skillEffectDetailTip-title")
  self.detailDec = self:child("skillEffectDetailTip-dec")
  self.roundText = self:child("skillEffectDetailTip-round")
end

function M:initEvent()
  Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemon_head_cell Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_TOUCH_SCREEN, function(sender)
    if UI:isOpen(self) and not self.isProtected then
      self:onHide()
    end
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:onHide()
  UI:closeWnd("skillEffectDetailTip")
end

function M:onShow(data, dx, dy)
  self.isProtected = true
  self.title:SetText(data.title)
  self.detailDec:SetText(data.detailDec)
  self.roundText:SetText(data.roundDec)
  local offsetY = 0
  if dx < self.mid_x then
    self.skillEffectDetailTipContent:SetHorizontalAlignment(0)
  else
    self.skillEffectDetailTipContent:SetHorizontalAlignment(2)
  end
  if dy < self.mid_y then
    self.skillEffectDetailTipContent:SetVerticalAlignment(0)
    offsetY = 20
  else
    self.skillEffectDetailTipContent:SetVerticalAlignment(2)
    offsetY = -20
  end
  self.skillEffectDetailTipClickPosition:SetXPosition({0, dx})
  self.skillEffectDetailTipClickPosition:SetYPosition({
    0,
    dy + offsetY
  })
  UI:openWnd("skillEffectDetailTip")
  World.Timer(5, function()
    self.isProtected = false
  end)
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(1)
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
