local WinLandInfoEdit = M

function WinLandInfoEdit:init()
  WinBase.init(self, "LandInfoEdit.json")
  self._allEvent = {}
  self.landPanelOffset = World.cfg.landPanelOffset or {}
  self:initUI()
  self:initEvent()
end

function WinLandInfoEdit:initUI()
  self.lytListInfo = self:child("LandInfoEdit-listInfo")
  self.imgDec = self:child("LandInfoEdit-dec")
  self.txtTitle = self:child("LandInfoEdit-title")
  self.editParam = self:child("LandInfoEdit-param")
  self.imgClose = self:child("LandInfoEdit-close")
  self.imgRefresh = self:child("LandInfoEdit-refresh")
  self:initList()
end

function WinLandInfoEdit:initList()
  self.gv = UIMgr:new_widget("grid_view")
  self.gv:InitConfig(0, 20, 1)
  self.lytListInfo:AddChildWindow(self.gv)
  for key, v in pairs(self.landPanelOffset) do
    local node = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "List" .. key)
    node:SetWidth({0, 100})
    node:SetHeight({0, 50})
    node:SetText(key)
    self:subscribe(node, UIEvent.EventWindowClick, function()
      self:updateInfo(key)
    end)
    self.gv:AddItem(node)
  end
end

function WinLandInfoEdit:initEvent()
  self:subscribe(self.imgClose, UIEvent.EventWindowClick, function()
    self:onHide()
  end)
  self:subscribe(self.imgRefresh, UIEvent.EventWindowClick, function()
    if self.curKey then
      Me:updateHousePanelUI(self.curKey, self.landPanelOffset)
    end
  end)
  self:subscribe(self.editParam, UIEvent.EventEditTextInput, function()
    if self.curKey then
      local param = self.editParam:GetPropertyString("Text", "")
      self.landPanelOffset[self.curKey] = Lib.createV3ByString(param)
    end
  end)
end

function WinLandInfoEdit:subscribeEvent()
end

function WinLandInfoEdit:updateInfo(key)
  self.txtTitle:SetText(key)
  self.curKey = key
  local params
  if key and self.landPanelOffset[key] then
    params = Lib.createStringByV3(self.landPanelOffset[key])
  else
    params = ""
  end
  self.editParam:SetProperty("Text", params)
end

function WinLandInfoEdit:initView()
  self:updateInfo("")
end

function WinLandInfoEdit:onHide()
  UI:closeWnd("landInfoEdit")
end

function WinLandInfoEdit:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("landInfoEdit")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLandInfoEdit:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinLandInfoEdit:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinLandInfoEdit
