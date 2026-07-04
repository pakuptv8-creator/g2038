local RegionEffectsConfig = T(Config, "RegionEffectsConfig")
local settings = {}

function RegionEffectsConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/regionEffects.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      partID = string.gsub(vConfig.s_partID or "", "#", "") or "",
      effectName = vConfig.s_effectName or "",
      yaw = tonumber(vConfig.n_yaw) or 0
    }
    local posArr = Lib.splitString(vConfig.s_pos or "", "#", true)
    data.pos = Lib.v3(posArr[1] or 0, posArr[2] or 0, posArr[3] or 0)
    local scaleArr = Lib.splitString(vConfig.s_scale or "", "#", true)
    data.scale = Lib.v3(scaleArr[1] or 1, scaleArr[2] or 1, scaleArr[3] or 1)
    local rotationArr = Lib.splitString(vConfig.s_rotation or "", "#", true)
    data.rotation = Lib.v3(rotationArr[1] or 0, rotationArr[2] or 0, rotationArr[3] or 0)
    settings[data.id] = data
  end
end

function RegionEffectsConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgRegionEffectsConfig, id:", id)
    return
  end
  return settings[id]
end

function RegionEffectsConfig:getCfgCount()
  return Lib.getTableSize(settings)
end

function RegionEffectsConfig:getCfgByPartId(partId)
  local tbData = {}
  for id, date in pairs(settings) do
    if date and tonumber(date.partID) == tonumber(partId) then
      table.insert(tbData, date)
    end
  end
  return tbData
end

function RegionEffectsConfig:getCfgByPos(pos)
  for id, date in pairs(settings) do
    if date and tonumber(date.pos.x) == tonumber(pos.x) and tonumber(date.pos.y) == tonumber(pos.y) and tonumber(date.pos.z) == tonumber(pos.z) then
      return date
    end
  end
  return nil
end

function RegionEffectsConfig:delCfgDate(id)
  local path = Root.Instance():getGamePath() .. "config/regionEffects.csv"
  local _data, header = Lib.read_csv_file(path)
  local newData = {}
  local pIndex = 0
  for index, v in pairs(Lib.copy(_data)) do
    if tonumber(v.n_id) then
      if tonumber(v.n_id) ~= tonumber(id) then
        pIndex = pIndex + 1
        if not newData[pIndex] then
          newData[pIndex] = {}
        end
        if tonumber(v.n_id) > tonumber(id) then
          newData[pIndex].n_id = tonumber(v.n_id) - 1
        else
          newData[pIndex].n_id = v.n_id
        end
        newData[pIndex].s_partID = v.s_partID
        newData[pIndex].s_effectName = v.s_effectName
        newData[pIndex].s_pos = v.s_pos
        newData[pIndex].s_scale = v.s_scale
        newData[pIndex].s_rotation = v.s_rotation
      end
    else
      pIndex = pIndex + 1
      if not newData[pIndex] then
        newData[pIndex] = {}
      end
      newData[pIndex] = v
    end
  end
  print("===========newData", Lib.v2s(newData))
  local data = {
    items = newData or {},
    header = header
  }
  Lib.write_csv(path, data)
  RegionEffectsConfig:init()
end

function RegionEffectsConfig:rewriteCfg(tbData)
  local path = Root.Instance():getGamePath() .. "config/regionEffects.csv"
  local _data, header = Lib.read_csv_file(path)
  local newData = {}
  local newIndex = 0
  for index, v in pairs(Lib.copy(_data)) do
    if tonumber(v.n_id) == tonumber(tbData.n_id) then
      _data[index].n_id = tbData.n_id
      _data[index].s_partID = tbData.s_partID
      _data[index].s_effectName = tbData.s_effectName
      _data[index].s_pos = tbData.s_pos
      _data[index].s_scale = tbData.s_scale
      _data[index].s_rotation = tbData.s_rotation
      goto lbl_66
    end
  end
  newIndex = #_data + 1
  for index, key in pairs(header) do
    if tbData[key] then
      newData[key] = tbData[key]
    else
      newData[key] = ""
    end
  end
  _data[newIndex] = newData
  ::lbl_66::
  local data = {
    items = _data or {},
    header = header
  }
  Lib.write_csv(path, data)
  RegionEffectsConfig:init()
end

function RegionEffectsConfig:getAllConfigs()
  return settings
end

RegionEffectsConfig:init()
return RegionEffectsConfig
