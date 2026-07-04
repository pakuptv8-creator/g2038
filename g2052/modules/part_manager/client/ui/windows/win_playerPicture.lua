local WinPlayerPicture = M

function WinPlayerPicture:init()
  WinBase.init(self, "PlayerPicture.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinPlayerPicture:initUI()
  self.lytPlayerPanel = self:child("PlayerPicture-PlayerPanel")
  self.actorPlayerModel = self:child("PlayerPicture-PlayerModel")
  self.txtPlayerName = self:child("PlayerPicture-PlayerName")
end

function WinPlayerPicture:initEvent()
end

function WinPlayerPicture:subscribeEvent()
end

function WinPlayerPicture:initView(info)
  self:updatePictureModeShow(info)
end

local function checkValue(skins, key)
  if skins[key] == "" or skins[key] == nil then
    return true
  end
  return false
end

local function checkUseSuits(skins)
  assert(type(skins) == "table")
  if not skins.custom_suits then
    return false
  end
  if (type(skins.custom_suits) == "string" and skins.custom_suits ~= "" or type(skins.custom_suits) ~= "string" and next(skins.custom_suits)) and checkValue(skins, "armor_foot") and checkValue(skins, "armor_thigh") and checkValue(skins, "armor_chest") and (skins.suits_head == 0 or checkValue(skins, "armor_head")) then
    return true
  end
  return false
end

local function resetSkin(result)
  local newSkins = {}
  local useSuits = checkUseSuits(result)
  for master, slave in pairs(result or {}) do
    local skin = slave
    if useSuits then
      if master == "custom_suits" and type(slave) ~= "string" then
        for i, v in pairs(slave) do
          if i == 1 then
            skin = tostring(v)
          else
            skin = skin .. "-" .. tostring(v)
          end
        end
      end
      if (master == "custom_face" or master == "clothes_tops" or master == "custom_hair" or master == "clothes_pants" or master == "custom_shoes") and slave == 0 then
        skin = ""
      end
    end
    newSkins[master] = skin
  end
  return newSkins
end

function WinPlayerPicture:updatePictureModeShow(info)
  self._root:SetWidth({
    0,
    info.width
  })
  self._root:SetHeight({
    0,
    info.height
  })
  self.txtPlayerName:SetText(info.nameContent)
  self.actorPlayerModel:SetActor1(info.sex == 1 and "g2052_boy.actor" or "g2052_girl.actor", "")
  local skins = resetSkin(info.skinData or {})
  for k, v in pairs(skins) do
    if k == "skin_color" then
      self.actorPlayerModel:SetActorCustomColor(v)
    elseif k == "custom_bag" then
    elseif EntityClient.getPartDyeColor and GUIActorWindow.UseBodyPartDyeColor then
      local color = Me:getPartDyeColor(k, v)
      self.actorPlayerModel:UseBodyPartDyeColor(k, v, color or "")
    else
      self.actorPlayerModel:UseBodyPart(k, v)
    end
  end
  self.actorPlayerModel:SetActorScale(info.actorScale)
  self.actorPlayerModel:UpdateSelf(1)
end

function WinPlayerPicture:onHide()
  UI:closeWnd("playerPicture")
end

function WinPlayerPicture:onShow(isShow, info)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("playerPicture", info)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinPlayerPicture:onOpen(info)
  self:initView(info)
  self:subscribeEvent()
end

function WinPlayerPicture:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinPlayerPicture
