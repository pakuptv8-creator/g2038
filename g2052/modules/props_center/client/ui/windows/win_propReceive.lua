local WinPropReceive = M

function WinPropReceive:init()
  WinBase.init(self, "PropReceive.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPropReceive:initUI()
  self.imgBg = self:child("PropReceive-Bg")
  self.lytProp = self:child("PropReceive-Prop")
  self.lytPlayer = self:child("PropReceive-Player")
  self.imgPatternSend = self:child("PropReceive-Pattern-Send")
  self.btnConfirm = self:child("PropReceive-Confirm")
  self.btnCancel = self:child("PropReceive-Cancel")
  self.propWidget = UIMgr:new_widget("propItem1")
  self.lytProp:AddChildWindow(self.propWidget)
  self.propWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.playerWidget = UIMgr:new_widget("playerItem1")
  self.lytPlayer:AddChildWindow(self.playerWidget)
  self.playerWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function WinPropReceive:initEvent()
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "agreeGiveProp",
      fromUserId = self.fromUserId,
      itemId = self.itemId
    })
    self:onHide()
  end)
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinPropReceive:subscribeEvent()
end

function WinPropReceive:initView()
  self.playerWidget:invoke("reload", self.fromUserId)
  self.propWidget:invoke("reload", self.itemId)
end

function WinPropReceive:onHide()
  UI:closeWnd("propReceive")
end

function WinPropReceive:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("propReceive")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPropReceive:onOpen(itemId, fromUserId)
  if not itemId or not fromUserId then
    return
  end
  if self.countDown then
    self.countDown()
  end
  self.countDown = World.LightTimer("WinPropReceive CountDown", 20 * World.cfg.receivePropCountDown, function()
    self:onHide()
    return false
  end)
  self.itemId = itemId
  self.fromUserId = fromUserId
  self:initView()
  self:subscribeEvent()
end

function WinPropReceive:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
end

return WinPropReceive
