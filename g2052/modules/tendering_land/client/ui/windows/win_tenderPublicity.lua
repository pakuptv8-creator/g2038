local WinTenderPublicity = M
local TenderingConfig = T(Config, "TenderingConfig")

function WinTenderPublicity:init()
  WinBase.init(self, "TenderPublicity.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinTenderPublicity:initUI()
  self.lytPublicityPanel = self:child("TenderPublicity-PublicityPanel")
  self.txtTitleText = self:child("TenderPublicity-TitleText")
  self.txtPlayerText = self:child("TenderPublicity-PlayerText")
  self.imgPraiseIcon = self:child("TenderPublicity-PraiseIcon")
  self.txtPraiseNum = self:child("TenderPublicity-PraiseNum")
end

function WinTenderPublicity:initEvent()
end

function WinTenderPublicity:subscribeEvent()
end

function WinTenderPublicity:initView(data)
  self:updateContentInfo(data)
end

function WinTenderPublicity:updateContentInfo(data)
  local landCfg = TenderingConfig:getCfgByLandNameAndRegionId(data.blockId, data.regionId)
  if landCfg and landCfg.buildName then
    self.txtTitleText:SetVisible(true)
    self.txtTitleText:SetText(Lang:toText(landCfg.buildName))
  else
    self.txtTitleText:SetVisible(false)
  end
  if data.nickName then
    self.txtPlayerText:SetVisible(true)
    self.txtPlayerText:SetText(data.nickName)
  else
    self.txtPlayerText:SetVisible(false)
  end
  if data.likeNumber then
    self.txtPraiseNum:SetVisible(true)
    self.txtPraiseNum:SetText(data.likeNumber)
  else
    self.txtPraiseNum:SetVisible(false)
  end
end

function WinTenderPublicity:onHide()
  UI:closeWnd("tenderPublicity")
end

function WinTenderPublicity:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("tenderPublicity")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinTenderPublicity:onOpen(data)
  self:initView(data)
  self:subscribeEvent()
end

function WinTenderPublicity:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinTenderPublicity
