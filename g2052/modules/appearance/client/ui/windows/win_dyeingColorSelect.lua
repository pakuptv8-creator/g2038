local WinDyeingColorSelect = M

function WinDyeingColorSelect:init()
  WinBase.init(self, "DyeingColorSelect.json")
  self._allEvent = {}
  self._selectColor = Color.new(1, 1, 0)
  self._locked = false
  self:initUI()
  self:initEvent()
end

function WinDyeingColorSelect:initUI()
  self.lytContentPanel = self:child("ColorSelect-ContentPanel")
  self.imgContentBg = self:child("ColorSelect-ContentBg")
  self.imgTitleBg = self:child("ColorSelect-titleBg")
  self.txtTitle = self:child("ColorSelect-TitleText")
  self.lytColorPanel = self:child("ColorSelect-ColorPanel")
  self.btnClose = self:child("ColorSelect-CloseBtn")
  self.btnConfirm = self:child("ColorSelect-Confirm")
  self.imgSelectColor = self:child("ColorSelect-SelectColor")
  self.colorPalette = UIMgr:new_widget("colorPaletteWidget", function(color)
    self._selectColor = color
    self.imgSelectColor:SetDrawColor({
      self._selectColor.r,
      self._selectColor.g,
      self._selectColor.b,
      1
    })
  end, self._selectColor)
  self.colorPalette:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytColorPanel:AddChildWindow(self.colorPalette)
  self.btnClose:SetVisible(false)
end

function WinDyeingColorSelect:initEvent()
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    if self._locked then
      return
    end
    if self._confirmCb then
      self._confirmCb(self._selectColor)
    end
  end)
end

function WinDyeingColorSelect:subscribeEvent()
end

function WinDyeingColorSelect:initView(params)
  self.txtTitle:SetText(params.title or "")
  self._selectColor = Color.new(1, 1, 0)
  self.imgSelectColor:SetDrawColor({
    self._selectColor.r,
    self._selectColor.g,
    self._selectColor.b,
    1
  })
  self.colorPalette:invoke("resetInitColor")
end

function WinDyeingColorSelect:onOpen(params)
  params = params or {}
  self._leaveCb = params.leaveCb
  self._confirmCb = params.confirmCb
  self:initView(params)
  self:subscribeEvent()
end

function WinDyeingColorSelect:setLocked()
  self._locked = true
end

function WinDyeingColorSelect:undoLocked()
  self._locked = false
end

function WinDyeingColorSelect:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinDyeingColorSelect
