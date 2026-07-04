local InteractEventConfig = T(Config, "InteractEventConfig")
local cjson = require("cjson")
local settings = {}
local triggersType = {
  [2] = "PART_TOUCH_ENTITY_BEGIN",
  [3] = "PART_TOUCH_ENTITY_END",
  [5] = "PART_TOUCH_PART_BEGIN",
  [6] = "PART_TOUCH_PART_END",
  [8] = "ENTER_SCENE"
}

function InteractEventConfig:init()
  local csvData = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/interact_events.csv", 2)
  for _, vConfig in pairs(csvData) do
    local data = {
      key = vConfig.s_key or "",
      func = vConfig.s_func or "",
      sync = vConfig.s_sync or "",
      timeTriggerData = Lib.splitString(vConfig.s_timeTriggerData or "", "#"),
      isNeedCheckObstacle = tonumber(vConfig.n_isNeedCheckObstacle) or 0,
      delay = tonumber(vConfig.n_delay),
      triggerSound = vConfig.s_triggerSound ~= "" and vConfig.s_triggerSound,
      breakSound = vConfig.s_breakSound ~= "" and vConfig.s_breakSound,
      clickTipEffect = vConfig.s_clickTipEffect ~= "" and vConfig.s_clickTipEffect,
      clickTipOffset = Lib.createV3ByString(vConfig.s_clickTipOffset or ""),
      eventReport = tonumber(vConfig.i_eventReport) or 0
    }
    local params = {}
    for k, v in pairs(vConfig) do
      local res = string.gsub(k, "^s_p(%d+)$", function(s)
        local index = tonumber(s)
        params[index] = v
        return ""
      end)
    end
    data.params = params
    data.startTimeList = {}
    data.closeTimeList = {}
    for _, timeData1 in pairs(data.timeTriggerData) do
      local timeData2 = Lib.splitString(timeData1, "$")
      local temp = Lib.splitString(timeData2[1], ":", true)
      if tonumber(timeData2[2]) == 1 then
        table.insert(data.startTimeList, temp)
      else
        table.insert(data.closeTimeList, temp)
      end
    end
    if vConfig.s_nextInteract and vConfig.s_nextInteract ~= "" then
      data.nextInteract = Lib.splitString(vConfig.s_nextInteract, "#")
      data.nextInteract[1] = tonumber(data.nextInteract[1]) or 0
      data.nextInteract[3] = tonumber(data.nextInteract[3]) or 0
    end
    if vConfig.s_bindRelation and vConfig.s_bindRelation ~= "" then
      data.bindRelation = Lib.splitString(vConfig.s_bindRelation, "#")
    end
    if vConfig.s_controlCascade and vConfig.s_controlCascade ~= "" then
      data.controlCascade = Lib.splitString(vConfig.s_controlCascade, "#")
    end
    if vConfig.s_controlBeCascade and vConfig.s_controlBeCascade ~= "" then
      data.controlBeCascade = Lib.splitString(vConfig.s_controlBeCascade, "#")
    end
    local isTimeTrigger = false
    if vConfig.s_triggers and vConfig.s_triggers ~= "" then
      local triggers = Lib.splitString(vConfig.s_triggers, "#")
      for _, v in pairs(triggers or {}) do
        if tonumber(v) == 1 then
          data.canClicked = true
        else
          if not data.triggers then
            data.triggers = {}
          end
          table.insert(data.triggers, triggersType[tonumber(v)])
        end
        if not data.triggersData then
          data.triggersData = {}
        end
        if v then
          table.insert(data.triggersData, tonumber(v))
        end
        if tonumber(v) == Define.PART_INTERACT_TYPE.GAME_TIME then
          isTimeTrigger = true
        end
      end
    end
    data.isTimeTrigger = isTimeTrigger
    if vConfig.s_counterKey and vConfig.s_counterKey ~= "" then
      data.counterLimit = {
        key = vConfig.s_counterKey,
        type = vConfig.s_counterType,
        counterMax = vConfig.n_counterMax and tonumber(vConfig.n_counterMax) or nil,
        counterMin = vConfig.n_counterMin and tonumber(vConfig.n_counterMin) or nil
      }
    end
    if vConfig.s_condition1 and vConfig.s_condition1 ~= "" then
      data.conditions = {
        cjson.decode(vConfig.s_condition1)
      }
    end
    if vConfig.s_invalidCallback and vConfig.s_invalidCallback ~= "" then
      data.invalidCallback = {
        vConfig.s_invalidCallback
      }
    end
    if vConfig.s_entityTargets and vConfig.s_entityTargets ~= "" then
      data.entityTargets = {}
      local targets = Lib.split(vConfig.s_entityTargets, ",")
      for i, entityFullName in ipairs(targets) do
        data.entityTargets[entityFullName] = true
      end
    end
    if vConfig.s_executionCallback and vConfig.s_executionCallback ~= "" then
      data.executionCallback = Lib.split(vConfig.s_executionCallback, ",")
    end
    if vConfig.s_precondition and vConfig.s_precondition ~= "" then
      local preconditionArr = Lib.splitString(vConfig.s_precondition, "#")
      local paramArr = Lib.splitString(preconditionArr[2] or "", ",")
      local condition = {
        index = tonumber(preconditionArr[1]),
        paramArr = paramArr
      }
      data.precondition = condition
    end
    if vConfig.s_interactPopIcon and vConfig.s_interactPopIcon ~= "" then
      data.interactPopIcon = vConfig.s_interactPopIcon
    end
    if vConfig.s_interactPopOffset and vConfig.s_interactPopOffset ~= "" then
      local interactPopOffset = Lib.splitString(vConfig.s_interactPopOffset, ",")
      data.interactPopOffset = Lib.v3(interactPopOffset[1] or 0, interactPopOffset[2] or 0, interactPopOffset[3] or 0)
    else
      data.interactPopOffset = Lib.v3(0, 0, 0)
    end
    settings[data.key] = data
  end
end

function InteractEventConfig:rewriteCfg(tbData)
  local path = Root.Instance():getGamePath() .. "config/interact_events.csv"
  local _data, header = Lib.read_csv_file(path)
  local newData = {}
  for index, v in pairs(Lib.copy(_data)) do
    if v.s_key == tbData.s_key and v.s_func == tbData.s_func then
      _data[index].s_key = tbData.s_key
      _data[index].s_func = tbData.s_func
      _data[index].s_triggers = tbData.s_triggers
      _data[index].s_sync = tbData.s_sync
      _data[index].s_clickTipEffect = tbData.s_clickTipEffect
      _data[index].s_clickTipOffset = tbData.s_clickTipOffset
      _data[index].s_p1 = tbData.s_p1
      _data[index].s_p2 = tbData.s_p2
      _data[index].s_p3 = tbData.s_p3
      _data[index].s_p4 = tbData.s_p4
      _data[index].s_p5 = tbData.s_p5
      _data[index].s_p6 = tbData.s_p6
      _data[index].s_p7 = tbData.s_p7
      _data[index].s_p8 = tbData.s_p8
      goto lbl_89
    end
  end
  for index, key in pairs(header) do
    if tbData[key] then
      newData[key] = tbData[key]
    else
      newData[key] = ""
    end
  end
  _data[#_data + 1] = newData
  ::lbl_89::
  local data = {
    items = _data or {},
    header = header
  }
  Lib.write_csv(path, data)
  InteractEventConfig:init()
end

function InteractEventConfig:getCfgById(id)
  if not settings[id] then
    return
  end
  return settings[id]
end

function InteractEventConfig:getAllCfgs()
  return settings
end

function InteractEventConfig:isCascadeRelation(name, upName)
  if not settings[name] then
    return false
  end
  if not settings[name].controlBeCascade then
    return false
  end
  if not settings[upName] then
    return false
  end
  if not settings[upName].controlCascade then
    return false
  end
  local beCascade = false
  for _, pName in pairs(settings[name].controlBeCascade) do
    if pName == upName then
      beCascade = true
    end
  end
  local cascade = false
  for _, cName in pairs(settings[upName].controlCascade) do
    if cName == name then
      cascade = true
    end
  end
  return cascade and beCascade
end

function InteractEventConfig:verifyInteractType(key, type)
  for _, v in pairs(settings) do
    if v.key == key then
      for _, triggerType in pairs(v.triggersData or {}) do
        if triggerType == type then
          return true
        end
      end
    end
  end
  return false
end

function InteractEventConfig:verifyClickInteractTip(key, type)
  for _, v in pairs(settings) do
    if v.key == key and v.clickTipEffect then
      for _, triggerType in pairs(v.triggersData or {}) do
        if triggerType == type then
          return true
        end
      end
    end
  end
  return false
end

InteractEventConfig:init()
