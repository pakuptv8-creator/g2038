local WinPropGive = M

function WinPropGive:init()
  WinBase.init(self, "PropGive.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPropGive:initUI()
  self.imgClose = self:child("PropGive-Close")
  self.imgBg = self:child("PropGive-Bg")
  self.lytProp = self:child("PropGive-Prop")
  self.lytPlayer = self:child("PropGive-Player")
  self.imgPatternSend = self:child("PropGive-Pattern-Send")
  self.btnConfirm = self:child("PropGive-Confirm")
  self.propWidget = UIMgr:new_widget("propItem1")
  self.lytProp:AddChildWindow(self.propWidget)
  self.propWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.playerWidget = UIMgr:new_widget("playerItem1")
  self.lytPlayer:AddChildWindow(self.playerWidget)
  self.playerWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function WinPropGive:initEvent()
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    Me:requestGiveProp(self.targetUserId, self.itemId)
    self:onHide()
  end)
  self:subscribe(self.imgClose, UIEvent.EventWindowClick, function(_, dx, dy)
    self:onHide()
  end)
end

function WinPropGive:subscribeEvent()
end

function WinPropGive:initView()
  self.playerWidget:invoke("reload", self.targetUserId)
  self.propWidget:invoke("reload", self.itemId)
end

function WinPropGive:onHide()
  UI:closeWnd("propGive")
end

function WinPropGive:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("propGive")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPropGive:onOpen(itemId, targetUserId)
  if not itemId or not targetUserId then
    return
  end
  self.itemId = itemId
  self.targetUserId = targetUserId
  self:initView()
  self:subscribeEvent()
end

function WinPropGive:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPropGive
