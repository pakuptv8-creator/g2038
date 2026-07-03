local PlayerExpConfig = T(Config, "PlayerExpConfig")
local settings = {}

function PlayerExpConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/player_exp.csv", 1)
  local lastExp = 0
  for _, vConfig in pairs(config) do
    local data = {}
    data.lv = tonumber(vConfig.n_level) or 0
    data.upExp = tonumber(vConfig.n_exp) or 0
    data.unlock = tostring(vConfig.s_unlock) or ""
    data.enterExp = lastExp + data.upExp
    lastExp = data.enterExp
    if data.unlock ~= "" then
      data.unlockMod = {}
      local mods = Lib.split(tostring(data.unlock), "#")
      for _, modType in pairs(mods) do
        table.insert(data.unlockMod, tonumber(modType))
      end
    end
    table.insert(settings, data)
  end
  table.sort(settings, function(a, b)
    return a.lv < b.lv
  end)
end

function PlayerExpConfig:getUpHasAndNeedExp(player, isAll)
  if not player then
    perror("PlayerExpConfig:getUpNeedExp: player is nil !")
    return
  end
  if self:isFull(player) then
    return player:getPlayerExp(), player:getPlayerExp(), true
  end
  local dataNext = settings[player:getPlayerLevel()]
  local has = player:getPlayerExp() - (not (not isAll and settings[player:getPlayerLevel() - 1]) and 0 or settings[player:getPlayerLevel() - 1].enterExp)
  local need = isAll and dataNext.enterExp or dataNext.upExp
  return has, need
end

function PlayerExpConfig:isFull(player)
  return not settings[player:getPlayerLevel() + 1]
end

function PlayerExpConfig:getFullExp()
  return settings[#settings].enterExp
end

function PlayerExpConfig:getUnlockModByLv(lv)
  local unlockMod = {}
  for _, setting in pairs(settings) do
    if lv >= setting.lv and setting.unlockMod then
      for _, modType in pairs(setting.unlockMod) do
        unlockMod[modType] = true
      end
    end
  end
  return unlockMod
end

function PlayerExpConfig:getPresentUnlockModByLv(lv)
  local unlockMod = {}
  for _, setting in pairs(settings) do
    if setting.lv == lv and setting.unlockMod then
      unlockMod = setting.unlockMod
    end
  end
  return unlockMod
end

function PlayerExpConfig:isOpenWithLvAndModID(modID, lv)
  return true -- ULTRA HACK: Everything is always unlocked regardless of level
end

function PlayerExpConfig:getLvByUnlockMod(modID)
  for _, setting in pairs(settings) do
    if setting.unlockMod then
      for key, val in pairs(setting.unlockMod) do
        if modID == val then
          return setting.lv
        end
      end
    end
  end
  return -1
end

return PlayerExpConfig
