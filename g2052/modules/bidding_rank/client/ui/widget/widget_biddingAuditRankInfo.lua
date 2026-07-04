local widget_base = require("ui.widget.widget_base")
local WidgetBiddingAuditRankInfo = Lib.derive(widget_base)

function WidgetBiddingAuditRankInfo:init()
  widget_base.init(self, "BiddingAuditRankInfo.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBiddingAuditRankInfo:initUI()
  self.txtBiddingRankInfoRankNum = self:child("BiddingRankInfo-RankNum")
  self.imgBiddingRankInfoBuildImg = self:child("BiddingRankInfo-BuildImg")
  self.txtBiddingRankInfoDesc = self:child("BiddingRankInfo-Desc")
  self.txtBiddingRankInfoCreaterName = self:child("BiddingRankInfo-CreaterName")
  self.lytBiddingRankInfoAudit = self:child("BiddingRankInfo-Audit")
  self.txtBiddingRankInfoAuditStatus = self:child("BiddingRankInfo-AuditStatus")
  self.btnBiddingRankInfoAuditPass = self:child("BiddingRankInfo-Audit_Pass")
  self.btnBiddingRankInfoAuditUnPass = self:child("BiddingRankInfo-Audit_UnPass")
  self.btnBiddingRankInfoAuditPass:SetText(Lang:toText("g2052.gui.bidding_audit.pass"))
  self.btnBiddingRankInfoAuditUnPass:SetText(Lang:toText("g2052.gui.bidding_audit.unpass"))
end

function WidgetBiddingAuditRankInfo:initEvent()
  self:subscribe(self.btnBiddingRankInfoAuditPass, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "auditBiddingMap",
      auditType = 1,
      mapId = self.data.mapId
    })
  end)
  self:subscribe(self.btnBiddingRankInfoAuditUnPass, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "auditBiddingMap",
      auditType = -1,
      mapId = self.data.mapId
    })
  end)
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    local playerName = self.data.nickName or self.data.userId
    UI:getWnd("commonDialog"):onShow(true, {
      title = Lang:toText("g2052.gui.bidding_rank.preview_tip"),
      desc = Lang:formatMessageByIndex("g2052.gui.bidding_rank.preview", playerName),
      confirmCallback = function()
        Me:sendPacket({
          pid = "previewBiddingAuditMap",
          blockId = self.blockId,
          mapId = self.data.mapId,
          mapResourceUrl = self.data.mapResourceUrl
        })
        local wnd = UI:getWnd("biddingAuditRankList")
        wnd:hide()
      end,
      cancelCallback = function()
      end
    })
  end)
end

function WidgetBiddingAuditRankInfo:updateData(blockId, pageNum, data)
  self.blockId = blockId
  self.pageNum = pageNum
  self.data = data
  local playerId = data.userId
  local img = data.picUrl
  Lib.logDebug("img === ", img)
  AsyncProcess.GetUserDetail(playerId, function(userInfo)
    if not userInfo then
      return
    end
    if playerId == self.data.userId then
      self.txtBiddingRankInfoCreaterName:SetText(string.format(Lang:toText("g2052.gui.bidding_audit.info_name"), playerId, userInfo.nickName))
    end
  end)
  self.txtBiddingRankInfoRankNum:SetText(data.id)
  self.txtBiddingRankInfoCreaterName:SetText(string.format(Lang:toText("g2052.gui.bidding_audit.info_name"), data.userId, data.nickName))
  self.imgBiddingRankInfoBuildImg:SetImageUrl(img)
  local desc = string.format(Lang:toText("g2052.gui.bidding_audit.auditOperator"), data.auditOperator)
  self.txtBiddingRankInfoDesc:SetText(desc)
  self:updateAuditBtn(data.auditStatus)
end

function WidgetBiddingAuditRankInfo:updateAuditBtn(auditStatus)
  self.txtBiddingRankInfoAuditStatus:SetText(Lang:toText(Define.AUDIT_STATUS_TIPS[auditStatus]))
  if auditStatus == Define.AUDIT_STATUS.PASS then
    self.btnBiddingRankInfoAuditPass:SetEnabled(false)
    self.btnBiddingRankInfoAuditPass:SetTouchable(false)
    self.btnBiddingRankInfoAuditUnPass:SetEnabled(true)
    self.btnBiddingRankInfoAuditUnPass:SetTouchable(true)
  elseif auditStatus == Define.AUDIT_STATUS.UN_PASS then
    self.btnBiddingRankInfoAuditPass:SetEnabled(true)
    self.btnBiddingRankInfoAuditPass:SetTouchable(true)
    self.btnBiddingRankInfoAuditUnPass:SetEnabled(false)
    self.btnBiddingRankInfoAuditUnPass:SetTouchable(false)
  else
    self.btnBiddingRankInfoAuditPass:SetEnabled(true)
    self.btnBiddingRankInfoAuditPass:SetTouchable(true)
    self.btnBiddingRankInfoAuditUnPass:SetEnabled(true)
    self.btnBiddingRankInfoAuditUnPass:SetTouchable(true)
  end
end

function WidgetBiddingAuditRankInfo:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetBiddingAuditRankInfo
