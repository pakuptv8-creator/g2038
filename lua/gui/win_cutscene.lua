local M = _ENV.M

function M:init()
  WinBase.init(self, "cutscene.json")
  self:initWnd()
end

function M:initWnd()
  self.subtitle = self:child("cutscene-subtitle")
  self.effect = self:child("cutscene-effect")
  self.skip = self:child("cutscene-skip")
  self.skip:SetText(Lang:toText("skip"))
  self.dialog = self:child("canvas-dialog")
  self.dialog:SetVisible(false)
end

function M:playEffect(name)
  Lib.log("M:playEffect " .. name)
  self.effect:SetVisible(true)
  self.effect:PlayEffect1(name)
end

function M:stopEffect()
  Lib.log("M:stopEffect")
  self.effect:SetVisible(false)
end

function M:showSubtitle(content)
  self.dialog:SetVisible(true)
  self.subtitle:SetText(Lang:toText(content))
end

function M:hideSubtitle()
  self.dialog:SetVisible(false)
end
