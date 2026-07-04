local widget_base = require("ui.widget.widget_base")
local WidgetModMapDiscussRelay = Lib.derive(widget_base)

function WidgetModMapDiscussRelay:init()
  widget_base.init(self, "ModMapDiscussRelay.json")
  self:initUI()
  self:initEvent()
end

function WidgetModMapDiscussRelay:initUI()
  self.imgBg = self:child("ModMapDiscussRelay-Bg")
  self.editInput = self:child("ModMapDiscussRelay-Input")
  self.btnRelayBtn = self:child("ModMapDiscussRelay-RelayBtn")
  self.editShow = self:child("ModMapDiscussRelay-Input-Show")
end

function WidgetModMapDiscussRelay:initEvent()
  self:subscribe(self.btnRelayBtn, UIEvent.EventButtonClick, function()
    if self.inputText and self.fun then
      Lib.logDebug("--WidgetModMapDiscussRelay btnRelayBtn:" .. self.inputText)
      self.fun(self.inputText)
    end
  end)
  self:subscribe(self.editInput, UIEvent.EventEditTextInput, function()
    local inputText = string.format(self.editInput:GetPropertyString("Text", ""))
    local maxWord = World.cfg.modReplayMaxWordsNum or 96
    self.inputText = Lib.standardizingInput(inputText, maxWord)
    self:updateInputShow()
    Lib.logDebug("--WidgetModMapDiscussRelay editInput:" .. inputText)
  end)
end

function WidgetModMapDiscussRelay:reload(cb)
  self.fun = cb
end

function WidgetModMapDiscussRelay:updateInputShow()
  if not self.inputText then
    return
  end
  local keep = World.cfg.modReplayWordShowCut or 24
  local s = Lib.standardizingInput(self.inputText, keep, "...")
  self.editShow:SetText(s)
end

function WidgetModMapDiscussRelay:clear()
  self.inputText = nil
  self.editInput:SetProperty("Text", "")
  self.editShow:SetText("")
end

return WidgetModMapDiscussRelay
