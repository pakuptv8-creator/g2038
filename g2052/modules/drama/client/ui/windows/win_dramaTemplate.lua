local WinDramaTemplate = M
local DramaTemplateConfig = T(Config, "DramaTemplateConfig")

function WinDramaTemplate:init()
  WinBase.init(self, "DramaTemplate.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaTemplate:initUI()
  self.lytMainPanel = self:child("DramaTemplate-MainPanel")
  self.imgTopBg = self:child("DramaTemplate-TopBg")
  self.txtTitleText = self:child("DramaTemplate-TitleText")
  self.imgContentBg = self:child("DramaTemplate-ContentBg")
  self.lytContentPanel = self:child("DramaTemplate-ContentPanel")
  self.btnCloseBtn = self:child("DramaTemplate-CloseBtn")
  self.txtTitleText:SetText(Lang:toText("g2052.gui.drama.template.title"))
  self:initContentAdapter()
end

function WinDramaTemplate:initContentAdapter()
  local params = {
    xDis = 0,
    yDis = 18,
    xCellNum = 2,
    widgetWidth = 230,
    widgetHeight = 90,
    widgetJson = "DramaTemplateItem.json",
    widgetName = "dramaTemplateItem",
    gvParent = self.lytContentPanel,
    dataList = {}
  }
  self.dramaListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.dramaGridView = self.dramaListView:getGridView()
  self.dramaGridView:SetMoveAble(true)
  self.dramaGridView:SetvScorllMoveAble(true)
  self.dramaGridView:SetAutoColumnCount(false)
  self.dramaAdapter = self.dramaListView:getAdapter()
end

function WinDramaTemplate:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinDramaTemplate:subscribeEvent()
end

function WinDramaTemplate:initView()
  self.dramaAdapter:clearItems()
  self.dramaGridView:ResetPos()
  local showData = DramaTemplateConfig:getAllCfgs(true)
  self.dramaAdapter:setData(showData)
end

function WinDramaTemplate:onHide()
  UI:closeWnd("dramaTemplate")
end

function WinDramaTemplate:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaTemplate")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaTemplate:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinDramaTemplate:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinDramaTemplate
