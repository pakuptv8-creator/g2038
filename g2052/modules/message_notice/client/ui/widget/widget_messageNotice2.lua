local widget_base = require("ui.widget.widget_base")
local WidgetMessageNotice = Lib.derive(widget_base)
local MessageConfig = T(Config, "MessageConfig")

function WidgetMessageNotice:init()
  widget_base.init(self, "G2052MessageNotice2.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetMessageNotice:initUI()
end

function WidgetMessageNotice:initEvent()
  self.noticeText = self:child("G2052VideoSoundSetting-Text")
  self.noticeIcon = self:child("G2052VideoSoundSetting-Icon")
  self.panel = self:child("G2052VideoSoundSetting-Panel")
end

function WidgetMessageNotice:reset(data)
  if self.moveTimer then
    self:moveTimer()
  end
  if not data then
    return
  end
  local cfg = MessageConfig:getCfgById(data.id)
  if not cfg then
    return
  end
  self.panel:SetVisible(true)
  self.panel:SetYPosition({
    0,
    -self.panel:GetHeight()[2]
  })
  if data.replaceStr then
    self.noticeText:SetText(Lang:toText({
      cfg.text,
      data.replaceStr
    }))
  else
    self.noticeText:SetText(Lang:toText(cfg.text))
  end
  self.noticeIcon:SetImage(cfg.icon)
  local moveSpeed = World.cfg.messageNotice.noticeMoveSpeed or 10
  local startTime = os.time()
  self.moveTimer = World.Timer(1, function()
    if os.time() - startTime >= cfg.showTime then
      self.panel:SetVisible(false)
    else
      if self.panel:GetYPosition()[2] < 0 then
        self.panel:SetYPosition({
          0,
          self.panel:GetYPosition()[2] + moveSpeed
        })
      end
      if self.panel:GetYPosition()[2] > 0 then
        self.panel:SetYPosition({0, 0})
      end
      return true
    end
  end)
end

function WidgetMessageNotice:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMessageNotice
