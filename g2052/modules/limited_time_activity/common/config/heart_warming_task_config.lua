local HeartWarmingTaskConfig = T(Config, "HeartWarmingTaskConfig")
local settings = {}
local activityCfg = {}

function HeartWarmingTaskConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/heart_warming_task.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      taskId = tonumber(vConfig.n_taskId) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      taskType = tonumber(vConfig.n_taskType) or 1,
      targetNum = tonumber(vConfig.n_targetNum) or 1,
      isAccumulative = tonumber(vConfig.n_isAccumulative) or 0,
      taskDay = tonumber(vConfig.n_taskDay) or 1,
      rewardNum = tonumber(vConfig.n_rewardNum) or 0,
      taskTitle = vConfig.s_taskTitle or "",
      taskDesc = vConfig.s_taskDesc or ""
    }
    settings[data.taskId] = data
    if not activityCfg[data.activityId] then
      activityCfg[data.activityId] = {}
    end
    table.insert(activityCfg[data.activityId], data)
  end
end

function HeartWarmingTaskConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgHeartWarmingTaskConfig, id:", id)
    return
  end
  return settings[id]
end

function HeartWarmingTaskConfig:getAllCfgs()
  return settings
end

function HeartWarmingTaskConfig:getCfgByActivityId(activityId)
  return Lib.copy(activityCfg[activityId] or {})
end

function HeartWarmingTaskConfig:getCfgByActivityIdAndDay(activityId, day)
  local activityTask = self:getCfgByActivityId(activityId)
  local result = {}
  for key, info in pairs(activityTask) do
    if info.taskDay == day then
      table.insert(result, info)
    end
  end
  return result
end

HeartWarmingTaskConfig:init()
return HeartWarmingTaskConfig
