local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local LuaTimer = T(Lib, "LuaTimer")
local skillEffectCfg = T(Config, "SkillEffectConfig")

function M:init()
  widget_base.init(self, "skilleffectCell.json")
  self.itemInfo = {}
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self._allEvent = {}
  self.itemIcon = self:child("skilleffectCell-item")
  self.roundText = self:child("skilleffectCell-round")
  self.roundText:SetText("1")
  self.itemEffect = self:child("skilleffectCell-effect")
  self.itemEffect:SetVisible(false)
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function(window, dx, dy)
    local data = {}
    data.title = string.format("[%s]%s", Lang:toText(self.itemInfo.skillName), Lang:toText("ui_skill_effect_tip_title"))
    local effectCfg = skillEffectCfg:getConfigById(self.itemInfo.skilleffectId)
    local dcm = math.abs(effectCfg and effectCfg.dcm or 0) * 100
    local intger = math.abs(effectCfg and effectCfg.intger or 0)
    local detailDec = Lang:toText(self.itemInfo.effectDec)
    if dcm ~= 0 then
      detailDec = string.gsub(detailDec, "@dcm@", tostring(dcm))
    end
    if intger ~= 0 then
      detailDec = string.gsub(detailDec, "@intger@", tostring(intger))
    end
    if self.itemInfo.isLong then
      data.detailDec = detailDec
      data.roundDec = ""
    else
      if 0 < (self.itemInfo.round or 0) then
        detailDec = string.gsub(detailDec, "@round@", tostring(self.itemInfo.round))
      end
      data.detailDec = detailDec
      data.roundDec = string.format(Lang:toText("ui_skill_effect_tip_round"), self.itemInfo.round)
    end
    UI:getWnd("skillEffectDetailTip"):onShow(data, dx, dy)
  end)
end

function M:updateInfo(itemInfo)
  self.itemInfo = itemInfo
  self.itemIcon:SetImage(itemInfo.icon)
  if itemInfo.isLong then
    self.roundText:SetText("")
  else
    self.roundText:SetText(itemInfo.round)
  end
  if itemInfo.effectName then
    self.itemEffect:SetVisible(true)
    self.itemEffect:SetEffectName(itemInfo.effectName)
  else
    self.itemEffect:SetVisible(false)
  end
end

function M:onDestroy()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
  self._allEvent = {}
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
