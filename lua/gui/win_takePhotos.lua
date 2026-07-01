local handles = T(Player, "PackageHandlers")

function M:init()
  WinBase.init(self, "TakePhotos.json")
  self:initWnd()
end

function M:initWnd()
  self.action = self:child("TakePhotos-action")
  self.close = self:child("TakePhotos-close")
  self:subscribe(self.action, UIEvent.EventButtonClick, function()
    Me:playSoundByKey("photo_click")
    handles.TakePhotos(Me, nil)
  end)
  self:subscribe(self.close, UIEvent.EventButtonClick, function()
    Me:cameraModeClose()
  end)
end
