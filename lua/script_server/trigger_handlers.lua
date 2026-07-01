local setting = require("common.setting")
local Handlers = T(Trigger, "Handlers")
local oldTime = 0
local weekTime = 0

function Handlers.ENTER_MAP(context)
  local map = context.map
  local obj = context.obj1
  if map.cfg.mapBuff then
    obj:data("main").mapBuff = obj:addBuff(map.cfg.mapBuff)
  end
end

function Handlers.LEAVE_MAP(context)
  local map = context.map
  local obj = context.obj1
  if obj:data("main").mapBuff then
    obj:removeBuff(obj:data("main").mapBuff)
  end
end

function Handlers.ENTITY_DAMAGE(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  local from = context.obj2
  if not from or not from:isValid() then
    return
  end
end

function Handlers.ENTITY_DIE(context)
  local target = context.obj1
  local from = context.obj2
end

function Handlers.ENTITY_HP_NOTIFY(context)
  local entity = context.obj1
  if not entity.isPlayer then
    return
  end
end

local minutesInterval = 1

function Handlers.GAME_UPDATE()
  local curTime = os.time()
  if oldTime == 0 then
    oldTime = curTime
    return
  end
  if weekTime == 0 then
    weekTime = curTime
    return
  end
  local isDateChanged = Lib.confirmDateChanged(oldTime, curTime, World.cfg.offsetTime)
  if isDateChanged then
    if not Lib.isSameWeek(weekTime, curTime) then
      weekTime = curTime
      Game.resetRank()
    end
    oldTime = curTime
    Game.OnDateChanged()
  end
  minutesInterval = minutesInterval + 1
  if minutesInterval == 60 then
    Game.UpdatesPlayerOnlineTime()
    minutesInterval = 1
  end
  Game.verifyPlayerGiftDue()
end

function Handlers.REMOVE_ITEM(data)
end

function Handlers.SKILL_CAST(context)
  local from = context.obj1
  local target = context.obj2
  local skillInfo = from.curSkillBaseInfo
  local cfg = setting:fetch("skill", context.fullName)
  if skillInfo and skillInfo.setting_full_name == context.fullName and skillInfo.isEffectTriiger ~= 1 and cfg and cfg.isMainSkill then
    SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.skillCast, from, target)
    SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.skillCast, from, target, skillInfo.skill_effect)
  end
  if skillInfo and skillInfo.setting_full_name == context.fullName and cfg and cfg.isMainSkill and skillInfo.isAccuracy then
    if skillInfo.count == 1 then
      SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.beAccuracy, from, target)
      SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.beAccuracy, from, target, skillInfo.skill_effect)
    else
      for i, objID in pairs(skillInfo.attackTargetId or {}) do
        if objID then
          local pTarget = World.CurWorld:getEntity(objID)
          if pTarget and pTarget:isValid() then
            SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.beAccuracy, from, pTarget)
            SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.beAccuracy, from, pTarget, skillInfo.skill_effect)
          end
        end
      end
    end
  end
end

function Handlers.PLAYER_BE_SEND_MESSAGE(context)
  local player = context.obj1
  local content = context.content
  if content and content.key == "GYMPVP" and player and player:isValid() then
    player:listenPVPGYMMessage(content.rankType, content.rankIndex, content.gym_id, content.gym_type, content.rank, content.playerId, content.name, content.challengeId, content.challengeName)
  end
end
