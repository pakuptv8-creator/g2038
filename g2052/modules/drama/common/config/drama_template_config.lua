local DramaTemplateConfig = T(Config, "DramaTemplateConfig")
local settings = {}

function DramaTemplateConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/drama_template.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      remarks = vConfig.s_remarks or "",
      templateName = vConfig.s_templateName or "",
      templateDesc = vConfig.s_templateDesc or "",
      img = vConfig.s_img or "",
      smallImg = vConfig.s_smallImg or "",
      mutex = vConfig.s_mutex or "",
      isCustom = tonumber(vConfig.n_isCustom) or 0,
      isEmpty = tonumber(vConfig.n_isEmpty) or 0,
      adornPart = vConfig.s_adornPart ~= "" and vConfig.s_adornPart,
      weather = tonumber(vConfig.n_weather) or 0,
      openFog = tonumber(vConfig.n_openFog) or 0,
      priority = tonumber(vConfig.n_priority) or 0
    }
    data.mutexList = Lib.splitString(data.mutex, "#", true)
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return a.sortId < b.sortId
  end)
end

function DramaTemplateConfig:getCfgById(id)
  for _, v in pairs(settings) do
    if v.id == id then
      return Lib.copy(v)
    end
  end
  return
end

function DramaTemplateConfig:getAllCfgs(wipeEmptyTemplate, wipeCustomTemplate, wipeIdList)
  local result = {}
  for _, v in pairs(settings) do
    if (v.isEmpty == 0 or not wipeEmptyTemplate) and (v.isCustom == 0 or not wipeCustomTemplate) then
      local wipe = false
      if wipeIdList then
        for i, id in pairs(wipeIdList) do
          if id == v.id and v.isEmpty == 0 then
            wipe = true
            break
          end
        end
      end
      if not wipe then
        table.insert(result, v)
      end
    end
  end
  return result
end

function DramaTemplateConfig:isEmptyTemplate(id)
  local cfg = self:getCfgById(id)
  if cfg then
    return cfg.isEmpty ~= 0
  end
  return false
end

DramaTemplateConfig:init()
return DramaTemplateConfig
