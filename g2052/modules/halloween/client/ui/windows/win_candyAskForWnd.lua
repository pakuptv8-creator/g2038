local WinCandyAskForWnd = M

function WinCandyAskForWnd:init()
  WinBase.init(self, "CandyAskForWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinCandyAskForWnd:initUI()
  self.imgBg = self:child("CandyAskForWnd-Bg")
  self.imgBBG = self:child("CandyAskForWnd-BBG")
  self.imgCandyIcon = self:child("CandyAskForWnd-CandyIcon")
  self.lytPlayer = self:child("CandyAskForWnd-Player")
  self.imgPatternSend = self:child("CandyAskForWnd-Pattern-Send")
  self.txtAskTips = self:child("CandyAskForWnd-AskTips")
  self.btnConfirm = self:child("CandyAskForWnd-Confirm")
  self.btnCancel = self:child("CandyAskForWnd-Cancel")
  self.playerWidget = UIMgr:new_widget("playerItem1")
  self.lytPlayer:AddChildWindow(self.playerWidget)
  self.playerWidget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
end

function WinCandyAskForWnd:initEvent()
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    self:responseCandyAskFor(true)
    self:onHide()
  end)
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    self:responseCandyAskFor(false)
    self:onHide()
  end)
end

function WinCandyAskForWnd:subscribeEvent()
end

function WinCandyAskForWnd:initView(fromUserID, fromName)
  self.fromUserID = fromUserID
  self.fromName = fromName
  self.playerWidget:invoke("reload", self.fromUserID)
  local text = Lang:toText({
    "g2052.gui.halloween.askFor.ask",
    fromName
  })
  self.txtAskTips:SetText(text)
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
  self.countDown = World.LightTimer("WinPropReceive CountDown", 20 * World.cfg.receivePropCountDown, function()
    self:onHide()
    return false
  end)
end

function WinCandyAskForWnd:responseCandyAskFor(result)
  Me:sendPacket({
    pid = "CSResponseCandyAskFor",
    fromUserId = self.fromUserID,
    result = result
  })
end

function WinCandyAskForWnd:onHide()
  UI:closeWnd("candyAskForWnd")
end

function WinCandyAskForWnd:onShow(isShow, fromUserID, fromName)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("candyAskForWnd", fromUserID, fromName)
    else
      if self.fromUserID == fromUserID then
        return
      end
      self:responseCandyAskFor(false)
      self:initView(fromUserID, fromName)
    end
  else
    self:onHide()
  end
end

function WinCandyAskForWnd:onOpen(fromUserID, fromName)
  self:initView(fromUserID, fromName)
  self:subscribeEvent()
end

function WinCandyAskForWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.countDown then
    self.countDown()
    self.countDown = nil
  end
end

return WinCandyAskForWnd
