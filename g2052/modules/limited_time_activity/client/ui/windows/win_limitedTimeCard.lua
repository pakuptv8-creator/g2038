local WinLimitedTimeCard = M
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeCardConfig = T(Config, "LimitedTimeCardConfig")

function WinLimitedTimeCard:init()
  WinBase.init(self, "LimitedTimeCard.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLimitedTimeCard:initUI()
  self.btnHelp = self:child("LimitedTimeCard-help")
  self:child("LimitedTimeCard-title"):SetText(Lang:toText("gui.limit.time.activity.card.title"))
  self.ltyCellList = self:child("LimitedTimeCard-cell_list")
  self:initItemList()
end

function WinLimitedTimeCard:initItemList()
  self.gvCellList = UIMgr:new_widget("grid_view")
  self.ltyCellList:AddChildWindow(self.gvCellList)
  self.gvCellList:SetMoveAble(false)
  self.gvCellList:SetClipChild(false)
  self.gvCellList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.cellAdapter = UIMgr:new_adapter("common", 325, 503, "limitedTimeCardCell", "LimitedTimeCardCell.json")
  self.gvCellList:invoke("setAdapter", self.cellAdapter)
end

function WinLimitedTimeCard:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeActivityCommonDialog", {
      title = "gui.limit.time.activity.help",
      dec = "gui.limit.time.card.help"
    })
  end)
end

function WinLimitedTimeCard:subscribeEvent()
end

function WinLimitedTimeCard:updateView()
  if not self.cfg then
    return
  end
  local count = #self.cfg
  self.gvCellList:InitConfig(93, 0, count)
  self.cellAdapter:setData(self.cfg)
end

function WinLimitedTimeCard:initView()
  self.params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD)
  for _, node in pairs(self.imgCard or {}) do
    node:SetVisible(false)
  end
  if self.params and self.params.id then
    self.cfg = LimitedTimeCardConfig:getSameActivityCfgByActivityId(self.params.id)
    self:updateView()
  end
end

function WinLimitedTimeCard:onHide()
  UI:closeWnd("limitedTimeCard")
end

function WinLimitedTimeCard:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("limitedTimeCard")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLimitedTimeCard:onOpen()
  self:initView()
  self:subscribeEvent()
  GameAnalytics.NewDesign("monthly_card_click", {})
end

function WinLimitedTimeCard:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLimitedTimeCard
