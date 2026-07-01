function M:init()
  WinBase.init(self, "FollowPetPrivilege.json", false)
  
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.title = self:child("FollowPetPrivilege-wnd_title")
  self.closeBtn = self:child("FollowPetPrivilege-wnd_close")
  self.itemBg = self:child("FollowPetPrivilege-item_icon_frame")
  self.itemIcon = self:child("FollowPetPrivilege-item_icon")
  self.itemName = self:child("FollowPetPrivilege-item_name")
  self.itemDesc = self:child("FollowPetPrivilege-item_desc")
  self.priceName = self:child("FollowPetPrivilege-item_price")
  self.priceIcon = self:child("FollowPetPrivilege-item_price_icon")
  self.priceNum = self:child("FollowPetPrivilege-item_price_num")
  self.noBtn = self:child("FollowPetPrivilege-item_no")
  self.yewBtn = self:child("FollowPetPrivilege-item_yes")
  self.callback = nil
end

function M:initEvent()
  self:subscribe(self.closeBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.noBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.yewBtn, UIEvent.EventButtonClick, function()
    self.yewBtn:SetTouchable(false)
    Me:sendPacket({
      pid = "buyFollowPetPrivilege"
    }, function(isSucceed)
      if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CONFIRM_FOLLOW_PET then
        Me:gotoNextGuide()
      end
      self.yewBtn:SetTouchable(true)
      UI:closeWnd(self)
    end)
  end)
end

function M:onOpen(content)
  if not content then
    return
  end
  GameAnalytics.Design(1, {
    "Follow_click"
  })
  if content.title then
    self.title:SetText(Lang:toText(content.title))
  end
  if content.itemIcon then
    self.itemIcon:SetImage(content.itemIcon)
  end
  if content.itemName then
    self.itemName:SetText(Lang:toText(content.itemName))
  end
  if content.itemDesc then
    self.itemDesc:SetText(Lang:toText(content.itemDesc))
  end
  if content.itemBg then
    self.itemBg:SetImage(content.itemBg)
  end
  if content.priceIcon then
    self.priceIcon:SetImage(content.priceIcon)
  end
  if content.priceNum then
    self.priceNum:SetText(content.priceNum)
  end
  if content.priceName then
    self.priceName:SetText(Lang:toText(content.priceName))
  end
end
