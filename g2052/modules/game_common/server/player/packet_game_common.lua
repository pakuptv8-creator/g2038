local Interact = T(World, "Interact")
local handles = T(Player, "PackageHandlers")
local InteractSoundHelper = T(Lib, "InteractSoundHelper")

function handles:clientInitiatesTransfer(packet)
  local params = packet.params or {}
  if params.map and params.pos then
    print("--clientInitiatesTransfer--", params.c, params.pos, params.yaw)
    self:setMapPos(params.map, params.pos, params.yaw, nil, false, {
      yaw = params.yaw
    })
  end
  if packet.transportInfo and packet.transportInfo.type == Define.TRANSPORT_TYPE.HOUSE then
    self:requestOpenHouseUI(packet.transportInfo)
  end
end

function handles:triggerPartInteractC2S(packet)
  local partID = packet.partID
  local part = Instance.getByInstanceId(partID)
  if not part or not part:isValid() then
    return
  end
  Interact.tryPartInteract(Define.PART_INTERACT_TYPE.CLICKED, part, self, true)
end

function handles:SwitchTelevisionChannels(packet)
  local id = packet.targetID
  local add = packet.add
  self:switchTelevisionChannels(id, add)
end

function handles:CloseTelevision(packet)
  self:updateCurWatchTelevision()
end

function handles:RequestGoToBornPos(packet)
  self:setMapPos(World.cfg.defaultMap or "map001", World.cfg.initPos)
end

function handles:reqDyeingPart(packet)
  local partName = packet.partName
  local color = packet.color
  local effectInfo = packet.effectInfo
  if not partName or not color then
    return
  end
  
  local function doDyeing(self)
    if not self or not self:isValid() then
      return
    end
    self:dyeing(partName, {
      color.r,
      color.g,
      color.b,
      1
    })
  end
  
  if effectInfo.effectName and effectInfo.effectName ~= "" and effectInfo.parentPartID then
    local interactPart = Instance.getByInstanceId(effectInfo.parentPartID)
    if interactPart then
      local parent = interactPart:getParent()
      if parent then
        local effectPart
        local count = parent:getChildrenCount()
        for i = 0, count - 1 do
          local child = parent:getChildAt(i)
          if child:getChildrenCount() > 0 then
            local count_c = child:getChildrenCount()
            for i = 0, count_c - 1 do
              local part = child:getChildAt(i)
              if string.match(part:getName(), effectInfo.effectName) then
                effectPart = part
                break
              end
            end
          end
        end
        if effectPart then
          effectPart.visible = true
          World.Timer(effectInfo.effectPlayTime or 40, function()
            effectPart.visible = false
            doDyeing(self)
          end)
          return
        end
      end
    end
  end
  doDyeing(self)
end

function handles:SendSoundToOthers(packet)
  WorldServer.BroadcastPacket({
    pid = "SendSoundToOthers",
    data = packet.data,
    host = self.platformUserId
  })
end

function handles:CSSendShortChatMsg(packet)
  local msg = World.CurWorld:filterWord(packet.msg)
  if not msg or utf8.len(msg) > 1000 then
    return
  end
  local packet2 = {
    pid = "ChatMessage",
    fromname = self.name,
    msg = msg,
    emoji = false,
    args = table.pack(self.objID, nil, Define.Page.COMMON, self.platformUserId),
    textVipColor = self:getTextVipColor()
  }
  self:sendChatMsg(packet2, true)
  local ChatMsgCacheHelper = T(Lib, "ChatMsgCacheHelper")
  ChatMsgCacheHelper:addOneCommonChatMsg(packet2)
  self:doShortChatDanceAction(packet.id)
end
