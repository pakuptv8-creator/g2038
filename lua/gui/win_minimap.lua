local subscribeEvent = require("script_client.event_cache")
local mapSize = 100
local miniMapSize = 210
local mapCenter = {
  x = 0,
  y = 0,
  z = 0
}
local isMini = true
local locationsTable = {}
local rotateOffset = 0
local positionOffset = {x = -5, y = 60}

function M:rotate(pos, deg)
  local ret = {}
  local rad = math.rad(deg)
  ret.x = math.cos(rad) * pos.x + math.sin(rad) * pos.z
  ret.z = -math.sin(rad) * pos.x + math.cos(rad) * pos.z
  return ret
end

function M:SetMapPos(window, pos, isMe, width)
  if not pos then
    return
  end
  local mapwidth = self.m_mapimage:GetWidth()[2]
  local mapheight = self.m_mapimage:GetHeight()[2]
  local rotate_pos = self:rotate({
    x = pos.x - mapCenter.x,
    z = pos.z - mapCenter.z
  }, -rotateOffset)
  local minimappos = {}
  minimappos.x = (rotate_pos.x + mapSize / 2) / mapSize
  minimappos.y = (rotate_pos.z + mapSize / 2) / mapSize
  local x = mapwidth / 2 - minimappos.x * mapwidth
  local y = mapheight / 2 - minimappos.y * mapheight
  if isMe then
    width = 200
  else
    width = width or 24
  end
  window:SetArea({0, x}, {0, y}, {0, width}, {0, width})
end

function M:getScenePos(x, y)
  local mapwidth = self.m_mapimage:GetWidth()[2]
  local mapheight = self.m_mapimage:GetHeight()[2]
  return {
    x = mapSize / 2 - x / mapwidth * mapSize,
    y = mapSize / 2 - y / mapheight * mapSize
  }
end

function M:maximize()
  local layout = self:root()
  layout:SetProperty("VerticalAlignment", "Centre")
  layout:SetProperty("HorizontalAlignment", "Centre")
  layout:SetArea({0, 0}, {-0.05, 0}, {0, 512}, {0, 512})
  self.m_background:SetArea({0, 0}, {0, 0}, {0, 512}, {0, 512})
  self.m_clip:SetArea({0, 0}, {0, 0}, {0, 512}, {0, 512})
  self.m_mapimage:SetArea({0, 0}, {0, 0}, {0, 512}, {0, 512})
  isMini = false
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
end

function M:setMapName(name)
  self.m_mapname:SetText(name)
end

function M:setMapSize(size)
  mapSize = size
end

function M:setMapCenter(center)
  mapCenter = center
end

function M:setMapImage(file)
  self.m_mapimage:SetImage(file)
end

function M:minimize()
  local config = World.CurMap.cfg.miniMap
  positionOffset = config.positionOffset or {x = -5, y = 60}
  miniMapSize = config.miniMapSize or 210
  local layout = self:root()
  layout:SetProperty("VerticalAlignment", "Top")
  layout:SetProperty("HorizontalAlignment", "Right")
  layout:SetArea({
    0,
    positionOffset.x
  }, {
    0,
    positionOffset.y
  }, {0, 250}, {0, 300})
  self.m_background:SetArea({0, 0}, {0, 0}, {
    0,
    miniMapSize + 10
  }, {
    0,
    miniMapSize + 10
  })
  self.m_clip:SetArea({0, 5}, {0, 5}, {0, miniMapSize}, {0, miniMapSize})
  self.m_mapimage:SetArea({0, 0}, {0, 0}, {0, 1024}, {0, 1024})
  isMini = true
  self:root():SetLevel(60)
end

function M:updateEntityPos(v)
  local config = World.CurMap.cfg.miniMap
  if config then
    local entity = World.CurWorld:getEntity(v.objectID)
    if entity and entity:isValid() and entity:getPosition() then
      if entity.isPlayer and entity.objID ~= Me.objID then
        v.image:SetImage(config.otherPlayerIcon)
        v.width = 10
        local dis = Lib.getPosDistanceSqr(entity:getPosition(), Me:getPosition())
        if 1600 <= dis then
          v.image:SetVisible(false)
          if v.text then
            v.text:SetVisible(false)
          end
          return
        end
      end
      self:SetMapPos(v.image, entity:getPosition(), v.objectID == Me.objID, v.width)
      if v.text then
        v.text:SetArea({
          0,
          v.image:GetXPosition()[2] - v.textOffset
        }, {
          0,
          v.image:GetYPosition()[2] + 36
        }, {0, 100}, {0, 50})
        v.text:SetProperty("Visible", 1)
      end
      if v.isRotate then
        local yaw = entity:getRotationYaw()
        if entity.rideOnId then
          local car = World.CurWorld:getEntity(entity.rideOnId)
          if car and car:isValid() then
            yaw = car:getRotationYaw()
          end
        end
        v.image:SetProperty("Rotate", yaw + rotateOffset + v.rotate + 90)
      end
      v.image:SetVisible(true)
    elseif v.objectID ~= nil then
      v.image:SetProperty("Visible", 0)
      if v.text then
        v.text:SetProperty("Visible", 0)
      end
    else
      self:SetMapPos(v.image, v.pos, v.objectID == Me.objID, v.width)
      if v.text then
        v.text:SetArea({
          0,
          v.image:GetXPosition()[2] - v.textOffset
        }, {
          0,
          v.image:GetYPosition()[2] + 36
        }, {0, 100}, {0, 50})
      end
    end
  end
end

function M:load()
  local config = World.CurMap.cfg.miniMap
  if config then
    rotateOffset = config.rotateOffset or 0
    self.m_pos:SetVisible(not config.hideCoord)
    local bgImage = ""
    if not config.hideBg then
      bgImage = config.bg and config.bg or "set:main_page.json image:map_bg.png"
    end
    self.m_background:SetImage(bgImage)
    if config.bgNineGrid then
      self.m_background:SetProperty("StretchType", "NineGrid")
      self.m_background:SetProperty("StretchOffset", config.bgNineGrid)
    end
    self:setMapName(Lang:toText(config.MapName or config.mapName))
    self:setMapSize(config.MapSize or config.mapSize)
    self:setMapCenter(config.mapCenter or {
      x = 0,
      y = 0,
      z = 0
    })
    self:setMapImage("map/" .. World.CurMap.name .. "/" .. (config.MapFile or config.mapFile))
    self.m_mapimage:SetProperty("Rotate", 90)
    self:minimize()
    Lib.emitEvent(Event.EVENT_START_TICK_MINI_MAP)
  end
end

function M:init()
  WinBase.init(self, "MiniMap.json")
  self.m_background = self:child("main_layout-background")
  self.m_mapimage = self:child("main_layout-map_image")
  self.m_clip = self:child("main_layout-clip")
  self.m_mapname = self:child("main_layout-mapname")
  self.m_mapname:SetText("")
  self.m_pos = self:child("main_layout-pos")
  self.m_pos:SetText("")
  self.objIconList = {}
  self.objIconNameList = {}
  self.iconIndex = 1
  self:subscribe(self.m_background, UIEvent.EventWindowClick, function(_, x, y)
    if Me:getCurGym() == 0 then
      Me:gameBehaviorReport("ui", "map")
      UI:getWnd("pokemonBigMap"):onShow()
    end
  end)
  self:load()
  Lib.subscribeEvent(Event.EVENT_START_TICK_MINI_MAP, function()
    local offset = self.m_clip:GetWidth()[2] / 2
    if self.tickTimer then
      self.tickTimer()
      self.tickTimer = nil
    end
    self.tickTimer = World.LightTimer("mapz", 1, function()
      return self:tick(offset)
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_STOP_TICK_MINI_MAP, function()
    self.tickTimer()
    self.tickTimer = nil
  end)
  Lib.subscribeEvent(Event.EVENT_MAP_RELOAD, function()
    Lib.logDebug("EVENT_MAP_RELOAD")
    if not Me:isInBattle() then
      self.m_background:SetVisible(true)
    end
    self:load()
  end)
  Lib.subscribeEvent(Event.EVENT_MAP_MAXIMIZE, function()
    Lib.logDebug("EVENT_MAP_MAXIMIZE")
    self:maximize()
  end)
  Lib.subscribeEvent(Event.EVENT_MAP_MINIMIZE, function()
    Lib.logDebug("EVENT_MAP_MINIMIZE")
    self:minimize()
  end)
  subscribeEvent(Event.EVENT_MAP_SETICON, function(key, icon, text, pos, rotate, objectID, isRotate, width)
    Lib.logDebug("EVENT_MAP_SETICON rotate = ", rotate)
    self:SetIcon(key, icon, text, pos, rotate, objectID, isRotate, width)
  end)
  Lib.subscribeEvent(Event.EVENT_MAP_REMOVEICON, function(key)
    Lib.logDebug("EVENT_MAP_REMOVEICON")
    self:removeIcon(key)
  end)
  Lib.subscribeEvent(Event.EVENT_OPEN_MINI_MAP, function()
    Lib.logDebug("show mini map")
    self.m_background:SetVisible(true)
  end)
  Lib.subscribeEvent(Event.EVENT_HIDE_MINI_MAP, function()
    Lib.logDebug("hide mini map")
    self.m_background:SetVisible(false)
  end)
end

function M:tick(offset)
  local pos = Me:getPosition()
  local rotate_pos = self:rotate({
    x = pos.x - mapCenter.x,
    z = pos.z - mapCenter.z
  }, -rotateOffset)
  local minimappos = {}
  minimappos.x = (rotate_pos.x + mapSize / 2) / mapSize
  minimappos.y = (rotate_pos.z + mapSize / 2) / mapSize
  local mapwidth = self.m_mapimage:GetWidth()[2]
  local mapheight = self.m_mapimage:GetHeight()[2]
  if isMini == true then
    self.m_mapimage:SetArea({
      0,
      minimappos.x * mapwidth + offset - mapwidth
    }, {
      0,
      minimappos.y * mapheight + offset - mapwidth
    }, {0, mapwidth}, {0, mapheight})
  end
  for k, v in pairs(locationsTable) do
    self:updateEntityPos(v)
  end
  return true
end

function M:SetIcon(key, icon, text, pos, rotate, objectID, isRotate, width)
  if icon == nil and text == nil then
    return
  end
  if locationsTable[key] == nil then
    locationsTable[key] = {}
  end
  locationsTable[key].objectID = objectID
  locationsTable[key].pos = pos
  locationsTable[key].rotate = rotate or 0
  locationsTable[key].isRotate = isRotate
  locationsTable[key].width = width
  if icon and locationsTable[key].image == nil then
    local image = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "StaticImage" .. key)
    image:SetVerticalAlignment(1)
    image:SetHorizontalAlignment(1)
    self.m_mapimage:AddChildWindow(image)
    locationsTable[key].image = image
  end
  if text and locationsTable[key].text == nil then
    local text = GUIWindowManager.instance:CreateGUIWindow1("StaticText", "StaticText" .. key)
    self.m_mapimage:AddChildWindow(text)
    locationsTable[key].text = text
  end
  if icon then
    locationsTable[key].image:SetImage(icon)
  end
  if text then
    locationsTable[key].text:SetText(text)
  end
  locationsTable[key].image:SetProperty("Rotate", locationsTable[key].rotate + rotateOffset)
  locationsTable[key].textOffset = 0
  local entity = World.CurWorld:getEntity(objectID)
  if entity then
    self:SetMapPos(locationsTable[key].image, entity:getPosition(), objectID == Me.objID, width)
    if text and locationsTable[key].text then
      locationsTable[key].textOffset = #text * 3
      locationsTable[key].text:SetArea({
        0,
        locationsTable[key].image:GetXPosition()[2] - locationsTable[key].textOffset
      }, {
        0,
        locationsTable[key].image:GetYPosition()[2] + 36
      }, {0, 100}, {0, 50})
    end
    if isRotate and entity:getRotationYaw() then
      locationsTable[key].image:SetProperty("Rotate", entity:getRotationYaw() + rotateOffset + locationsTable[key].rotate)
    end
  else
    self:SetMapPos(locationsTable[key].image, pos, objectID == Me.objID, width)
    if text and locationsTable[key].text then
      locationsTable[key].textOffset = #text * 3
      locationsTable[key].text:SetArea({
        0,
        locationsTable[key].image:GetXPosition()[2] - locationsTable[key].textOffset
      }, {
        0,
        locationsTable[key].image:GetYPosition()[2] + 36
      }, {0, 100}, {0, 50})
    end
  end
end

function M:removeIcon(key)
  if locationsTable[key] then
    if locationsTable[key].image then
      self.m_mapimage:RemoveChildWindow1(locationsTable[key].image)
      GUIWindowManager.instance:DestroyGUIWindow(locationsTable[key].image)
    end
    if locationsTable[key].text then
      self.m_mapimage:RemoveChildWindow1(locationsTable[key].text)
      GUIWindowManager.instance:DestroyGUIWindow(locationsTable[key].text)
    end
    locationsTable[key] = nil
  end
end

return M
