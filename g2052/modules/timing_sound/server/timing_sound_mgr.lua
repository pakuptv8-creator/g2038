local TimingSoundMgr = T(Lib, "TimingSoundMgr")
local TimingSoundConfig = T(Config, "TimingSoundConfig")
local soundDistance = World.cfg.soundDistance or {1, 20}

local function inspectionTime(info, hour, min)
  local needOperateSound = false
  local isPlay = true
  local type = Define.TIMING_TYPE.TRIGGER
  for i, v in pairs(info or {}) do
    local times = Lib.splitString(v, ",")
    for z, time in pairs(times) do
      isPlay = z == 1 and true or false
      local time = Lib.splitString(time, ":", true)
      if time[1] == hour and time[2] == min then
        needOperateSound = true
        type = #times
        break
      end
    end
    if needOperateSound then
      break
    end
  end
  return needOperateSound, isPlay, type
end

function TimingSoundMgr:init()
  self.audioNodeList = {}
  self.timingSoundKey = TimingSoundConfig:getKeyList()
end

function TimingSoundMgr:audioNodeAddControl(node)
  local id = node:getInstanceID()
  local name = node.name
  if not self.audioNodeList[name] then
    if self.timingSoundKey[name] then
      self.audioNodeList[name] = {}
    else
      return
    end
  end
  self.audioNodeList[name][id] = node
end

function TimingSoundMgr:updateTime(day, hour, min)
  for key, v in pairs(self.audioNodeList) do
    if v and next(v) then
      local info = TimingSoundConfig:getControlInfoByKeyAndDay(key, day)
      local needOperateSound, isPlay, type = inspectionTime(info, hour, min)
      if needOperateSound then
        for id, node in pairs(v or {}) do
          if not node or not node:isValid() then
            self.audioNodeList[key][id] = nil
          else
            self:operateSound(node, isPlay, type)
          end
        end
      end
    end
  end
end

function TimingSoundMgr:operateSound(node, isPlay, type)
  local info = TimingSoundConfig:getCfgById(node.name)
  if info then
    if not node.initLoopState then
      node.initLoopState = node:getProperty("loopState")
    end
    if info.sound then
      node:setProperty("audioFilePath", info.sound)
    end
    local loop
    if info.loop then
      loop = info.loop == 1 and "true" or "false"
      if isPlay and type == Define.TIMING_TYPE.TRIGGER then
        node:setProperty("loopState", loop)
      end
    end
    if not next(info.range) then
      node:setProperty("losslessDistance", info.range[1] or soundDistance[1])
      node:setProperty("maxDistance", info.range[2] or soundDistance[2])
    end
    if type == Define.TIMING_TYPE.SECTION then
      if isPlay then
        node:setProperty("loopState", "true")
      else
        node:setProperty("loopState", loop or node.initLoopState)
      end
    end
    if isPlay then
      node:playAudio()
    else
      node:stopAudio()
    end
  end
end

TimingSoundMgr:init()
return TimingSoundMgr
