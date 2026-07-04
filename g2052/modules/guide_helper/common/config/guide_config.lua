local GuideConfig = T(Config, "GuideConfig")
local settings = {}

function GuideConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/guide.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      uiName = vConfig.s_uiName or "",
      title = vConfig.s_title or "",
      newModule = tonumber(vConfig.n_newModule) == 1,
      imgs = Lib.splitString(vConfig.s_imgs or "", "#"),
      dec = Lib.splitString(vConfig.s_dec or "", "#")
    }
    data.info = {}
    for i, v in pairs(data.imgs) do
      table.insert(data.info, {
        img = v,
        text = data.dec[i] or ""
      })
    end
    settings[data.uiName] = data
  end
end

function GuideConfig:getCfgByUIName(uiName)
  if not settings[uiName] then
    Lib.logError("can not find cfgGuideConfig, uiName:", uiName)
    return
  end
  return settings[uiName]
end

function GuideConfig:getAllCfgs()
  return settings
end

GuideConfig:init()
return GuideConfig
