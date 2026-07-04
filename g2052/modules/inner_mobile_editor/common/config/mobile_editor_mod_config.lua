local class = require("common.3rd.middleclass.middleclass")
local MobileEditorModConfig = class("MobileEditorModConfig")

function MobileEditorModConfig:initialize()
  Lib.logDebug("MobileEditorModConfig:initialize")
  self.settings = {}
  self:load()
end

function MobileEditorModConfig:load()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/mobile_editor_mod.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id)
    data.type = tonumber(vConfig.n_type)
    data.icon = tostring(vConfig.s_icon)
    data.name = tostring(vConfig.s_name)
    data.cfgName = tostring(vConfig.s_cfg_name)
    table.insert(self.settings, data)
  end
end

function MobileEditorModConfig:getConfig(id)
  for _, data in ipairs(self.settings) do
    if data.id == id then
      return data
    end
  end
  return nil
end

function MobileEditorModConfig:getConfigs()
  return self.settings
end

return MobileEditorModConfig
