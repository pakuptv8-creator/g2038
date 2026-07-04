local EmergencyEffectMgr = T(Lib, "EmergencyEffectMgr")
local handles = T(Player, "PackageHandlers")
local EmergencyConfig = T(Config, "EmergencyConfig")

function handles:emergencyAppear(packet)
  local locationId = packet.id
  local emergencyCfg = EmergencyConfig:getCfgById(packet.emergencyType)
  if not emergencyCfg then
    return
  end
  local houseData
  local houseInfo = Me.allHouseInfo or {}
  if 0 < #houseInfo then
    for i, v in ipairs(houseInfo) do
      if houseInfo[i].id == locationId then
        houseData = houseInfo[i]
        break
      end
    end
  end
  if not houseData then
    return
  end
  local combustibles = packet.firePos
  if 0 < #combustibles then
    EmergencyEffectMgr:createEffect(packet.emergencyType, locationId, combustibles)
  end
  if houseData.ownerId == Me.platformUserId then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.event.house.on.fire"))
    if UI:getWnd("disasterWnd"):isSelectDisaster(1) then
      return
    end
    if not Me.cancelShowDisasterTime then
      Me.cancelShowDisasterTime = 0
    end
    if os.time() - Me.cancelShowDisasterTime < 300 then
      return
    end
    UI:getWnd("commonDialog"):onShow(true, {
      title = "g2052.gui.tendering.tips",
      desc = "gui.limit.time.heart.warming.house_fire",
      confirmCallback = function()
        UI:getWnd("disasterWnd"):doSelectDisasterItem(1)
      end,
      cancelCallback = function()
        Me.cancelShowDisasterTime = os.time()
      end
    })
  elseif Me:getProfessionId() == emergencyCfg.notified_profession then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText({
      "g2052.event.alarm.of.fire",
      houseData.index
    }))
  end
end

function handles:delEmergencyEffect(packet)
  EmergencyEffectMgr:delEffect(packet.type, packet.key, packet.posList)
end

function handles:emergencyDisappear(packet)
  local key = packet.id
  for _, v in pairs(Define.EMERGENCY_TYPE) do
    EmergencyEffectMgr:delEffect(v, key)
  end
end
