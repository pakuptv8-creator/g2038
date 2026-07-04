local widget_base = require("ui.widget.widget_base")
local WidgetWorldChatItem = Lib.derive(widget_base)
local WorldChatHelper = T(Lib, "WorldChatHelper")

function WidgetWorldChatItem:init()
  widget_base.init(self, "WorldChatItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetWorldChatItem:initUI()
  self.lytHeadPanel = self:child("WorldChatItem-HeadPanel")
  self.imgHeadImg = self:child("WorldChatItem-HeadImg")
  self.imgHeadFrame = self:child("WorldChatItem-HeadFrame")
  self.imgHeadMale = self:child("WorldChatItem-HeadMale")
  self.imgHeadFemale = self:child("WorldChatItem-HeadFemale")
  self.txtName = self:child("WorldChatItem-Name")
  self.imgChatPop = self:child("WorldChatItem-ChatPop")
  self.txtChatText = self:child("WorldChatItem-ChatText")
  self.imgEmoji = self:child("WorldChatItem-Emoji")
end

function WidgetWorldChatItem:initEvent()
  self:subscribe(self.lytHeadPanel, UIEvent.EventWindowClick, function()
    if self.data.userId == Me.platformUserId then
      return
    end
    UI:getWnd("playerInteractPop"):onShow(true, self.data.userId, true)
  end)
end

function WidgetWorldChatItem:setSide(isSelf)
  local headPanelX = 28
  local txtNameX = 107
  local emojiX = 100
  local chatPopX = 100
  if isSelf then
    self.lytHeadPanel:SetHorizontalAlignment(2)
    self.lytHeadPanel:SetXPosition({
      0,
      -headPanelX
    })
    self.txtName:SetHorizontalAlignment(2)
    self.txtName:SetTextHorzAlign(2)
    self.txtName:SetXPosition({
      0,
      -txtNameX
    })
    self.imgChatPop:SetHorizontalAlignment(2)
    self.imgChatPop:SetXPosition({
      0,
      -chatPopX
    })
    self.imgChatPop:SetImage("set:g2052_chat_world.json image:img_9_bubble_self")
    self.imgChatPop:SetStretchOffset(30, 30, 25, 11)
    self.txtChatText:SetXPosition({0, -9})
    self.imgEmoji:SetHorizontalAlignment(2)
    self.imgEmoji:SetXPosition({
      0,
      -emojiX
    })
  else
    self.lytHeadPanel:SetHorizontalAlignment(0)
    self.lytHeadPanel:SetXPosition({0, headPanelX})
    self.txtName:SetHorizontalAlignment(0)
    self.txtName:SetTextHorzAlign(0)
    self.txtName:SetXPosition({0, txtNameX})
    self.imgChatPop:SetHorizontalAlignment(0)
    self.imgChatPop:SetXPosition({0, chatPopX})
    self.imgChatPop:SetImage("set:g2052_chat_world.json image:img_9_bubble_other")
    self.imgChatPop:SetStretchOffset(30, 30, 25, 11)
    self.txtChatText:SetXPosition({0, -3})
    self.imgEmoji:SetHorizontalAlignment(0)
    self.imgEmoji:SetXPosition({0, emojiX})
  end
end

function WidgetWorldChatItem:updateItemByData(data)
  self.data = data
  self:setSide(data.userId == Me.platformUserId)
  self.txtName:SetText(data.nickName)
  if data.emoji and data.emoji ~= "" then
    self.imgChatPop:SetVisible(false)
    self.imgEmoji:SetVisible(true)
    self.imgEmoji:SetImage(data.emoji or "")
    self._root:SetHeight({0, 110})
  else
    self.imgChatPop:SetVisible(true)
    self.imgEmoji:SetVisible(false)
    local finalMsg = data.msg
    self.txtChatText:SetText(finalMsg)
    self:autoBarSize(finalMsg)
  end
  self:updateHeadInfo()
end

function WidgetWorldChatItem:updateHeadInfo()
  self.txtName:SetText(self.data.nickName)
  self.imgHeadMale:SetVisible(self.data.sex == 1)
  self.imgHeadFemale:SetVisible(self.data.sex == 2)
  local detailInfo = WorldChatHelper:getWorldDetailInfo(self.data.userId)
  if detailInfo then
    self:setUserHeadImg(detailInfo.picUrl)
  else
    self:setUserHeadImg()
    self:listenHeadImgInfo(self.data.userId)
  end
end

function WidgetWorldChatItem:listenHeadImgInfo(userId)
  if self.userPicUrlInfoCancel then
    self.userPicUrlInfoCancel()
    self.userPicUrlInfoCancel = nil
  end
  self.userPicUrlInfoCancel = Lib.lightSubscribeEvent("error!!!!! EVENT_WORLD_USER_PIC_URL", "EVENT_WORLD_USER_PIC_URL" .. userId, function(picUrl)
    self:setUserHeadImg(picUrl)
    self.userPicUrlInfoCancel()
    self.userPicUrlInfoCancel = nil
  end)
end

function WidgetWorldChatItem:setUserHeadImg(picUrl)
  if picUrl and 0 < #picUrl then
    self.imgHeadImg:SetImageUrl(picUrl)
  else
    self.imgHeadImg:SetImage(World.cfg.defaultAvatar)
  end
end

function WidgetWorldChatItem:autoBarSize(msg)
  local strW = self.txtChatText:GetFont():GetStringWidth(msg)
  local uiW = self.txtChatText:GetWidth()[2]
  uiW = 0 < uiW and uiW or -uiW
  local maxWidth = 320
  local maxHeight = 95
  local initPopHeight = 40
  if maxWidth < strW + uiW then
    self.imgChatPop:SetWidth({0, maxWidth})
    uiW = maxWidth - uiW
    local offsetLine = math.floor(strW / uiW)
    self.imgChatPop:SetHeight({
      0,
      initPopHeight + offsetLine * 27
    })
    self._root:SetHeight({
      0,
      maxHeight + offsetLine * 27
    })
  else
    self.imgChatPop:SetHeight({0, initPopHeight})
    self.imgChatPop:SetWidth({
      0,
      math.max(strW + uiW + 5, 60)
    })
    self._root:SetHeight({0, maxHeight})
  end
end

function WidgetWorldChatItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetWorldChatItem
