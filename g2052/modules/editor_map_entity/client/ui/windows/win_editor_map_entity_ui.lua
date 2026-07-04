local WinEditor_map_entity_ui = M
require("lfs")
local cjson = require("cjson")

function WinEditor_map_entity_ui:init()
  WinBase.init(self, "editor_map_entity_ui.json")
  self.sceneObjItemList = {}
  self:initUI()
  self:initEvent()
  self:root():SetLevel(0)
end

function WinEditor_map_entity_ui:initUI()
  self.lytEditorMapEntityUiEntityListLyt = self:child("editor_map_entity_ui_entity_list_lyt")
  self.lytSceneObjList = self:child("editor_map_entity_ui_scene_obj_list")
  self.lytSceneInfo = self:child("editor_map_entity_ui_scene_obj_linfo")
  self.btnSave = self:child("editor_map_entity_ui-save")
  self.btnClose = self:child("editor_map_entity_ui-close")
  self.btnDelete = self:child("editor_map_entity_ui-Delect")
  self.btnDelete:SetLevel(0)
  self.btnAdd = self:child("editor_map_entity_ui-add")
  self.editNewSceneName = self:child("editor_map_entity_ui-newScene")
  self.sceneObjGridView = UIMgr:new_widget("grid_view")
  self.sceneObjGridView:invoke("INIT_CONFIG", 0, 10, 1)
  self.sceneObjGridView:invoke("MOVE_ABLE", true)
  self.sceneObjGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytSceneObjList:AddChildWindow(self.sceneObjGridView)
  self.sceneInfoGridView = UIMgr:new_widget("grid_view")
  self.sceneInfoGridView:invoke("INIT_CONFIG", 0, 10, 1)
  self.sceneInfoGridView:invoke("MOVE_ABLE", true)
  self.sceneInfoGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.sceneInfoGridView:SetLevel(99)
  self.lytSceneInfo:AddChildWindow(self.sceneInfoGridView)
end

function WinEditor_map_entity_ui:initEvent()
  self:subscribe(self.btnSave, UIEvent.EventButtonClick, function()
    self:save()
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnDelete, UIEvent.EventButtonClick, function()
    self:delete()
  end)
  self:subscribe(self.btnAdd, UIEvent.EventButtonClick, function()
    self:add()
  end)
end

function WinEditor_map_entity_ui:subscribeEvent()
end

function WinEditor_map_entity_ui:getEntityCfgList()
  local path = Root.Instance():getGamePath() .. "plugin/myplugin/entity"
  local fileList = {}
  for file in lfs.dir(path) do
    if file ~= "." and file ~= ".." then
      local f = path .. "/" .. file
      local attr = lfs.attributes(f)
      if attr.mode == "directory" then
        table.insert(fileList, file)
      else
      end
    end
  end
  return fileList
end

function WinEditor_map_entity_ui:getSceneUIList()
  return Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUI")
end

function WinEditor_map_entity_ui:updateSceneObjList()
  self.sceneObjGridView:invoke("INIT_CONFIG", 0, 10, 1)
  self.sceneObjGridView:SetAutoColumnCount(false)
  local sceneUIList = self:getSceneUIList() or {}
  local childCount = #self.sceneObjItemList
  for i, ui in ipairs(sceneUIList) do
    local node
    local uiParams = ui:root():data("sceneUIParams")
    local key = uiParams.key
    if i > childCount then
      node = UIMgr:new_widget("editor_scene_obj")
      self.sceneObjGridView:AddItem(node)
      self.sceneObjItemList[i] = node
    else
      node = self.sceneObjItemList[i]
    end
    local item = node:get()
    item:setText(key)
    item:clickCallBack(ui, function(cui)
      self:updateSceneInfo(cui)
      self:updateSceneObjList()
    end)
    item:selected(ui == self.select_ui)
  end
  for i = #sceneUIList + 1, childCount do
    local node = self.sceneObjItemList[i]
    self.sceneObjGridView:RemoveItem(node)
  end
end

function WinEditor_map_entity_ui:updateSceneInfoParams()
  local paramsCell = UIMgr:new_widget("editorMapUIParams")
  self.sceneInfoGridView:AddItem(paramsCell)
  paramsCell:get():setData(self.select_ui)
  paramsCell:get():valueUpdate(function(value)
    self:updateSceneUI()
  end)
end

function WinEditor_map_entity_ui:updateSceneUIInfo()
  local uiParams = self.select_ui:root():data("sceneUIParams")
  local sceneKey = uiParams.sceneKey
  local key = uiParams.key
  local width = uiParams.width
  local sceneRatio = uiParams.sceneRatio
  local height = uiParams.height
  local rotate = uiParams.rotate
  local position = uiParams.position
  local uiCfg = Plugins.CallTargetPluginFunc("scene_ui", "getSceneUICfg", key)
  local viewDistance = uiCfg.viewDistance
  local uiName = uiCfg.uiName
  local nameCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(nameCell)
  nameCell:get():setData("\229\144\141\231\167\176", key)
  nameCell:get():valueUpdate(function(value)
    uiCfg.key = key
    self:updateSceneUI()
  end)
  local isSaveCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(isSaveCell)
  isSaveCell:get():setData("\229\173\152\229\130\168\229\136\176\229\156\176\229\155\190", true)
  isSaveCell:get():valueUpdate(function(value)
    uiCfg.needSave = Lib.toBool(value)
    if uiCfg.needSave then
      local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
      for i, _uiCfg in ipairs(uiCfgList) do
        if _uiCfg.key == key then
          return
        end
      end
      table.insert(uiCfgList, uiCfg)
    else
      local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
      for i, _uiCfg in ipairs(uiCfgList) do
        if _uiCfg.key == key then
          table.remove(uiCfgList, i)
          break
        end
      end
    end
    self:updateSceneUI()
  end)
  local positionCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(positionCell)
  positionCell:get():setData("\229\157\144\230\160\135", position.x .. "," .. position.y .. "," .. position.z)
  positionCell:get():valueUpdate(function(value)
    uiCfg.position = Lib.strToV3(value)
    self:updateSceneUI()
  end)
  positionCell:get():keyDoubleCLick(function()
    local troPosition = uiCfg.position
    Me:setPosition(troPosition)
  end)
  local rotateCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(rotateCell)
  rotateCell:get():setData("\230\151\139\232\189\172", rotate.x .. "," .. rotate.y .. "," .. rotate.z)
  rotateCell:get():valueUpdate(function(value)
    uiCfg.rotate = Lib.strToV3(value)
    self:updateSceneUI()
  end)
  local widthCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(widthCell)
  widthCell:get():setData("\229\174\189\229\186\166", width)
  widthCell:get():valueUpdate(function(value)
    uiCfg.width = value
    self:updateSceneUI()
  end)
  local sceneRatioCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(sceneRatioCell)
  sceneRatioCell:get():setData("\229\174\189\233\171\152\230\175\148", sceneRatio)
  sceneRatioCell:get():valueUpdate(function(value)
    uiCfg.sceneRatio = value
    self:updateSceneUI()
  end)
  local uiCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(uiCell)
  uiCell:get():setData("UI", uiName)
  uiCell:get():valueUpdate(function(value)
    uiCfg.uiName = value
    self:updateSceneUI()
  end)
  local viewDistanceCell = UIMgr:new_widget("editor_map_info_cell")
  self.sceneInfoGridView:AddItem(viewDistanceCell)
  viewDistanceCell:get():setData("\232\167\134\232\183\157", viewDistance)
  viewDistanceCell:get():valueUpdate(function(value)
    uiCfg.viewDistance = value
    self:updateSceneUI()
  end)
  self:updateSceneInfoParams()
end

function WinEditor_map_entity_ui:updateSceneUI()
  local uiParams = self.select_ui:root():data("sceneUIParams")
  local key = uiParams.key
  local uiCfg = Plugins.CallTargetPluginFunc("scene_ui", "getSceneUICfg", key)
  Plugins.CallTargetPluginFunc("scene_ui", "updateSceneUI", self.select_ui, uiCfg)
end

function WinEditor_map_entity_ui:updateSceneInfo(cui)
  self.select_ui = cui
  self.sceneInfoGridView:RemoveAllItems()
  self.sceneInfoGridView:SetAutoColumnCount(false)
  self:updateSceneUIInfo()
end

function WinEditor_map_entity_ui:delete()
  if self.select_ui then
    local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
    local uiParams = self.select_ui:root():data("sceneUIParams")
    local key = uiParams.key
    local ui_name = uiParams.ui_name
    for i, uiCfg in ipairs(uiCfgList) do
      if uiCfg.key == key then
        table.remove(uiCfgList, i)
        break
      end
    end
    Plugins.CallTargetPluginFunc("scene_ui", "closeMapSceneUI", self.select_ui, ui_name)
    self:updateSceneObjList()
  end
end

function WinEditor_map_entity_ui:add()
  local uiName = self.editNewSceneName:GetPropertyString("Text", "")
  local default = {
    width = 15,
    viewDistance = 50,
    uiName = uiName,
    rotate = {
      x = 0,
      y = 0,
      z = 0
    },
    position = {
      x = 0,
      y = 0,
      z = 0
    },
    key = "newSceneUI",
    needSave = true
  }
  local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
  table.insert(uiCfgList, default)
  Plugins.CallTargetPluginFunc("scene_ui", "createSceneUI", default)
end

local function loadjson(filename)
  local file = io.open(filename, "r")
  if not file then
    print("\230\150\135\228\187\182\228\184\141\229\173\152\229\156\168", filename)
    return
  end
  local content = file:read("*a")
  file:close()
  return cjson.decode(content)
end

local function comp(s1, s2)
  if s2 == "cfg" then
    return false
  elseif s1 == "cfg" then
    return true
  else
    if s1 == "x" or s1 == "y" or s1 == "z" then
      return s1 < s2
    end
    return s2 < s1
  end
  return true
end

local function savejson(fileData, filename)
  local file = io.open(filename, "w+")
  file:write(Lib.toJson(fileData, function(s1, s2)
    return comp(s1, s2)
  end))
  file:close()
end

function WinEditor_map_entity_ui:_saveSceneUI(jsonData)
  local sceneUI = self:getSceneUIList()
  local jsonSceneUI = jsonData.sceneUI
  local uiCfgList = Plugins.CallTargetPluginFunc("scene_ui", "getAllSceneUICfg")
  jsonData.sceneUI = uiCfgList
end

function WinEditor_map_entity_ui:save()
  local mapName = World.CurMap.name
  local path = Root.Instance():getGamePath() .. "map/" .. mapName .. "/setting.json"
  local jsonData = loadjson(path)
  self:_saveSceneUI(jsonData)
  savejson(jsonData, path)
end

function WinEditor_map_entity_ui:initView()
  local fileList = self:getEntityCfgList()
  self:updateSceneObjList()
end

function WinEditor_map_entity_ui:onHide()
  UI:closeWnd("editor_map_entity_ui")
end

function WinEditor_map_entity_ui:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("editor_map_entity_ui")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinEditor_map_entity_ui:onOpen()
  self._allEvent = {}
  self:initView()
  self:subscribeEvent()
end

function WinEditor_map_entity_ui:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinEditor_map_entity_ui
