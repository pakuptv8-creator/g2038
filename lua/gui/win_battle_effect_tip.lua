local UIAnimationManager = T(UILib, "UIAnimationManager")
local LuaTimer = T(Lib, "LuaTimer")

function M:init()
  WinBase.init(self, "battle_effect_tip.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.animateList = {}
  self.lyCanvasCharacteristic = {}
  self.txtCanvasCharacteristicTitle = {}
  self.lyCanvasCharacteristicTextList = {}
  self.txtCanvasCharacteristicText = {}
  self.gvCanvasCharacteristicTextList = {}
  self.characteristicTimer = {}
  for i = 1, 2 do
    self.lyCanvasCharacteristic[i] = self:child("battle_effect_tip-characteristic" .. i)
    self.txtCanvasCharacteristicTitle[i] = self:child("battle_effect_tip-characteristic_title" .. i)
    self.lyCanvasCharacteristicTextList[i] = self:child("battle_effect_tip-characteristic_text_list" .. i)
    self.txtCanvasCharacteristicText[i] = self:child("battle_effect_tip-characteristic_text" .. i)
    self.gvCanvasCharacteristicTextList[i] = UIMgr:new_widget("grid_view")
    self.lyCanvasCharacteristicTextList[i]:AddChildWindow(self.gvCanvasCharacteristicTextList[i])
    self.gvCanvasCharacteristicTextList[i]:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
    self.gvCanvasCharacteristicTextList[i]:InitConfig(0, 5, 1)
    self.gvCanvasCharacteristicTextList[i]:AddItem(self.txtCanvasCharacteristicText[i])
    self.lyCanvasCharacteristic[i]:SetVisible(false)
  end
end

function M:initEvent()
end

function M:subscribeEvent()
end

function M:initView()
end

function M:showCanvasCharacteristic(effectInfo)
  local curShowId = effectInfo.showId
  self:clearAnimate(curShowId)
  self:clearCharacterTimer(curShowId)
  self.lyCanvasCharacteristic[curShowId]:SetVisible(true)
  self.txtCanvasCharacteristicTitle[curShowId]:SetText(Lang:toText("skill_effect_title"))
  self.txtCanvasCharacteristicText[curShowId]:SetText(effectInfo.txtContent)
  self:playShowAnimation(curShowId)
  self.characteristicTimer[curShowId] = LuaTimer:scheduleTimer(function()
    self:hideCanvasCharacteristic(curShowId)
  end, 2000, 1)
end

function M:playShowAnimation(showId)
  self.lyCanvasCharacteristic[showId]:SetXPosition({-1, 0})
  self.animateList[showId] = UIAnimationManager:play(self.lyCanvasCharacteristic[showId], "showCanvasCharacteristic" .. showId)
end

function M:hideCanvasCharacteristic(curShowId)
  self.lyCanvasCharacteristic[curShowId]:SetVisible(false)
  self:clearAnimate(curShowId)
  self:clearCharacterTimer(curShowId)
  if not self.lyCanvasCharacteristic[1]:IsVisible() and not self.lyCanvasCharacteristic[2]:IsVisible() then
    self:onHide()
  end
end

function M:clearAnimate(curShowId)
  UIAnimationManager:stop(self.animateList[curShowId])
  self.animateList[curShowId] = nil
end

function M:clearCharacterTimer(curShowId)
  if self.characteristicTimer[curShowId] then
    LuaTimer:cancel(self.characteristicTimer[curShowId])
    self.characteristicTimer[curShowId] = nil
  end
end

function M:onHide()
  UI:closeWnd("battle_effect_tip")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("battle_effect_tip")
    end
  else
    self:onHide()
  end
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
  self:clearAnimate(1)
  self:clearAnimate(2)
  self:clearCharacterTimer(1)
  self:clearCharacterTimer(2)
end

return M
