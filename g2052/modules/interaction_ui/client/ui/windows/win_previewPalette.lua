local WinPreviewPalette = M
local paletteEditor = require("special.palette_editor")

function WinPreviewPalette:init()
  WinBase.init(self, "PreviewPalette.json")
  self:initUI()
  self:initEvent()
end

function WinPreviewPalette:initUI()
  self.imgPreviewIMG = self:child("PreviewIMG")
end

function WinPreviewPalette:initEvent()
end

function WinPreviewPalette:showPreview(data)
  if data then
    UI:setViewTexture(data, self.imgPreviewIMG)
  else
    self.imgPreviewIMG:SetImage(self.cfg.defaultPic)
  end
end

function WinPreviewPalette:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PREVIEW_PALETTE, function(objID, data)
    print("--EVENT_UPDATE_PREVIEW_PALETTE---")
    if self.attachObjID ~= objID then
      return
    end
    print("--showPreview---")
    self:showPreview(data)
  end)
end

function WinPreviewPalette:initView()
  local attach = World.CurWorld:getEntity(self.attachObjID)
  if not attach then
    return
  end
  self:showPreview(attach:getPaletteData())
end

function WinPreviewPalette:onHide()
  UI:closeWnd("previewPalette")
end

function WinPreviewPalette:onOpen(cfg, objID)
  objID = objID or cfg.objID
  self._allEvent = {}
  self.attachObjID = objID
  self.paletteEditor = paletteEditor
  self.cfg = cfg
  self:subscribeEvent()
  self:initView()
end

function WinPreviewPalette:onClose()
  self.paletteEditor = nil
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPreviewPalette
