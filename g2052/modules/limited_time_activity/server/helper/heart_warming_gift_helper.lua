local base = require("server.helper.limited_time_activity_helper")
local HeartWarmingGiftHelper = Lib.class("HeartWarmingGiftHelper", base)
local HeartWarmingGiftConfig = T(Config, "HeartWarmingGiftConfig")
local HeartWarmingTaskConfig = T(Config, "HeartWarmingTaskConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function HeartWarmingGiftHelper:onNotStart()
end

function HeartWarmingGiftHelper:onStart()
end

function HeartWarmingGiftHelper:onEnd()
end

function HeartWarmingGiftHelper:initHeartWarmData(player)
  if not self.params then
    return
  end
  local heartWarmStart = player:getHeartWarmStart()
  if not heartWarmStart[self.params.id] then
    heartWarmStart[self.params.id] = {}
    heartWarmStart[self.params.id][1] = Lib.getDayStartTime(os.time())
    player:setHeartWarmStart(heartWarmStart)
  end
  local heartWarmTask = player:getHeartWarmTask()
  if not heartWarmTask[self.params.id] then
    heartWarmTask[self.params.id] = {}
    local activityTaskData = HeartWarmingTaskConfig:getCfgByActivityId(self.params.id)
    for _, val in pairs(activityTaskData) do
      heartWarmTask[self.params.id][val.taskId] = {}
      if val.taskDay == 1 then
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.START
      else
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.NOT_START
      end
      heartWarmTask[self.params.id][val.taskId].taskProgress = 0
    end
    player:setHeartWarmTask(heartWarmTask)
  end
end

function HeartWarmingGiftHelper:checkHeartWarmDayInfo(player)
  if not self.params then
    return
  end
  local heartWarmStart = player:getHeartWarmStart()
  local curTime = Lib.getDayStartTime(os.time())
  local passTime = curTime - heartWarmStart[self.params.id][1]
  local passDay = passTime / Lib.getDaySeconds()
  local isChanged = false
  if 2 <= passDay then
    if heartWarmStart[self.params.id][3] == nil then
      heartWarmStart[self.params.id][3] = curTime
      isChanged = true
    end
    if heartWarmStart[self.params.id][2] == nil then
      heartWarmStart[self.params.id][2] = curTime - Lib.getDaySeconds()
      isChanged = true
    end
  end
  if 1 <= passDay and heartWarmStart[self.params.id][2] == nil then
    heartWarmStart[self.params.id][2] = curTime
    isChanged = true
  end
  if isChanged then
    player:setHeartWarmStart(heartWarmStart)
  end
end

function HeartWarmingGiftHelper:updateDayTaskState(player)
  if not self.params then
    return
  end
  local heartWarmStart = player:getHeartWarmStart()
  local heartWarmTask = player:getHeartWarmTask()
  local isChanged = false
  local isFinish = false
  local activityTaskData = HeartWarmingTaskConfig:getCfgByActivityId(self.params.id)
  for _, val in pairs(activityTaskData) do
    if not heartWarmTask[self.params.id][val.taskId] then
      isChanged = true
      heartWarmTask[self.params.id][val.taskId] = {}
      if val.taskDay == 1 then
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.START
      else
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.NOT_START
      end
      heartWarmTask[self.params.id][val.taskId].taskProgress = 0
    end
    if heartWarmTask[self.params.id][val.taskId].taskState == Define.HEART_WARM_TASK_STATE.NOT_START and heartWarmStart[self.params.id][val.taskDay] then
      if heartWarmTask[self.params.id][val.taskId].taskProgress >= val.targetNum then
        if heartWarmTask[self.params.id][val.taskId].taskState ~= Define.HEART_WARM_TASK_STATE.END and heartWarmTask[self.params.id][val.taskId].taskState ~= Define.HEART_WARM_TASK_STATE.FINISH then
          heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.FINISH
          isFinish = true
          local reportData = {
            d3_task_id = val.taskId
          }
          Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_task_finish", reportData, player)
        end
      else
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.START
      end
      isChanged = true
    end
  end
  if isChanged then
    player:setHeartWarmTask(heartWarmTask)
    if isFinish then
      self:updateDayAllFinishTask(player)
    end
  end
end

function HeartWarmingGiftHelper:updateTaskProgress(player, taskType)
  if not self.params then
    return
  end
  local isChanged = false
  local isFinish = false
  local heartWarmStart = player:getHeartWarmStart()
  local heartWarmTask = player:getHeartWarmTask()
  local activityTaskData = HeartWarmingTaskConfig:getCfgByActivityId(self.params.id)
  for _, val in pairs(activityTaskData) do
    if not heartWarmTask[self.params.id][val.taskId] then
      isChanged = true
      heartWarmTask[self.params.id][val.taskId] = {}
      if val.taskDay == 1 then
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.START
      else
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.NOT_START
      end
      heartWarmTask[self.params.id][val.taskId].taskProgress = 0
    end
    if val.taskType == taskType and heartWarmTask[self.params.id][val.taskId].taskProgress < val.targetNum then
      if val.isAccumulative == 1 then
        heartWarmTask[self.params.id][val.taskId].taskProgress = heartWarmTask[self.params.id][val.taskId].taskProgress + 1
      elseif heartWarmStart[self.params.id][val.taskDay] then
        heartWarmTask[self.params.id][val.taskId].taskProgress = heartWarmTask[self.params.id][val.taskId].taskProgress + 1
      end
      if heartWarmTask[self.params.id][val.taskId].taskProgress >= val.targetNum and heartWarmStart[self.params.id][val.taskDay] and heartWarmTask[self.params.id][val.taskId].taskState ~= Define.HEART_WARM_TASK_STATE.END and heartWarmTask[self.params.id][val.taskId].taskState ~= Define.HEART_WARM_TASK_STATE.FINISH then
        heartWarmTask[self.params.id][val.taskId].taskState = Define.HEART_WARM_TASK_STATE.FINISH
        isFinish = true
        local reportData = {
          d3_task_id = val.taskId
        }
        Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_task_finish", reportData, player)
      end
      isChanged = true
    end
  end
  if isChanged then
    player:setHeartWarmTask(heartWarmTask)
    if isFinish then
      self:updateDayAllFinishTask(player)
    end
  end
end

function HeartWarmingGiftHelper:updateDayAllFinishTask(player)
  local heartWarmTask = player:getHeartWarmTask()
  local isChanged = false
  for taskDay = 1, 3 do
    local dayTaskData = HeartWarmingTaskConfig:getCfgByActivityIdAndDay(self.params.id, taskDay)
    local isAllFinish = true
    local allTaskId
    for _, val in pairs(dayTaskData) do
      if val.taskType ~= Define.HEART_WARM_TASK_TYPE.ALL_FINISH then
        if heartWarmTask[self.params.id][val.taskId].taskState == Define.HEART_WARM_TASK_STATE.NOT_START or heartWarmTask[self.params.id][val.taskId].taskState == Define.HEART_WARM_TASK_STATE.START then
          isAllFinish = false
        end
      else
        allTaskId = val.taskId
      end
    end
    if isAllFinish and allTaskId ~= nil and heartWarmTask[self.params.id][allTaskId].taskState ~= Define.HEART_WARM_TASK_STATE.END and heartWarmTask[self.params.id][allTaskId].taskState ~= Define.HEART_WARM_TASK_STATE.FINISH then
      isChanged = true
      heartWarmTask[self.params.id][allTaskId].taskState = Define.HEART_WARM_TASK_STATE.FINISH
      heartWarmTask[self.params.id][allTaskId].taskProgress = 1
      local reportData = {d3_task_id = allTaskId}
      Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_task_finish", reportData, player)
    end
  end
  if isChanged then
    player:setHeartWarmTask(heartWarmTask)
  end
end

function HeartWarmingGiftHelper:onUpdateDayTime()
  if not self.params then
    return
  end
  if self.curTime then
    local isSameDay = Lib.isSameDay(self.curTime, os.time())
    if not isSameDay then
      for _, player in pairs(Game.GetAllPlayers()) do
        self:checkHeartWarmDayInfo(player)
        self:updateDayTaskState(player)
      end
      self.curTime = os.time()
    end
  else
    self.curTime = os.time()
  end
end

function HeartWarmingGiftHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncHeartWarmGiftActivity",
      params = self.params,
      status = self.status,
      addition = addition
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncHeartWarmGiftActivity",
      params = self.params,
      status = self.status,
      addition = addition
    })
  end
end

function HeartWarmingGiftHelper:playActivity(player, params, buyInfo)
  if player.isHeartWarmingPlaying then
    return
  end
  local isSucceed = false
  if buyInfo.taskId ~= nil then
    local heartWarmTask = player:getHeartWarmTask()
    if heartWarmTask[self.params.id][buyInfo.taskId].taskState == Define.HEART_WARM_TASK_STATE.FINISH then
      heartWarmTask[self.params.id][buyInfo.taskId].taskState = Define.HEART_WARM_TASK_STATE.END
      player:setHeartWarmTask(heartWarmTask)
      local activityTaskData = HeartWarmingTaskConfig:getCfgById(buyInfo.taskId)
      local heartWarmIntegral = player:getHeartWarmIntegral()
      local curIntegral = heartWarmIntegral[self.params.id] or 0
      heartWarmIntegral[self.params.id] = curIntegral + activityTaskData.rewardNum
      player:setHeartWarmIntegral(heartWarmIntegral)
      isSucceed = true
    end
  elseif buyInfo.giftId ~= nil then
    local giftCfg = HeartWarmingGiftConfig:getCfgById(buyInfo.giftId)
    local heartWarmReward = player:getHeartWarmReward()
    if not heartWarmReward[giftCfg.giftKey] then
      heartWarmReward[giftCfg.giftKey] = true
      player:setHeartWarmReward(heartWarmReward)
      LimitedTimeActivityGameMgr:onBuySuccess(player, giftCfg)
      isSucceed = true
    end
  end
  player.isHeartWarmingPlaying = false
  local addition = {
    isSucceed = isSucceed,
    giftId = buyInfo.giftId,
    taskId = buyInfo.taskId
  }
  self:syncActivityInfo(player, "SCReceiveHeartWarmResult", addition)
end

return HeartWarmingGiftHelper
