local WinLimitedTimeActivityCommonDialog = M
local LimitedTimeDrawAwardsConfig = T(Config, "LimitedTimeDrawAwardsConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinLimitedTimeActivityCommonDialog:init()
  WinBase.init(self, "LimitedTimeActivityCommonDialog.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeActivityCommonDialog:initData()
  self.awardData = LimitedTimeGiftItemConfig:getAllCfgs()
end

function WinLimitedTimeActivityCommonDialog:initUI()
  self.lytWnd = self:child("LimitedTimeActivityCommonDialog-wnd")
  self.lytMask = self:child("LimitedTimeActivityCommonDialog-mask")
  self.imgWndBg = self:child("LimitedTimeActivityCommonDialog-wnd_bg")
  self.imgTopImg = self:child("LimitedTimeActivityCommonDialog-topImg")
  self.txtTitle = self:child("LimitedTimeActivityCommonDialog-title")
  self.gvDetails = self:child("LimitedTimeActivityCommonDialog-details")
  self.txtDetailsText = self:child("LimitedTimeActivityCommonDialog-details_text")
  self.imgDetailsBg = self:child("LimitedTimeActivityCommonDialog-details_bg")
  self.btnClose = self:child("LimitedTimeActivityCommonDialog-close")
  self.imgCloseImg = self:child("LimitedTimeActivityCommonDialog-closeImg")
  self.ltyPlaceholder = self:child("LimitedTimeActivityCommonDialog-placeholder")
  self.gvDetails:AddItem(self.txtDetailsText)
  self.ltyItemPool = self:child("LimitedTimeActivityCommonDialog-itemPool")
  self.ltyQuestion = self:child("LimitedTimeActivityCommonDialog-question")
  self.txtQuestionText = self:child("LimitedTimeActivityCommonDialog-question_text")
  self.txtQuestionInfo = self:child("LimitedTimeActivityCommonDialog-question_info")
  self.btnQuestionYes = self:child("LimitedTimeActivityCommonDialog-question_yes")
  self.btnQuestionNo = self:child("LimitedTimeActivityCommonDialog-question_no")
  self.btnQuestionYes:SetText(Lang:toText("gui.limit.time.activity.confirm.tips"))
  self.btnQuestionNo:SetText(Lang:toText("gui.limit.time.activity.cancel.tips"))
  self:initItemPool()
end

function WinLimitedTimeActivityCommonDialog:initItemPool()
  self.gvItemList = UIMgr:new_widget("grid_view")
  self.ltyItemPool:AddChildWindow(self.gvItemList)
  self.gvItemList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvItemList:InitConfig(30, 10, 4)
  self.itemAdapter = UIMgr:new_adapter("common", 120, 143, "limitedTimeActivityItem", "LimitedTimeActivityItem.json")
  self.gvItemList:invoke("setAdapter", self.itemAdapter)
end

function WinLimitedTimeActivityCommonDialog:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnQuestionYes, UIEvent.EventButtonClick, function()
    if self.yesFun then
      self.yesFun()
    end
    self:onHide()
  end)
  self:subscribe(self.btnQuestionNo, UIEvent.EventButtonClick, function()
    if self.noFun then
      self.noFun()
    end
    self:onHide()
  end)
end

function WinLimitedTimeActivityCommonDialog:subscribeEvent()
end

function WinLimitedTimeActivityCommonDialog:initView(params)
  if params then
    local type = params.type or Define.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.TEXT
    self.imgDetailsBg:SetVisible(false)
    self.ltyItemPool:SetVisible(false)
    self.ltyQuestion:SetVisible(false)
    self.txtTitle:SetText(Lang:toText(params.title))
    if type == Define.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.TEXT then
      self.imgDetailsBg:SetVisible(true)
      self.txtDetailsText:SetText(Lang:toText(params.dec))
      if self.txtDetailsText:GetPixelSize().y > self.gvDetails:GetPixelSize().y then
        self.gvDetails:SetMoveAble(true)
      else
        self.gvDetails:SetMoveAble(false)
      end
    elseif type == Define.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.POND then
      self.ltyItemPool:SetVisible(true)
      local pond = LimitedTimeDrawAwardsConfig:getCfgByPondId(params.pondId or 0)
      local data = {}
      for _, v in pairs(pond or {}) do
        for _, id in pairs(v.giftContent or {}) do
          if self.awardData[id] then
            if not self.awardData[id].quality then
              self.awardData[id].quality = v.quality
            end
            self.awardData[id].isClick = true
            table.insert(data, self.awardData[id])
          end
        end
      end
      self.itemAdapter:setData(data)
    elseif type == Define.LIMITED_TIME_ACTIVITY_COMMON_DIALOG_TYPE.QUESTION then
      self.ltyQuestion:SetVisible(true)
      self.txtQuestionText:SetText(Lang:toText(params.questionText))
      self.txtQuestionInfo:SetText(Lang:toText(params.questionDec))
      self.yesFun = params.yesFun
      self.noFun = params.noFun
    end
  end
end

function WinLimitedTimeActivityCommonDialog:onHide()
  UI:closeWnd("limitedTimeActivityCommonDialog")
end

function WinLimitedTimeActivityCommonDialog:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeActivityCommonDialog")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeActivityCommonDialog:onOpen(params)
  self:initView(params)
  self:subscribeEvent()
end

function WinLimitedTimeActivityCommonDialog:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self.yesFun = nil
  self.noFun = nil
end

return WinLimitedTimeActivityCommonDialog
