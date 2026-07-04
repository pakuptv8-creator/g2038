local PropsAttrConfig = T(Config, "PropsAttrConfig")
local settings = {}

function PropsAttrConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/props_attr.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      name = vConfig.s_name or "",
      isBombInteract = tonumber(vConfig.n_isBombInteract) or 0,
      canIgnite = tonumber(vConfig.n_canIgnite) or 0,
      isPublicCrime = tonumber(vConfig.n_isPublicCrime) or 0
    }
    settings[data.name] = data
  end
end

function PropsAttrConfig:isBombInteract(partName)
  if not settings[partName] then
    return false
  end
  return settings[partName].isBombInteract == 1
end

function PropsAttrConfig:isPropsCanIgnite(partName)
  if not settings[partName] then
    return false
  end
  return settings[partName].canIgnite == 1
end

function PropsAttrConfig:isPublicCrimeWhenDestroy(partName)
  if not settings[partName] then
    return false
  end
  return settings[partName].isPublicCrime == 1
end

PropsAttrConfig:init()
return PropsAttrConfig
