local PrivilegeConfig = T(Config, "PrivilegeConfig")
local settings = {}

function PrivilegeConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/privilege.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      sort = tonumber(vConfig.n_sort) or 0,
      type = tonumber(vConfig.n_type) or 0,
      name = vConfig.s_name or "",
      icon = vConfig.s_icon or "",
      bgImg = vConfig.s_bgImg or "",
      dec = Lib.splitString(vConfig.s_dec or "", "#"),
      currency = tonumber(vConfig.n_currency) or 0,
      price = tonumber(vConfig.n_price) or 0,
      initPrice = tonumber(vConfig.n_initPrice) or 0,
      percent = tonumber(vConfig.n_percent) or 0
    }
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return a.sort < b.sort
  end)
end

function PrivilegeConfig:getCfgById(id)
  for _, v in pairs(settings) do
    if v.id == id then
      return Lib.copy(v)
    end
  end
  return
end

function PrivilegeConfig:getAllCfgs()
  return Lib.copy(settings)
end

function PrivilegeConfig:getCfgByType(type)
  for _, v in pairs(settings) do
    if v.type == type then
      return Lib.copy(v)
    end
  end
  return
end

PrivilegeConfig:init()
return PrivilegeConfig
