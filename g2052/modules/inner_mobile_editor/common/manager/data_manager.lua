local DataManager = T(MobileEditor, "DataManager")
local GameManager = T(MobileEditor, "GameManager")
local IInstance = require("common.engine.engine_instance")
local util = require("common.util.util")

local function checkAllChildren(self, children)
  for _, v in pairs(children or {}) do
    if v.class == "Model" or v.class == "MeshPart" then
      self.modelNum = self.modelNum + 1
    else
      self.partsNum = self.partsNum + 1
    end
    if v.children then
      checkAllChildren(self, v.children)
    end
  end
end

function DataManager:initialize()
  Lib.logDebug("CameraManager:initialize")
  self:subscribeEvents()
end

function DataManager:finalize()
end

function DataManager:subscribeEvents()
  Lib.subscribeEvent(Event.EVENT_SAVE_MAP_CHANGE, function()
    local ModeManager = T(MobileEditor, "ModeManager")
    if not ModeManager:instance():isInEditorMode() then
      return
    end
    local blockId = ModeManager:instance():getBlockId()
    local filePath = string.format("map/%s/setting.json", blockId)
    local userEditorPath = string.format("map/%d_map/%s", Me.platformUserId, blockId)
    local obj = Lib.readGameJson(filePath)
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getCurScene()
    self.partsNum = 0
    self.modelNum = 0
    local configs = {}
    local count = scene:getRoot():getChildrenCount()
    for i = 1, count do
      local object = scene:getRoot():getChildAt(i - 1)
      if object and object:isValid() then
        local className = IInstance:getClassName(object)
        if className then
          local config = util:getAllChildrenAsTable(object)
          if config.properties and config.properties.needSync then
            config.properties.needSync = "false"
          end
          if config.properties and config.properties.id then
            config.properties.id = tostring(Instance:allocateId())
          end
          if className == "Model" or className == "MeshPart" then
            self.modelNum = self.modelNum + 1
          else
            self.partsNum = self.partsNum + 1
          end
          checkAllChildren(self, config.children)
          table.insert(configs, config)
        end
      end
    end
    obj.scene = configs
    local newCompletePath = Lib.combinePath(Root.Instance():getGamePath(), userEditorPath)
    if not Lib.fileExists(newCompletePath) then
      Lib.mkPath(newCompletePath)
    end
    local newFilePath = Lib.combinePath(userEditorPath, "setting.json")
    Lib.saveGameJson(newFilePath, obj)
    self:saveEditRecord(self.partsNum, self.modelNum)
    Lib.emitEvent(Event.EVENT_SAVE_MAP_FINISH)
  end)
end

function DataManager:getMapJsonData()
  local ModeManager = T(MobileEditor, "ModeManager")
  local filePath = string.format("map/%d_map/%s/setting.json", Me.platformUserId, ModeManager:instance():getBlockId())
  local obj = Lib.readGameJson(filePath)
  if obj then
    local mapJson = Lib.toJson(obj)
    local data = {
      mapName = string.format("%d_map/%s", Me.platformUserId, ModeManager:instance():getBlockId()),
      mapJson = mapJson
    }
    return data
  end
end

function DataManager:compressMapJson(blockId)
  local ModeManager = T(MobileEditor, "ModeManager")
  local defaultAttrPath = string.format("modules/inner_mobile_editor/default_attr_part.json")
  local defaultAttr = Lib.readGameJson(defaultAttrPath)
  local id = blockId or ModeManager:instance():getBlockId()
  local filePath = string.format("map/%d_map/%s/setting.json", Me.platformUserId, id)
  local obj = Lib.readGameJson(filePath)
  if not obj then
    Lib.logWarning("not find map setting !!!!!!!!!!  blockId: ", id)
    return
  end
  
  local function compressAttr(part)
    if not part then
      return
    end
    for key, val in pairs(part.properties) do
      local defVal = defaultAttr[key]
      if defVal and defVal == val then
        part.properties[key] = nil
      end
    end
  end
  
  local function doCompare(part)
    compressAttr(part)
    if part.children then
      for i = 1, #part.children do
        local child = part.children[i]
        if i == #part.children then
          return doCompare(child)
        else
          doCompare(child)
        end
      end
    end
  end
  
  for _, part in ipairs(obj.scene) do
    doCompare(part)
  end
  Lib.saveGameJson(filePath, obj)
end

function DataManager:saveEditRecord(partsNum, modelNum)
  local dir = Root.Instance():getGamePath() .. "editRecord"
  Lib.mkPath(dir)
  local path = dir .. "/changed.json"
  local data = {parts_number = partsNum, model_number = modelNum}
  util:saveFile(path, data)
end

return DataManager
