local WinPlayerInteractRequest = M
local PlayerInteractiveConfig = T(Config, "PlayerInteractiveConfig")

function WinPlayerInteractRequest:init()
  WinBase.init(self, "PlayerInteractRequest.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPlayerInteractRequest:initUI()
  self.imgPanel = self:child("PlayerInteractRequest-panel")
  self.lytHeadPanel = self:child("PlayerInteractRequest-HeadPanel")
  self.imgHeadIcon = self:child("PlayerInteractRequest-HeadIcon")
  self.imgHeadFrame = self:child("PlayerInteractRequest-HeadFrame")
  self.imgSexIcon = self:child("PlayerInteractRequest-SexIcon")
  self.imgSexIcon:SetVisible(false)
  self.txtPlayerName = self:child("PlayerInteractRequest-PlayerName")
  self.btnAgree = self:child("PlayerInteractRequest-Agree")
  self.btnRefuse = self:child("PlayerInteractRequest-Refuse")
  self.imgActionIcon = self:child("PlayerInteractRequest-ActionIcon")
end

function WinPlayerInteractRequest:initEvent()
  self:subscribe(self.btnAgree, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "ResponsePlayerInteractive",
      fromId = self.fromId,
      interactiveID = self.interactiveID,
      isAgree = true
    })
    self:onHide()
    local defaultData = {
      double_interact_id = self.interactiveID
    }
    Plugins.CallTargetPluginFunc("report", "report", "doubleAction_accept", defaultData, Me)
  end)
  self:subscribe(self.btnRefuse, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "ResponsePlayerInteractive",
      fromId = self.fromId,
      interactiveID = self.interactiveID,
      isAgree = false
    })
    self:onHide()
  end)
end

function WinPlayerInteractRequest:subscribeEvent()
end

function WinPlayerInteractRequest:initView(fromId, interactiveID)
  self.fromId = fromId
  self.interactiveID = interactiveID
  local data = PlayerInteractiveConfig:getCfgById(interactiveID)
  self.imgActionIcon:SetImage(data.normalIcon)
  self:updateNameShow(fromId)
  self:stopAutoTimer()
  local totalTime = 0
  self.autoTimer = World.Timer(20, function()
    totalTime = totalTime + 20
    if 200 <= totalTime then
      self:onHide()
      self:stopAutoTimer()
      return false
    end
    return true
  end)
end

function WinPlayerInteractRequest:updateNameShow(fromId)
  local fromEntity = World.CurWorld:getEntity(fromId)
  if not fromEntity or not fromEntity:isValid() then
    self:onHide()
    return
  end
  self.txtPlayerName:SetText(fromEntity.name or "")
  self.imgSexIcon:SetImage("")
  self.imgHeadIcon:SetImage(World.cfg.defaultAvatar)
  AsyncProcess.GetUserDetail(fromEntity.platformUserId, function(data)
    if not data then
      return
    end
    self.txtPlayerName:SetText(data.nickName)
    if data.picUrl and #data.picUrl > 0 then
      self.imgHeadIcon:SetImageUrl(data.picUrl)
    end
    if data.sex and data.sex == 1 then
      self.imgSexIcon:SetImage("set:g2052_icon.json image:img_0_gender02")
    elseif data.sex and data.sex == 2 then
      self.imgSexIcon:SetImage("set:g2052_icon.json image:img_0_gender01")
    end
  end)
end

function WinPlayerInteractRequest:stopAutoTimer()
  if self.autoTimer then
    self.autoTimer()
    self.autoTimer = nil
  end
end

function WinPlayerInteractRequest:onHide()
  UI:closeWnd("playerInteractRequest")
end

function WinPlayerInteractRequest:onShow(isShow, fromId, interactiveID)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("playerInteractRequest")
    end
    self:initView(fromId, interactiveID)
  else
    self:onHide()
  end
end

function WinPlayerInteractRequest:onOpen()
  self:subscribeEvent()
end

function WinPlayerInteractRequest:onClose()
  self:stopAutoTimer()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinPlayerInteractRequest
