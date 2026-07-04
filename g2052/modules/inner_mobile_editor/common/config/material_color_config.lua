local class = require("common.3rd.middleclass.middleclass")
local MaterialColorConfig = class("MaterialColorConfig")

function MaterialColorConfig:initialize()
  Lib.logDebug("MaterialColorConfig:initialize")
  self.settings = {}
  self:load()
end

function MaterialColorConfig:load()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/mobile_editor_material_color.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id)
    local str = Lib.splitString(tostring(vConfig.s_rgba), "#")
    local rgba = {
      r = str[1],
      g = str[2],
      b = str[3],
      a = str[4]
    }
    data.rgba = rgba
    table.insert(self.settings, data)
  end
end

function MaterialColorConfig:getConfig(index)
  for i, data in ipairs(self.settings) do
    if i == index then
      return data
    end
  end
  return nil
end

function MaterialColorConfig:getConfigs()
  return self.settings
end

return MaterialColorConfig
