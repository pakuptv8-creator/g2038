local WinLimitedTimeActivityItemDialog = M

function WinLimitedTimeActivityItemDialog:init()
  WinBase.init(self, "LimitedTimeActivityItemDialog.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeActivityItemDialog:initUI()
  self.lytWnd = self:child("LimitedTimeActivityItemDialog-wnd")
  self.lytMask = self:child("LimitedTimeActivityItemDialog-mask")
  self.imgWndBg = self:child("LimitedTimeActivityItemDialog-wnd_bg")
  self.imgTopImg = self:child("LimitedTimeActivityItemDialog-topImg")
  self.txtTitle = self:child("LimitedTimeActivityItemDialog-title")
  self.lytItemList = self:child("LimitedTimeActivityItemDialog-item_list")
  self.lytDetails = self:child("LimitedTimeActivityItemDialog-details")
  self.txtRewardDesc = self:child("LimitedTimeActivityItemDialog-reward_desc")
  self.imgLAdorn = self:child("LimitedTimeActivityItemDialog-l_adorn")
  self.imgRAdorn0 = self:child("LimitedTimeActivityItemDialog-r_adorn_0")
  self.imgDetailsBg = self:child("LimitedTimeActivityItemDialog-details_bg")
  self.txtDecText = self:child("LimitedTimeActivityItemDialog-dec_text")
  self.btnClose = self:child("LimitedTimeActivityItemDialog-close")
  self.imgFrame = self:child("LimitedTimeActivityItemDialog-frame")
  self.imgIcon = self:child("LimitedTimeActivityItemDialog-icon")
  local length = self.txtRewardDesc:GetFont():GetTextExtent(Lang:toText("gui.limit.time.activity.reward.dec"), 1.0)
  self.txtRewardDesc:SetWidth({0, length})
  self.txtRewardDesc:SetText(Lang:toText("gui.limit.time.activity.reward.dec"))
end

function WinLimitedTimeActivityItemDialog:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function WinLimitedTimeActivityItemDialog:subscribeEvent()
end

function WinLimitedTimeActivityItemDialog:initView(params)
  if params then
    self.txtDecText:SetText(Lang:toText(params.dec))
    self.txtTitle:SetText(Lang:toText(params.name))
    if not params.frameImg then
      local quality = params.quality or 1
      self.imgFrame:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
    else
      self.imgFrame:SetImage(params.frameImg)
    end
    self.imgIcon:SetImage(params.icon)
  end
end

function WinLimitedTimeActivityItemDialog:onHide()
  UI:closeWnd("limitedTimeActivityItemDialog")
end

function WinLimitedTimeActivityItemDialog:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeActivityItemDialog")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeActivityItemDialog:onOpen(params)
  self:initView(params)
  self:subscribeEvent()
end

function WinLimitedTimeActivityItemDialog:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitedTimeActivityItemDialog
