local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
local settings = {}

function LimitedTimeActivityConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_activity.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_activity.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      type = tonumber(vConfig.n_type) or 0,
      key = tonumber(vConfig.n_type) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      startTime = Lib.splitString(vConfig.s_startTime or "", "-", true),
      endTime = Lib.splitString(vConfig.s_endTime or "", "-", true),
      updateTime = Lib.splitString(vConfig.s_updateTime or "", "-", true),
      commonWnd = tonumber(vConfig.n_commonWnd) or 0,
      tabName = vConfig.s_tabName,
      tabJson = vConfig.s_tabJson,
      tabBgRes = vConfig.s_tabBgRes,
      TextColorLeftTop = vConfig.s_textColorLeftTop,
      TextColorRightTop = vConfig.s_textColorRightTop,
      TextColorLeftBottom = vConfig.s_textColorLeftBottom,
      TextColorRightBottom = vConfig.s_textColorRightBottom
    }
    settings[data.id] = data
  end
end

function LimitedTimeActivityConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeActivityConfig, id:", id)
    return
  end
  return Lib.copy(settings[id])
end

function LimitedTimeActivityConfig:getAllCfgs()
  return Lib.copy(settings)
end

function LimitedTimeActivityConfig:getSameGroupByCommonWnd(commonWnd)
  local data = {}
  for _, v in pairs(settings) do
    if v.commonWnd == commonWnd then
      table.insert(data, v)
    end
  end
  table.sort(data, function(a, b)
    return a.sortId < b.sortId
  end)
  return data
end

function LimitedTimeActivityConfig:rewriteCfg(tbData)
  if not tbData or type(tbData) ~= "table" then
    return
  end
  local path = Root.Instance():getGamePath() .. "config/commercialize/limited_time_activity.csv"
  local _data, header = Lib.read_csv_file(path)
  for index, v in pairs(Lib.copy(_data)) do
    if v.n_type == tostring(tbData.n_type) then
      for key, v in pairs(tbData) do
        _data[index][key] = v
      end
      break
    end
  end
  local data = {
    items = _data or {},
    header = header
  }
  Lib.write_csv(path, data)
  self:init()
end

LimitedTimeActivityConfig:init()
return LimitedTimeActivityConfig
