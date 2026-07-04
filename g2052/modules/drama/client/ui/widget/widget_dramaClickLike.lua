local widget_base = require("ui.widget.widget_base")
local WidgetDramaClickLike = Lib.derive(widget_base)
local DramaClientHelper = T(Lib, "DramaClientHelper")

function WidgetDramaClickLike:init()
  widget_base.init(self, "DramaClickLike.json")
  self._allEvent = {}
  self.delEffectTimer = {}
  self.likeCountNotSend = 0
  self.likeCountHaveSent = {}
  self.totalLikeCount = 0
  self.likeNumInData = 0
  self.clickLikeLimit = World.cfg.maxGiveLikeCount or 10
  self:initUI()
  self:initEvent()
end

function WidgetDramaClickLike:initUI()
  self.imgHeadImage = self:child("DramaClickLike-HeadImage")
  self.btnLikeButton = self:child("DramaClickLike-LikeButton")
  self.txtLikeNumText = self:child("DramaClickLike-LikeNumText")
  self.lytEffect = self:child("DramaClickLike-EffectPanel")
  self.lytCurDramaPanel = self:child("DramaClickLike-CurDramaPanel")
  self.btnLeave = self:child("DramaClickLike-ButtonLeave")
  self:child("DramaClickLike-Title"):SetText(Lang:toText("g2052.gui.drama.cur.drama"))
  self.btnLikeButton:SetVisible(self:canShowClickLikeBtn())
end

function WidgetDramaClickLike:isDramaOwner()
  local inf = DramaClientHelper.curDramaInfo
  if inf then
    return inf.userId == Me.platformUserId
  end
  return false
end

function WidgetDramaClickLike:initEvent()
  self:subscribe(self.btnLikeButton, UIEvent.EventButtonClick, function()
    self:clickLike()
  end)
  self:subscribe(self.lytCurDramaPanel, UIEvent.EventWindowClick, function()
    UI:openWnd("dramaTemplateInfo", DramaClientHelper.curDramaInfo)
  end)
  self:subscribe(self.btnLeave, UIEvent.EventButtonClick, function()
    local DramaClientHelper = T(Lib, "DramaClientHelper")
    DramaClientHelper:requestLeaveDrama()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_LIKE_INF, function(data)
    if data and data.ownerLikeInfo then
      if not self.data then
        if data.ownerLikeInfo.picUrl and #data.ownerLikeInfo.picUrl > 0 then
          self.imgHeadImage:SetImageUrl(data.ownerLikeInfo.picUrl)
        else
          self.imgHeadImage:SetImage(World.cfg.defaultAvatar)
        end
        if data.giveLikeRecord then
          local myClickLikeCount = data.giveLikeRecord[Me.platformUserId] or 0
          self.clickLikeLimit = self.clickLikeLimit - myClickLikeCount
        end
        self.btnLikeButton:SetVisible(self:canShowClickLikeBtn())
      end
      self.data = data
      if data.ownerLikeInfo.score then
        if data.giveALikeUserId == Me.platformUserId then
          table.remove(self.likeCountHaveSent, 1)
        end
        self.likeNumInData = data.ownerLikeInfo.score
        self.txtLikeNumText:SetText(Lib.toNewThousandthString(self:getShowLikeNum()))
      end
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_CUR_DETAIL, function()
    self.btnLikeButton:SetVisible(self:canShowClickLikeBtn())
  end)
end

function WidgetDramaClickLike:clickLike()
  if not (self:checkClickLikeLimit() and self.data) or self:isDramaOwner() then
    return
  end
  if not self.clickTimer then
    self.clickTimer = World.Timer(60, function()
      self:sendToServer()
      self.clickTimer = nil
    end)
  end
  self.likeCountNotSend = self.likeCountNotSend + 1
  self.totalLikeCount = self.totalLikeCount + 1
  self.txtLikeNumText:SetText(Lib.toNewThousandthString(self:getShowLikeNum()))
  if not self:checkClickLikeLimit() then
    self.btnLikeButton:SetVisible(false)
  end
  self:setEffect("g2052_like.effect")
end

function WidgetDramaClickLike:setEffect(clickEffect)
  local posx = World.cfg.dramaSetting.clickLikeEffect.posOffsetX or -50
  local posy = World.cfg.dramaSetting.clickLikeEffect.posOffsetY or -50
  local size = World.cfg.dramaSetting.clickLikeEffect.size or 150
  local showEffect = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "show-effect")
  showEffect:SetTouchable(false)
  showEffect:SetArea({0, posx}, {0, posy}, {0, size}, {0, size})
  showEffect:SetHorizontalAlignment(1)
  showEffect:SetVerticalAlignment(1)
  showEffect:PlayEffect1(clickEffect)
  self.lytEffect:AddChildWindow(showEffect)
  self.delEffectTimer[#self.delEffectTimer + 1] = World.Timer(40, function()
    self.lytEffect:RemoveChildWindow1(showEffect)
  end)
end

function WidgetDramaClickLike:sendToServer()
  if self.likeCountNotSend > 0 then
    Me:sendPacket({
      pid = "clickLickC2S",
      count = self.likeCountNotSend
    })
    table.insert(self.likeCountHaveSent, self.likeCountNotSend)
    self.likeCountNotSend = 0
  end
end

function WidgetDramaClickLike:checkClickLikeLimit()
  return self.totalLikeCount < self.clickLikeLimit
end

function WidgetDramaClickLike:getShowLikeNum()
  local haveSentNum = 0
  for _, v in pairs(self.likeCountHaveSent) do
    haveSentNum = haveSentNum + v
  end
  return self.likeNumInData + self.likeCountNotSend + haveSentNum
end

function WidgetDramaClickLike:canShowClickLikeBtn()
  return not self:isDramaOwner() and self:checkClickLikeLimit()
end

function WidgetDramaClickLike:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.delEffectTimer then
    for k, fun in pairs(self.delEffectTimer) do
      fun()
    end
  end
  if self.clickTimer then
    self.clickTimer()
    self.clickTimer = nil
  end
end

return WidgetDramaClickLike
