local HalloweenGhostConfig = T(Config, "HalloweenGhostConfig")
local settings = {}

function HalloweenGhostConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/halloween_ghost.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      type = tonumber(vConfig.n_type) or 0,
      pos = self:parsePosInfo(vConfig.s_pos or ""),
      cfgName = vConfig.s_cfgName or ""
    }
    settings[data.id] = data
  end
end

function HalloweenGhostConfig:parseTransform(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", ",")
  local x = tonumber(samplesStr[1]) or 0
  local y = tonumber(samplesStr[2]) or 0
  local z = tonumber(samplesStr[3]) or 0
  return Vector3.new(x, y, z)
end

function HalloweenGhostConfig:parsePosInfo(dataStr)
  local samplesStr = Lib.splitString(dataStr or "", "#")
  local result = {}
  result.position = self:parseTransform(samplesStr[1] or "")
  result.rotation = self:parseTransform(samplesStr[2] or "")
  return result
end

function HalloweenGhostConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgHalloweenGhostConfig, id:", id)
    return
  end
  return settings[id]
end

function HalloweenGhostConfig:getAllCfgs()
  return settings
end

HalloweenGhostConfig:init()
return HalloweenGhostConfig
