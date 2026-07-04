local widget_base = require("ui.widget.widget_base")
local WidgetChatBubbleItem = Lib.derive(widget_base)

function WidgetChatBubbleItem:init()
  widget_base.init(self, "ChatBubbleItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetChatBubbleItem:initUI()
  self.lytContentPanel = self:child("ChatBubbleItem-ContentPanel")
  self.imgContentBg = self:child("ChatBubbleItem-ContentBg")
  self.imgArrow = self:child("ChatBubbleItem-Arrow")
  self.txtContentStr = self:child("ChatBubbleItem-ContentStr")
  self.txtTestStr = self:child("ChatBubbleItem-TestStr")
  self.lytVoicePanel = self:child("ChatBubbleItem-VoicePanel")
  self.txtVoiceText = self:child("ChatBubbleItem-VoiceText")
end

function WidgetChatBubbleItem:initEvent()
end

function WidgetChatBubbleItem:updateTextShow(msg, voiceTime, userId, textVipColor)
  self.chatBubbleSetting = World.cfg.chatSetting.chatBubbleSetting
  if voiceTime and 0 < voiceTime then
    self.lytVoicePanel:SetVisible(true)
    self.txtTestStr:SetVisible(false)
    self.txtContentStr:SetVisible(false)
    local times = math.floor(voiceTime / 1000)
    self.txtVoiceText:SetText(times .. "\"")
    self.lytContentPanel:SetWidth({
      0,
      self.chatBubbleSetting.minWidth
    })
  else
    self.lytVoicePanel:SetVisible(false)
    self.txtTestStr:SetVisible(false)
    self.txtContentStr:SetVisible(true)
    self.txtTestStr:SetText(msg)
    local strW = self.txtTestStr:GetFont():GetStringWidth(msg)
    if strW >= self.chatBubbleSetting.maxWidth - 10 then
      self.lytContentPanel:SetWidth({
        0,
        self.chatBubbleSetting.maxWidth
      })
    elseif strW > self.chatBubbleSetting.minWidth - 10 then
      self.lytContentPanel:SetWidth({
        0,
        strW + 10
      })
    else
      self.lytContentPanel:SetWidth({
        0,
        self.chatBubbleSetting.minWidth
      })
    end
  end
  self.txtContentStr:SetText(msg)
  self.txtContentStr:SetTextColor(Lib.getTextColor("000000"))
  if World.cfg.isUseChatVIP then
    if Me:checkPlayerIsVipByUserId(userId) then
      self.imgContentBg:SetImage("set:g2052_chat_box.json image:img_9_air_bubbles04")
      self.imgArrow:SetImage("set:g2052_chat_box.json image:img_9_air_bubbles03")
      local vipTextColor = textVipColor or World.cfg.ChatTextColor or "000000"
      if vipTextColor == "FFFFFF" then
        vipTextColor = "000000"
      end
      self.txtContentStr:SetTextColor(Lib.getTextColor(vipTextColor))
    else
      self.imgContentBg:SetImage("set:g2052_chat_box.json image:img_9_air_bubbles02")
      self.imgArrow:SetImage("set:g2052_chat_box.json image:img_9_air_bubbles01")
    end
  end
end

function WidgetChatBubbleItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetChatBubbleItem
