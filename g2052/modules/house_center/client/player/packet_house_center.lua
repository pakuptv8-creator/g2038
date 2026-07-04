local HouseConfig = T(Config, "HouseConfig")
local handles = T(Player, "PackageHandlers")
local landPanelOffset = World.cfg.landPanelOffset or {
  land = {
    x = 0.7,
    y = -0.7,
    z = -14.66
  }
}

function handles:openHouseUI(packet)
  if packet.targetId then
    if UI:isOpen("house") then
      UI:closeWnd("house")
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.home.list.is.open"))
    end
    UI:openWnd("house", packet.targetId, packet.oldTargetId, packet.landName)
  end
end

function handles:SyncHouseInfo(packet)
  local params = packet.params or {}
  self:updateHouseInfo(params)
  local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
  for _, info in pairs(params) do
    if info.mapId == Me.map.id then
      local key = "housePanelUI" .. info.index
      local ui = Plugins.CallTargetPluginFunc("scene_ui", "getSceneUI", key)
      local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName)
      local landInfo = HouseConfig:getLandInfo(info.landName) or {}
      local rotate = Lib.copy(info.rotation)
      local pos = Lib.copy(info.pos)
      local panelOffset = landInfo.landPanelOffset or Lib.v3(0, 0, 0)
      pos = pos + Lib.correctMoveDistance(rotate, Lib.v3(panelOffset.x, panelOffset.y, panelOffset.z))
      if houseInfo then
        pos = pos + Lib.correctMoveDistance(rotate, houseInfo.panelOffset)
      end
      local uiName = "housePanel"
      local default = {
        width = 8,
        viewDistance = 64,
        uiName = uiName,
        rotate = rotate,
        position = pos,
        key = key,
        params = info
      }
      if ui then
        Plugins.CallTargetPluginFunc("scene_ui", "updateSceneUI", ui, default)
      else
        table.insert(uiCfgList, default)
        Plugins.CallTargetPluginFunc("scene_ui", "createSceneUI", default)
      end
    end
  end
end

function handles:updateHouseConfig(packet)
  HouseConfig:rewriteCfg(packet.tbData)
end

function handles:againApplyHouse(packet)
  UI:getWnd("commonDialog"):onShow(true, {
    title = "g2052.gui.house.remould",
    desc = "g2052.gui.house.remould.dec",
    confirmCallback = function()
      Me:sendPacket({
        pid = "ReconfirmApplyHouse",
        params = packet.params
      })
    end,
    cancelCallback = function()
    end
  })
end

function handles:onEarthquakeS2C(packet)
  Blockman.instance:addCameraShake(packet.scale, packet.duration, packet.count, 2)
end
