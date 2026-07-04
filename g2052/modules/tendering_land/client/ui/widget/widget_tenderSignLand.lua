local widget_base = require("ui.widget.widget_base")
local WidgetTenderSignLand = Lib.derive(widget_base)

function WidgetTenderSignLand:init()
  widget_base.init(self, "TenderSignLand.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetTenderSignLand:initUI()
  self.imgLandPanel = self:child("TenderSignLand-LandPanel")
  self.lytBg = self:child("TenderSignLand-Bg")
  self.imgLandIcon = self:child("TenderSignLand-LandIcon")
  self.lytTopBg = self:child("TenderSignLand-TopBg")
  self.txtLandTitle = self:child("TenderSignLand-LandTitle")
  self.lytAwardBg = self:child("TenderSignLand-AwardBg")
  self.txtAwardTitle = self:child("TenderSignLand-AwardTitle")
  self.btnGoToBtn = self:child("TenderSignLand-GoToBtn")
  self.lytAwardContent = self:child("TenderSignLand-AwardContent")
  self.txtEndTime = self:child("TenderSignLand-endTime")
  self.imgEndTimeBg = self:child("TenderSignLand-endTimeBg")
  self.btnVoteBtn = self:child("TenderSignLand-VoteBtn")
  self.btnEditorBtn = self:child("TenderSignLand-EditorBtn")
  self.btnVoteBtn:SetVisible(false)
  self.btnEditorBtn:SetVisible(false)
  self:initAdapter()
  self.txtAwardTitle:SetText(Lang:toText("g2052.gui.tendering.sign.award_pre"))
  self.btnGoToBtn:SetText(Lang:toText("g2052.gui.tendering.sign.go_land"))
  self.btnVoteBtn:SetText(Lang:toText("g2052.gui.tendering.vote_tips"))
  self.btnEditorBtn:SetText(Lang:toText("g2052.gui.tendering.editor_tips"))
end

function WidgetTenderSignLand:initAdapter()
  local params = {
    xDis = 8,
    yDis = 0,
    xCellNum = 3,
    widgetWidth = 80,
    widgetHeight = 60,
    widgetJson = "TenderSignAward.json",
    widgetName = "tenderSignAward",
    gvParent = self.lytAwardContent,
    dataList = {}
  }
  self.awardListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.awardGridView = self.awardListView:getGridView()
  self.awardGridView:SetMoveAble(true)
  self.awardGridView:SetvScorllMoveAble(false)
  self.awardGridView:SethScorllMoveAble(true)
  self.awardAdapter = self.awardListView:getAdapter()
end

function WidgetTenderSignLand:initEvent()
  self:subscribe(self.btnGoToBtn, UIEvent.EventButtonClick, function()
    if Me:getInteractPlayerHorseID() > 0 then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.transfer.fail")
      return
    end
    local landMapPos = self.data.landMapPos
    local params = {
      map = landMapPos[1] or "map001",
      pos = Lib.v3(tonumber(landMapPos[2] or 0), tonumber(landMapPos[3] or 0), tonumber(landMapPos[4] or 0)),
      yaw = tonumber(landMapPos[5] or 0)
    }
    Me:sendPacket({
      pid = "clientInitiatesTransfer",
      params = params
    })
    UI:closeWnd("tenderSignWnd")
  end)
  self:subscribe(self.btnEditorBtn, UIEvent.EventButtonClick, function()
    Me:showBiddingOpenEditor(self.data.landName, self.data.screenShot)
    UI:closeWnd("tenderSignWnd")
  end)
  self:subscribe(self.btnVoteBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("biddingRankList", self.data.landName, "tenderSign")
    UI:closeWnd("tenderSignWnd")
  end)
end

function WidgetTenderSignLand:onDataChanged(data)
  self.data = data
  self.txtLandTitle:SetText(Lang:toText(data.buildName))
  self.imgLandIcon:SetImage(data.landIcon)
  self:updateAwardInfo()
  self:updateEndTime(data.timeLineInfo)
end

function WidgetTenderSignLand:updateAwardInfo()
  self.awardAdapter:clearItems()
  self.awardGridView:SetMoveAble(true)
  self.awardGridView:InitConfig(8, 0, #self.data.landAwardList)
  self.awardAdapter:setData(self.data.landAwardList)
  self.awardGridView:ResetPos()
end

function WidgetTenderSignLand:updateEndTime(data)
  self.btnVoteBtn:SetVisible(false)
  self.btnEditorBtn:SetVisible(false)
  if self.data and data then
    local landName = self.data.landName
    local status = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", landName)
    local info = data or {}
    local curInfo = info[status]
    local titleText = ""
    local textLen = 0
    if curInfo then
      local timeRemaining = curInfo.timeRemaining
      local langKey = "ui.bidding.activity." .. status
      titleText = Lang:toText(langKey) .. Lang:toText({
        "ui.end.after.days",
        timeRemaining
      })
      self.txtEndTime:SetText(titleText)
    else
      titleText = Lang:toText("ui.bidding.activity.normal")
      self.txtEndTime:SetText(titleText)
    end
    textLen = self.txtEndTime:GetFont():GetTextExtent(titleText, 1.0)
    self.imgEndTimeBg:SetWidth({
      0,
      textLen + 10
    })
    if status == Define.BIDDING_STATUS.BIDDING or status == Define.BIDDING_STATUS.AUDIT then
      self.btnEditorBtn:SetVisible(true)
    elseif status == Define.BIDDING_STATUS.ELECTION or status == Define.BIDDING_STATUS.FINALS then
      self.btnVoteBtn:SetVisible(true)
    end
  end
end

function WidgetTenderSignLand:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetTenderSignLand
