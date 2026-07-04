local WinG2052Guide = M
local GuideConfig = T(Config, "GuideConfig")
local xDis = 48

function WinG2052Guide:init()
  WinBase.init(self, "G2052Guide.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinG2052Guide:initUI()
  self.lytMain = self:child("G2052Guide-main")
  self.lytTipList = self:child("G2052Guide-tip_list")
  self.lytContent = self:child("G2052Guide-content")
  self.imgWnd = self:child("G2052Guide-wnd")
  self.imgTitleBg = self:child("G2052Guide-title_bg")
  self.txtTitle = self:child("G2052Guide-title")
  self.btnClose = self:child("G2052Guide-close")
  self.lytImgList = self:child("G2052Guide-img_list")
  self:initTipList()
  self:initImgList()
end

function WinG2052Guide:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMain, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
end

function WinG2052Guide:subscribeEvent()
end

function WinG2052Guide:initTipList()
end

function WinG2052Guide:initImgList()
  self.guideView = GridViewHelper.new({
    name = "guideView",
    xCellNum = 3,
    xDis = xDis,
    yDis = 0,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = true,
    widgetWidth = 215,
    widgetHeight = 388,
    widgetJson = "G2052GuideCell.json",
    widgetName = "g2052GuideCell",
    gvParent = self.lytImgList,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
end

function WinG2052Guide:updateImgList(cfg)
  if cfg then
    local imgs = cfg.imgs or {}
    local x = xDis
    if #imgs < 3 then
      x = 88
    end
    self.guideView:updateGridViewConfig(x, 0, #imgs)
    self.guideView:setData(cfg.info, -1, nil, true)
  end
end

function WinG2052Guide:initView(uiName)
  self.startShowTime = nil
  local isTip = false
  if uiName then
    isTip = true
    local cfg = GuideConfig:getCfgByUIName(uiName)
    if cfg then
      self:updateImgList(cfg)
      self.txtTitle:SetText(Lang:toText(cfg.title))
    end
    self.startShowTime = os.time()
  end
  self.lytMain:SetVisible(not isTip)
  self.lytContent:SetVisible(isTip)
end

function WinG2052Guide:onHide()
  UI:closeWnd("g2052Guide")
  if self.fun then
    self.fun(self.uiName, self.data)
  end
end

function WinG2052Guide:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052Guide")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinG2052Guide:onOpen(uiName, fun, ...)
  self.uiName = uiName
  self.fun = fun
  self.data = (...)
  self:initView(uiName)
  self:subscribeEvent()
end

function WinG2052Guide:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.startShowTime and self.uiName and self.uiName ~= "" then
    local defaultData = {
      guide_ui_time = os.time() - self.startShowTime,
      guide_ui_name = self.uiName or ""
    }
    Plugins.CallTargetPluginFunc("report", "report", "guide_ui_open", defaultData, Me)
  end
end

return WinG2052Guide
