local WinBiddingAuditPreview = M

function WinBiddingAuditPreview:init()
  WinBase.init(self, "BiddingAuditPreview.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinBiddingAuditPreview:initUI()
  self.lytBiddingPreview = self:child("BiddingPreview")
  self.btnBiddingPreviewReturn = self:child("BiddingPreview-Return")
  self.btnBiddingPreviewPass = self:child("BiddingPreview-Pass")
  self.btnBiddingPreviewUnPass = self:child("BiddingPreview-UnPass")
  self.txtBiddingPreviewCurrStatus = self:child("BiddingPreview-CurrStatus")
  self.btnAuditRank = self:child("BiddingPreview-AuditRank")
  self.btnBiddingPreviewPass:SetText(Lang:toText("g2052.gui.bidding_audit.pass"))
  self.btnBiddingPreviewUnPass:SetText(Lang:toText("g2052.gui.bidding_audit.unpass"))
  self.btnAuditRank:SetText(Lang:toText("g2052.gui.bidding_audit.preview_rank"))
end

function WinBiddingAuditPreview:initEvent()
  self:subscribe(self.btnBiddingPreviewReturn, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "leavePreviewModel"
    })
    local wnd = UI:getWnd("biddingAuditRankList")
    wnd:show()
  end)
  self:subscribe(self.btnBiddingPreviewPass, UIEvent.EventButtonClick, function()
    local modelData = Me.modelData
    Me:sendPacket({
      pid = "auditBiddingMap",
      auditType = 1,
      mapId = modelData.mapId
    })
  end)
  self:subscribe(self.btnBiddingPreviewUnPass, UIEvent.EventButtonClick, function()
    local modelData = Me.modelData
    Me:sendPacket({
      pid = "auditBiddingMap",
      auditType = -1,
      mapId = modelData.mapId
    })
  end)
  self:subscribe(self.btnAuditRank, UIEvent.EventButtonClick, function()
    local wnd = UI:getWnd("biddingAuditRankList")
    wnd:reShow()
  end)
end

function WinBiddingAuditPreview:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.BIDDING_AUDIT_SUCCESS, function()
    self:initView()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.BIDDING_LOADED_AUDIT_MAP_INFO, function(data)
    self:updateView(data)
  end)
end

function WinBiddingAuditPreview:initView()
end

function WinBiddingAuditPreview:requestAuditData()
  local modelData = Me.modelData
  if not modelData then
    return
  end
  self.blockId = modelData.blockId
  self.mapId = modelData.mapId
  Me:sendPacket({
    pid = "requestAuditBiddingInfo",
    blockId = self.blockId,
    mapId = modelData.mapId
  })
end

function WinBiddingAuditPreview:updateView(data)
  Lib.logDebug("============", Lib.v2s(data))
  if not (data and data.data) or not data.data[1] then
    return
  end
  local info = data.data[1]
  self.txtBiddingPreviewCurrStatus:SetText(Lang:toText(Define.AUDIT_STATUS_TIPS[info.auditStatus]))
  if info.auditStatus == Define.AUDIT_STATUS.PASS then
    self.btnBiddingPreviewPass:SetEnabled(false)
    self.btnBiddingPreviewPass:SetTouchable(false)
    self.btnBiddingPreviewUnPass:SetEnabled(true)
    self.btnBiddingPreviewUnPass:SetTouchable(true)
  elseif info.auditStatus == Define.AUDIT_STATUS.UN_PASS then
    self.btnBiddingPreviewPass:SetEnabled(true)
    self.btnBiddingPreviewPass:SetTouchable(true)
    self.btnBiddingPreviewUnPass:SetEnabled(false)
    self.btnBiddingPreviewUnPass:SetTouchable(false)
  else
    self.btnBiddingPreviewPass:SetEnabled(true)
    self.btnBiddingPreviewPass:SetTouchable(true)
    self.btnBiddingPreviewUnPass:SetEnabled(true)
    self.btnBiddingPreviewUnPass:SetTouchable(true)
  end
end

function WinBiddingAuditPreview:onHide()
  UI:closeWnd("biddingAuditPreview")
end

function WinBiddingAuditPreview:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("biddingAuditPreview")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinBiddingAuditPreview:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinBiddingAuditPreview:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinBiddingAuditPreview
