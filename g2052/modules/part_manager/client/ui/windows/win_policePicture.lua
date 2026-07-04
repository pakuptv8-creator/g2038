local WinPolicePicture = M

function WinPolicePicture:init()
  WinBase.init(self, "PolicePicture.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPolicePicture:initUI()
  self.lytPlayerPanel1 = self:child("PolicePicture-PlayerPanel1")
  self.actorPlayerModel1 = self:child("PolicePicture-PlayerModel1")
  self.txtPlayerName1 = self:child("PolicePicture-PlayerName1")
  self.lytPlayerPanel2 = self:child("PolicePicture-PlayerPanel2")
  self.actorPlayerModel2 = self:child("PolicePicture-PlayerModel2")
  self.txtPlayerName2 = self:child("PolicePicture-PlayerName2")
end

function WinPolicePicture:initEvent()
end

function WinPolicePicture:subscribeEvent()
end

function WinPolicePicture:initView(params)
  self:updatePicturePlayerShow(params)
end

function WinPolicePicture:updatePicturePlayerShow(params)
  self.lytPlayerPanel1:SetVisible(false)
  self.lytPlayerPanel2:SetVisible(false)
  if params[1] then
    self.lytPlayerPanel1:SetVisible(true)
    self:updatePictureModeShow(self.txtPlayerName1, self.actorPlayerModel1, params[1])
  end
  if params[2] then
    self.lytPlayerPanel2:SetVisible(true)
    self:updatePictureModeShow(self.txtPlayerName2, self.actorPlayerModel2, params[2])
  end
end

function WinPolicePicture:updatePictureModeShow(node1, node2, params)
  node1:SetTextColor(Lib.getTextColor(params.nameColor))
  node1:SetText(params.nameContent)
  node2:SetActor1(params.sex == 1 and "g2052_boy.actor" or "g2052_girl.actor", "")
  for k, v in pairs(params.skinData or {}) do
    if k == "skin_color" then
      node2:SetActorCustomColor(v)
    elseif k == "custom_bag" then
    elseif EntityClient.getPartDyeColor and GUIActorWindow.UseBodyPartDyeColor then
      local color = Me:getPartDyeColor(k, v)
      node2:UseBodyPartDyeColor(k, v, color or "")
    else
      node2:UseBodyPart(k, v)
    end
  end
  node2:SetActorScale(params.actorScale)
  node2:UpdateSelf(1)
end

function WinPolicePicture:onHide()
  UI:closeWnd("policePicture")
end

function WinPolicePicture:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("policePicture")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPolicePicture:onOpen(params)
  self:initView(params)
  self:subscribeEvent()
end

function WinPolicePicture:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinPolicePicture
