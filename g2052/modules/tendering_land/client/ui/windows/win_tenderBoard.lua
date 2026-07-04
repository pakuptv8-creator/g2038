local WinTenderBoard = M

function WinTenderBoard:init()
  WinBase.init(self, "TenderBoard.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinTenderBoard:initUI()
  self.lytWorkPanel = self:child("TenderBoard-WorkPanel")
  self.txtTitleText = self:child("TenderBoard-TitleText")
  self.txtStateText = self:child("TenderBoard-StateText")
  self.txtPlayerText = self:child("TenderBoard-PlayerText")
  self.txtOrganizeText = self:child("TenderBoard-OrganizeText")
  self.imgEditorIcon = self:child("TenderBoard-EditorIcon")
  self.txtEditorText = self:child("TenderBoard-EditorText")
  self.imgRankIcon = self:child("TenderBoard-RankIcon")
  self.txtRankText = self:child("TenderBoard-RankText")
  self.lytWorkPanel:SetVisible(true)
  self.txtEditorText:SetText(Lang:toText("g2052.gui.tendering.editor_tips"))
  self.txtRankText:SetText(Lang:toText("g2052.gui.tendering.rank_tips"))
end

function WinTenderBoard:initEvent()
end

function WinTenderBoard:subscribeEvent()
end

function WinTenderBoard:initView(data, tenderState)
  self:updateContentInfo(data, tenderState)
end

function WinTenderBoard:updateContentInfo(data, tenderState)
  self.tenderState = tenderState
  self.imgEditorIcon:SetVisible(false)
  self.imgRankIcon:SetVisible(false)
  self:updateWorkingData(data)
  if not (tenderState and data) or self.tenderState == Define.BIDDING_STATUS.NORMAL or self.tenderState == Define.BIDDING_STATUS.WAIT then
    return
  end
  if self.tenderState == Define.BIDDING_STATUS.PUBLICITY then
    self.txtRankText:SetText(Lang:toText("g2052.gui.tendering.go_preview"))
  else
    self.txtRankText:SetText(Lang:toText("g2052.gui.tendering.rank_tips"))
  end
  if self.tenderState == Define.BIDDING_STATUS.ELECTION or self.tenderState == Define.BIDDING_STATUS.FINALS or self.tenderState == Define.BIDDING_STATUS.SELECT or self.tenderState == Define.BIDDING_STATUS.PUBLICITY then
    self.imgEditorIcon:SetVisible(true)
    self.imgRankIcon:SetVisible(true)
  else
    self.imgEditorIcon:SetVisible(true)
  end
end

function WinTenderBoard:updateWorkingData(data)
  if data.signTitle and data.signTitle ~= "" then
    self.txtTitleText:SetVisible(true)
    self.txtTitleText:SetText(Lang:toText(data.signTitle))
  else
    self.txtTitleText:SetVisible(false)
  end
  if data.signState and data.signState ~= "" then
    self.txtStateText:SetVisible(true)
    self.txtStateText:SetText(Lang:toText(data.signState))
  else
    self.txtStateText:SetVisible(false)
  end
  if data.signPlayer and data.signPlayer ~= "" then
    self.txtPlayerText:SetVisible(true)
    self.txtPlayerText:SetText(Lang:toText(data.signPlayer))
    AsyncProcess.GetUserDetail(data.signPlayer, function(userInfo)
      if not userInfo then
        return
      end
      self.txtPlayerText:SetText(userInfo.nickName)
    end)
  else
    self.txtPlayerText:SetVisible(false)
  end
  if data.signUnit and data.signUnit ~= "" then
    self.txtOrganizeText:SetVisible(true)
    self.txtOrganizeText:SetText(Lang:toText(data.signUnit))
  else
    self.txtOrganizeText:SetVisible(false)
  end
end

function WinTenderBoard:onHide()
  UI:closeWnd("tenderBoard")
end

function WinTenderBoard:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("tenderBoard")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinTenderBoard:onOpen(data, tenderState)
  self:initView(data, tenderState)
  self:subscribeEvent()
end

function WinTenderBoard:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinTenderBoard
